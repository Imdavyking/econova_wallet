// coins/native_btc_coin.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:wallet_app/utils/bech32m.dart';
import 'package:wallet_app/utils/btc_script_utils.dart';
import 'package:wallet_app/utils/segwit_tx.dart';
import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

// Testnet4 is the current active Bitcoin testnet.
// Mempool.space supports it at /testnet4/api.
// HRP is still 'tb', derivation coin_type is still 1.
const _mempoolMain = 'https://mempool.space/api';
const _mempoolTest = 'https://mempool.space/testnet4/api';

// ─── Isolate args & top-level compute functions ───────────────────────────────
// Must be top-level so Flutter's compute() can send them across isolate
// boundaries.

class NativeBtcDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final NetworkType network;

  const NativeBtcDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.network,
  });
}

/// Runs in a separate isolate — derives P2WPKH (tb1q / bc1q) address.
Map<String, dynamic> calculateNativeBtcKey(NativeBtcDeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);
  final address = P2WPKH(
    data: PaymentData(pubkey: node.publicKey),
    network: args.network,
  ).data.address!;

  return {
    'address': address,
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
    'publicKey': HEX.encode(node.publicKey),
  };
}

class TaprootBtcDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final String hrp; // 'tb' or 'bc'

  const TaprootBtcDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.hrp,
  });
}

BigInt _modP(BigInt x) =>
    x %
    BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
        radix: 16);

BigInt _powModP(BigInt base, BigInt exp) => base.modPow(
    exp,
    BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
        radix: 16));

(BigInt, BigInt)? _pointAdd((BigInt, BigInt)? p1, (BigInt, BigInt)? p2) {
  if (p1 == null) return p2;
  if (p2 == null) return p1;
  final P = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16);
  BigInt m;
  if (p1.$1 == p2.$1) {
    if (p1.$2 != p2.$2) return null;
    m = (BigInt.from(3) * p1.$1 * p1.$1) *
        _powModP(BigInt.two * p1.$2, P - BigInt.two) %
        P;
  } else {
    m = (p2.$2 - p1.$2) * _powModP(p2.$1 - p1.$1, P - BigInt.two) % P;
  }
  final x = _modP(m * m - p1.$1 - p2.$1);
  final y = _modP(m * (p1.$1 - x) - p1.$2);
  return (x, y);
}

(BigInt, BigInt)? _pointMul(BigInt k, (BigInt, BigInt) pt) {
  (BigInt, BigInt)? r;
  var p = pt;
  while (k > BigInt.zero) {
    if (k.isOdd) r = _pointAdd(r, p);
    p = _pointAdd(p, p)!;
    k >>= 1;
  }
  return r;
}

/// BIP341 tapTweak — key-path only (no script tree).
/// Returns the x-only tweaked public key as 32 bytes.
Uint8List tapTweak(Uint8List internalKey) {
  // taggedHash("TapTweak", internalKey)
  final tag = utf8.encode('TapTweak');
  final tagHash = sha256Bytes(Uint8List.fromList(tag));
  final preimage = Uint8List.fromList([...tagHash, ...tagHash, ...internalKey]);
  final t = sha256Bytes(preimage);
  final tInt = BigInt.parse(HEX.encode(t), radix: 16);

  // lift_x: get the even-y point for internalKey
  final P = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16);
  final x = BigInt.parse(HEX.encode(internalKey), radix: 16);
  final ySq = _modP(x.modPow(BigInt.from(3), P) + BigInt.from(7));
  var y = _powModP(ySq, (P + BigInt.one) ~/ BigInt.from(4));
  if (y.isOdd) y = P - y;

  final G = (
    BigInt.parse(
        '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
        radix: 16),
    BigInt.parse(
        '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
        radix: 16),
  );

  final tweaked = _pointAdd((x, y), _pointMul(tInt, G))!;
  final xBytes = tweaked.$1.toRadixString(16).padLeft(64, '0');
  return Uint8List.fromList(HEX.decode(xBytes));
}

/// Runs in a separate isolate — derives P2TR (tb1p / bc1p) address.
Map<String, dynamic> calculateTaprootBtcKey(TaprootBtcDeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);

  // Strip 02/03 prefix → 32-byte x-only internal key
  final internalKey = Uint8List.fromList(node.publicKey.sublist(1));

  // BIP341 tapTweak (key-path only, no script tree)
  final tweakedKey = tapTweak(internalKey);

  // Encode tweaked key as bech32m with witness version 1
  final words = convertBits(tweakedKey, 8, 5, true);
  final address = bech32mEncode(args.hrp, [1, ...words]);

  return {
    'address': address,
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
    'publicKey': HEX.encode(node.publicKey),
    'tweakedPublicKey': HEX.encode(internalKey),
  };
}

// ─── P2WPKH (tb1q / bc1q) ─────────────────────────────────────────────────────

class NativeBtcCoin extends Coin {
  final bool isTestnet;
  final String blockExplorer;
  final String image;

  NativeBtcCoin({
    required this.isTestnet,
    required this.blockExplorer,
    required this.image,
  });

  String get _api => isTestnet ? _mempoolTest : _mempoolMain;
  String get _derivPath => isTestnet ? "m/84'/1'/0'/0/0" : "m/84'/0'/0'/0/0";
  NetworkType get _network => isTestnet ? testnet : bitcoin;

  // ─── Address ────────────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'nativeBtcP2WPKHv2i$isTestnet${walletImportType.name}';
    Map<String, dynamic> cache = {};

    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }

    final result = await compute(
      calculateNativeBtcKey,
      NativeBtcDeriveArgs(
        seedRoot: seedPhraseRoot,
        derivationPath: _derivPath,
        network: _network,
      ),
    );

    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  // ─── Balance ────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(Uri.parse('$_api/address/$address'));
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('NativeBTC balance fetch failed: ${res.statusCode}');
    }
    final stats = jsonDecode(res.body)['chain_stats'] as Map<String, dynamic>;
    final funded = stats['funded_txo_sum'] as int;
    final spent = stats['spent_txo_sum'] as int;
    return (funded - spent) / pow(10, 8);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'NativeBTCBalance$address';
    final stored = pref.get(key) as double?;
    if (useCache) return stored ?? 0.0;
    try {
      final bal = await getUserBalance(address: address);
      await pref.put(key, bal);
      return bal;
    } catch (_) {
      return stored ?? 0.0;
    }
  }

  // ─── UTXOs ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getUtxos(String address) async {
    final res = await http.get(Uri.parse('$_api/address/$address/utxo'));
    if (res.statusCode ~/ 100 != 2) throw Exception('UTXO fetch failed');
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  // ─── Fee ────────────────────────────────────────────────────────────────────

  Future<int> _getFeeRate() async {
    final res = await http.get(Uri.parse('$_api/v1/fees/recommended'));
    if (res.statusCode ~/ 100 != 2) return 5;
    return jsonDecode(res.body)['halfHourFee'] as int;
  }

  int _estimateFee(int inputs, int outputs, int feeRate) =>
      (inputs * 68 + outputs * 31 + 10) * feeRate;

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final address = await getAddress();
    final utxos = await _getUtxos(address);
    final feeRate = await _getFeeRate();
    return _estimateFee(utxos.length.clamp(1, 5), 2, feeRate) / pow(10, 8);
  }

  // ─── Send ────────────────────────────────────────────────────────────────────
  //
  // Supports sending to any address type: P2PKH (m…/n…), P2WPKH (bc1q…/tb1q…),
  // P2TR (bc1p…/tb1p…). The correct output scriptPubKey is built via
  // buildOutputScript() based on address type detection.
  //
  // Inputs are always P2WPKH (our own address type) — BIP143 signing.

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final satoshiToSend = amount.toBigIntDec(decimals()).toInt();
    if (kDebugMode) print('BTC satoshiToSend: $satoshiToSend');
    if (satoshiToSend < 546) throw Exception('Amount below dust limit');

    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);
    final address = keyPair.address;

    final utxos = await _getUtxos(address);
    if (utxos.isEmpty) throw Exception('No UTXOs available');

    final feeRate = await _getFeeRate();
    final privBytes = txDataToUintList(keyPair.privateKey!);

    // ── Step 1: select UTXOs ──────────────────────────────────────────────────
    int totalIn = 0;
    final selectedUtxos = <Map<String, dynamic>>[];
    for (final utxo in utxos) {
      selectedUtxos.add(utxo);
      totalIn += utxo['value'] as int;
      if (totalIn >=
          satoshiToSend + _estimateFee(selectedUtxos.length, 2, feeRate)) break;
    }

    final fee = _estimateFee(selectedUtxos.length, 2, feeRate);
    if (kDebugMode) {
      print(
          'BTC totalIn: $totalIn  fee: $fee  change: ${totalIn - satoshiToSend - fee}');
    }
    if (totalIn < satoshiToSend + fee) {
      throw Exception(
        'Insufficient balance (need ${satoshiToSend + fee} sat, have $totalIn)',
      );
    }
    final change = totalIn - satoshiToSend - fee;

    // ── Step 2: build output scripts ──────────────────────────────────────────
    // toScript supports P2PKH / P2WPKH / P2TR recipients.
    // changeScript is always P2WPKH (sending change back to our own address).
    final toScript = buildBtcOutputScript(to, isTestnet);
    final changeScript = change > 546
        ? p2wpkhScript(
            Uint8List.fromList(const SegwitCodec().decode(address).program),
          )
        : null;

    // ── Step 3: BIP143 shared hashes ─────────────────────────────────────────
    final hashPrevouts = buildHashPrevouts(selectedUtxos);
    final hashSequence = buildHashSequence(selectedUtxos.length);
    final hashOutputs = buildHashOutputs(
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
    );

    final scriptCode = p2wpkhScriptCode(
      hash160(compressedPubKey(privBytes)),
    );

    // ── Step 4: sign each input ───────────────────────────────────────────────
    final witnesses = <List<Uint8List>>[];
    for (int i = 0; i < selectedUtxos.length; i++) {
      final txid =
          HEX.decode(selectedUtxos[i]['txid'] as String).reversed.toList();
      final preimage = bip143Preimage(
        hashPrevouts: hashPrevouts,
        hashSequence: hashSequence,
        txid: txid,
        vout: selectedUtxos[i]['vout'] as int,
        scriptCode: scriptCode,
        value: selectedUtxos[i]['value'] as int,
        hashOutputs: hashOutputs,
      );
      witnesses.add(buildInputWitness(
        privBytes: privBytes,
        sigHash: dsha256(preimage),
      ));
    }

    // ── Step 5: serialize & broadcast ────────────────────────────────────────
    final txHex = buildSegwitTxHex(
      inputs: selectedUtxos,
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
      witnesses: witnesses,
    );
    if (kDebugMode) print('BTC txHex: $txHex');

    final res = await http.post(
      Uri.parse('$_api/tx'),
      headers: {'Content-Type': 'text/plain'},
      body: txHex,
    );
    if (res.statusCode ~/ 100 != 2) {
      if (kDebugMode) print('BTC broadcast error: ${res.body}');
      throw Exception('Broadcast failed: ${res.body}');
    }

    return (txHash: res.body.trim(), txRaw: txHex);
  }

  // ─── Boilerplate ─────────────────────────────────────────────────────────────

  @override
  int decimals() => 8;

  @override
  String getDefault() => 'BTC';

  @override
  String getExplorer() => blockExplorer;

  @override
  String getGeckoId() => 'bitcoin';

  @override
  String getImage() => image;

  @override
  String getName() => isTestnet ? 'Bitcoin (SegWit Test4)' : 'Bitcoin';

  @override
  String getPayScheme() => 'bitcoin';

  @override
  String getRampID() => 'BTC_BTC';

  @override
  String getSymbol() => 'BTC';

  @override
  bool get isRpcWorking => true;

  @override
  Future<String?> resolveAddress(String address) async => null;

  // Accepts P2PKH (m…/n…/1…), P2WPKH (bc1q…/tb1q…), P2TR (bc1p…/tb1p…)
  @override
  void validateAddress(String address) {
    if (detectBtcAddrType(address, isTestnet) != BtcAddrType.unknown) return;
    throw Exception('Invalid BTC address');
  }

  @override
  Map<String, dynamic> toJson() => {
        'isTestnet': isTestnet,
        'blockExplorer': blockExplorer,
        'image': image,
        'type': 'NativeBtcCoin',
      };
}

// ─── P2TR (tb1p / bc1p) ────────────────────────────────────────────────────────

class TaprootBtcCoin extends Coin {
  final bool isTestnet;
  final String blockExplorer;
  final String image;

  TaprootBtcCoin({
    required this.isTestnet,
    required this.blockExplorer,
    required this.image,
  });

  String get _api => isTestnet ? _mempoolTest : _mempoolMain;
  String get _derivPath => isTestnet ? "m/86'/1'/0'/0/0" : "m/86'/0'/0'/0/0";
  String get _hrp => isTestnet ? 'tb' : 'bc';

  // ─── Address ────────────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'nativeBtcP2TRv42$isTestnet${walletImportType.name}';
    Map<String, dynamic> cache = {};

    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }

    final result = await compute(
      calculateTaprootBtcKey,
      TaprootBtcDeriveArgs(
        seedRoot: seedPhraseRoot,
        derivationPath: _derivPath,
        hrp: _hrp,
      ),
    );

    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  // ─── Balance ────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(Uri.parse('$_api/address/$address'));
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('P2TR balance fetch failed: ${res.statusCode}');
    }
    final stats = jsonDecode(res.body)['chain_stats'] as Map<String, dynamic>;
    final funded = stats['funded_txo_sum'] as int;
    final spent = stats['spent_txo_sum'] as int;
    return (funded - spent) / pow(10, 8);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'TaprootBTCBalance$address';
    final stored = pref.get(key) as double?;
    if (useCache) return stored ?? 0.0;
    try {
      final bal = await getUserBalance(address: address);
      await pref.put(key, bal);
      return bal;
    } catch (_) {
      return stored ?? 0.0;
    }
  }

  // ─── Send ─────────────────────────────────────────────────────────────────────
  // Taproot spending requires BIP340 Schnorr signing — not in bitcoin_flutter.
  // P2TR is receive-only; users send from their SegWit (tb1q / bc1q) address.

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    throw UnimplementedError(
      'Taproot spending is not yet supported. '
      'Please send from your SegWit (tb1q / bc1q) address.',
    );
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.0;

  // ─── Boilerplate ─────────────────────────────────────────────────────────────

  @override
  int decimals() => 8;

  @override
  String getDefault() => 'BTC';

  @override
  String getExplorer() => blockExplorer;

  @override
  String getGeckoId() => 'bitcoin';

  @override
  String getImage() => image;

  @override
  String getName() =>
      isTestnet ? 'Bitcoin (Taproot Test4)' : 'Bitcoin (Taproot)';

  @override
  String getPayScheme() => 'bitcoin';

  @override
  String getRampID() => 'BTC_BTC';

  @override
  String getSymbol() => 'BTC';

  @override
  bool get isRpcWorking => true;

  @override
  Future<String?> resolveAddress(String address) async => null;

  // Accepts same address types as NativeBtcCoin for consistency
  @override
  void validateAddress(String address) {
    if (detectBtcAddrType(address, isTestnet) != BtcAddrType.unknown) return;
    throw Exception('Invalid BTC Taproot address');
  }

  @override
  Map<String, dynamic> toJson() => {
        'isTestnet': isTestnet,
        'blockExplorer': blockExplorer,
        'image': image,
        'type': 'TaprootBtcCoin',
      };
}

// ─── Factories ────────────────────────────────────────────────────────────────

List<NativeBtcCoin> getNativeBtcCoins() {
  if (enableTestNet) {
    return [
      NativeBtcCoin(
        isTestnet: true,
        blockExplorer:
            'https://mempool.space/testnet4/tx/$blockExplorerPlaceholder',
        image: 'assets/bitcoin.jpg',
      ),
    ];
  }
  return [
    NativeBtcCoin(
      isTestnet: false,
      blockExplorer: 'https://mempool.space/tx/$blockExplorerPlaceholder',
      image: 'assets/bitcoin.jpg',
    ),
  ];
}

List<TaprootBtcCoin> getTaprootBtcCoins() {
  if (enableTestNet) {
    return [
      TaprootBtcCoin(
        isTestnet: true,
        blockExplorer:
            'https://mempool.space/testnet4/tx/$blockExplorerPlaceholder',
        image: 'assets/bitcoin.jpg',
      ),
    ];
  }
  return [
    TaprootBtcCoin(
      isTestnet: false,
      blockExplorer: 'https://mempool.space/tx/$blockExplorerPlaceholder',
      image: 'assets/bitcoin.jpg',
    ),
  ];
}

// DER-encode each integer — strip leading zeros, prepend 0x00 if high bit set
Uint8List derInt(Uint8List bytes) {
  int start = 0;
  while (start < bytes.length - 1 && bytes[start] == 0) {
    start++;
  }
  final stripped = bytes.sublist(start);
  return (stripped[0] & 0x80 != 0)
      ? Uint8List.fromList([0x00, ...stripped])
      : stripped;
}
