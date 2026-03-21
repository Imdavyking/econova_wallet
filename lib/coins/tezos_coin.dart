// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:dartez/dartez.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet_app/service/wallet_service.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

const tezorDecimals = 6;

class TezosCoin extends Coin {
  TezosTypes tezorType;
  String server;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;

  TezosCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.tezorType,
    required this.server,
  });

  // ── Coin interface ──────────────────────────────────────────────────────────

  @override
  String getExplorer() => blockExplorer;

  @override
  String getDefault() => default_;

  @override
  String getImage() => image;

  @override
  String getName() => name;

  @override
  String getSymbol() => symbol;

  @override
  int decimals() => tezorDecimals;

  @override
  String getGeckoId() => 'tezos';

  @override
  String getRampID() => tezorType == TezosTypes.mainNet ? 'XTZ_XTZ' : '';

  @override
  String getPayScheme() => 'tezos';

  // ── Serialization ───────────────────────────────────────────────────────────

  factory TezosCoin.fromJson(Map<String, dynamic> json) {
    return TezosCoin(
      tezorType: json['tezorType'],
      server: json['server'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'server': server,
      'tezorType': tezorType,
      'default': default_,
      'symbol': symbol,
      'name': name,
      'blockExplorer': blockExplorer,
      'image': image,
    };
  }

  // ── Key derivation ──────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final cacheKey = 'tezorDetails${tezorType.index}';
    List mmenomicMapping = [];

    if (pref.get(cacheKey) != null) {
      mmenomicMapping = jsonDecode(pref.get(cacheKey)) as List;
      for (int i = 0; i < mmenomicMapping.length; i++) {
        if (mmenomicMapping[i]['mmenomic'] == mnemonic) {
          return AccountData.fromJson(
            Map<String, dynamic>.from(mmenomicMapping[i]['key']),
          );
        }
      }
    }

    final keys = await compute(
      calculateTezorKey,
      TezosArgs(mnemonic: mnemonic),
    );

    mmenomicMapping.add({'key': keys, 'mmenomic': mnemonic});
    await pref.put(cacheKey, jsonEncode(mmenomicMapping));

    return AccountData.fromJson(Map<String, dynamic>.from(keys));
  }

  // ── Balance ─────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await Dartez.getBalance(address, server);
    return double.parse(res) / pow(10, tezorDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = '${tezorType.index}AddressBalance$address';
    final storedBalance = pref.get(key);
    double savedBalance = storedBalance ?? 0;

    if (useCache) return savedBalance;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

  // ── Transfer ─────────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountData = await importData(data);

    final keyStore = KeyStoreModel(
      publicKey: accountData.publicKey!,
      secretKey: accountData.privateKey!,
      publicKeyHash: accountData.address,
    );

    final signer = Dartez.createSigner(keyStore.secretKey!);

    final microTez = double.parse(amount) * pow(10, tezorDecimals);

    final result = await Dartez.sendTransactionOperation(
      server,
      signer,
      keyStore,
      to,
      microTez.toInt(),
    );

    final txHash =
        (Map.from(result)['operationGroupID'] as String).replaceAll('\n', '');

    return (txHash: txHash, txRaw: null);
  }

  // ── Misc ────────────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    if (!validateTezosAddress(address)) {
      throw Exception('Invalid $default_ address');
    }
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0;

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer.replaceFirst(blockExplorerPlaceholder, address);
  }
}

// ── Registry ──────────────────────────────────────────────────────────────────

List<TezosCoin> getTezosBlockchains() {
  if (enableTestNet) {
    return [
      TezosCoin(
        blockExplorer: 'https://ghostnet.tzkt.io/$blockExplorerPlaceholder',
        symbol: 'XTZ',
        default_: 'XTZ',
        name: 'Tezos(Testnet)',
        image: 'assets/tezos.png',
        tezorType: TezosTypes.ghostNet,
        server: 'https://rpc.tzkt.io/ghostnet',
      ),
    ];
  }
  return [
    TezosCoin(
      blockExplorer: 'https://tzkt.io/$blockExplorerPlaceholder',
      symbol: 'XTZ',
      default_: 'XTZ',
      name: 'Tezos',
      image: 'assets/tezos.png',
      tezorType: TezosTypes.mainNet,
      server: 'https://rpc.tzkt.io/mainnet',
    ),
  ];
}

// ── Address validation ────────────────────────────────────────────────────────

final List<String> implicitPrefix = ['tz1', 'tz2', 'tz3', 'tz4'];
final List<String> contractPrefix = ['KT1', 'txr1'];

class Prefix {
  static const TZ1 = 'tz1';
  static const TZ2 = 'tz2';
  static const TZ3 = 'tz3';
  static const TZ4 = 'tz4';
  static const KT = 'KT';
  static const KT1 = 'KT1';

  static const EDSK2 = 'edsk2';
  static const SPSK = 'spsk';
  static const P2SK = 'p2sk';

  static const EDPK = 'edpk';
  static const SPPK = 'sppk';
  static const P2PK = 'p2pk';
  static const BLPK = 'BLpk';

  static const EDESK = 'edesk';
  static const SPESK = 'spesk';
  static const P2ESK = 'p2esk';

  static const EDSK = 'edsk';
  static const EDSIG = 'edsig';
  static const SPSIG = 'spsig';
  static const P2SIG = 'p2sig';
  static const SIG = 'sig';

  static const NET = 'Net';
  static const NCE = 'nce';
  static const B = 'B';
  static const O = 'o';
  static const LO = 'Lo';
  static const LLO = 'LLo';
  static const P = 'P';
  static const CO = 'Co';
  static const ID = 'id';

  static const EXPR = 'expr';
  static const TZ = 'TZ';

  static const VH = 'vh';
  static const SASK = 'sask';
  static const ZET1 = 'zet1';

  static const TXR1 = 'txr1';
  static const TXI = 'txi';
  static const TXM = 'txm';
  static const TXC = 'txc';
  static const TXMR = 'txmr';
  static const TXRL = 'txM';
  static const TXW = 'txw';
}

class PrefixByte {
  static const Map<String, List<int>> prefix = {
    Prefix.TZ1: [6, 161, 159],
    Prefix.TZ2: [6, 161, 161],
    Prefix.TZ3: [6, 161, 164],
    Prefix.TZ4: [6, 161, 166],
    Prefix.KT: [2, 90, 121],
    Prefix.KT1: [2, 90, 121],
    Prefix.EDSK: [43, 246, 78, 7],
    Prefix.EDSK2: [13, 15, 58, 7],
    Prefix.SPSK: [17, 162, 224, 201],
    Prefix.P2SK: [16, 81, 238, 189],
    Prefix.EDPK: [13, 15, 37, 217],
    Prefix.SPPK: [3, 254, 226, 86],
    Prefix.P2PK: [3, 178, 139, 127],
    Prefix.BLPK: [6, 149, 135, 204],
    Prefix.EDESK: [7, 90, 60, 179, 41],
    Prefix.SPESK: [0x09, 0xed, 0xf1, 0xae, 0x96],
    Prefix.P2ESK: [0x09, 0x30, 0x39, 0x73, 0xab],
    Prefix.EDSIG: [9, 245, 205, 134, 18],
    Prefix.SPSIG: [13, 115, 101, 19, 63],
    Prefix.P2SIG: [54, 240, 44, 52],
    Prefix.SIG: [4, 130, 43],
    Prefix.NET: [87, 82, 0],
    Prefix.NCE: [69, 220, 169],
    Prefix.B: [1, 52],
    Prefix.O: [5, 116],
    Prefix.LO: [133, 233],
    Prefix.LLO: [29, 159, 109],
    Prefix.P: [2, 170],
    Prefix.CO: [79, 179],
    Prefix.ID: [153, 103],
    Prefix.EXPR: [13, 44, 64, 27],
    Prefix.TZ: [2, 90, 121],
    Prefix.VH: [1, 106, 242],
    Prefix.SASK: [11, 237, 20, 92],
    Prefix.ZET1: [18, 71, 40, 223],
    Prefix.TXR1: [1, 128, 120, 31],
    Prefix.TXI: [79, 148, 196],
    Prefix.TXM: [79, 149, 30],
    Prefix.TXC: [79, 148, 17],
    Prefix.TXMR: [18, 7, 206, 87],
    Prefix.TXRL: [79, 146, 82],
    Prefix.TXW: [79, 150, 72],
  };
}

enum ValidationResult { noPrefixMatched, invalidChecksum, invalidLength, valid }

bool validateTezosAddress(String value) {
  try {
    final result =
        validatePrefixedValue(value, [...implicitPrefix, ...contractPrefix]);
    return result == ValidationResult.valid;
  } catch (e) {
    return false;
  }
}

ValidationResult validatePrefixedValue(String value, List<String> prefixes) {
  final RegExp regExp = RegExp('^(${prefixes.join('|')})');
  final RegExpMatch? match = regExp.firstMatch(value);

  if (match == null || (match.group(0) ?? '').isEmpty) {
    return ValidationResult.noPrefixMatched;
  }

  final String prefixKey = match.group(0)!;

  if (!isValidPrefix(prefixKey)) {
    return ValidationResult.noPrefixMatched;
  }

  String decodedValue = value;
  final RegExp contractAddressRegExp = RegExp(r'^(KT1\w{33})(%(.*))?$');
  final RegExpMatch? contractAddress = contractAddressRegExp.firstMatch(value);

  if (contractAddress != null) {
    decodedValue = contractAddress.group(1)!;
  }

  List<int>? decoded;
  try {
    decoded = bs58check.decode(decodedValue);
  } catch (_) {}

  if (decoded == null) return ValidationResult.invalidChecksum;

  decoded = decoded.sublist(PrefixByte.prefix[prefixKey]!.length);

  if (decoded.length != prefixLength[prefixKey]) {
    return ValidationResult.invalidLength;
  }

  return ValidationResult.valid;
}

bool isValidPrefix(String prefixKey) {
  return PrefixByte.prefix.containsKey(prefixKey) &&
      prefixLength.containsKey(prefixKey);
}

final Map<String, int> prefixLength = {
  Prefix.TZ1: 20,
  Prefix.TZ2: 20,
  Prefix.TZ3: 20,
  Prefix.TZ4: 20,
  Prefix.KT: 20,
  Prefix.KT1: 20,
  Prefix.EDPK: 32,
  Prefix.SPPK: 33,
  Prefix.P2PK: 33,
  Prefix.BLPK: 48,
  Prefix.EDSIG: 64,
  Prefix.SPSIG: 64,
  Prefix.P2SIG: 64,
  Prefix.SIG: 64,
  Prefix.NET: 4,
  Prefix.B: 32,
  Prefix.P: 32,
  Prefix.O: 32,
  Prefix.VH: 32,
  Prefix.SASK: 169,
  Prefix.ZET1: 43,
  Prefix.TXR1: 20,
  Prefix.TXI: 32,
  Prefix.TXM: 32,
  Prefix.TXC: 32,
  Prefix.TXMR: 32,
  Prefix.TXRL: 32,
  Prefix.TXW: 32,
};

enum TezosTypes { mainNet, ghostNet }

// ── Isolate args & key derivation ─────────────────────────────────────────────

class TezosArgs {
  final String mnemonic;

  const TezosArgs({required this.mnemonic});
}

Future<Map<String, dynamic>> calculateTezorKey(TezosArgs args) async {
  final KeyStoreModel keyStore = await Dartez.restoreIdentityFromDerivationPath(
    "m/44'/1729'/0'/0'",
    args.mnemonic,
  );

  return {
    'address': keyStore.publicKeyHash,
    'privateKey': keyStore.secretKey,
    'publicKey': keyStore.publicKey,
  };
}
