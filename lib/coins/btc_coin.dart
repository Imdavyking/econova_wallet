// coins/native_btc_coin.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/big_int_ext.dart';

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

/// Runs in a separate isolate — derives P2TR (tb1p / bc1p) address.
///
/// Leather uses the raw x-only pubkey as the witness program directly —
/// no BIP341 tapTweak applied. tweakedPublicKey == x-only pubkey.
Map<String, dynamic> calculateTaprootBtcKey(TaprootBtcDeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);

  // Strip 02/03 prefix byte → 32-byte x-only pubkey
  final xOnlyPubkey = Uint8List.fromList(node.publicKey.sublist(1));

  // Encode as bech32m with witness version 1 — no tapTweak
  final address = const SegwitCodec().encode(
    Segwit(args.hrp, 1, xOnlyPubkey),
  );

  return {
    'address': address,
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
    'publicKey': HEX.encode(node.publicKey),
    'tweakedPublicKey': HEX.encode(xOnlyPubkey),
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
    // v2 — bumped to bust stale cache
    final saveKey = 'nativeBtcP2WPKHv2$isTestnet${walletImportType.name}';
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
  // amount is a BTC string e.g. "0.0001" — converted to satoshis internally.
  //
  // IMPORTANT — segwit signing order:
  //   1. addInput  (all inputs, with scriptPubKey)
  //   2. addOutput (all outputs — recipient + change)
  //   3. sign      (each input with witnessValue)
  //   4. build + broadcast
  //
  // The BIP143 sighash commits to outputs, so outputs must exist before
  // signing. Also ECPair must be created with compressed: true or
  // publicKey will be null and sign() will throw.

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    // amount is BTC — convert to satoshis
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

    // compressed: true is required — without it publicKey is null
    // and txb.sign() throws "Null check operator used on a null value"
    final ecPair = ECPair.fromPrivateKey(
      privBytes,
      network: _network,
      compressed: true,
    );

    // Derive P2WPKH scriptPubKey — required as 4th arg of addInput
    // so bitcoin_flutter knows this is a segwit input and constructs
    // the witness correctly
    final p2wpkh = P2WPKH(
      data: PaymentData(pubkey: ecPair.publicKey),
      network: _network,
    );
    final script = p2wpkh.data.output!;

    // ── Step 1: select UTXOs ──────────────────────────────────────────────
    int totalIn = 0;
    final selectedUtxos = <Map<String, dynamic>>[];

    for (final utxo in utxos) {
      selectedUtxos.add(utxo);
      totalIn += utxo['value'] as int;
      final fee = _estimateFee(selectedUtxos.length, 2, feeRate);
      if (totalIn >= satoshiToSend + fee) break;
    }

    final fee = _estimateFee(selectedUtxos.length, 2, feeRate);
    if (kDebugMode) {
      print(
          'BTC totalIn: $totalIn  fee: $fee  change: ${totalIn - satoshiToSend - fee}');
    }

    if (totalIn < satoshiToSend + fee) {
      throw Exception(
          'Insufficient balance (need ${satoshiToSend + fee} sat, have $totalIn)');
    }

    final change = totalIn - satoshiToSend - fee;

    // ── Step 2: build tx ──────────────────────────────────────────────────
    final txb = TransactionBuilder(network: _network)..setVersion(2);

// For native P2WPKH — do NOT pass script to addInput
// Pass it as redeemScript in sign() instead
    for (final utxo in selectedUtxos) {
      txb.addInput(
        utxo['txid'] as String,
        utxo['vout'] as int,
      );
    }

// Add outputs BEFORE signing (BIP143 sighash commits to outputs)
    txb.addOutput(to, satoshiToSend);
    if (change > 546) txb.addOutput(address, change);

// Sign — pass the P2WPKH output script as redeemScript
// This is what hashForWitnessV0 needs to build the BIP143 sighash
    for (int i = 0; i < selectedUtxos.length; i++) {
      txb.sign(
        vin: i,
        keyPair: ecPair,
        witnessValue: selectedUtxos[i]['value'] as int,
        redeemScript: script, // P2WPKH output script (OP_0 <20-byte-hash>)
      );
    }

    final txHex = txb.build().toHex();
    if (kDebugMode) print('BTC txHex: $txHex');

    // ── Step 3: broadcast ─────────────────────────────────────────────────
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

  @override
  validateAddress(String address) {
    final prefix = isTestnet ? 'tb1q' : 'bc1q';
    if (!address.startsWith(prefix)) {
      throw Exception('Expected $prefix... address');
    }
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
    // v3 — bumped to bust stale cache from tapTweak era
    final saveKey = 'nativeBtcP2TRv3$isTestnet${walletImportType.name}';
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
  // Taproot spending requires BIP340 Schnorr signing which bitcoin_flutter
  // does not yet support. P2TR is receive-only — users send via tb1q address.

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

  @override
  validateAddress(String address) {
    final prefix = isTestnet ? 'tb1p' : 'bc1p';
    if (!address.startsWith(prefix)) {
      throw Exception('Expected $prefix... taproot address');
    }
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
