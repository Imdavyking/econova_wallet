// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nanodart/nanodart.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/big_int_ext.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';

// Nano raw decimals: 1 NANO = 10^30 raw
const nanoDecimals = 30;

// Default representative (official Nano Foundation rep)
const _nanoRep =
    'nano_3arg3asgtigae3xckabaaewkx3bzsh7nwz7jkmjos79ihyaxwphhm6qgjps4';

class NanoCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String api;
  String geckoID;
  String rampID;
  String payScheme;

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
  int decimals() => nanoDecimals;
  @override
  String getGeckoId() => geckoID;
  @override
  String getPayScheme() => payScheme;
  @override
  String getRampID() => rampID;

  NanoCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory NanoCoin.fromJson(Map<String, dynamic> json) => NanoCoin(
        blockExplorer: json['blockExplorer'],
        symbol: json['symbol'],
        default_: json['default'],
        image: json['image'],
        name: json['name'],
        api: json['api'],
        geckoID: json['geckoID'],
        rampID: json['rampID'],
        payScheme: json['payScheme'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'blockExplorer': blockExplorer,
        'symbol': symbol,
        'default': default_,
        'image': image,
        'name': name,
        'api': api,
        'geckoID': geckoID,
        'rampID': rampID,
        'payScheme': payScheme,
      };

  // ── Address derivation ────────────────────────────────────────────────────

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'nanoCoinDetailsV${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = NanoDeriveArgs(seedRoot: seedPhraseRoot);
    final keys = await compute(calculateNanoKey, args);

    mnemonicMap[mnemonic] = keys;
    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  // ── Balance ───────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final response = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'account_balance',
        'account': address,
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('Nano balance failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data['error'] != null) return 0.0;

    final raw = BigInt.parse(data['balance'] as String);
    return raw / BigInt.from(10).pow(nanoDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'nanoBalance$address$api';
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

  // ── Fee ───────────────────────────────────────────────────────────────────

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.0;

  // ── Transfer ──────────────────────────────────────────────────────────────
  // Flow:
  //   1. account_info  → get frontier + current balance
  //   2. block_create  → node builds state block + does PoW (no phone CPU)
  //   3. Sign the block hash with ed25519+Blake2b locally (private key never sent)
  //   4. process       → broadcast

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);
    final address = details.address;
    final privateKeyHex = details.privateKey!.replaceFirst('0x', '');

    // 1. Get account info
    final infoRes = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'account_info',
        'account': address,
        'representative': true,
      }),
    );
    final infoData = jsonDecode(infoRes.body);
    final isNewAccount = infoData['error'] != null;

    final frontier = isNewAccount
        ? '0000000000000000000000000000000000000000000000000000000000000000'
        : infoData['frontier'] as String;

    final currentBalance = isNewAccount
        ? BigInt.zero
        : BigInt.parse(infoData['balance'] as String);

    final representative =
        isNewAccount ? _nanoRep : infoData['representative'] as String;

    final sendRaw = amount.toBigIntDec(nanoDecimals);
    final newBalance = currentBalance - sendRaw;
    if (newBalance < BigInt.zero) throw Exception('Insufficient balance');

    // 2. block_create — node does PoW, phone does nothing heavy.
    //    No 'key' field — private key never leaves the device.
    //    The node returns an unsigned block + hash; we sign locally below.
    final createRes = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'block_create',
        'type': 'state',
        'account': address,
        'previous': frontier,
        'representative': representative,
        'balance': newBalance.toString(),
        'destination': to,
      }),
    );

    final createData = jsonDecode(createRes.body);
    if (createData['error'] != null) {
      throw Exception('block_create failed: ${createData['error']}');
    }

    final blockHash = createData['hash'] as String;
    final block = createData['block'] as Map<String, dynamic>;

    // 3. Sign locally with ed25519+Blake2b via pure-Dart nanodart (no FFI)
    final sig = NanoSignatures.signBlock(
      blockHash,
      privateKeyHex.toUpperCase(),
    );
    block['signature'] = sig;

    // 4. Broadcast
    final processRes = await http.post(
      Uri.parse(api),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'process',
        'json_block': 'true',
        'subtype': 'send',
        'block': block,
      }),
    );

    final processData = jsonDecode(processRes.body);
    if (processData['error'] != null) {
      throw Exception('Nano broadcast failed: ${processData['error']}');
    }

    return (txHash: processData['hash'] as String, txRaw: null);
  }

  // ── Validate ──────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    if (!NanoAccounts.isValid(NanoAccountType.NANO, address)) {
      throw Exception('Invalid Nano address');
    }
  }

  // ── Explorer ──────────────────────────────────────────────────────────────

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/block/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }
}

// ── Key derivation ────────────────────────────────────────────────────────────
// Nano uses its OWN seed derivation — NOT BIP44/SLIP-0010:
//   privateKey[i] = blake2b_32(nanoSeed || index_as_uint32_be)
// The "nanoSeed" here is derived from the BIP39 seed bytes directly (first 32 bytes)

class NanoDeriveArgs {
  final SeedPhraseRoot seedRoot;
  const NanoDeriveArgs({required this.seedRoot});
}

Future<Map<String, dynamic>> calculateNanoKey(NanoDeriveArgs args) async {
  // Use first 32 bytes of BIP39 seed as Nano seed
  // This matches how most wallets (Natrium, Nault) handle BIP39→Nano
  final keyData = await ED25519_HD_KEY.derivePath(
    "m/44'/165'/0'",
    args.seedRoot.seed, // full 64-byte BIP39 seed
  );
  final privateKeyHex = HEX.encode(keyData.key).toUpperCase();

  // Public key + address via nanodart as before
  final publicKeyHex = NanoKeys.createPublicKey(privateKeyHex);
  final address =
      NanoAccounts.createAccount(NanoAccountType.NANO, publicKeyHex);

  return {
    'address': address,
    'privateKey': privateKeyHex.toLowerCase(),
  };
}

// ── Factory ───────────────────────────────────────────────────────────────────

List<NanoCoin> getNanoBlockChains() {
  if (enableTestNet) {
    return [
      NanoCoin(
        name: 'Nano (Testnet)',
        symbol: 'XNO',
        default_: 'XNO',
        image: 'assets/nano.png',
        blockExplorer:
            'https://nanoticker.info/block/$blockExplorerPlaceholder',
        api:
            'https://test-proxy.nanos.cc/proxy', // Nano Beta network public node
        geckoID: 'nano',
        rampID: '',
        payScheme: 'nano',
      )
    ];
  }
  return [
    NanoCoin(
      name: 'Nano',
      symbol: 'XNO',
      default_: 'XNO',
      image: 'assets/nano.png',
      blockExplorer: 'https://nanolooker.com/block/$blockExplorerPlaceholder',
      api: 'https://proxy.nanos.cc/proxy', // free public node, no API key
      geckoID: 'nano',
      rampID: '',
      payScheme: 'nano',
    ),
  ];
}
