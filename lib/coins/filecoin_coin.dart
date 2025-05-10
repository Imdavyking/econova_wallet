// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import '../utils/blake2bhash.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter/foundation.dart';
// ignore_for_file: constant_identifier_names

import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:leb128/leb128.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

import 'package:cbor/cbor.dart' as cbor;
import 'package:cryptowallet/utils/addressToBytes.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:web3dart/crypto.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';

const filecoinfaucet = 'https://faucet.calibration.fildev.network/';
const fileCoinDecimals = 18;

class FilecoinCoin extends Coin {
  String prefix;
  String baseUrl;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  FilecoinCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.baseUrl,
    required this.prefix,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });
  @override
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

  factory FilecoinCoin.fromJson(Map<String, dynamic> json) {
    return FilecoinCoin(
      prefix: json['prefix'],
      baseUrl: json['baseUrl'],
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
    data['prefix'] = prefix;
    data['baseUrl'] = baseUrl;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/message/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'fileCoinDetailsPrivate${walletImportType.name}$prefix';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final results = _FilecoinDerive.fromPrivateKey(
      privateKey: HEX.decode(privateKey),
      addressPrefix: prefix,
    );

    final keys = results.toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'fileCoinDetail$prefix${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = FilecoinDeriveArgs(
      seedRoot: seedPhraseRoot,
      addressPrefix: prefix,
    );

    final keys = await compute(calculateFileCoinKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'fileCoinAddressBalance$address$baseUrl';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "id": 1,
          "method": "Filecoin.WalletBalance",
          "params": [address]
        }),
      );
      final responseBody = response.body;
      if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
        throw Exception(responseBody);
      }

      final base = BigInt.from(10);

      String resBal = jsonDecode(responseBody)['result'];

      double fileCoinBal = BigInt.parse(resBal) / base.pow(decimals());

      await pref.put(key, fileCoinBal);

      return fileCoinBal;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  validateAddress(String address) {
    if (!validateFilecoinAddress(address)) {
      throw Exception('not a valid filecoin address');
    }
  }

  Future<int> getFileCoinNonce(
    String addressPrefix,
    String baseUrl,
  ) async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final fileCoinDetails = await importData(data);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "id": 1,
          "jsonrpc": "2.0",
          "method": "Filecoin.MpoolGetNonce",
          "params": [fileCoinDetails.address]
        }),
      );
      final responseBody = response.body;
      if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
        throw Exception(responseBody);
      }

      return jsonDecode(responseBody)['result'];
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> fileCoinEstimateGas(
    String baseUrl,
    Map msg,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "id": 1,
          "jsonrpc": "2.0",
          "method": "Filecoin.GasEstimateMessageGas",
          "params": [
            msg,
            {"MaxFee": "30000000000000"},
            []
          ]
        }),
      );
      final responseBody = response.body;

      if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
        throw Exception(responseBody);
      }

      Map<String, dynamic>? jsonDecodedBody =
          jsonDecode(responseBody)['result'];

      if (jsonDecodedBody == null) {
        throw Exception('no response for gas fee available');
      }

      return jsonDecodedBody;
    } catch (e) {
      return {
        "GasLimit": 0,
        "GasFeeCap": "0",
        "GasPremium": "0",
      };
    }
  }

  bool validateFilecoinAddress(String address) {
    try {
      const checksumHashLength = 4;
      const fileCoinPrefixs = ['f', 't'];
      if (!fileCoinPrefixs.contains(address.substring(0, 1))) {
        return false;
      }
      final protocol = address[1];
      final protocolByte = Leb128.encodeUnsigned(int.parse(protocol));
      final raw = address.substring(2);
      if (protocol == '1' || protocol == '2' || protocol == '3') {
        List<int> payloadCksm = Base32.decode(raw);

        if (payloadCksm.length < checksumHashLength) {
          throw Exception('Invalid address length');
        }

        Uint8List payload =
            payloadCksm.sublist(0, payloadCksm.length - 4) as Uint8List;

        Uint8List checksum = payloadCksm.sublist(payload.length) as Uint8List;

        List<int> byteList = List.from(protocolByte)..addAll(payload);
        Uint8List bytes = Uint8List.fromList(byteList);

        if (!_validateChecksum(bytes, checksum)) {
          throw Exception('Invalid address checksum');
        }

        return true;
      } else if (protocol == '0') {
        const maxInt64StringLength = 19;
        if (raw.length > maxInt64StringLength) {
          throw Exception('Invalid ID address length');
        }
        final payload = Leb128.encodeUnsigned(int.parse(raw));
        final bytes = [...protocolByte, ...payload];
        if (kDebugMode) {
          print(bytes);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  _validateChecksum(Uint8List bytes, Uint8List checksum) {
    return seqEqual(_getChecksum(bytes), checksum);
  }

  Uint8List _getChecksum(Uint8List data) {
    return blake2bHash(data, digestSize: 4) as Uint8List;
  }

  Map constructFilecoinMsg(
    String destinationAddress,
    String from,
    int nonce,
    BigInt filecoinToSend,
  ) {
    final msg = {
      "Version": 0,
      "To": destinationAddress,
      "From": from,
      "Nonce": nonce,
      "Value": '$filecoinToSend',
      "GasLimit": 0,
      "GasFeeCap": "0",
      "GasPremium": "0",
      "Method": 0,
      "Params": ""
    };
    return msg;
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final amounToSend = amount.toBigIntDec(fileCoinDecimals);

    String data = WalletService.getActiveKey(walletImportType)!.data;
    final fileCoinDetails = await importData(data);
    final nonce = await getFileCoinNonce(
      prefix,
      baseUrl,
    );

    final msg = constructFilecoinMsg(
      to,
      fileCoinDetails.address,
      nonce,
      amounToSend,
    );

    final gasFromNetwork = await fileCoinEstimateGas(baseUrl, msg);
    if (gasFromNetwork.isNotEmpty) {
      msg['GasLimit'] = gasFromNetwork['GasLimit'];
      msg['GasFeeCap'] = gasFromNetwork['GasFeeCap'];
      msg['GasPremium'] = gasFromNetwork['GasPremium'];
    }

    final signature = transactionSignLotus(msg, fileCoinDetails.privateKey!);
    const signTypeSecp = 1;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "id": 1,
        "jsonrpc": "2.0",
        "method": "Filecoin.MpoolPush",
        "params": [
          {
            "Message": msg,
            "Signature": {
              "Type": signTypeSecp,
              "Data": signature,
            },
          }
        ]
      }),
    );

    final responseBody = response.body;
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }

    Map jsonDecodedBody = json.decode(responseBody) as Map;

    return jsonDecodedBody['result']['/'];
  }

  @override
  int decimals() {
    return fileCoinDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final getFileCoinDetails = await importData(data);

    final nonce = await getFileCoinNonce(prefix, baseUrl);
    final attoFIL = double.parse(amount) * pow(10, fileCoinDecimals.toInt());

    BigInt amounToSend = BigInt.from(attoFIL);

    final msg = constructFilecoinMsg(
      to,
      getFileCoinDetails.address,
      nonce,
      amounToSend,
    );

    final gasFromNetwork = await fileCoinEstimateGas(
      baseUrl,
      msg,
    );

    // Transaction Fee = GasLimit * GasFeeCap + GasPremium
    final gasLimit = gasFromNetwork['GasLimit'];
    final gasFeeCap = double.parse(gasFromNetwork['GasFeeCap']);
    final gasPremium = double.parse(gasFromNetwork['GasPremium']);
    final fees =
        ((gasLimit * gasFeeCap) + gasPremium) / pow(10, fileCoinDecimals);

    return fees;
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<FilecoinCoin> getFilecoinBlockChains() {
  List<FilecoinCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      FilecoinCoin(
        name: 'Filecoin(Testnet)',
        symbol: 'FIL',
        default_: 'FIL',
        blockExplorer:
            'https://calibration.filfox.info/en/message/$blockExplorerPlaceholder',
        image: 'assets/filecoin.png',
        baseUrl: 'https://api.calibration.node.glif.io/rpc/v0',
        prefix: 't',
        geckoID: 'filecoin',
        payScheme: 'filecoin',
        rampID: "FILECOIN_FIL",
      ),
    );
  } else {
    blockChains.addAll([
      FilecoinCoin(
        name: 'Filecoin',
        symbol: 'FIL',
        default_: 'FIL',
        blockExplorer:
            'https://filfox.info/en/message/$blockExplorerPlaceholder',
        image: 'assets/filecoin.png',
        baseUrl: 'https://api.node.glif.io/rpc/v0',
        prefix: 'f',
        geckoID: 'filecoin',
        payScheme: 'filecoin',
        rampID: "FILECOIN_FIL",
      ),
    ]);
  }
  return blockChains;
}

class FilecoinDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String addressPrefix;

  const FilecoinDeriveArgs({
    required this.seedRoot,
    required this.addressPrefix,
  });
}

class _FilecoinDerive {
  static AccountData fromPrivateKey({
    required List<int> privateKey,
    required String addressPrefix,
  }) {
    final pk = _hexToU8a(HEX.encode(privateKey));
    final e = getSecp256k1();

    final publickEy =
        e.privateToPublicKey(PrivateKey.fromBytes(getSecp256k1(), pk));

    final protocolByte = Leb128.encodeUnsigned(1);
    final payload = blake2bHash(HEX.decode(publickEy.toHex()), digestSize: 20);

    final addressBytes = [...protocolByte, ...payload];
    final checksum = blake2bHash(addressBytes, digestSize: 4);
    Uint8List bytes = Uint8List.fromList([...payload, ...checksum]);
    final address = '${addressPrefix}1${Base32.encode(bytes)}';
    return AccountData(
      address: address.toLowerCase(),
      privateKey: HEX.encode(privateKey),
    );
  }
}

Map calculateFileCoinKey(FilecoinDeriveArgs config) {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final node = seedRoot_.root.derivePath("m/44'/461'/0'/0");
  final rs0 = node.derive(0);

  final results = _FilecoinDerive.fromPrivateKey(
    privateKey: rs0.privateKey!,
    addressPrefix: config.addressPrefix,
  );

  return {
    "address": results.address,
    "privateKey": results.privateKey,
  };
}

Uint8List _hexToU8a(String hex) {
  RegExp hexRegex = RegExp(r'^(0x)?[a-fA-F0-9]+$');
  if (!hexRegex.hasMatch(hex)) {
    throw ArgumentError('Provided string is not valid hex value');
  }
  final value = hex.startsWith('0x') ? hex.substring(2) : hex;
  final valLength = value.length ~/ 2;

  final bufLength = (valLength).ceil();

  final result = Uint8List(bufLength);
  final offset = (bufLength - valLength).clamp(0, bufLength);
  for (var index = 0; index < bufLength; index++) {
    result[index + offset] =
        int.parse(value.substring(index * 2, index * 2 + 2), radix: 16);
  }
  return result;
}

String transactionSignLotus(Map msg, String privateKeyHex) {
  final to = addressAsBytes(msg['To']);
  final from = addressAsBytes(msg['From']);
  final value = serializeBigNum(msg['Value']);
  final gasfeecap = serializeBigNum(msg['GasFeeCap']);
  final gaspremium = serializeBigNum(msg['GasPremium']);
  final gaslimit = msg['GasLimit'];
  int? method = msg['Method'];
  final params = msg['Params'];
  int? nonce = msg['Nonce'];
  int? version = msg['Version'];

  final messageToEncode = [
    version ?? 0,
    to,
    from,
    nonce ?? 0,
    value,
    gaslimit,
    gasfeecap,
    gaspremium,
    method ?? 0,
    base64.decode(params ?? '')
  ];
  cbor.init();
  final output = cbor.OutputStandard();
  final encoder = cbor.Encoder(output);
  output.clear();
  encoder.writeArray(messageToEncode);
  final unsignedMessage = output.getDataAsList();
  Uint8List privateKey = HEX.decode(privateKeyHex) as Uint8List;

  final messageDigest = getDigest(Uint8List.fromList(unsignedMessage));

  final signatureEC = sign(messageDigest, privateKey);
  final recid = signatureEC.v - 27;

  final cid = base64.encode([
    ...signatureEC.r.toUint8List(),
    ...signatureEC.s.toUint8List(),
    recid,
  ]);
  return cid;
}
