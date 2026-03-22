// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:cardano_dart_types/cardano_dart_types.dart' hide Coin;
import 'package:cardano_flutter_sdk/cardano_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/utils/wallet_transaction.dart';
import 'package:wallet_app/fetchers/cardano_trx_fetcher.dart';
import '../extensions/big_int_ext.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const int _cardanoDecimals = 6;
const int _minUtxoLovelace = 1000000;
const int _estimatedTxFee = 200000;

const _blockfrostMainnet = 'https://cardano-mainnet.blockfrost.io/api/v0';
const _blockfrostPreprod = 'https://cardano-preprod.blockfrost.io/api/v0';

// ── Isolate args ──────────────────────────────────────────────────────────────

class CardanoDeriveArgs {
  final String mnemonic;
  final bool isTestnet;
  const CardanoDeriveArgs({required this.mnemonic, required this.isTestnet});
}

Future<Map<String, dynamic>> calculateCardanoKey(CardanoDeriveArgs args) async {
  final network = args.isTestnet ? NetworkId.testnet : NetworkId.mainnet;
  final wallet = await WalletFactory.fromMnemonic(
    network,
    args.mnemonic.split(' '),
  );

  final addrKit = await wallet.getPaymentAddressKit(addressIndex: 0);
  return {
    'address': addrKit.address.bech32Encoded,
  };
}

// ── CBOR unsigned transaction builder ─────────────────────────────────────────

String _buildUnsignedTxHex({
  required List<Map<String, dynamic>> utxos,
  required int lovelaceToSend,
  required String toAddress,
  required String changeAddress,
  required int fee,
  required int ttl,
}) {
  final change = utxos.fold<int>(0, (s, u) => s + (u['value'] as int)) -
      lovelaceToSend -
      fee;

  final inputs = CborList(
    utxos
        .map((u) => CborList([
              CborBytes(HEX.decode(u['tx_hash'] as String) as Uint8List),
              CborSmallInt(u['tx_index'] as int),
            ]))
        .toList(),
    tags: [258],
  );

  final toAddrBytes = _bech32ToBytes(toAddress);
  final changeAddrBytes = _bech32ToBytes(changeAddress);

  final outputs = <CborValue>[
    CborList([CborBytes(toAddrBytes), CborInt(BigInt.from(lovelaceToSend))]),
  ];
  if (change >= _minUtxoLovelace) {
    outputs.add(CborList([
      CborBytes(changeAddrBytes),
      CborInt(BigInt.from(change)),
    ]));
  }

  final txBody = CborMap({
    const CborSmallInt(0): inputs,
    const CborSmallInt(1): CborList(outputs),
    const CborSmallInt(2): CborInt(BigInt.from(fee)),
    const CborSmallInt(3): CborInt(BigInt.from(ttl)),
  });

  final tx = CborList([
    txBody,
    CborMap({}),
    const CborBool(true),
    const CborNull(),
  ]);

  return HEX.encode(cbor.encode(tx));
}

Uint8List _bech32ToBytes(String bech32Addr) {
  final addr = CardanoAddress.fromBech32(bech32Addr);
  return addr.bytes.toUint8List();
}

// ── CardanoCoin ───────────────────────────────────────────────────────────────

class CardanoCoin extends Coin {
  final bool isTestnet;
  final String blockFrostKey;
  final String blockExplorer;

  CardanoCoin({
    required this.isTestnet,
    required this.blockFrostKey,
    required this.blockExplorer,
  });

  String get _api => isTestnet ? _blockfrostPreprod : _blockfrostMainnet;
  Map<String, String> get _headers => {'project_id': blockFrostKey};
  NetworkId get _network => isTestnet ? NetworkId.testnet : NetworkId.mainnet;

  // ── Coin interface ──────────────────────────────────────────────────────────

  @override
  int decimals() => _cardanoDecimals;
  @override
  String getDefault() => 'ADA';
  @override
  String getExplorer() => blockExplorer;
  @override
  String getGeckoId() => 'cardano';
  @override
  String getImage() => 'assets/cardano.png';
  @override
  String getName() => isTestnet ? 'Cardano (Preprod)' : 'Cardano';
  @override
  String getPayScheme() => 'cardano';
  @override
  String getRampID() => isTestnet ? '' : 'ADA_ADA';
  @override
  String getSymbol() => 'ADA';
  @override
  bool get supportPrivateKey => false;
  @override
  String savedTransKey() => 'cardanoTxV4${isTestnet}_$blockFrostKey';

  @override
  TransactionFetcher? get transactionFetcher => CardanoTransactionFetcher(
        blockFrostKey: blockFrostKey,
        isTestnet: isTestnet,
      );

  // ── Serialization ───────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() => {
        'isTestnet': isTestnet,
        'blockFrostKey': blockFrostKey,
        'blockExplorer': blockExplorer,
        'type': 'CardanoCoin',
      };

  factory CardanoCoin.fromJson(Map<String, dynamic> json) => CardanoCoin(
        isTestnet: json['isTestnet'],
        blockFrostKey: json['blockFrostKey'],
        blockExplorer: json['blockExplorer'],
      );

  // ── Address ─────────────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final cacheKey = 'cardanoCoin${isTestnet}_${walletImportType.name}';
    Map<String, dynamic> cached = {};

    if (pref.containsKey(cacheKey)) {
      cached = Map<String, dynamic>.from(jsonDecode(pref.get(cacheKey)));
      if (cached.containsKey(mnemonic)) {
        return AccountData.fromJson(cached[mnemonic]);
      }
    }

    final keys = await compute(
      calculateCardanoKey,
      CardanoDeriveArgs(mnemonic: mnemonic, isTestnet: isTestnet),
    );

    cached[mnemonic] = keys;
    await pref.put(cacheKey, jsonEncode(cached));
    return AccountData.fromJson(keys);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transaction/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  void validateAddress(String address) {
    try {
      CardanoAddress.fromBech32(address);
    } catch (_) {
      throw Exception('Invalid Cardano address');
    }
  }

  // ── Balance ─────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(
      Uri.parse('$_api/addresses/$address'),
      headers: _headers,
    );
    if (res.statusCode == 404) return 0;
    if (res.statusCode ~/ 100 != 2) throw Exception('Balance fetch failed');

    final amounts = jsonDecode(res.body)['amount'] as List;
    final lovelace = amounts
        .where((e) => e['unit'] == 'lovelace')
        .fold<BigInt>(BigInt.zero, (s, e) => s + BigInt.parse(e['quantity']));

    return lovelace / BigInt.from(pow(10, _cardanoDecimals));
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'cardanoBalanceV4_$address';
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

  // ── Fee ─────────────────────────────────────────────────────────────────────

  @override
  Future<double> getTransactionFee(String amount, String to) async =>
      _estimatedTxFee / pow(10, _cardanoDecimals);

  // ── UTxOs ───────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getUtxos(String address) async {
    final res = await http.get(
      Uri.parse('$_api/addresses/$address/utxos'),
      headers: _headers,
    );
    if (res.statusCode == 404) return [];
    if (res.statusCode ~/ 100 != 2) throw Exception('UTxO fetch failed');

    return (jsonDecode(res.body) as List).map((e) {
      final lovelace = (e['amount'] as List)
          .where((a) => a['unit'] == 'lovelace')
          .fold<int>(0, (s, a) => s + int.parse(a['quantity'] as String));
      return {
        'tx_hash': e['tx_hash'],
        'tx_index': e['tx_index'],
        'value': lovelace,
      };
    }).toList();
  }

  Future<int> _getCurrentSlot() async {
    final res = await http.get(
      Uri.parse('$_api/blocks/latest'),
      headers: _headers,
    );
    if (res.statusCode ~/ 100 != 2) throw Exception('Slot fetch failed');
    return jsonDecode(res.body)['slot'] as int;
  }

  // ── Transfer ─────────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final lovelaceToSend = amount.toBigIntDec(_cardanoDecimals).toInt();
    if (lovelaceToSend < _minUtxoLovelace) {
      throw Exception('Minimum send is 1 ADA');
    }

    // data is the raw mnemonic string for phrase key wallets
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);
    final address = keyPair.address;

    final utxos = await _getUtxos(address);
    if (utxos.isEmpty) throw Exception('No UTxOs available');

    const fee = _estimatedTxFee;
    final ttl = await _getCurrentSlot() + 7200;

    final selected = <Map<String, dynamic>>[];
    int totalIn = 0;
    for (final utxo in utxos) {
      selected.add(utxo);
      totalIn += utxo['value'] as int;
      if (totalIn >= lovelaceToSend + fee) break;
    }
    if (totalIn < lovelaceToSend + fee) throw Exception('Insufficient balance');

    final unsignedTxHex = _buildUnsignedTxHex(
      utxos: selected,
      lovelaceToSend: lovelaceToSend,
      toAddress: to,
      changeAddress: address,
      fee: fee,
      ttl: ttl,
    );

    // Sign using cardano_flutter_sdk — must use fromMnemonic for correct Icarus derivation
    final wallet = await WalletFactory.fromMnemonic(
      _network,
      data.split(' '),
    );

    final parsedTx = CardanoTransaction.deserializeFromHex(unsignedTxHex);
    final witnessSet = await wallet.signTransaction(
      tx: parsedTx,
      witnessBech32Addresses: {address},
    );
    final signedTx = parsedTx.copyWithAdditionalSignatures(witnessSet);
    final signedTxHex = signedTx.serializeHexString();

    final res = await http.post(
      Uri.parse('$_api/tx/submit'),
      headers: {..._headers, 'Content-Type': 'application/cbor'},
      body: HEX.decode(signedTxHex),
    );

    if (res.statusCode ~/ 100 != 2) {
      if (kDebugMode) print('Cardano error: ${res.body}');
      throw Exception('Broadcast failed: ${res.body}');
    }

    final txHash = jsonDecode(res.body) as String;
    return (txHash: txHash, txRaw: signedTxHex);
  }
}

// ── Registry ──────────────────────────────────────────────────────────────────

List<CardanoCoin> getCardanoBlockChains() {
  if (enableTestNet) {
    return [
      CardanoCoin(
        isTestnet: true,
        blockFrostKey: 'preprodmpCaCFGCxLihVPPxXxqEvEnp7dyFmG6J',
        blockExplorer:
            'https://preprod.cardanoscan.io/transaction/$blockExplorerPlaceholder',
      ),
    ];
  }
  return [
    CardanoCoin(
      isTestnet: false,
      blockFrostKey: 'mainnetpgkQqXqQ4HjK6gzUKaHW6VU9jcmcKEbd',
      blockExplorer:
          'https://cardanoscan.io/transaction/$blockExplorerPlaceholder',
    ),
  ];
}
