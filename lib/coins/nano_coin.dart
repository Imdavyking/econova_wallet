// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nanodart/nanodart.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'package:wallet_app/fetchers/nano_trx_fetcher.dart';

// 1 NANO / 1 BAN = 10^30 raw (both use the same raw unit)
const nanoDecimals = 30;

// Default representatives
const _nanoRep =
    'nano_3arg3asgtigae3xckabaaewkx3bzsh7nwz7jkmjos79ihyaxwphhm6qgjps4';

// ── Base class (shared logic for Nano-protocol coins) ─────────────────────────

class NanoBaseCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String api;
  String geckoID;
  String rampID;
  String payScheme;

  /// SLIP-0010 derivation path  e.g. "m/44'/165'/0'" or "m/44'/198'/0'"
  final String derivationPath;

  /// nanodart account type: NanoAccountType.NANO or NanoAccountType.BANANO
  final int accountType;

  /// Default representative for new / unopened accounts
  final String defaultRepresentative;

  /// Cache key prefix — must differ per coin so caches don't collide
  final String cachePrefix;

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

  @override
  String get caip2Namespace => 'nano';
  @override
  String get caip2Reference => 'nano';

  NanoBaseCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.derivationPath,
    required this.accountType,
    required this.defaultRepresentative,
    required this.cachePrefix,
  });

  // ── Serialisation ─────────────────────────────────────────────────────────

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
        'derivationPath': derivationPath,
        'accountType': accountType,
        'defaultRepresentative': defaultRepresentative,
        'cachePrefix': cachePrefix,
      };

  @override
  bool get supportBip39Seed => true;

  // ── Address derivation ────────────────────────────────────────────────────

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: '${cachePrefix}DetailsV1${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateNanoKey,
          NanoDeriveArgs(
            seedRoot: seedPhraseRoot,
            derivationPath: derivationPath,
            accountType: accountType,
          ),
        ),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $nanoApiKey',
      };

  Future<Map<String, dynamic>> _accountInfo(String address) async {
    final res = await http.post(
      Uri.parse(api),
      headers: _headers,
      body: jsonEncode({
        'action': 'account_info',
        'account': address,
        'representative': true,
      }),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Balance ───────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final response = await http.post(
      Uri.parse(api),
      headers: _headers,
      body: jsonEncode({
        'action': 'account_balance',
        'account': address,
      }),
    );

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('$name balance failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data['error'] != null) {
      debugPrint(data['message']);
      throw Exception('could not get balance');
    }

    // Include receivable so the user always sees their full incoming balance.
    // Pocketing happens lazily via receivePending().
    final confirmed = BigInt.parse(data['balance'] as String);
    final receivable = BigInt.parse(data['receivable'] as String? ?? '0');
    return (confirmed + receivable) / BigInt.from(10).pow(nanoDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = '${cachePrefix}Balance$address$api';
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

  // ── Transaction fetcher ───────────────────────────────────────────────────

  @override
  TransactionFetcher? get transactionFetcher => NanoTransactionFetcher(
        api: api,
        symbol: symbol,
        decimals: nanoDecimals,
        blockExplorer: blockExplorer,
      );

  // ── Fee ───────────────────────────────────────────────────────────────────

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0.0;

  // ── Receive pending ───────────────────────────────────────────────────────
  // Call explicitly on wallet open or before a send when balance is short.
  // Do NOT call inside getBalance — work_generate is rate-limited.

  Future<void> receivePending() async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final details = await importData(data);
      final address = details.address;
      final privateKeyHex = details.privateKey!.replaceFirst('0x', '');
      final publicKeyHex =
          NanoKeys.createPublicKey(privateKeyHex.toUpperCase());

      // 1. Fetch all receivable block hashes
      final receivableRes = await http.post(
        Uri.parse(api),
        headers: _headers,
        body: jsonEncode({
          'action': 'receivable',
          'account': address,
          'count': '32',
          'source': 'true',
        }),
      );
      final receivableData = jsonDecode(receivableRes.body);
      final blocks = receivableData['blocks'];
      if (blocks == null ||
          blocks is String ||
          blocks is List ||
          (blocks as Map).isEmpty) return;

      for (final entry in (blocks as Map<String, dynamic>).entries) {
        final pendingHash = entry.key;
        final pendingAmount = BigInt.parse(entry.value['amount'] as String);

        // 2. Fresh account state (may change block-by-block)
        final infoData = await _accountInfo(address);
        final isNew = infoData['error'] != null;

        final frontier = isNew
            ? '0000000000000000000000000000000000000000000000000000000000000000'
            : infoData['frontier'] as String;
        final currentBalance =
            isNew ? BigInt.zero : BigInt.parse(infoData['balance'] as String);
        final representative = isNew
            ? defaultRepresentative
            : infoData['representative'] as String;

        final newBalance = currentBalance + pendingAmount;

        // 3. Build block hash locally
        final blockHash = NanoBlocks.computeStateHash(
          accountType,
          address,
          frontier,
          representative,
          newBalance,
          pendingHash,
        );

        // 4. Sign locally — private key never leaves device
        final signature = NanoSignatures.signBlock(
          blockHash,
          privateKeyHex.toUpperCase(),
        );

        // 5. PoW on node
        final workRes = await http.post(
          Uri.parse(api),
          headers: _headers,
          body: jsonEncode({
            'action': 'work_generate',
            'hash': isNew ? publicKeyHex : frontier,
          }),
        );
        final workData = jsonDecode(workRes.body);
        if (workData['error'] != null) {
          debugPrint('work_generate failed: ${workData['error']}');
          continue;
        }
        final work = workData['work'] as String;

        // 6. Broadcast
        final processRes = await http.post(
          Uri.parse(api),
          headers: _headers,
          body: jsonEncode({
            'action': 'process',
            'json_block': 'true',
            'subtype': 'receive',
            'block': {
              'type': 'state',
              'account': address,
              'previous': frontier,
              'representative': representative,
              'balance': newBalance.toString(),
              'link': pendingHash,
              'signature': signature,
              'work': work,
            },
          }),
        );
        final processData = jsonDecode(processRes.body);
        if (processData['error'] != null) {
          debugPrint('process failed: ${processData['error']}');
        }
      }
    } catch (e, sk) {
      debugPrint('receivePending error: $e $sk');
    }
  }

  // ── Transfer ──────────────────────────────────────────────────────────────

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
    final infoData = await _accountInfo(address);
    final isNewAccount = infoData['error'] != null;

    var frontier = isNewAccount
        ? '0000000000000000000000000000000000000000000000000000000000000000'
        : infoData['frontier'] as String;
    var currentBalance = isNewAccount
        ? BigInt.zero
        : BigInt.parse(infoData['balance'] as String);
    var representative = isNewAccount
        ? defaultRepresentative
        : infoData['representative'] as String;

    final sendRaw = amount.toBigIntDec(nanoDecimals);

    // Fast pre-check using cached balance (confirmed + receivable).
    final cachedBalance = await getBalance(true);
    if (cachedBalance < double.parse(amount)) {
      throw Exception('Insufficient balance');
    }

    // Only pocket pending if confirmed balance alone can't cover the send —
    // avoids an unnecessary work_generate call on every transfer.
    if (currentBalance < sendRaw) {
      await receivePending();

      // Re-fetch after pocketing
      final refreshData = await _accountInfo(address);
      if (refreshData['error'] == null) {
        frontier = refreshData['frontier'] as String;
        currentBalance = BigInt.parse(refreshData['balance'] as String);
        representative = refreshData['representative'] as String;
      }
    }

    final newBalance = currentBalance - sendRaw;
    if (newBalance < BigInt.zero) throw Exception('Insufficient balance');

    // 2. Build block hash locally
    final blockHash = NanoBlocks.computeStateHash(
      accountType,
      address,
      frontier,
      representative,
      newBalance,
      to,
    );

    // 3. Sign locally — private key never leaves device
    final signature = NanoSignatures.signBlock(
      blockHash,
      privateKeyHex.toUpperCase(),
    );

    // 4. PoW on node
    final workRes = await http.post(
      Uri.parse(api),
      headers: _headers,
      body: jsonEncode({
        'action': 'work_generate',
        'hash': frontier,
      }),
    );
    final workData = jsonDecode(workRes.body);
    if (workData['error'] != null) {
      throw Exception('work_generate failed: ${workData['message']}');
    }
    final work = workData['work'] as String;

    // 5. Broadcast
    final processRes = await http.post(
      Uri.parse(api),
      headers: _headers,
      body: jsonEncode({
        'action': 'process',
        'json_block': 'true',
        'subtype': 'send',
        'block': {
          'type': 'state',
          'account': address,
          'previous': frontier,
          'representative': representative,
          'balance': newBalance.toString(),
          'link': to,
          'signature': signature,
          'work': work,
        },
      }),
    );

    final processData = jsonDecode(processRes.body);
    if (processData['error'] != null) {
      throw Exception('$name broadcast failed: ${processData['error']}');
    }

    return (txHash: processData['hash'] as String, txRaw: null);
  }

  // ── Validate ──────────────────────────────────────────────────────────────

  @override
  void validateAddress(String address) {
    if (!NanoAccounts.isValid(accountType, address)) {
      throw Exception('Invalid $name address');
    }
  }

  // ── Explorer ──────────────────────────────────────────────────────────────

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/blocks/', '/accounts/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }
}

// ── Nano ──────────────────────────────────────────────────────────────────────

class NanoCoin extends NanoBaseCoin {
  NanoCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.api,
    required super.geckoID,
    required super.rampID,
    required super.payScheme,
  }) : super(
          derivationPath: "m/44'/165'/0'",
          accountType: NanoAccountType.NANO,
          defaultRepresentative: _nanoRep,
          cachePrefix: 'nano',
        );

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
}
// ── Key derivation ────────────────────────────────────────────────────────────

class NanoDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final String derivationPath;
  final int accountType;

  const NanoDeriveArgs({
    required this.seedRoot,
    required this.derivationPath,
    required this.accountType,
  });
}

Future<Map<String, dynamic>> calculateNanoKey(NanoDeriveArgs args) async {
  // SLIP-0010 ed25519 derivation
  // Nano:   m/44'/165'/0'  (coin type 165)
  // Banano: m/44'/198'/0'  (coin type 198)
  final keyData = await ED25519_HD_KEY.derivePath(
    args.derivationPath,
    args.seedRoot.seed, // full 64-byte BIP39 seed
  );

  final privateKeyHex = HEX.encode(keyData.key).toUpperCase();
  final publicKeyHex = NanoKeys.createPublicKey(privateKeyHex);
  final address = NanoAccounts.createAccount(args.accountType, publicKeyHex);

  return {
    'address': address,
    'privateKey': privateKeyHex.toLowerCase(),
  };
}

// ── Factories ─────────────────────────────────────────────────────────────────

List<NanoCoin> getNanoBlockChains() {
  return [
    NanoCoin(
      name: 'Nano',
      symbol: 'XNO',
      default_: 'XNO',
      image: 'assets/nano.png',
      blockExplorer:
          'https://nanexplorer.com/nano/blocks/$blockExplorerPlaceholder',
      api: 'https://rpc.nano.to',
      geckoID: 'nano',
      rampID: '',
      payScheme: 'nano',
    ),
  ];
}
