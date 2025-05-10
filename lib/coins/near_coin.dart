// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import '../extensions/big_int_ext.dart';
import '../model/near_trx_obj.dart' as near_trx_obj;
import '../service/mint_service.dart';
import '../service/wallet_service.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:http/http.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
// ignore: implementation_imports, unused_import
import 'package:near_api_flutter/src/models/actions/dapp_function.dart'
    as near_borsh_dapp;

const nearDecimals = 24;

class NearDappTxResponse {
  final Uint8List signature;
  const NearDappTxResponse({required this.signature});
}

class _NearTokenMetaData {
  String name;
  String symbol;
  int decimals;
  String spec;
  String icon;

  _NearTokenMetaData({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.spec,
    required this.icon,
  });
}

class NearCoin extends Coin {
  String api;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String suffix;
  String geckoID;
  String? mintContractID;
  String rampID;
  String payScheme;

  NearCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.suffix,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    this.mintContractID,
  });

  factory NearCoin.fromJson(Map<String, dynamic> json) {
    return NearCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      suffix: json['suffix'],
      mintContractID: json['mintContractID'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['suffix'] = suffix;
    data['mintContractID'] = mintContractID;
    data['geckoID'] = geckoID;

    return data;
  }

  @override
  Future<String> resolveAddress(String address) async {
    return address;
  }

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'nearDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final results =
        await _NearDerive.fromPrivateKey(privateKey: HEX.decode(privateKey));

    final keys = results.toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey = 'nearDetails${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = NearDeriveArgs(
      seedRoot: seedPhraseRoot,
    );

    final keys = await compute(calculateNearKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  Future<Uint8List> signMessage(Uint8List message) async {
    final account = await getAccount();
    return ed.sign(account.keyPair.privateKey, message);
  }

  Future<_NearTokenMetaData?> getMetaData(String contractID) async {
    final account = await getAccount();

    String method = 'ft_metadata';
    String args = json.encode({});
    Contract contract = Contract(contractID, account);

    var result = await contract.callViewFuntion(method, args);

    if (result['result'] == null) return null;

    List<int> blRst = List<int>.from(result['result']['result']);

    final decoded = json.decode(ascii.decode(blRst));

    return _NearTokenMetaData(
      name: decoded['name'],
      symbol: decoded['symbol'],
      decimals: decoded['decimals'],
      spec: decoded['spec'],
      icon: decoded['icon'],
    );
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'nearAddressBalance$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final request = await post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            "jsonrpc": "2.0",
            "id": "dontcare",
            "method": "query",
            "params": {
              "request_type": "view_account",
              "finality": "final",
              "account_id": address
            },
          },
        ),
      );

      if (request.statusCode ~/ 100 == 4 || request.statusCode ~/ 100 == 5) {
        throw Exception('Request failed');
      }
      Map decodedData = jsonDecode(request.body);

      final BigInt balance = BigInt.parse(decodedData['result']['amount']);
      final base = BigInt.from(10);

      final nearBal = balance / base.pow(decimals());
      await pref.put(key, nearBal);

      return nearBal;
    } catch (e) {
      return savedBalance;
    }
  }

  near_borsh_dapp.Action _mapAction(near_trx_obj.Action action,
      [near_trx_obj.NearDappTrx? tx]) {
    if (action is near_trx_obj.Transfer) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.Transfer(
          deposit: Utils.decodeNearDeposit(action.deposit),
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.FunctionCall) {
      // final BigInt defaultGas = BigInt.from(30000000000000);
      // BigInt? gas = action.gas ?? defaultGas;
      BigInt? gas = action.gas;
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.FunctionCall(
          methodName: action.methodName,
          args: action.args,
          gas: gas,
          deposit: Utils.decodeNearDeposit(action.deposit),
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.DeployContract) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.DeployContract(
          code: action.code,
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.CreateAccount) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.CreateAccount(),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.Stake) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.Stake(
          publicKey: near_borsh_dapp.PublicKey(
            data: action.publicKey,
            keyType: 0,
          ),
          stake: Utils.decodeNearDeposit(action.stake),
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.AddKey) {
      final permission = near_borsh_dapp.AccessKeyPermission(
        enumValue: action.value,
        permission: _mapPermission(action.accessKey.permission),
      );
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.AddKey(
          publicKey: near_borsh_dapp.PublicKey(
            data: action.publicKey,
            keyType: 0,
          ),
          accessKey: near_borsh_dapp.AccessKey(
            nonce: BigInt.from(tx!.nonce),
            permission: permission,
          ),
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.DeleteKey) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.DeleteKey(
          publicKey: near_borsh_dapp.PublicKey(
            data: action.publicKey,
            keyType: 0,
          ),
        ),
        enumValue: action.value,
      );
    } else if (action is near_trx_obj.DeleteAccount) {
      return near_borsh_dapp.Action(
        actionType: near_borsh_dapp.DeleteAccount(
          beneficiaryId: action.beneficiaryId,
        ),
        enumValue: action.value,
      );
    }
    throw Exception('Unknown action type: ${action.runtimeType}');
  }

  near_borsh_dapp.Assignable _mapPermission(dynamic permission) {
    if (permission is near_trx_obj.FunctionCallPermission) {
      return near_borsh_dapp.FunctionCallPermission(
        allowance: permission.allowance,
        receiverId: permission.receiverId,
        methodNames: permission.methodNames,
      );
    }
    throw Exception('Unknown permission type: ${permission.runtimeType}');
  }

  Future<NearDappTxResponse> signDappTrx(near_trx_obj.NearDappTrx tx) async {
    final account = await getAccount();

    if (tx.encoded != null) {
      Uint8List signature = _signTransaction(
        account.keyPair.privateKey,
        tx.encoded!,
      );

      return NearDappTxResponse(
        signature: signature,
      );
    }

    final nearBorsh = near_borsh_dapp.Transaction(
      actions: tx.actions.map((action) => _mapAction(action, tx)).toList(),
      blockHash: tx.blockHash.data,
      receiverId: tx.receiverId,
      signerId: tx.signerId,
      nonce: BigInt.from(tx.nonce),
      publicKey: near_borsh_dapp.PublicKey(
        data: tx.publicKey.data,
        keyType: 0,
      ),
    );

    Uint8List signature = _signTransaction(
      account.keyPair.privateKey,
      nearBorsh.toBorsh(),
    );

    return NearDappTxResponse(
      signature: signature,
    );
  }

  Uint8List _signTransaction(
      PrivateKey privateKey, Uint8List serializedTransaction) {
    Uint8List hashedSerializedTx =
        TransactionManager.toSHA256(serializedTransaction);
    return TransactionManager.signTransaction(privateKey, hashedSerializedTx);
  }

  Future<bool> mintToken() async {
    try {
      final account = await getAccount();
      String method = 'ft_mint';
      BigInt mintAmt = MintService.getMint();
      String args = json.encode(
        {
          "account": account.accountId,
          "amount": mintAmt.toString(),
        },
      );

      Contract contract = Contract(mintContractID!, account);

      Map result = await contract.callFunction(
        method,
        args,
      );

      final entry = result['result'];

      if (entry == null) {
        return false;
      }

      if (entry['final_execution_status'] == 'EXECUTED_OPTIMISTIC') {
        await MintService.deleteMint();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Account> getAccount() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final getNearDetails = await importData(data);
    final privateKeyPublic = [
      ...HEX.decode(getNearDetails.privateKey!),
      ...HEX.decode(getNearDetails.address)
    ];
    final publicKey = PublicKey(
      HEX.decode(
        getNearDetails.address,
      ),
    );
    return Account(
      accountId: getNearDetails.address,
      keyPair: KeyPair(
        PrivateKey(privateKeyPublic),
        publicKey,
      ),
      provider: NearRpcProvider(api),
    );
  }

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final account = await getAccount();
    final amountBig = amount.toBigIntDec(nearDecimals);

    final trans = await account.sendTokens(
      amountBig,
      to,
    );

    String transactionHash = trans['result']['transaction']['hash'];

    return transactionHash.replaceAll('\n', '');
  }

  @override
  validateAddress(String address) {
    if (address.endsWith(suffix)) {
      return;
    }
    final bytes = HEX.decode(address);
    const exceptedLength = 64;
    const exceptedBytesLength = 32;
    if (address.length != exceptedLength) {
      throw Exception("Near address must have a length of 64");
    }
    if (bytes.length != exceptedBytesLength) {
      throw Exception("Near address must have a decoded byte length of 32");
    }
  }

  @override
  int decimals() {
    return nearDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/txns/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<NearCoin> getNearBlockChains() {
  List<NearCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      NearCoin(
        name: 'NEAR(Testnet)',
        symbol: 'NEAR',
        default_: 'NEAR',
        blockExplorer:
            'https://testnet.nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/near.png',
        api: 'https://rpc.testnet.near.org',
        suffix: '.testnet',
        mintContractID: 'primewallet.testnet',
        geckoID: "near",
        payScheme: "near",
        rampID: "NEAR_NEAR",
      ),
    );
  } else {
    blockChains.addAll([
      NearCoin(
        name: 'NEAR',
        symbol: 'NEAR',
        default_: 'NEAR',
        blockExplorer: 'https://nearblocks.io/txns/$blockExplorerPlaceholder',
        image: 'assets/near.png',
        api: 'https://rpc.mainnet.near.org',
        suffix: '.near',
        mintContractID: '',
        geckoID: "near",
        payScheme: "near",
        rampID: "NEAR_NEAR",
      )
    ]);
  }
  return blockChains;
}

class NearRpcProvider extends RPCProvider {
  final String endpoint;

  NearRpcProvider(this.endpoint) : super(endpoint);
}

class NearDeriveArgs {
  final SeedPhraseRoot seedRoot;

  const NearDeriveArgs({
    required this.seedRoot,
  });
}

class _NearDerive {
  static Future<AccountData> fromPrivateKey(
      {required List<int> privateKey}) async {
    final publicKey = await ED25519_HD_KEY.getPublicKey(privateKey);

    final address = HEX.encode(publicKey).substring(2);
    return AccountData(
      address: address,
      privateKey: HEX.encode(privateKey),
    );
  }
}

Future calculateNearKey(NearDeriveArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  KeyData masterKey =
      await ED25519_HD_KEY.derivePath("m/44'/397'/0'", seedRoot_.seed);

  final detail = await _NearDerive.fromPrivateKey(privateKey: masterKey.key);

  return {
    'privateKey': detail.privateKey,
    'address': detail.address,
  };
}
