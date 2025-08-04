// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:aptos/aptos.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:alan/wallet/export.dart';
import 'package:alan/x/export.dart';
import 'package:bech32/bech32.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:alan/alan.dart' as cosmos;
import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:sui/utils/sha.dart';
import 'package:web3dart/crypto.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

class CosmosCoin extends Coin {
  String bech32Hrp;
  String lcdUrl;
  String grpcUrl;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String path;
  String denom;
  int coinDecimals;
  String chainId;
  int grpcPort;
  String pubKeyTypeUrl;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  bool requireMemo() => true;

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

  CosmosCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.bech32Hrp,
    required this.lcdUrl,
    required this.path,
    required this.coinDecimals,
    required this.denom,
    required this.grpcUrl,
    required this.chainId,
    required this.grpcPort,
    required this.pubKeyTypeUrl,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory CosmosCoin.fromJson(Map<String, dynamic> json) {
    return CosmosCoin(
      lcdUrl: json['lcdUrl'],
      bech32Hrp: json['bech32Hrp'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      path: json['path'],
      coinDecimals: json['coinDecimals'],
      denom: json['denom'],
      grpcUrl: json['grpcUrl'],
      chainId: json['chainId'],
      grpcPort: json['grpcPort'],
      pubKeyTypeUrl: json['pubKeyTypeUrl'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lcdUrl'] = lcdUrl;
    data['bech32Hrp'] = bech32Hrp;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['path'] = path;
    data['coinDecimals'] = coinDecimals;
    data['image'] = image;
    data['denom'] = denom;
    data['grpcUrl'] = grpcUrl;
    data['chainId'] = chainId;
    data['grpcPort'] = grpcPort;
    data['pubKeyTypeUrl'] = pubKeyTypeUrl;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transactions/', '/account/')
        .replaceFirst('/transaction/', '/account/')
        .replaceFirst('/tx/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  AccountData cosmosPrivateKeyToAddress(
    String privateKey,
    NetworkInfo networkInfo,
  ) {
    final wallet = cosmos.Wallet.import(
      networkInfo,
      Uint8List.fromList(
        HEX.decode(privateKey),
      ),
    );

    return AccountData(
      address: wallet.bech32Address,
      privateKey: HEX.encode(wallet.privateKey),
      publicKey: HEX.encode(wallet.publicKey),
      hex_address: HEX.encode(wallet.address),
    );
  }

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'cosmosDetailsPrivate${walletImportType.name}$bech32Hrp';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final keys = cosmosPrivateKeyToAddress(
      privateKey,
      getNetworkInfo(),
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'cosmosDetails$bech32Hrp${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }
    final networkInfo = getNetworkInfo();

    final args = CosmosDeriveArgs(
      mnemonic: mnemonic,
      networkInfo: networkInfo,
      path: path,
    );

    final keys = await compute(calculateCosmosKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final response = await get(
      Uri.parse(
        '$lcdUrl/cosmos/bank/v1beta1/balances/$address',
      ),
    );

    final responseBody = response.body;

    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }

    List balances = jsonDecode(responseBody)['balances'];

    if (balances.isEmpty) {
      return 0;
    }

    final String balance = balances
        .where((element) => element['denom'] == denom)
        .toList()[0]['amount'];

    final base = BigInt.from(10);

    return BigInt.parse(balance) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'cosmosAddressBalance$address$lcdUrl';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;
    try {
      double cosmosBal = await getUserBalance(address: address);
      await pref.put(key, cosmosBal);

      return cosmosBal;
    } catch (e) {
      return savedBalance;
    }
  }

  Map<String, dynamic> makeADR36AminoSignDoc(String signer, dynamic data) {
    String base64Data =
        data is String ? base64Encode(utf8.encode(data)) : base64Encode(data);

    return {
      'chain_id': '',
      'account_number': '0',
      'sequence': '0',
      'fee': {
        'gas': '0',
        'amount': [],
      },
      'msgs': [
        {
          'type': 'sign/MsgSignData',
          'value': {
            'signer': signer,
            'data': base64Data,
          },
        },
      ],
      'memo': '',
    };
  }

  String sortedJsonByKeyStringify(Map<String, dynamic> obj) {
    return jsonEncode(sortObjectByKey(obj));
  }

  dynamic sortObjectByKey(dynamic obj) {
    if (!(obj is Map || obj is List) || obj == null) {
      return obj;
    }

    if (obj is List) {
      return obj.map(sortObjectByKey).toList();
    }

    var sortedKeys = obj.keys.toList()..sort();

    var result = <String, dynamic>{};
    sortedKeys.forEach((key) {
      result[key] = sortObjectByKey(obj[key]);
    });
    return result;
  }

  Uint8List serializeSignDoc(Map<String, dynamic> signDoc) {
    String jsonString = sortedJsonByKeyStringify(signDoc);

    final result = utf8.encode(escapeHTML(jsonString));

    return Uint8List.fromList(result);
  }

  String escapeHTML(String str) {
    return str
        .replaceAll('<', '\u003c')
        .replaceAll('>', '\u003e')
        .replaceAll('&', '\u0026');
  }

  Future<String?> sendTrxDapp(List<int> buffer, String mode) async {
    final networkInfo = getNetworkInfo();
    final txSender = cosmos.TxSender.fromNetworkInfo(networkInfo);
    cosmos.Tx tx = cosmos.Tx.fromBuffer(buffer);

    final response = await txSender.broadcastTx(tx);

    return response.txhash;
  }

  String get msgSend => '/cosmos.bank.v1beta1.MsgSend';

  List<CosmosTrxDetails> decodeBodyBytesDapp({required String bodyBytes}) {
    final txBody = cosmos.TxBody.fromBuffer(HEX.decode(strip0x(bodyBytes)));
    final messages = txBody.messages;

    List<CosmosTrxDetails> detailsList = [];

    for (var message in messages) {
      CosmosTrxDetails details = CosmosTrxDetails(
        memo: txBody.memo,
        amount: [],
        fromAddress: '',
        toAddress: '',
      );

      final field = message.getField(message.getTagNumber('typeUrl')!);
      final value = message.getField(message.getTagNumber('value')!);

      if (field == msgSend) {
        final bankInfo = bank.MsgSend.fromBuffer(value);
        details.amount = bankInfo.amount;
        details.fromAddress = bankInfo.fromAddress;
        details.toAddress = bankInfo.toAddress;
        detailsList.add(details);
      }
    }

    return detailsList;
  }

  String parseAmount(String denomSent, String amount) {
    if (denomSent == denom) {
      return '${double.parse(amount) / pow(10, decimals())} $symbol';
    }
    return '$amount $denomSent';
  }

  Future<List<Map>> signTranxDapp({
    required String authInfoBytes,
    required String bodyBytes,
  }) async {
    final networkInfo = getNetworkInfo();
    cosmos.Wallet wallet = await getWallet();
    final account = await AuthQuerier.build(networkInfo.gRPCChannel)
        .getAccountData(wallet.bech32Address);

    final sigRaw = cosmos.SignDoc(
      authInfoBytes: HEX.decode(strip0x(authInfoBytes)),
      bodyBytes: HEX.decode(strip0x(bodyBytes)),
      accountNumber: account?.accountNumber,
      chainId: chainId,
    );

    final bytesToSign = sigRaw.writeToBuffer();
    final isEthSecp256C = cosmos.Wallet.isEthSecp256(path);
    final sigBytes =
        wallet.sign(Uint8List.fromList(bytesToSign), isEthSecp256C);

    return [
      {
        'signDoc': {
          'bodyBytes': bodyBytes,
          'authInfoBytes': authInfoBytes,
          'chainId': chainId,
          'accountNumber': account?.accountNumber.toString(),
        },
        ...encodeSecp256k1Signature(wallet.publicKey, sigBytes),
      }
    ];
  }

  Map encodeSecp256k1Pubkey(Uint8List pubkey) {
    if (pubkey.length != 33 || (pubkey[0] != 0x02 && pubkey[0] != 0x03)) {
      throw Exception(
        "Public key must be compressed secp256k1, i.e. 33 bytes starting with 0x02 or 0x03",
      );
    }
    return {
      'type': "tendermint/PubKeySecp256k1",
      'value': base64.encode(pubkey),
    };
  }

  Map encodeSecp256k1Signature(Uint8List pubkey, Uint8List signature) {
    if (signature.length != 64) {
      throw Exception(
          "Signature must be 64 bytes long. Cosmos SDK uses a 2x32 byte fixed length encoding for the secp256k1 signature integers r and s.");
    }

    return {
      'pub_key': encodeSecp256k1Pubkey(pubkey),
      'signature': base64.encode(signature),
    };
  }

  Future<List> signAminoDapp(
    Map<String, dynamic> signDoc,
    String signer,
  ) async {
    cosmos.Wallet wallet = await getWallet();

    if (signer != wallet.bech32Address) {
      throw Exception("Unmatched signer");
    }

    final msg = serializeSignDoc(signDoc);

    final isEthSecp256C = cosmos.Wallet.isEthSecp256(path);

    final hash = isEthSecp256C ? keccak256(msg) : sha256(msg);

    final signatureEC = sign(hash, wallet.privateKey);

    return [
      {
        'signed': signDoc,
        ...encodeSecp256k1Signature(
          wallet.publicKey,
          Uint8List.fromList([
            ...signatureEC.r.toUint8List(),
            ...signatureEC.s.toUint8List(),
          ]),
        )
      }
    ];
  }

  Future<List> signMessageDapp(String message) async {
    cosmos.Wallet wallet = await getWallet();
    String decoded = message;
    if (isHexString(message)) {
      try {
        decoded = ascii.decode(txDataToUintList(message));
      } catch (_) {}
    }
    final signDoc = makeADR36AminoSignDoc(
      wallet.bech32Address,
      decoded,
    );

    final msg = serializeSignDoc(signDoc);

    final isEthSecp256C = cosmos.Wallet.isEthSecp256(path);

    final hash = isEthSecp256C ? keccak256(msg) : sha256(msg);

    final signatureEC = sign(hash, wallet.privateKey);

    return [
      {
        'signDoc': signDoc,
        ...encodeSecp256k1Signature(
          wallet.publicKey,
          Uint8List.fromList([
            ...signatureEC.r.toUint8List(),
            ...signatureEC.s.toUint8List(),
          ]),
        )
      }
    ];
  }

  Future<cosmos.Wallet> getWallet() async {
    final networkInfo = getNetworkInfo();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    return cosmos.Wallet.fromJson(
      {
        'hex_address': details.hex_address,
        'public_key': details.publicKey,
        'network_info': networkInfo.toJson(),
      },
      Uint8List.fromList(
        HEX.decode(details.privateKey!),
      ),
    );
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final networkInfo = getNetworkInfo();
    final uatomToSend = amount.toBigIntDec(decimals());

    final feeD = await getTransactionFee(amount, to) * pow(10, decimals());

    cosmos.Wallet wallet = await getWallet();

    final message = bank.MsgSend.create()
      ..fromAddress = wallet.bech32Address
      ..toAddress = to;

    final coin = cosmos.Coin.create()
      ..denom = denom
      ..amount = '$uatomToSend';
    message.amount.add(coin);

    final signer = cosmos.TxSigner.fromNetworkInfo(networkInfo);

    final fee = cosmos.Fee();
    fee.gasLimit = 200000.toInt64();
    final feeCoin = cosmos.Coin.create()
      ..denom = denom
      ..amount = BigInt.from(feeD).toString();
    fee.amount.add(feeCoin);

    final tx = await signer.createAndSign(
      wallet,
      [message],
      memo: memo,
      fee: fee,
      isEthSecp256: cosmos.Wallet.isEthSecp256(path),
      pubKeyTypeUrl: pubKeyTypeUrl,
    );

    final txSender = cosmos.TxSender.fromNetworkInfo(networkInfo);
    final response = await txSender.broadcastTx(tx);

    if (response.isSuccessful) {
      return response.txhash;
    }
    if (kDebugMode) {
      print(response.toString());
    }

    return null;
  }

  @override
  validateAddress(String address) {
    Bech32 sel = bech32.decode(address);
    if (sel.hrp != bech32Hrp) {
      throw Exception('not a valid $default_ address');
    }
  }

  @override
  int decimals() {
    return coinDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.001;
  }

  cosmos.NetworkInfo getNetworkInfo() {
    return cosmos.NetworkInfo(
      bech32Hrp: bech32Hrp,
      lcdInfo: cosmos.LCDInfo(host: lcdUrl),
      grpcInfo: cosmos.GRPCInfo(
        host: grpcUrl,
        credentials: channelOptionsFromJson(secure(grpcPort)),
        port: grpcPort,
      ),
    );
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

String secure(int grpcPort) {
  return grpcPort == 443 ? 'secure' : 'insecure';
}

class CosmosTrxDetails {
  String memo;
  List<cosmos.Coin> amount;
  String fromAddress;
  String toAddress;

  CosmosTrxDetails({
    required this.memo,
    required this.amount,
    required this.fromAddress,
    required this.toAddress,
  });
}

// https://docs.injective.network/nodes/interact-node/
List<CosmosCoin> getCosmosBlockChains() {
  List<CosmosCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll([
      CosmosCoin(
        blockExplorer:
            'https://explorer.polypore.xyz/theta-testnet-001/tx/$blockExplorerPlaceholder',
        symbol: 'ATOM',
        name: 'Cosmos(Test)',
        default_: 'ATOM',
        image: 'assets/cosmos.png',
        bech32Hrp: 'cosmos',
        lcdUrl: 'https://rest.sentry-01.theta-testnet.polypore.xyz',
        grpcUrl: 'rest.sentry-01.theta-testnet.polypore.xyz',
        path: "m/44'/118'/0'/0/0",
        coinDecimals: 6,
        chainId: "theta-testnet-001",
        denom: 'uatom',
        grpcPort: 9090,
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        geckoID: 'cosmos',
        payScheme: 'cosmos',
        rampID: 'COSMOS_ATOM',
      ),
      CosmosCoin(
        blockExplorer:
            'https://explorer.burnt.com/xion-testnet-1/$blockExplorerPlaceholder',
        symbol: 'XION',
        name: 'XION(Test)',
        default_: 'XION',
        image: 'assets/xion.png',
        bech32Hrp: 'xion',
        lcdUrl: 'https://rpc.xion-testnet-1.burnt.com',
        grpcUrl: 'https://grpc.xion-testnet-1.burnt.com',
        path: "m/44'/118'/0'/0/0",
        coinDecimals: 6,
        chainId: "xion-testnet-1",
        denom: 'uxion',
        grpcPort: 9090,
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        geckoID: 'xion-2',
        payScheme: 'xion',
        rampID: '',
      ),
      CosmosCoin(
        blockExplorer:
            'https://www.mintscan.io/osmosis-testnet/tx/$blockExplorerPlaceholder',
        symbol: 'OSMO',
        name: 'Osmosis(Test)',
        default_: 'OSMO',
        image: 'assets/osmosis.png',
        bech32Hrp: 'osmo',
        lcdUrl: 'https://lcd.osmotest5.osmosis.zone',
        grpcUrl: 'grpc.osmotest5.osmosis.zone',
        path: "m/44'/118'/0'/0/0",
        coinDecimals: 6,
        chainId: "osmo-test-5",
        denom: 'uosmo',
        grpcPort: 9090,
        geckoID: 'osmosis',
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        payScheme: 'osmosis',
        rampID: '',
      ),
      CosmosCoin(
        blockExplorer:
            'https://cronos-pos.org/explorer/croeseid4/tx/$blockExplorerPlaceholder',
        symbol: 'CRO',
        name: 'Crypto.org(Test)',
        default_: 'CRO',
        image: 'assets/cryptoorg.webp',
        bech32Hrp: 'tcro',
        lcdUrl: 'https://rest.testnet-croeseid-4.cronos-pos.org',
        grpcUrl: 'grpc-testnet-croeseid-4.crypto.org',
        // grpcUrl: 'grpc.testnet-croeseid-4.cronos-pos.org',  -> new url when old one is migrated
        path: "m/44'/394'/0'/0/0",
        coinDecimals: 8,
        chainId: "testnet-croeseid-4",
        denom: 'basetcro',
        grpcPort: 9090,
        geckoID: "crypto-com-chain",
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        payScheme: 'cryptoorg',
        rampID: '',
      ),
      CosmosCoin(
        blockExplorer:
            'https://testnet.explorer.injective.network/transaction/$blockExplorerPlaceholder',
        symbol: 'INJ',
        name: 'Native Injective(Test)',
        default_: 'INJ',
        image: 'assets/injective.png',
        bech32Hrp: "inj",
        lcdUrl: 'https://testnet.sentry.lcd.injective.network',
        grpcUrl: 'testnet.sentry.chain.grpc.injective.network',
        path: "m/44'/60'/0'/0/0",
        coinDecimals: 18,
        chainId: "injective-888",
        denom: 'inj',
        grpcPort: 443,
        pubKeyTypeUrl: '/injective.crypto.v1beta1.ethsecp256k1.PubKey',
        geckoID: 'injective-protocol',
        payScheme: 'nativeinjective',
        rampID: '',
      ),
      CosmosCoin(
        name: 'Native Evmos (Test)',
        symbol: 'EVMOS',
        default_: 'EVMOS',
        image: 'assets/evmos.png',
        bech32Hrp: 'evmos',
        blockExplorer:
            'https://www.mintscan.io/evmos-testnet/tx/$blockExplorerPlaceholder',
        lcdUrl: 'https://rest.evmos-testnet.lava.build',
        grpcUrl: 'grpc.evmos-testnet.lava.build',
        path: "m/44'/60'/0'/0/0",
        coinDecimals: 18,
        chainId: "evmos_9000-4",
        denom: 'atevmos',
        grpcPort: 443,
        pubKeyTypeUrl: '/ethermint.crypto.v1.ethsecp256k1.PubKey',
        geckoID: 'evmos',
        payScheme: 'evmos',
        rampID: '',
      ),
    ]);
  } else {
    blockChains.addAll([
      // CosmosCoin(
      //   blockExplorer:
      //       'https://www.mintscan.io/cosmos/tx/$blockExplorerPlaceholder',
      //   symbol: 'ATOM',
      //   name: 'Cosmos',
      //   default_: 'ATOM',
      //   image: 'assets/cosmos.png',
      //   bech32Hrp: 'cosmos',
      //   lcdUrl: 'https://stargate.cosmos.network',
      //   grpcUrl: 'https://stargate.cosmos.network',
      //   path: "m/44'/118'/0'/0/0",
      //   coinDecimals: 6,
      //   chainId: "cosmoshub-4",
      //   denom: 'uatom',
      //   geckoID: 'cosmos',
      //   payScheme: 'cosmos',
      //   rampID: 'COSMOS_ATOM',
      //   pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
      //   grpcPort: 9090,
      // ),
      CosmosCoin(
        blockExplorer:
            'https://www.mintscan.io/osmosis/tx/$blockExplorerPlaceholder',
        symbol: 'OSMO',
        name: 'Osmosis',
        default_: 'OSMO',
        image: 'assets/osmosis.png',
        bech32Hrp: 'osmo',
        lcdUrl: 'https://lcd.osmosis.zone',
        grpcUrl: 'grpc.osmosis.zone',
        path: "m/44'/118'/0'/0/0",
        coinDecimals: 6,
        chainId: "osmosis-1",
        denom: 'uosmo',
        grpcPort: 9090,
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        geckoID: 'osmosis',
        payScheme: 'osmosis',
        rampID: '',
      ),
      CosmosCoin(
        blockExplorer:
            'https://cronos-pos.org/explorer/tx/$blockExplorerPlaceholder',
        symbol: 'CRO',
        name: 'Crypto.org',
        default_: 'CRO',
        image: 'assets/cryptoorg.webp',
        bech32Hrp: 'cro',
        lcdUrl: "https://rest.mainnet.cronos-pos.org",
        grpcUrl: "grpc-mainnet.crypto.org",
        // grpcUrl: "grpc.mainnet.cronos-pos.org", -> new url when old one is migrated
        path: "m/44'/394'/0'/0/0",
        chainId: "crypto-org-chain-mainnet-1",
        coinDecimals: 8,
        denom: 'basecro',
        grpcPort: 9090,
        pubKeyTypeUrl: '/cosmos.crypto.secp256k1.PubKey',
        geckoID: "crypto-com-chain",
        payScheme: 'cryptoorg',
        rampID: '',
      ),
      CosmosCoin(
        blockExplorer:
            'https://explorer.injective.network/transaction/$blockExplorerPlaceholder',
        symbol: 'INJ',
        name: 'Native Injective',
        default_: 'INJ',
        image: 'assets/injective.png',
        bech32Hrp: "inj",
        lcdUrl: 'https://sentry.lcd.injective.network',
        grpcUrl: 'sentry.chain.grpc.injective.network',
        path: "m/44'/60'/0'/0/0",
        coinDecimals: 18,
        chainId: "injective-1",
        denom: 'inj',
        grpcPort: 443,
        pubKeyTypeUrl: '/injective.crypto.v1beta1.ethsecp256k1.PubKey',
        geckoID: 'injective-protocol',
        payScheme: 'nativeinjective',
        rampID: '',
      ),
      CosmosCoin(
        name: 'Native Evmos',
        symbol: 'EVMOS',
        default_: 'EVMOS',
        image: 'assets/evmos.png',
        bech32Hrp: 'evmos',
        blockExplorer:
            'https://www.mintscan.io/evmos/tx/$blockExplorerPlaceholder',
        lcdUrl: 'https://rest.evmos.lava.build',
        grpcUrl: 'grpc.evmos.lava.build',
        path: "m/44'/60'/0'/0/0",
        coinDecimals: 18,
        chainId: "evmos_9001-2",
        denom: 'aevmos',
        grpcPort: 443,
        pubKeyTypeUrl: '/ethermint.crypto.v1.ethsecp256k1.PubKey',
        geckoID: 'evmos',
        payScheme: 'evmos',
        rampID: '',
      ),
    ]);
  }
  return blockChains;
}

class CosmosDeriveArgs {
  final NetworkInfo networkInfo;
  final String path;
  final String mnemonic;
  const CosmosDeriveArgs({
    required this.networkInfo,
    required this.path,
    required this.mnemonic,
  });
}

Map calculateCosmosKey(CosmosDeriveArgs config) {
  final wallet = cosmos.Wallet.derive(
    config.mnemonic.split(' '),
    config.networkInfo,
    derivationPath: config.path,
  );

  return {
    'address': wallet.bech32Address,
    'privateKey': HEX.encode(wallet.privateKey),
    'publicKey': HEX.encode(wallet.publicKey),
    'hex_address': HEX.encode(wallet.address),
  };
}


// pubKey does not match signer address inj12zd4wvdln9ksnq3czu6kn0fj3zu4ar2lh4aymv with signer index: 0: invalid pubkey
// solution: use correct typeurl /injective.crypto.v1beta1.ethsecp256k1.PubKey 