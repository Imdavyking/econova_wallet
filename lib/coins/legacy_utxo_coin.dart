// coins/legacy_utxo_coin.dart
//
// Legacy P2PKH coins — BTC(test) · DOGE · DASH · BCH · ZEC
//
// Derivation : BIP44  m/44'/<coin_type>'/0'/0/0  →  P2PKH address
//              derivationPath is an explicit constructor field (mirrors UtxoCoin)
//
// API routing
//   BTC testnet  — mempool.space/testnet4  (no key required, Esplora format)
//   Everything else — Crypto APIs v2  (key in rpc_urls.dart → utxoApiKey)
//                     Free plan = testnets only; mainnet requires paid plan.
//
// Address quirks
//   BCH  — P2PKH byte → CashAddr for display; legacy address sent to Crypto APIs
//   ZEC  — P2PKH byte → t-address (two-byte version prefix)
//            mainnet  [0x1c, 0xb8]  →  t1…
//            testnet  [0x1d, 0x25]  →  tm…
//
// Sending
//   BTC · DOGE · DASH  — standard P2PKH, bitcoin_flutter TransactionBuilder
//   BCH                — SIGHASH_FORKID (0x41), custom BIP143-style signing in bch_tx.dart
//   ZEC                — DISABLED: Sapling v4 format is out of scope
//
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:bitbox/bitbox.dart' as bitbox;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/utils/alt_ens.dart';
import 'package:wallet_app/utils/bch_tx.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';
import 'package:wallet_app/utils/utxo_script_utils.dart'; // replaces btc_script_utils
import 'package:wallet_app/utils/wallet_transaction.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/pos_networks.dart';
import '../utils/rpc_urls.dart';
import 'package:wallet_app/fetchers/mempool_trx_fetcher.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _cryptoApisBase = 'https://rest.cryptoapis.io';
const _mempoolTestBase = 'https://mempool.space/testnet4/api';
const _legacyDecimals = 8;

// ─── Mempool.space API (BTC testnet only) ─────────────────────────────────────

class _MempoolApi {
  static Future<double> balance(String address) async {
    final res = await http.get(
      Uri.parse('$_mempoolTestBase/address/$address'),
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Mempool balance failed (${res.statusCode})');
    }
    final stats = jsonDecode(res.body)['chain_stats'] as Map<String, dynamic>;
    final funded = stats['funded_txo_sum'] as int;
    final spent = stats['spent_txo_sum'] as int;
    return (funded - spent) / 1e8;
  }

  static Future<List<_Utxo>> utxos(String address) async {
    final res = await http.get(
      Uri.parse('$_mempoolTestBase/address/$address/utxo'),
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Mempool UTXOs failed (${res.statusCode})');
    }
    return (jsonDecode(res.body) as List)
        .cast<Map<String, dynamic>>()
        .map((u) => _Utxo(
              txid: u['txid'] as String,
              vout: u['vout'] as int,
              satoshis: u['value'] as int,
            ))
        .toList();
  }

  static Future<int> feeRate() async {
    final res = await http.get(
      Uri.parse('$_mempoolTestBase/v1/fees/recommended'),
    );
    if (res.statusCode ~/ 100 != 2) return 5;
    return jsonDecode(res.body)['halfHourFee'] as int;
  }

  static Future<String> broadcast(String txHex) async {
    final res = await http.post(
      Uri.parse('$_mempoolTestBase/tx'),
      headers: {'Content-Type': 'text/plain'},
      body: txHex,
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Mempool broadcast failed: ${res.body}');
    }
    return res.body.trim();
  }
}

// ─── Crypto APIs v2 client ────────────────────────────────────────────────────

class _CryptoApis {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-API-Key': utxoApiKey,
      };

  static Future<double> balance(
    String blockchain,
    String network,
    String address,
  ) async {
    final res = await http.get(
      Uri.parse(
        '$_cryptoApisBase/addresses-latest/utxo/$blockchain/$network/$address/balance',
      ),
      headers: _headers,
    );
    _assertOk(res, 'balance');
    return double.parse(
      (_item(res)['confirmedBalance'] as Map)['amount'] as String,
    );
  }

  static Future<List<_Utxo>> utxos(
    String blockchain,
    String network,
    String address,
  ) async {
    final res = await _getUtxos(blockchain, network, address);

    if (_isSyncRequired(res)) {
      await _syncAddress(blockchain, network, address);
      await Future.delayed(const Duration(seconds: 3));
      final retry = await _getUtxos(blockchain, network, address);
      _assertOk(retry, 'UTXOs (post-sync)');
      return _parseUtxos(retry);
    }

    _assertOk(res, 'UTXOs');
    return _parseUtxos(res);
  }

  static Future<String> broadcast(
    String blockchain,
    String network,
    String txHex,
  ) async {
    final res = await http.post(
      Uri.parse(
        '$_cryptoApisBase/blockchain-tools/$blockchain/$network/transactions/broadcast',
      ),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'item': {'signedTransactionHex': txHex},
        },
      }),
    );
    _assertOk(res, 'broadcast');
    return _item(res)['transactionId'] as String;
  }

  static Future<http.Response> _getUtxos(
    String blockchain,
    String network,
    String address,
  ) =>
      http.get(
        Uri.parse(
          '$_cryptoApisBase/addresses-historical/utxo/$blockchain/$network/$address/unspent-outputs',
        ),
        headers: _headers,
      );

  static List<_Utxo> _parseUtxos(http.Response res) {
    return (jsonDecode(res.body)['data']['items'] as List)
        .cast<Map<String, dynamic>>()
        .where((u) => u['isAvailable'] == true)
        .map(_Utxo.fromCryptoApis)
        .toList();
  }

  static bool _isSyncRequired(http.Response res) {
    if (res.statusCode != 409) return false;
    try {
      final code = jsonDecode(res.body)['error']['code'] as String?;
      return code == 'sync_address_not_active';
    } catch (_) {
      return false;
    }
  }

  static Future<void> _syncAddress(
    String blockchain,
    String network,
    String address,
  ) async {
    final res = await http.post(
      Uri.parse(
        '$_cryptoApisBase/addresses-historical/utxo/$blockchain/$network/$address/sync',
      ),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'item': {'address': address},
        },
      }),
    );
    if (res.statusCode != 201 && res.statusCode != 409) {
      throw Exception(
        'Crypto APIs sync failed (${res.statusCode}): ${res.body}',
      );
    }
    if (kDebugMode) {
      print('CryptoApis: syncing $address on $blockchain/$network');
    }
  }

  static void _assertOk(http.Response res, String context) {
    if (res.statusCode ~/ 100 != 2) {
      throw Exception(
        'Crypto APIs $context failed (${res.statusCode}): ${res.body}',
      );
    }
  }

  static Map<String, dynamic> _item(http.Response res) =>
      (jsonDecode(res.body)['data']['item'] as Map<String, dynamic>);
}

// ─── UTXO value object ────────────────────────────────────────────────────────

class _Utxo {
  final String txid;
  final int vout;
  final int satoshis;

  const _Utxo({
    required this.txid,
    required this.vout,
    required this.satoshis,
  });

  factory _Utxo.fromCryptoApis(Map<String, dynamic> j) => _Utxo(
        txid: j['transactionId'] as String,
        vout: j['index'] as int,
        satoshis: (double.parse(j['amount'] as String) * 1e8).round(),
      );
}

// ─── Per-coin static configuration ───────────────────────────────────────────

class _CoinConfig {
  final String blockchain;
  final int coinType;
  final NetworkType network;

  /// Bech32 HRP — used by detectAddrType for cross-type address validation.
  /// BTC: 'bc' (mainnet) or 'tb' (testnet). DOGE/DASH/ZEC/BCH: '' (no bech32).
  final String hrp;

  final int dustLimit;
  final int minimumFee;
  final int feeRate;
  final bool sendEnabled;
  final String cryptoApisNetwork;
  final bool useMempool;
  final String mempoolBase;

  const _CoinConfig({
    required this.blockchain,
    required this.coinType,
    required this.network,
    this.hrp = '',
    this.dustLimit = 546,
    this.minimumFee = 10000,
    this.feeRate = 10,
    this.sendEnabled = true,
    this.cryptoApisNetwork = 'mainnet',
    this.useMempool = false,
    this.mempoolBase = 'https://mempool.space/testnet4/api', // testnet default
  });
}

final _configs = <String, _CoinConfig>{
  'DOGE': _CoinConfig(
    blockchain: 'dogecoin',
    coinType: 3,
    network: dogecoin,
    dustLimit: 1000000,
    minimumFee: 100000000,
    feeRate: 400000,
  ),
  'DASH': _CoinConfig(
    blockchain: 'dash',
    coinType: 5,
    network: dash,
    dustLimit: 546,
    minimumFee: 100000,
    feeRate: 10,
  ),
  'BCH': _CoinConfig(
    blockchain: 'bitcoin-cash',
    coinType: 145,
    network: bitcoincash,
    dustLimit: 546,
    minimumFee: 1000,
    feeRate: 2,
  ),
  'ZEC': _CoinConfig(
    blockchain: 'zcash',
    coinType: 133,
    network: zcash,
    dustLimit: 546,
    minimumFee: 10000,
    feeRate: 10,
    sendEnabled: false,
  ),
  'BTC': _CoinConfig(
    blockchain: 'bitcoin',
    coinType: 0,
    network: bitcoin,
    hrp: 'bc',
    dustLimit: 546,
    minimumFee: 1000,
    feeRate: 5,
    useMempool: true,
    mempoolBase: 'https://mempool.space/api',
  ),
  'BTC_testnet': _CoinConfig(
    blockchain: 'bitcoin',
    coinType: 0,
    network: testnet,
    hrp: 'tb',
    dustLimit: 546,
    minimumFee: 1000,
    feeRate: 5,
    useMempool: true,
    mempoolBase: 'https://mempool.space/testnet4/api',
  ),
  'ZEC_testnet': _CoinConfig(
    blockchain: 'zcash',
    coinType: 133,
    network: zcashTestnet,
    dustLimit: 546,
    minimumFee: 10000,
    feeRate: 10,
    sendEnabled: false,
    cryptoApisNetwork: 'testnet',
  ),
};

// ─── LegacyUtxoCoin ───────────────────────────────────────────────────────────

class LegacyUtxoCoin extends Coin {
  final String symbol;
  final String name;
  final String default_;
  final String image;
  final String blockExplorer;
  final String derivationPath;
  final String geckoID;
  final String rampID;
  final String payScheme;
  final bool isTestnet;

  final _CoinConfig _cfg;

  LegacyUtxoCoin({
    required this.symbol,
    required this.name,
    required this.default_,
    required this.image,
    required this.blockExplorer,
    required this.derivationPath,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    this.isTestnet = false,
  }) : _cfg = _configs[isTestnet ? '${symbol}_testnet' : symbol]!;

  // ── Metadata ──────────────────────────────────────────────────────────────────

  @override
  String getSymbol() => symbol;
  @override
  String getName() => name;
  @override
  String getDefault() => default_;
  @override
  String getImage() => image;
  @override
  String getExplorer() => blockExplorer;
  @override
  String getGeckoId() => geckoID;
  @override
  String getRampID() => rampID;
  @override
  String getPayScheme() => payScheme;
  @override
  int decimals() => _legacyDecimals;
  @override
  bool get isRpcWorking => true;

  // ── BCH address helpers ───────────────────────────────────────────────────────

  String _toApiAddress(String displayAddress) {
    if (symbol != 'BCH') return displayAddress;
    return bitbox.Address.toLegacyAddress('bitcoincash:$displayAddress');
  }

  // ── Address derivation ────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey =
        'legacyUtxoV1_${symbol}_${isTestnet ? 'test' : 'main'}_${walletImportType.name}';
    Map<String, dynamic> cache = {};

    if (pref.containsKey(saveKey)) {
      cache = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (cache.containsKey(mnemonic)) {
        return AccountData.fromJson(cache[mnemonic]);
      }
    }

    final result = await compute(
      _deriveKey,
      _DeriveArgs(
        seedRoot: seedPhraseRoot,
        derivationPath: derivationPath,
        network: _cfg.network,
        symbol: symbol,
      ),
    );

    cache[mnemonic] = result;
    await pref.put(saveKey, jsonEncode(cache));
    return AccountData.fromJson(result);
  }

  // ── Explorer URLs ─────────────────────────────────────────────────────────────

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst('/transactions/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  // ── Address resolution ────────────────────────────────────────────────────────

  @override
  Future<String?> resolveAddress(String address) async {
    final result = await udResolver(domainName: address, currency: default_);
    return result['success'] == true ? result['msg'] as String? : null;
  }

  // ── Balance ───────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) {
    if (_cfg.useMempool) return _MempoolApi.balance(address);
    return _CryptoApis.balance(
      _cfg.blockchain,
      _cfg.cryptoApisNetwork,
      _toApiAddress(address),
    );
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final cacheKey = '${symbol}LegacyBalance$address';
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

  // ── Fee estimation ────────────────────────────────────────────────────────────
  // P2PKH: input ≈ 148 bytes · output ≈ 34 bytes · overhead ≈ 10 bytes

  int _estimateFee(int inputs, int outputs, int feeRate) {
    final weightedFee = (inputs * 148 + outputs * 34 + 10) * feeRate;
    return max(weightedFee, _cfg.minimumFee);
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final address = await getAddress();
    final apiAddress = _toApiAddress(address);

    int feeRate = _cfg.feeRate;
    int utxoCount;

    if (_cfg.useMempool) {
      feeRate = await _MempoolApi.feeRate();
      utxoCount = (await _MempoolApi.utxos(address)).length.clamp(1, 5);
    } else {
      utxoCount = (await _CryptoApis.utxos(
        _cfg.blockchain,
        _cfg.cryptoApisNetwork,
        apiAddress,
      ))
          .length
          .clamp(1, 5);
    }

    return _estimateFee(utxoCount, 2, feeRate) / pow(10, _legacyDecimals);
  }

  // ── Send ──────────────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    if (!_cfg.sendEnabled) {
      throw UnimplementedError('$symbol sending is not supported.');
    }

    final satoshiToSend = amount.toBigIntDec(decimals()).toInt();
    if (satoshiToSend < _cfg.dustLimit) {
      throw Exception(
          '$symbol: amount below dust limit (${_cfg.dustLimit} sat)');
    }

    final activeKey = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(activeKey);
    final address = keyPair.address;
    final apiAddress = _toApiAddress(address);

    // ── Fetch UTXOs ───────────────────────────────────────────────────────────
    final List<_Utxo> utxos;
    final int feeRate;

    if (_cfg.useMempool) {
      feeRate = await _MempoolApi.feeRate();
      utxos = await _MempoolApi.utxos(address);
    } else {
      feeRate = _cfg.feeRate;
      utxos = await _CryptoApis.utxos(
        _cfg.blockchain,
        _cfg.cryptoApisNetwork,
        apiAddress,
      );
    }

    if (utxos.isEmpty) throw Exception('$symbol: no UTXOs available');

    // ── Select UTXOs (first-fit) ──────────────────────────────────────────────
    int totalIn = 0;
    final selected = <_Utxo>[];
    for (final utxo in utxos) {
      selected.add(utxo);
      totalIn += utxo.satoshis;
      if (totalIn >=
          satoshiToSend + _estimateFee(selected.length, 2, feeRate)) {
        break;
      }
    }

    final fee = _estimateFee(selected.length, 2, feeRate);
    final change = totalIn - satoshiToSend - fee;

    if (totalIn < satoshiToSend + fee) {
      throw Exception(
        '$symbol: insufficient balance '
        '(need ${satoshiToSend + fee} sat, have $totalIn sat)',
      );
    }

    if (kDebugMode) print('$symbol totalIn=$totalIn fee=$fee change=$change');

    // ── BCH: SIGHASH_FORKID path ──────────────────────────────────────────────
    if (symbol == 'BCH') {
      final txHex = _buildBchTx(
        privKey: keyPair.privateKey!,
        ownAddress: address,
        to: to,
        selected: selected,
        satoshiToSend: satoshiToSend,
        change: change,
      );
      if (kDebugMode) print('BCH txHex: $txHex');
      final txid = await _CryptoApis.broadcast(
        _cfg.blockchain,
        _cfg.cryptoApisNetwork,
        txHex,
      );
      return (txHash: txid, txRaw: txHex);
    }

    // ── BTC · DOGE · DASH: standard P2PKH via bitcoin_flutter ────────────────
    final privBytes = txDataToUintList(keyPair.privateKey!);
    final ecPair = ECPair.fromPrivateKey(
      privBytes,
      network: _cfg.network,
      compressed: true,
    );

    final txb = TransactionBuilder(network: _cfg.network)..setVersion(1);

    for (final utxo in selected) {
      txb.addInput(utxo.txid, utxo.vout);
    }

    // BTC: use buildOutputScript() so legacy inputs can send to SegWit/Taproot.
    // DOGE/DASH: pure P2PKH networks — address string is sufficient.
    if (symbol == 'BTC') {
      txb.addOutput(
        buildOutputScript(to, _cfg.hrp, _cfg.network),
        satoshiToSend,
      );
      if (change > _cfg.dustLimit) {
        txb.addOutput(
          buildOutputScript(address, _cfg.hrp, _cfg.network),
          change,
        );
      }
    } else {
      txb.addOutput(to, satoshiToSend);
      if (change > _cfg.dustLimit) txb.addOutput(address, change);
    }

    for (int i = 0; i < selected.length; i++) {
      txb.sign(vin: i, keyPair: ecPair);
    }

    final txHex = txb.build().toHex();
    if (kDebugMode) print('$symbol txHex: $txHex');

    final txid = _cfg.useMempool
        ? await _MempoolApi.broadcast(txHex)
        : await _CryptoApis.broadcast(
            _cfg.blockchain,
            _cfg.cryptoApisNetwork,
            txHex,
          );

    return (txHash: txid, txRaw: txHex);
  }

  // ── BCH SIGHASH_FORKID signing ────────────────────────────────────────────────

  String _buildBchTx({
    required String privKey,
    required String ownAddress,
    required String to,
    required List<_Utxo> selected,
    required int satoshiToSend,
    required int change,
  }) {
    final privBytes = txDataToUintList(privKey);
    final toLegacy = bchToLegacy(to);
    final changeLegacy = bchToLegacy(ownAddress);

    final toScript = bchP2pkhScript(bchAddressHash160(toLegacy));
    final changeScript =
        change > 546 ? bchP2pkhScript(bchAddressHash160(changeLegacy)) : null;
    final ownScriptCode = bchP2pkhScript(bchAddressHash160(changeLegacy));
    final pubkey = compressedPubKey(privBytes);

    final bchUtxos = selected
        .map((u) => BchUtxo(txid: u.txid, vout: u.vout, satoshis: u.satoshis))
        .toList();

    final hashPrevouts = buildBchHashPrevouts(bchUtxos);
    final hashSequence = buildBchHashSequence(selected.length);
    final hashOutputs = buildBchHashOutputs(
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
    );

    final scriptSigs = <Uint8List>[];
    for (final utxo in selected) {
      final txid = HEX.decode(utxo.txid).reversed.toList();
      final preimage = bchSighashPreimage(
        hashPrevouts: hashPrevouts,
        hashSequence: hashSequence,
        txid: txid,
        vout: utxo.vout,
        scriptCode: ownScriptCode,
        value: utxo.satoshis,
        hashOutputs: hashOutputs,
      );
      final sig =
          buildBchSignature(privBytes: privBytes, sigHash: dsha256(preimage));
      scriptSigs.add(buildBchScriptSig(sig, pubkey));
    }

    return buildBchTxHex(
      inputs: bchUtxos,
      scriptSigs: scriptSigs,
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
    );
  }

  @override
  TransactionFetcher? get transactionFetcher {
    if (!_cfg.useMempool) return null; // Crypto APIs — no fetcher yet
    return MempoolTransactionFetcher(
      apiBase: _cfg.mempoolBase,
      symbol: symbol,
      explorerBase: blockExplorer.replaceFirst(
        '/tx/$blockExplorerPlaceholder',
        '/tx/',
      ),
    );
  }

  // ── Address validation ────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    // BCH: accepts CashAddr (q…) and legacy P2PKH
    if (symbol == 'BCH') {
      try {
        bitbox.Address.detectFormat(address);
        return;
      } catch (_) {
        throw Exception('Invalid BCH address');
      }
    }

    // ZEC: two-byte transparent prefix
    if (symbol == 'ZEC') {
      try {
        final decoded = bs58check.decode(address);
        final expectedPrefix = isTestnet ? [0x1d, 0x25] : [0x1c, 0xb8];
        if (decoded[0] == expectedPrefix[0] &&
            decoded[1] == expectedPrefix[1]) {
          return;
        }
      } catch (_) {}
      throw Exception(
          'Invalid ZEC ${isTestnet ? 'testnet' : 'mainnet'} t-address');
    }

    // BTC: use detectAddrType — accepts P2PKH, P2WPKH, and P2TR cross-type sends.
    if (symbol == 'BTC') {
      if (detectAddrType(address, _cfg.hrp, _cfg.network) !=
          UtxoAddrType.unknown) return;
      throw Exception('Invalid BTC address');
    }

    // DOGE, DASH — standard P2PKH base58check
    if (detectAddrType(address, '', _cfg.network) != UtxoAddrType.unknown) {
      return;
    }
    throw Exception('Invalid $symbol address');
  }

  // ── JSON round-trip ───────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'default': default_,
        'image': image,
        'blockExplorer': blockExplorer,
        'derivationPath': derivationPath,
        'geckoID': geckoID,
        'rampID': rampID,
        'payScheme': payScheme,
        'isTestnet': isTestnet,
      };

  factory LegacyUtxoCoin.fromJson(Map<String, dynamic> j) => LegacyUtxoCoin(
        symbol: j['symbol'] as String,
        name: j['name'] as String,
        default_: j['default'] as String,
        image: j['image'] as String,
        blockExplorer: j['blockExplorer'] as String,
        derivationPath: j['derivationPath'] as String,
        geckoID: j['geckoID'] as String,
        rampID: j['rampID'] as String,
        payScheme: j['payScheme'] as String,
        isTestnet: j['isTestnet'] as bool? ?? false,
      );
}

// ─── Isolate: key derivation ──────────────────────────────────────────────────

class _DeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final NetworkType network;
  final String symbol;

  const _DeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.network,
    required this.symbol,
  });
}

Map<String, dynamic> _deriveKey(_DeriveArgs args) {
  final node = args.seedRoot.root.derivePath(args.derivationPath);
  final p2pkh = P2PKH(
    data: PaymentData(pubkey: node.publicKey),
    network: args.network,
  );
  String address = p2pkh.data.address!;

  if (args.symbol == 'BCH') {
    if (bitbox.Address.detectFormat(address) == bitbox.Address.formatLegacy) {
      address = bitbox.Address.toCashAddress(address).split(':').last;
    }
  }

  if (args.symbol == 'ZEC') {
    final prefix = (args.network == zcashTestnet) ? [0x1d, 0x25] : [0x1c, 0xb8];
    final decoded = [...bs58check.decode(address)]..removeAt(0);
    final taddr = Uint8List(22)
      ..setAll(0, prefix)
      ..setAll(2, decoded);
    address = bs58check.encode(taddr);
  }

  return {
    'address': address,
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
  };
}

// ─── Factory ──────────────────────────────────────────────────────────────────

List<LegacyUtxoCoin> getLegacyUtxoCoins() {
  if (enableTestNet) {
    return [
      LegacyUtxoCoin(
        name: 'Bitcoin (Test)',
        symbol: 'BTC',
        default_: 'BTC',
        image: 'assets/bitcoin.jpg',
        blockExplorer:
            'https://mempool.space/testnet4/tx/$blockExplorerPlaceholder',
        derivationPath: "m/44'/0'/0'/0/0",
        geckoID: 'bitcoin',
        rampID: 'BTC_BTC',
        payScheme: 'bitcoin',
        isTestnet: true,
      ),
      LegacyUtxoCoin(
        name: 'Zcash (Test)',
        symbol: 'ZEC',
        default_: 'ZEC',
        image: 'assets/zcash.png',
        blockExplorer:
            'https://blockexplorer.one/zcash/testnet/tx/$blockExplorerPlaceholder',
        derivationPath: "m/44'/133'/0'/0/0",
        geckoID: 'zcash',
        rampID: '',
        payScheme: 'zcash',
        isTestnet: true,
      ),
    ];
  }

  return [
    LegacyUtxoCoin(
      name: 'Bitcoin (Legacy)',
      symbol: 'BTC',
      default_: 'BTC',
      image: 'assets/bitcoin.jpg',
      blockExplorer: 'https://mempool.space/tx/$blockExplorerPlaceholder',
      derivationPath: "m/44'/0'/0'/0/0",
      geckoID: 'bitcoin',
      rampID: 'BTC_BTC',
      payScheme: 'bitcoin',
      isTestnet: false,
    ),
    LegacyUtxoCoin(
      name: 'Dogecoin',
      symbol: 'DOGE',
      default_: 'DOGE',
      image: 'assets/dogecoin.png',
      blockExplorer:
          'https://live.blockcypher.com/doge/tx/$blockExplorerPlaceholder',
      derivationPath: "m/44'/3'/0'/0/0",
      geckoID: 'dogecoin',
      rampID: 'DOGE_DOGE',
      payScheme: 'doge',
    ),
    LegacyUtxoCoin(
      name: 'Dash',
      symbol: 'DASH',
      default_: 'DASH',
      image: 'assets/dash.png',
      blockExplorer:
          'https://live.blockcypher.com/dash/tx/$blockExplorerPlaceholder',
      derivationPath: "m/44'/5'/0'/0/0",
      geckoID: 'dash',
      rampID: '',
      payScheme: 'dash',
    ),
    LegacyUtxoCoin(
      name: 'Bitcoin Cash',
      symbol: 'BCH',
      default_: 'BCH',
      image: 'assets/bitcoin_cash.png',
      blockExplorer:
          'https://www.blockchain.com/explorer/transactions/bch/$blockExplorerPlaceholder',
      derivationPath: "m/44'/145'/0'/0/0",
      geckoID: 'bitcoin-cash',
      rampID: 'BCH_BCH',
      payScheme: 'bitcoincash',
    ),
    LegacyUtxoCoin(
      name: 'Zcash',
      symbol: 'ZEC',
      default_: 'ZEC',
      image: 'assets/zcash.png',
      blockExplorer:
          'https://blockexplorer.one/zcash/mainnet/tx/$blockExplorerPlaceholder',
      derivationPath: "m/44'/133'/0'/0/0",
      geckoID: 'zcash',
      rampID: '',
      payScheme: 'zcash',
    ),
  ];
}
