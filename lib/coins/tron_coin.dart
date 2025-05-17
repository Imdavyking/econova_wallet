// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/tron/tron.dart';
import '../service/wallet_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/crypto.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const TRX_FEE_LIMIT = 150000000;
const TRX_ADDRESS_PREFIX = '41';
const TRX_MESSAGE_HEADER = '\x19TRON Signed Message:\n32';

const tronDecimals = 6;

class TronCoin extends Coin {
  String api;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  bool get supportKeystore => true;
  @override
  bool requireMemo() => true;
  @override
  bool get supportPrivateKey => true;

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

  TronCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory TronCoin.fromJson(Map<String, dynamic> json) {
    return TronCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
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
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    data['image'] = image;

    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'tronDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final address = tronPrivateKeyToAddress(privateKey);

    final keys = AccountData(
      address: address,
      privateKey: privateKey,
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  String tronPrivateKeyToAddress(String privateKey) {
    final walletInfo = wallet.PrivateKey(BigInt.parse(privateKey, radix: 16));
    final publicKey = wallet.tron.createPublicKey(walletInfo);
    final address = wallet.tron.createAddress(publicKey);
    return address;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey = 'tronDetails${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = TronArgs(seedRoot: seedPhraseRoot);

    final keys = await compute(calculateTronKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  Future<String> get _canTransferKey async =>
      'tronAddressCanTransfer${await getAddress()}$api';

  @override
  Future<bool> get canTransfer async =>
      pref.get(await _canTransferKey, defaultValue: true);
  @override
  Future<double> getUserBalance({required String address}) async {
    final request = await get(
      Uri.parse('$api/v1/accounts/$address'),
      headers: {
        'TRON-PRO-API-KEY': tronGridApiKey,
        'Content-Type': 'application/json'
      },
    );

    if (request.statusCode ~/ 100 == 4 || request.statusCode ~/ 100 == 5) {
      throw Exception('Request failed');
    }

    Map<String, dynamic> decodedData = jsonDecode(request.body);
    final List? result = decodedData['data'];

    if (result == null || result.isEmpty) {
      await pref.put(await _canTransferKey, true);
      throw Exception('Account not found');
    }

    final data = result[0];

    final int? balance = data['balance'];
    if (balance == null) throw Exception('Account not found');

    final base = BigInt.from(10);
    final permission =
        AccountPermissionModel.fromJson(data['owner_permission']);
    await pref.put(
      await _canTransferKey,
      _canTransfer(permission, address),
    );
    return BigInt.from(balance) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'tronAddressBalance$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      double balTron = await getUserBalance(address: address);

      await pref.put(key, balTron);

      return balTron;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tronDetails = await importData(data);

    final ownerAddress = TronAddress(tronDetails.address);
    final rpc = TronProvider(TronHTTPProvider(url: api));
    final block = await rpc.request(TronRequestGetNowBlock());
    final toAddress = TronAddress(to);
    final contract = TransferContract(
      ownerAddress: ownerAddress,
      toAddress: toAddress,
      amount: TronHelper.toSun(amount),
    );
    const expSeconds = 60 * 6 * 60;

    final any = Any(typeUrl: contract.typeURL, value: contract);
    final transactionContract =
        TransactionContract(type: contract.contractType, parameter: any);

    final rawTr = TransactionRaw(
      refBlockBytes: block.blockHeader.rawData.refBlockBytes,
      refBlockHash: block.blockHeader.rawData.refBlockHash,
      expiration: block.blockHeader.rawData.timestamp + BigInt.from(expSeconds),
      contract: [transactionContract],
      timestamp: block.blockHeader.rawData.timestamp,
      feeLimit: BigInt.parse("10"),
      data: memo != null ? utf8.encode(memo) : null,
    );

    Uint8List privateKey =
        Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
    Uint8List txID = Uint8List.fromList(HEX.decode(rawTr.txID));
    final signatureEC = sign(txID, privateKey);
    final recid = signatureEC.v - 27;
    final signature = '${HEX.encode([
          ...signatureEC.r.toUint8List(),
          ...signatureEC.s.toUint8List(),
        ])}0$recid';

    final transaction =
        Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);

    final raw = BytesUtils.toHexString(transaction.toBuffer());

    final result = await rpc.request(TronRequestBroadcastHex(transaction: raw));

    if (result.isSuccess) {
      return result.txId;
    }

    debugPrint(result.toString());
    throw Exception('sending failed');
  }

  @override
  validateAddress(String address) {
    if (!wallet.isValidTronAddress(address)) {
      throw Exception('Invalid $default_ address');
    }
  }

  @override
  int decimals() {
    return tronDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transaction/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  bool _canTransfer(
    AccountPermissionModel permission,
    String address,
  ) {
    BigInt userWeight = BigInt.zero;
    for (PermissionKeysModel key in permission.keys) {
      if (key.address == address) {
        userWeight += key.weight;
        if (userWeight >= permission.threshold) {
          return true;
        }
      }
    }

    return userWeight >= permission.threshold;
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;
  @override
  String getRampID() => rampID;
}

List<TronCoin> getTronBlockchains() {
  List<TronCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.add(
      TronCoin(
        blockExplorer:
            'https://shasta.tronscan.org/#/transaction/$blockExplorerPlaceholder',
        symbol: 'TRX',
        default_: 'TRX',
        name: 'Tron(Testnet)',
        image: 'assets/tron.png',
        api: 'https://api.shasta.trongrid.io',
        geckoID: "tron",
        payScheme: "tron",
        rampID: '',
      ),
    );
  } else {
    blockChains.addAll([
      TronCoin(
        blockExplorer:
            'https://tronscan.org/#/transaction/$blockExplorerPlaceholder',
        symbol: 'TRX',
        name: 'Tron',
        default_: 'TRX',
        image: 'assets/tron.png',
        api: 'https://api.trongrid.io',
        geckoID: "tron",
        payScheme: "tron",
        rampID: '',
      ),
    ]);
  }

  return blockChains;
}

String tronAddressToHex(String address) {
  if (isHexString(address)) {
    return address.replaceFirst('0x', TRX_ADDRESS_PREFIX).toUpperCase();
  }
  return HEX.encode(bs58check.decode(address)).toUpperCase();
}

class TronArgs {
  final SeedPhraseRoot seedRoot;

  const TronArgs({
    required this.seedRoot,
  });
}

calculateTronKey(TronArgs config) {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final master = wallet.ExtendedPrivateKey.master(seedRoot_.seed, wallet.xprv);
  final root = master.forPath("m/44'/195'/0'/0/0");

  final privateKey = wallet.PrivateKey((root as wallet.ExtendedPrivateKey).key);
  final publicKey = wallet.tron.createPublicKey(privateKey);
  final address = wallet.tron.createAddress(publicKey);

  return {
    'privateKey': HEX.encode(privateKey.value.toUint8List()),
    'address': address,
  };
}

class TronHTTPProvider implements TronServiceProvider {
  TronHTTPProvider(
      {required this.url,
      http.Client? client,
      this.defaultRequestTimeout = const Duration(seconds: 30)})
      : client = client ?? http.Client();

  final String url;
  final http.Client client;
  final Duration defaultRequestTimeout;

  @override
  Future<TronServiceResponse<T>> doRequest<T>(TronRequestDetails params,
      {Duration? timeout}) async {
    if (params.type.isPostRequest) {
      final response = await client
          .post(params.toUri(url), headers: params.headers, body: params.body())
          .timeout(timeout ?? defaultRequestTimeout);
      return params.toResponse(response.bodyBytes, response.statusCode);
    }
    final response = await client
        .get(params.toUri(url), headers: params.headers)
        .timeout(timeout ?? defaultRequestTimeout);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
