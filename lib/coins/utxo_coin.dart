// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';

import '../service/wallet_service.dart';
import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:bitbox/bitbox.dart' as bitbox;
import 'package:wallet_app/utils/pos_networks.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/segwit_tx.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/alt_ens.dart';
import '../utils/app_config.dart';

const bitCoinDecimals = 8;

// ─── API endpoints ────────────────────────────────────────────────────────────
const _ltcApi = 'https://litecoinspace.org/api';

class UtxoCoin extends Coin {
  NetworkType POSNetwork;
  bool isP2WPKH;
  String derivationPath;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  UtxoCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.isP2WPKH,
    required this.derivationPath,
    required this.POSNetwork,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory UtxoCoin.fromJson(Map<String, dynamic> json) {
    return UtxoCoin(
      POSNetwork: json['POSNetwork'],
      derivationPath: json['derivationPath'],
      isP2WPKH: json["P2WPKH"],
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
  bool get isRpcWorking => symbol == 'LTC';

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst('explorer/transactions/bch/', 'explorer/addresses/bch/')
        .replaceFirst('/transactions/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['POSNetwork'] = POSNetwork;
    data["P2WPKH"] = isP2WPKH;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['derivationPath'] = derivationPath;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    return data;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey =
        'bitcoinDetail$POSNetwork$default_${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = UtxoDeriveArgs(
      seedRoot: seedPhraseRoot,
      derivationPath: derivationPath,
      isP2WPKH: isP2WPKH,
      POSNetwork: POSNetwork,
      default_: default_,
    );

    final keys = await compute(calculateUtxoKey, args);
    mnemonicMap[mnemonic] = keys;
    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  @override
  Future<String?> resolveAddress(String address) async {
    final resolver = await udResolver(
      domainName: address,
      currency: getDefault(),
    );
    if (resolver['success']) return resolver['msg'];
    return null;
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    if (symbol == 'LTC') return _getLtcBalance(address);
    throw UnimplementedError(
      '$symbol balance not available — no free public API.',
    );
  }

  Future<double> _getLtcBalance(String address) async {
    try {
      final res = await http.get(Uri.parse('$_ltcApi/address/$address'));
      if (res.statusCode ~/ 100 == 2) {
        final stats =
            jsonDecode(res.body)['chain_stats'] as Map<String, dynamic>;
        final funded = stats['funded_txo_sum'] as int;
        final spent = stats['spent_txo_sum'] as int;
        return (funded - spent) / pow(10, 8);
      }
    } catch (_) {}

    // Fallback — blockcypher
    final res = await http.get(Uri.parse(
        'https://api.blockcypher.com/v1/ltc/main/addrs/$address/balance'));
    if (res.statusCode ~/ 100 != 2) throw Exception('LTC balance failed');
    return (jsonDecode(res.body)['final_balance'] as int) / pow(10, 8);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = '${symbol}AddressBalance$address';
    final storedBalance = pref.get(key);
    double savedBalance = storedBalance ?? 0.0;
    if (useCache) return savedBalance;
    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

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
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    if (symbol == 'LTC') return _sendLtc(amount, to);
    throw UnimplementedError(
        '$symbol send not available — no free public API.');
  }

  // ── LTC send (BIP141/143 manual serialization) ────────────────────────────
  Future<({String txHash, String? txRaw})> _sendLtc(
      String amount, String to) async {
    final satoshiToSend = amount.toBigIntDec(decimals()).toInt();
    if (satoshiToSend < 546) throw Exception('Amount below dust limit');

    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);
    final address = keyPair.address;

    // ── Fetch UTXOs ──────────────────────────────────────────────────────────
    final utxoRes = await http.get(Uri.parse('$_ltcApi/address/$address/utxo'));
    if (utxoRes.statusCode ~/ 100 != 2) {
      throw Exception('LTC UTXO fetch failed');
    }
    final utxos =
        (jsonDecode(utxoRes.body) as List).cast<Map<String, dynamic>>();
    if (utxos.isEmpty) throw Exception('No UTXOs available');

    // ── Fee rate ─────────────────────────────────────────────────────────────
    int feeRate = 5;
    try {
      final feeRes = await http.get(Uri.parse('$_ltcApi/v1/fees/recommended'));
      if (feeRes.statusCode ~/ 100 == 2) {
        feeRate = jsonDecode(feeRes.body)['halfHourFee'] as int;
      }
    } catch (_) {}

    int estimateFee(int inputs, int outputs) =>
        (inputs * 68 + outputs * 31 + 10) * feeRate;

    // ── Select UTXOs ─────────────────────────────────────────────────────────
    int totalIn = 0;
    final selected = <Map<String, dynamic>>[];
    for (final utxo in utxos) {
      selected.add(utxo);
      totalIn += utxo['value'] as int;
      if (totalIn >= satoshiToSend + estimateFee(selected.length, 2)) break;
    }

    final fee = estimateFee(selected.length, 2);
    if (totalIn < satoshiToSend + fee) {
      throw Exception('Insufficient LTC balance');
    }
    final change = totalIn - satoshiToSend - fee;

    if (kDebugMode) {
      print('LTC totalIn: $totalIn  fee: $fee  change: $change');
    }

    // ── Output scripts ───────────────────────────────────────────────────────
    // Witness program from bech32 decode IS already the hash160 — do not re-hash.
    final toScript = p2wpkhScript(
      Uint8List.fromList(const SegwitCodec().decode(to).program),
    );
    final changeScript = change > 546
        ? p2wpkhScript(
            Uint8List.fromList(const SegwitCodec().decode(address).program),
          )
        : null;

    // ── BIP143 shared hashes ─────────────────────────────────────────────────
    final privBytes = txDataToUintList(keyPair.privateKey!);

    final hashPrevouts = buildHashPrevouts(selected);
    final hashSequence = buildHashSequence(selected.length);
    final hashOutputs = buildHashOutputs(
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
    );

    // scriptCode is derived from our own pubkey — hash the pubkey, not an address
    final scriptCode = p2wpkhScriptCode(
      hash160(compressedPubKey(privBytes)),
    );

    // ── Sign each input ───────────────────────────────────────────────────────
    final witnesses = <List<Uint8List>>[];
    for (int i = 0; i < selected.length; i++) {
      final txid = HEX.decode(selected[i]['txid'] as String).reversed.toList();
      final preimage = bip143Preimage(
        hashPrevouts: hashPrevouts,
        hashSequence: hashSequence,
        txid: txid,
        vout: selected[i]['vout'] as int,
        scriptCode: scriptCode,
        value: selected[i]['value'] as int,
        hashOutputs: hashOutputs,
      );
      witnesses.add(buildInputWitness(
        privBytes: privBytes,
        sigHash: dsha256(preimage),
      ));
    }

    // ── Serialize & broadcast ─────────────────────────────────────────────────
    final txHex = buildSegwitTxHex(
      inputs: selected,
      satoshiToSend: satoshiToSend,
      toScript: toScript,
      change: change,
      changeScript: changeScript,
      witnesses: witnesses,
    );
    if (kDebugMode) print('LTC txHex: $txHex');

    final res = await http.post(
      Uri.parse('$_ltcApi/tx'),
      headers: {'Content-Type': 'text/plain'},
      body: txHex,
    );
    if (res.statusCode ~/ 100 != 2) {
      if (kDebugMode) print('LTC broadcast error: ${res.body}');
      throw Exception('LTC broadcast failed: ${res.body}');
    }

    return (txHash: res.body.trim(), txRaw: txHex);
  }

  @override
  validateAddress(String address) {
    if (default_ == 'BCH') {
      bitbox.Address.detectFormat(address);
      return;
    }
    if (Address.validateAddress(address, POSNetwork)) return;

    bool canReceivePayment = false;
    try {
      final base58DecodeRecipient = bs58check.decode(address);
      final pubHashString = base58DecodeRecipient[0].toRadixString(16) +
          base58DecodeRecipient[1].toRadixString(16);
      canReceivePayment =
          hexToInt(pubHashString).toInt() == POSNetwork.pubKeyHash;
    } catch (_) {}

    if (!canReceivePayment) {
      try {
        final Bech32 sel = bech32.decode(address);
        canReceivePayment = POSNetwork.bech32 == sel.hrp;
      } catch (_) {}
    }

    if (!canReceivePayment) throw Exception('Invalid $symbol address');
  }

  @override
  int decimals() => bitCoinDecimals;

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    if (symbol == 'LTC') {
      final address = await getAddress();
      final utxoRes =
          await http.get(Uri.parse('$_ltcApi/address/$address/utxo'));
      if (utxoRes.statusCode ~/ 100 != 2) return 0.0;
      final utxos = jsonDecode(utxoRes.body) as List;
      int feeRate = 5;
      try {
        final feeRes =
            await http.get(Uri.parse('$_ltcApi/v1/fees/recommended'));
        if (feeRes.statusCode ~/ 100 == 2) {
          feeRate = jsonDecode(feeRes.body)['halfHourFee'] as int;
        }
      } catch (_) {}
      final fee = (utxos.length.clamp(1, 5) * 68 + 2 * 31 + 10) * feeRate;
      return fee / pow(10, 8);
    }
    return 0.0;
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

// ─── Factory ──────────────────────────────────────────────────────────────────

List<UtxoCoin> getUtxoCoins() {
  if (enableTestNet) return [];

  return [
    UtxoCoin(
      name: 'Litecoin',
      symbol: 'LTC',
      default_: 'LTC',
      blockExplorer: 'https://litecoinspace.org/tx/$blockExplorerPlaceholder',
      image: 'assets/litecoin.png',
      POSNetwork: litecoin,
      isP2WPKH: true,
      derivationPath: "m/84'/2'/0'/0/0",
      geckoID: 'litecoin',
      rampID: 'LTC_LTC',
      payScheme: 'litecoin',
    ),
    // ── Dead APIs — commented out until free alternatives are found ───────────

    // BCH — rest.bitcoin.com DEAD, bitbox package calls dead API
    // Free alternative: fullstack.cash (requires signup)
    // UtxoCoin(
    //   symbol: 'BCH',
    //   name: 'BitcoinCash',
    //   default_: 'BCH',
    //   blockExplorer:
    //       'https://www.blockchain.com/explorer/transactions/bch/$blockExplorerPlaceholder',
    //   image: 'assets/bitcoin_cash.png',
    //   POSNetwork: bitcoincash,
    //   isP2WPKH: false,
    //   derivationPath: "m/44'/145'/0'/0/0",
    //   geckoID: 'bitcoin-cash',
    //   rampID: 'BCH_BCH',
    //   payScheme: 'bitcoincash',
    // ),

    // DASH — insight.dash.org DEAD, no free alternative
    // UtxoCoin(
    //   name: 'Dash',
    //   symbol: 'DASH',
    //   default_: 'DASH',
    //   blockExplorer:
    //       'https://live.blockcypher.com/dash/tx/$blockExplorerPlaceholder',
    //   image: 'assets/dash.png',
    //   POSNetwork: dash,
    //   isP2WPKH: false,
    //   derivationPath: "m/44'/5'/0'/0/0",
    //   geckoID: 'dash',
    //   rampID: '',
    //   payScheme: 'dash',
    // ),

    // ZEC — zecblockexplorer.com unreliable, no free alternative
    // UtxoCoin(
    //   name: 'ZCash',
    //   symbol: 'ZEC',
    //   default_: 'ZEC',
    //   blockExplorer:
    //       'https://blockexplorer.one/zcash/mainnet/tx/$blockExplorerPlaceholder',
    //   image: 'assets/zcash.png',
    //   POSNetwork: zcash,
    //   isP2WPKH: false,
    //   derivationPath: "m/44'/133'/0'/0/0",
    //   geckoID: 'zcash',
    //   rampID: '',
    //   payScheme: 'zcash',
    // ),

    // DOGE — dogechain.info DEAD, chain.so DEAD (moved to paid)
    // No reliable free public API currently
    // UtxoCoin(
    //   name: 'Dogecoin',
    //   symbol: 'DOGE',
    //   default_: 'DOGE',
    //   blockExplorer:
    //       'https://live.blockcypher.com/doge/tx/$blockExplorerPlaceholder',
    //   image: 'assets/dogecoin.png',
    //   POSNetwork: dogecoin,
    //   isP2WPKH: false,
    //   derivationPath: "m/44'/3'/0'/0/0",
    //   geckoID: 'dogecoin',
    //   rampID: 'DOGE_DOGE',
    //   payScheme: 'doge',
    // ),
  ];
}

// ─── Derive args & compute function ──────────────────────────────────────────

class UtxoDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final bool isP2WPKH;
  final NetworkType POSNetwork;
  final String default_;

  const UtxoDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.isP2WPKH,
    required this.POSNetwork,
    required this.default_,
  });
}

Map calculateUtxoKey(UtxoDeriveArgs config) {
  final seedRoot_ = config.seedRoot;
  final node = seedRoot_.root.derivePath(config.derivationPath);

  String address;
  if (config.isP2WPKH) {
    address = P2WPKH(
      data: PaymentData(pubkey: node.publicKey),
      network: config.POSNetwork,
    ).data.address!;
  } else {
    address = P2PKH(
      data: PaymentData(pubkey: node.publicKey),
      network: config.POSNetwork,
    ).data.address!;
  }

  if (config.default_ == 'BCH') {
    if (bitbox.Address.detectFormat(address) == bitbox.Address.formatLegacy) {
      address = bitbox.Address.toCashAddress(address).split(':')[1];
    }
  }

  if (config.default_ == 'ZEC') {
    final baddr = [...bs58check.decode(address)];
    baddr.removeAt(0);
    final taddr = Uint8List(22);
    taddr.setAll(2, baddr);
    taddr.setAll(0, [0x1c, 0xb8]);
    address = bs58check.encode(taddr);
  }

  return {
    'address': address,
    'privateKey': '0x${HEX.encode(node.privateKey!)}',
  };
}
