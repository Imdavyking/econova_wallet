// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:cryptography/cryptography.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/wallet_transaction.dart';
import 'package:wallet_app/fetchers/tezos_trx_fetcher.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/blake2bhash.dart';
import '../utils/rpc_urls.dart';

const tezosDecimals = 6;

// ── Network config ────────────────────────────────────────────────────────────

enum TezosNetworkType { mainNet, ghostNet }

class _TezosNetwork {
  final String rpc; // used for forging, counter, block hash, inject
  final String api; // tzkt REST API — used for balance

  const _TezosNetwork({required this.rpc, required this.api});
}

const _networks = {
  TezosNetworkType.mainNet: _TezosNetwork(
    rpc: 'https://rpc.tzkt.io/mainnet',
    api: 'https://api.tzkt.io',
  ),
  TezosNetworkType.ghostNet: _TezosNetwork(
    rpc: 'https://rpc.tzkt.io/ghostnet',
    api: 'https://api.ghostnet.tzkt.io',
  ),
};

// ── Coin ──────────────────────────────────────────────────────────────────────

class TezosCoin extends Coin {
  final TezosNetworkType networkType;
  final String blockExplorer;
  final String symbol;
  final String default_;
  final String image;
  final String name;

  TezosCoin({
    required this.networkType,
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
  });

  _TezosNetwork get _net => _networks[networkType]!;

  // ── Coin interface ──────────────────────────────────────────────────────────

  @override
  String getName() => name;

  @override
  String getSymbol() => symbol;

  @override
  String getDefault() => default_;

  @override
  String getExplorer() => blockExplorer;

  @override
  String getImage() => image;

  @override
  int decimals() => tezosDecimals;

  @override
  String getGeckoId() => 'tezos';

  @override
  String getRampID() =>
      networkType == TezosNetworkType.mainNet ? 'XTZ_XTZ' : '';

  @override
  String getPayScheme() => 'tezos';

  @override
  TransactionFetcher? get transactionFetcher =>
      TezosTransactionFetcher(networkType: networkType);

  // ── Serialization ───────────────────────────────────────────────────────────

  factory TezosCoin.fromJson(Map<String, dynamic> json) {
    return TezosCoin(
      networkType: TezosNetworkType.values[json['networkType'] as int],
      blockExplorer: json['blockExplorer'] as String,
      symbol: json['symbol'] as String,
      default_: json['default'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'networkType': networkType.index,
        'default': default_,
        'symbol': symbol,
        'name': name,
        'blockExplorer': blockExplorer,
        'image': image,
      };

  // ── Key derivation ──────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final cacheKey = 'tezosV3_${networkType.index}_${walletImportType.name}';
    Map<String, dynamic> cache = {};

    if (pref.containsKey(cacheKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(cacheKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(Map<String, dynamic>.from(cache[mnemonic]));
      }
    }

    final keys = await compute(
      _deriveTezosKeys,
      TezosArgs(seedRoot: seedPhraseRoot),
    );

    cache[mnemonic] = keys;
    await pref.put(cacheKey, jsonEncode(cache));
    return AccountData.fromJson(keys);
  }

  // ── Balance ─────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(
      Uri.parse('${_net.api}/v1/accounts/$address'),
    );
    if (res.statusCode == 404) return 0.0;
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Balance fetch failed: ${res.statusCode}');
    }
    final mutez = jsonDecode(res.body)['balance'] as int? ?? 0;
    return mutez / pow(10, tezosDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final cacheKey = 'tezosBalance_${networkType.index}_$address';
    final stored = pref.get(cacheKey) as double?;

    if (useCache) return stored ?? 0.0;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(cacheKey, balance);
      return balance;
    } catch (_) {
      return stored ?? 0.0;
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
    final address = accountData.address;
    final privateKeyHex = accountData.privateKey!;
    final publicKeyEncoded = accountData.publicKey!; // edpk...

    final mutez =
        (double.parse(amount) * pow(10, tezosDecimals)).toInt().toString();

    // 1. Counter — RPC returns a JSON-quoted integer string e.g. "42"
    final counterRes = await http.get(
      Uri.parse(
          '${_net.rpc}/chains/main/blocks/head/context/contracts/$address/counter'),
    );
    if (counterRes.statusCode ~/ 100 != 2) {
      throw Exception('Counter fetch failed: ${counterRes.body}');
    }
    final rawCounter = jsonDecode(counterRes.body);
    int nextCounter =
        (rawCounter is int ? rawCounter : int.parse(rawCounter.toString())) + 1;

    // 2. Block hash for TTL
    final blockRes = await http.get(
      Uri.parse('${_net.rpc}/chains/main/blocks/head/hash'),
    );
    if (blockRes.statusCode ~/ 100 != 2) {
      throw Exception('Block hash fetch failed: ${blockRes.body}');
    }
    final blockHash = jsonDecode(blockRes.body) as String;

    // 3. Check if public key is already revealed on-chain
    final managerRes = await http.get(
      Uri.parse(
          '${_net.rpc}/chains/main/blocks/head/context/contracts/$address/manager_key'),
    );
    final managerKey =
        managerRes.statusCode ~/ 100 == 2 ? jsonDecode(managerRes.body) : null;
    final needsReveal = managerKey == null || managerKey == '';

    // 4. Build operation contents — prepend reveal if needed
    final contents = <Map<String, dynamic>>[];

    if (needsReveal) {
      contents.add({
        'kind': 'reveal',
        'source': address,
        'fee': '1300',
        'counter': nextCounter.toString(),
        'gas_limit': '1100',
        'storage_limit': '0',
        'public_key': publicKeyEncoded,
      });
      nextCounter++;
    }

    contents.add({
      'kind': 'transaction',
      'source': address,
      'fee': '1500',
      'counter': nextCounter.toString(),
      'gas_limit': '10600',
      'storage_limit': '300',
      'amount': mutez,
      'destination': to,
    });

    // 5. Forge operation via RPC
    final op = {'branch': blockHash, 'contents': contents};

    final forgeReq = http.Request(
      'POST',
      Uri.parse('${_net.rpc}/chains/main/blocks/head/helpers/forge/operations'),
    )
      ..headers['Content-Type'] = 'application/json'
      ..bodyBytes = utf8.encode(jsonEncode(op));
    final forgeRes = await http.Response.fromStream(await forgeReq.send());
    if (forgeRes.statusCode ~/ 100 != 2) {
      throw Exception('Forge failed: ${forgeRes.body}');
    }
    final forgedHex = jsonDecode(forgeRes.body) as String;

    // 6. Sign — watermark 0x03 + forged bytes, then Ed25519
    final privateKeyBytes =
        Uint8List.fromList(HEX.decode(privateKeyHex.replaceFirst('0x', '')));
    final signatureHex = await _signOperation(privateKeyBytes, forgedHex);

    // 7. Inject
    final signedHex = forgedHex + signatureHex;
    final injectReq = http.Request(
      'POST',
      Uri.parse('${_net.rpc}/injection/operation'),
    )
      ..headers['Content-Type'] = 'application/json'
      ..bodyBytes = utf8.encode(jsonEncode(signedHex));
    final injectRes = await http.Response.fromStream(await injectReq.send());
    if (injectRes.statusCode ~/ 100 != 2) {
      throw Exception('Inject failed: ${injectRes.body}');
    }
    final txHash = (jsonDecode(injectRes.body) as String).replaceAll('"', '');

    return (txHash: txHash, txRaw: signedHex);
  }

  // ── Misc ────────────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    if (!isValidTezosAddress(address)) {
      throw Exception('Invalid $default_ address');
    }
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async =>
      1500 / pow(10, tezosDecimals); // ~0.0015 XTZ flat estimate

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
        networkType: TezosNetworkType.ghostNet,
        blockExplorer: 'https://ghostnet.tzkt.io/$blockExplorerPlaceholder',
        symbol: 'XTZ',
        default_: 'XTZ',
        name: 'Tezos(Testnet)',
        image: 'assets/tezos.png',
      ),
    ];
  }
  return [
    TezosCoin(
      networkType: TezosNetworkType.mainNet,
      blockExplorer: 'https://tzkt.io/$blockExplorerPlaceholder',
      symbol: 'XTZ',
      default_: 'XTZ',
      name: 'Tezos',
      image: 'assets/tezos.png',
    ),
  ];
}

// ── Signing ───────────────────────────────────────────────────────────────────

Future<String> _signOperation(
    Uint8List privateKeyBytes, String forgedHex) async {
  // Watermark 0x03 = generic operation
  final watermarked = Uint8List.fromList(
    [0x03, ...HEX.decode(forgedHex)],
  );

  final msgHash = Uint8List.fromList(blake2bHash(watermarked, digestSize: 32));

  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);
  final sig = await algorithm.sign(msgHash, keyPair: keyPair);
  return HEX.encode(sig.bytes);
}

// ── Isolate key derivation ────────────────────────────────────────────────────

class TezosArgs {
  final SeedPhraseRoot seedRoot;
  const TezosArgs({required this.seedRoot});
}

Future<Map<String, dynamic>> _deriveTezosKeys(TezosArgs args) async {
  final derived = await ED25519_HD_KEY.derivePath(
    "m/44'/1729'/0'/0'",
    args.seedRoot.seed,
  );

  final privateKeyBytes = Uint8List.fromList(derived.key);

  // Use cryptography's Ed25519 to derive the public key from the 32-byte seed.
  // This matches what Tezos expects — standard ed25519 scalar multiplication.
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);
  final pubKey = await keyPair.extractPublicKey();
  final publicKeyBytes = Uint8List.fromList(pubKey.bytes); // 32 bytes

  // tz1 address: blake2b-160 of public key, then base58check with tz1 prefix
  final keyHash = blake2bHash(publicKeyBytes, digestSize: 20);
  final prefixed = Uint8List.fromList([6, 161, 159, ...keyHash]);
  final address = bs58check.encode(prefixed);

  // edpk public key: base58check encode with edpk prefix [13, 15, 37, 217]
  final edpkPrefixed = Uint8List.fromList([13, 15, 37, 217, ...publicKeyBytes]);
  final publicKeyEncoded = bs58check.encode(edpkPrefixed);

  return {
    'address': address,
    'privateKey': HEX.encode(privateKeyBytes),
    'publicKey': publicKeyEncoded,
  };
}

// ── Address validation ────────────────────────────────────────────────────────

const _implicitPrefixes = ['tz1', 'tz2', 'tz3', 'tz4'];
const _contractPrefixes = ['KT1', 'txr1'];

const _prefixBytes = {
  'tz1': [6, 161, 159],
  'tz2': [6, 161, 161],
  'tz3': [6, 161, 164],
  'tz4': [6, 161, 166],
  'KT1': [2, 90, 121],
  'txr1': [1, 128, 120, 31],
};

const _payloadLengths = {
  'tz1': 20,
  'tz2': 20,
  'tz3': 20,
  'tz4': 20,
  'KT1': 20,
  'txr1': 20,
};

bool isValidTezosAddress(String value) {
  try {
    for (final prefix in [..._implicitPrefixes, ..._contractPrefixes]) {
      if (!value.startsWith(prefix)) continue;

      // KT1 addresses may have an entrypoint suffix after '%'
      final bare = prefix == 'KT1'
          ? RegExp(r'^(KT1\w{33})').firstMatch(value)?.group(1) ?? value
          : value;

      final List<int> decoded;
      try {
        decoded = bs58check.decode(bare);
      } catch (_) {
        return false;
      }

      final prefBytes = _prefixBytes[prefix]!;
      final expectedLen = _payloadLengths[prefix]!;
      final payload = decoded.sublist(prefBytes.length);
      return payload.length == expectedLen;
    }
    return false;
  } catch (_) {
    return false;
  }
}
