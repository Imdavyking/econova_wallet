// coins/legacy_utxo_coin.dart
//
// Legacy P2PKH coins — DOGE · DASH · BCH · ZEC
//
// Derivation : BIP44  m/44'/<coin_type>'/0'/0/0  →  P2PKH address
// API        : Crypto APIs v2  (https://rest.cryptoapis.io)
//              Requires `utxoApiKey` in rpc_urls.dart
//              Header: X-API-Key
//
// Address quirks
//   BCH  — legacy P2PKH byte → CashAddr  (qXXX without the "bitcoincash:" prefix)
//   ZEC  — P2PKH byte       → t-address  (0x1c 0xb8 two-byte prefix)
//
// Sending
//   DOGE · DASH · BCH  — bitcoin_flutter TransactionBuilder (non-segwit P2PKH)
//   ZEC                — disabled; Sapling v4 format is out of scope
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
import 'package:wallet_app/utils/alt_ens.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/pos_networks.dart';
import '../utils/rpc_urls.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _cryptoApisBase = 'https://rest.cryptoapis.io/v2';
const _legacyDecimals = 8;

// ─── Crypto APIs HTTP client ──────────────────────────────────────────────────
//
// All blockchain-data and blockchain-tools calls go through here.
// Throws descriptive exceptions so callers can surface them in the UI.

class _CryptoApis {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-API-Key': utxoApiKey, // rpc_urls.dart
      };

  static Uri _dataUri(String blockchain, String network, String path) =>
      Uri.parse('$_cryptoApisBase/blockchain-data/$blockchain/$network/$path');

  static Uri _toolsUri(String blockchain, String network, String path) =>
      Uri.parse('$_cryptoApisBase/blockchain-tools/$blockchain/$network/$path');

  /// Confirmed spendable balance in coin units (e.g. 42.5 DOGE).
  static Future<double> balance(
    String blockchain,
    String network,
    String address,
  ) async {
    final res = await http.get(
      _dataUri(blockchain, network, 'addresses/$address'),
      headers: _headers,
    );
    _assertOk(res, 'balance');
    return double.parse(
      (_item(res)['confirmedBalance'] as Map)['amount'] as String,
    );
  }

  /// Available UTXOs for [address], already converted to satoshis.
  static Future<List<_Utxo>> utxos(
    String blockchain,
    String network,
    String address,
  ) async {
    final res = await http.get(
      _dataUri(blockchain, network, 'addresses/$address/unspent-outputs'),
      headers: _headers,
    );
    _assertOk(res, 'UTXOs');
    final items = (jsonDecode(res.body)['data']['items'] as List)
        .cast<Map<String, dynamic>>();
    return items
        .where((u) => u['isAvailable'] == true)
        .map(_Utxo.fromCryptoApis)
        .toList();
  }

  /// Broadcast a signed raw transaction hex. Returns the txid.
  static Future<String> broadcast(
    String blockchain,
    String network,
    String txHex,
  ) async {
    final res = await http.post(
      _toolsUri(blockchain, network, 'transactions/broadcast'),
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

  // ── Internals ────────────────────────────────────────────────────────────────

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
  final int satoshis; // always in satoshis regardless of source

  const _Utxo({
    required this.txid,
    required this.vout,
    required this.satoshis,
  });

  /// Crypto APIs returns amounts as decimal coin-unit strings ("0.00100000").
  factory _Utxo.fromCryptoApis(Map<String, dynamic> j) => _Utxo(
        txid: j['transactionId'] as String,
        vout: j['index'] as int,
        satoshis: (double.parse(j['amount'] as String) * 1e8).round(),
      );
}

// ─── Per-coin static configuration ───────────────────────────────────────────

class _CoinConfig {
  /// Crypto APIs blockchain identifier  (e.g. "dogecoin")
  final String blockchain;

  /// BIP44 coin_type  (SLIP-0044)
  final int coinType;

  /// bitcoin_flutter NetworkType for key derivation and tx building
  final NetworkType network;

  /// Smallest spendable output (satoshis)
  final int dustLimit;

  /// Minimum absolute fee (satoshis).
  /// Dominates for DOGE where the 1-DOGE floor overwhelms a per-byte calc.
  final int minimumFee;

  /// sat/byte used in the weight-based fee estimate.
  final int feeRate;

  /// false  →  throw on send (ZEC needs Sapling v4 which is out of scope).
  final bool sendEnabled;

  /// Crypto APIs network string — "mainnet" or "testnet".
  final String cryptoApisNetwork;

  const _CoinConfig({
    required this.blockchain,
    required this.coinType,
    required this.network,
    this.dustLimit = 546,
    this.minimumFee = 10000,
    this.feeRate = 10,
    this.sendEnabled = true,
    this.cryptoApisNetwork = 'mainnet',
  });
}

// Each entry keyed by the coin symbol used throughout the app.
final _configs = <String, _CoinConfig>{
  // 1 DOGE minimum fee (network policy); feeRate is secondary
  'DOGE': _CoinConfig(
    blockchain: 'dogecoin',
    coinType: 3,
    network: dogecoin, // pos_networks.dart
    dustLimit: 1000000, // 0.01 DOGE
    minimumFee: 100000000, // 1 DOGE
    feeRate: 400000, // dominated by minimumFee for typical tx sizes
  ),
  'DASH': _CoinConfig(
    blockchain: 'dash',
    coinType: 5,
    network: dash,
    dustLimit: 546,
    minimumFee: 100000, // 0.001 DASH
    feeRate: 10,
  ),
  'BCH': _CoinConfig(
    blockchain: 'bitcoin-cash',
    coinType: 145,
    network: bitcoincash,
    dustLimit: 546,
    minimumFee: 1000, // 0.00001 BCH
    feeRate: 2,
  ),
  // ZEC send disabled — Sapling v4 format required
  'ZEC': _CoinConfig(
    blockchain: 'zcash',
    coinType: 133,
    network: zcash,
    dustLimit: 546,
    minimumFee: 10000,
    feeRate: 10,
    sendEnabled: false,
  ),

  // ── Testnet-only entries (keyed as "<SYMBOL>_testnet") ───────────────────────

  // BTC legacy testnet — m/44'/0'/0'/0/0, P2PKH, Crypto APIs bitcoin/testnet
  'BTC_testnet': _CoinConfig(
    blockchain: 'bitcoin',
    coinType: 0,
    network: testnet, // bitcoin_flutter testnet
    dustLimit: 546,
    minimumFee: 1000,
    feeRate: 5,
    cryptoApisNetwork: 'testnet',
  ),

  // ZEC testnet — same derivation path, zcashTestnet network, t-address prefix [0x1d, 0x25]
  'ZEC_testnet': _CoinConfig(
    blockchain: 'zcash',
    coinType: 133,
    network: zcashTestnet, // pos_networks.dart
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
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    this.isTestnet = false,
  }) : _cfg = _configs[isTestnet ? '${symbol}_testnet' : symbol]!;

  // ── Coin interface — metadata ─────────────────────────────────────────────────

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

  // ── Address derivation ───────────────────────────────────────────────────────

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
        derivationPath: "m/44'/${_cfg.coinType}'/0'/0/0",
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

  // ── Address resolution (Unstoppable Domains) ──────────────────────────────────

  @override
  Future<String?> resolveAddress(String address) async {
    final result = await udResolver(domainName: address, currency: default_);
    return result['success'] == true ? result['msg'] as String? : null;
  }

  // ── Balance ───────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) =>
      _CryptoApis.balance(_cfg.blockchain, _cfg.cryptoApisNetwork, address);

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
  //
  // P2PKH weight: input ≈ 148 bytes · output ≈ 34 bytes · overhead ≈ 10 bytes.
  // Fee = max(weight × feeRate, minimumFee) to honour per-coin floors (DOGE).

  int _estimateFee(int inputs, int outputs) {
    final weightedFee = (inputs * 148 + outputs * 34 + 10) * _cfg.feeRate;
    return max(weightedFee, _cfg.minimumFee);
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final address = await getAddress();
    final utxos = await _CryptoApis.utxos(
        _cfg.blockchain, _cfg.cryptoApisNetwork, address);
    final count = utxos.length.clamp(1, 5);
    return _estimateFee(count, 2) / pow(10, _legacyDecimals);
  }

  // ── Send ──────────────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    if (!_cfg.sendEnabled) {
      throw UnimplementedError(
        '$symbol spending is not supported — Sapling v4 transaction format '
        'is required and currently out of scope.',
      );
    }

    final satoshiToSend = amount.toBigIntDec(decimals()).toInt();
    if (satoshiToSend < _cfg.dustLimit) {
      throw Exception(
          '$symbol: amount is below the dust limit (${_cfg.dustLimit} sat)');
    }

    final activeKey = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(activeKey);
    final address = keyPair.address;

    // ── Fetch UTXOs ───────────────────────────────────────────────────────────
    final utxos = await _CryptoApis.utxos(
        _cfg.blockchain, _cfg.cryptoApisNetwork, address);
    if (utxos.isEmpty) throw Exception('$symbol: no UTXOs available');

    // ── Select UTXOs (first-fit) ──────────────────────────────────────────────
    int totalIn = 0;
    final selected = <_Utxo>[];
    for (final utxo in utxos) {
      selected.add(utxo);
      totalIn += utxo.satoshis;
      if (totalIn >= satoshiToSend + _estimateFee(selected.length, 2)) break;
    }

    final fee = _estimateFee(selected.length, 2);
    final change = totalIn - satoshiToSend - fee;

    if (totalIn < satoshiToSend + fee) {
      throw Exception(
        '$symbol: insufficient balance '
        '(need ${satoshiToSend + fee} sat, have $totalIn sat)',
      );
    }

    if (kDebugMode) {
      print('$symbol  totalIn=$totalIn  fee=$fee  change=$change');
    }

    // ── Build and sign ────────────────────────────────────────────────────────
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

    txb.addOutput(to, satoshiToSend);
    if (change > _cfg.dustLimit) txb.addOutput(address, change);

    for (int i = 0; i < selected.length; i++) {
      txb.sign(vin: i, keyPair: ecPair);
    }

    final txHex = txb.build().toHex();
    if (kDebugMode) print('$symbol txHex: $txHex');

    // ── Broadcast ─────────────────────────────────────────────────────────────
    final txid = await _CryptoApis.broadcast(
        _cfg.blockchain, _cfg.cryptoApisNetwork, txHex);
    return (txHash: txid, txRaw: txHex);
  }

  // ── Address validation ────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    // BCH accepts both CashAddr and legacy formats
    if (symbol == 'BCH') {
      try {
        bitbox.Address.detectFormat(address);
        return;
      } catch (_) {
        throw Exception('Invalid BCH address');
      }
    }

    // ZEC — two-byte transparent address prefix differs by network:
    //   mainnet  → [0x1c, 0xb8]  (t1…)
    //   testnet  → [0x1d, 0x25]  (tm…)
    if (symbol == 'ZEC') {
      try {
        final decoded = bs58check.decode(address);
        final expectedPrefix = isTestnet ? [0x1d, 0x25] : [0x1c, 0xb8];
        if (decoded[0] == expectedPrefix[0] && decoded[1] == expectedPrefix[1])
          return;
      } catch (_) {}
      throw Exception('Invalid ZEC ${isTestnet ? 'testnet' : ''} t-address');
    }

    // DOGE, DASH — standard base58check against the network's pubKeyHash
    try {
      if (Address.validateAddress(address, _cfg.network)) return;
    } catch (_) {}

    try {
      final decoded = bs58check.decode(address);
      final versionByte = decoded[0];
      if (versionByte == _cfg.network.pubKeyHash) return;
    } catch (_) {}

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
        geckoID: j['geckoID'] as String,
        rampID: j['rampID'] as String,
        payScheme: j['payScheme'] as String,
        isTestnet: j['isTestnet'] as bool? ?? false,
      );
}

// ─── Isolate: key derivation ──────────────────────────────────────────────────
//
// Top-level so Flutter's compute() can cross the isolate boundary.

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

  // BCH: convert legacy P2PKH → CashAddr, strip the "bitcoincash:" prefix
  if (args.symbol == 'BCH') {
    if (bitbox.Address.detectFormat(address) == bitbox.Address.formatLegacy) {
      address = bitbox.Address.toCashAddress(address).split(':').last;
    }
  }

  // ZEC mainnet: rewrite version byte → [0x1c, 0xb8]  (t1… address)
  // ZEC testnet: rewrite version byte → [0x1d, 0x25]  (tm… address)
  if (args.symbol == 'ZEC') {
    final isTestnet = args.network == zcashTestnet;
    final prefix = isTestnet ? [0x1d, 0x25] : [0x1c, 0xb8];
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
      // BTC legacy P2PKH testnet — m/44'/0'/0'/0/0
      // Kept separate from NativeBtcCoin (SegWit) and TaprootBtcCoin.
      LegacyUtxoCoin(
        name: 'Bitcoin (Legacy Test)',
        symbol: 'BTC',
        default_: 'BTC',
        image: 'assets/bitcoin.jpg',
        blockExplorer:
            'https://www.blockchain.com/btc-testnet/tx/$blockExplorerPlaceholder',
        geckoID: 'bitcoin',
        rampID: 'BTC_BTC',
        payScheme: 'bitcoin',
        isTestnet: true,
      ),
      // ZEC testnet — receive-only; Sapling v4 send is out of scope
      LegacyUtxoCoin(
        name: 'Zcash (Test)',
        symbol: 'ZEC',
        default_: 'ZEC',
        image: 'assets/zcash.png',
        blockExplorer:
            'https://blockexplorer.one/zcash/testnet/tx/$blockExplorerPlaceholder',
        geckoID: 'zcash',
        rampID: '',
        payScheme: 'zcash',
        isTestnet: true,
      ),
    ];
  }

  return [
    LegacyUtxoCoin(
      name: 'Dogecoin',
      symbol: 'DOGE',
      default_: 'DOGE',
      image: 'assets/dogecoin.png',
      blockExplorer:
          'https://live.blockcypher.com/doge/tx/$blockExplorerPlaceholder',
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
      geckoID: 'bitcoin-cash',
      rampID: 'BCH_BCH',
      payScheme: 'bitcoincash',
    ),
    // ZEC is receive-only — Sapling v4 transaction format is out of scope.
    // Balance and address derivation work; transferToken throws UnimplementedError.
    LegacyUtxoCoin(
      name: 'Zcash',
      symbol: 'ZEC',
      default_: 'ZEC',
      image: 'assets/zcash.png',
      blockExplorer:
          'https://blockexplorer.one/zcash/mainnet/tx/$blockExplorerPlaceholder',
      geckoID: 'zcash',
      rampID: '',
      payScheme: 'zcash',
    ),
  ];
}
