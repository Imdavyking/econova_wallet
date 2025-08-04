// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:bech32/bech32.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'ethereum_coin.dart';

const harmonyDecimals = 18;
const _hrp = 'one';

class HarmonyCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;

  String geckoID;
  String rampID;
  String payScheme;
  int chainID;

  @override
  bool get supportKeystore => true;
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

  HarmonyCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.chainID,
  });

  factory HarmonyCoin.fromJson(Map<String, dynamic> json) {
    return HarmonyCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      chainID: json['chainID'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['rpc'] = rpc;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    data['chainID'] = chainID;

    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'harmonyPrivate$rpc${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final address = await etherPrivateKeyToAddress(privateKey);

    final keys = AccountData(
      address: _ethAddrToOne(address),
      hex_address: address,
      privateKey: privateKey,
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'harmonyCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = HarmonyArgs(seedRoot: seedPhraseRoot);
    final keys = await compute(calculateHarmonyKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final ethClient = Web3Client(rpc, http.Client());

    final userAddress = EthereumAddress.fromHex(_oneAddrToEth(address));

    final etherAmount = await ethClient.getBalance(userAddress);

    final base = BigInt.from(10);

    return etherAmount.getInWei / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'harmonyAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double ethBalance = await getUserBalance(address: address);

      await pref.put(key, ethBalance);

      return ethBalance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final client = Web3Client(
      rpc,
      http.Client(),
    );
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final credentials = EthPrivateKey.fromHex(
      response.privateKey!,
    );
    final gasPrice = await client.getGasPrice();
    final wei = amount.toBigIntDec(decimals());

    final trans = await client.signTransaction(
      credentials,
      Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(_oneAddrToEth(to)),
        value: EtherAmount.inWei(
          wei,
        ),
        gasPrice: gasPrice,
      ),
      chainId: chainID,
    );

    return await client.sendRawTransaction(trans);
  }

  @override
  validateAddress(String address) {
    Bech32 sel = bech32.decode(address);
    if (_hrp == sel.hrp) return;
    throw Exception("Invalid address");
  }

  @override
  int decimals() {
    return harmonyDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final transactionFee = await getEtherTransactionFee(
      rpc,
      null,
      EthereumAddress.fromHex(_oneAddrToEth(response.address)),
      EthereumAddress.fromHex(_oneAddrToEth(to)),
    );

    return transactionFee / pow(10, decimals());
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<HarmonyCoin> getHarmonyBlockChains() {
  List<HarmonyCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      HarmonyCoin(
        name: 'Harmony(Testnet)',
        symbol: 'ONE',
        default_: 'ONE',
        blockExplorer:
            'https://explorer.testnet.harmony.one/tx/$blockExplorerPlaceholder',
        image: 'assets/harmony.png',
        rpc: 'https://api.s0.b.hmny.io/',
        geckoID: 'harmony',
        rampID: "",
        payScheme: 'harmony',
        chainID: 1666700000,
      ),
    );
  } else {
    blockChains.addAll([
      HarmonyCoin(
        name: 'Harmony',
        symbol: 'ONE',
        default_: 'ONE',
        blockExplorer:
            'https://explorer.harmony.one/tx/$blockExplorerPlaceholder',
        image: 'assets/harmony.png',
        rpc: 'https://api.s0.t.hmny.io',
        geckoID: 'harmony',
        rampID: "",
        payScheme: 'harmony',
        chainID: 1666600000,
      ),
    ]);
  }
  return blockChains;
}

class HarmonyArgs {
  final SeedPhraseRoot seedRoot;

  const HarmonyArgs({
    required this.seedRoot,
  });
}

Future<Map> calculateHarmonyKey(HarmonyArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  const path = "m/44'/1023'/0'/0/0";
  final node = seedRoot_.root.derivePath(path);
  final privateKey = HEX.encode(node.privateKey!);
  final privatekeyStr = "0x$privateKey";
  final address = await etherPrivateKeyToAddress(privatekeyStr);

  return {
    'address': _ethAddrToOne(address),
    'privateKey': privatekeyStr,
    'hex_address': address,
  };
}

String _ethAddrToOne(String address) {
  final addrBz = _convertBits(HEX.decode(strip0x(address)) as Uint8List, 8, 5);
  return bech32.encode(Bech32(_hrp, addrBz));
}

String _oneAddrToEth(String address) {
  final bits = bech32.decode(address);

  final buf = _convertBits(Uint8List.fromList(bits.data), 5, 8, pad: false);

  return EthereumAddress.fromHex(HEX.encode(buf)).hexEip55;
}

Uint8List _convertBits(
  Uint8List data,
  int fromWidth,
  int toWidth, {
  bool pad = true,
}) {
  int acc = 0;
  int bits = 0;
  List<int> ret = [];
  int maxv = (1 << toWidth) - 1;

  for (int p = 0; p < data.length; p++) {
    int value = data[p];

    if (value < 0 || (value >> fromWidth) != 0) {
      return Uint8List(0); // Return an empty list if invalid
    }

    acc = (acc << fromWidth) | value;
    bits += fromWidth;

    while (bits >= toWidth) {
      bits -= toWidth;
      ret.add((acc >> bits) & maxv);
    }
  }

  if (pad) {
    if (bits > 0) {
      ret.add((acc << (toWidth - bits)) & maxv);
    }
  } else if (bits >= fromWidth || (acc << (toWidth - bits)) & maxv != 0) {
    return Uint8List(0); // Return an empty list if invalid
  }

  return Uint8List.fromList(ret);
}
