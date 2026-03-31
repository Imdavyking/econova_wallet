// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/model/token_approvals.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/service/x402_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';
import 'package:flutter/material.dart';
import '../main.dart';

enum WalletType {
  bip39PhraseOrSeedHex,
  privateKey,
  viewKey,
}

abstract class Coin {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Coin) return false;
    final otherCoin = other;

    return otherCoin.getName() == getName() &&
        otherCoin.decimals() == decimals() &&
        otherCoin.getExplorer() == getExplorer() &&
        otherCoin.getDefault() == getDefault();
  }

  String normalizeAmountString(String amountString) {
    return amountString.replaceAll(',', '');
  }

  Future<({String key, String timeKey})?> approvalCacheKeys() async => null;
  bool get canAddCustomToken => false;
  Future<CustomTokenMeta?> fetchCustomToken(String contractAddress) async =>
      null;
  Future<Coin?> addCustomToken(
    CustomTokenMeta meta,
    String contractAddress,
  ) async =>
      null;
  Future<List<TokenApproval>>? getApprovals() => null;
  Future<bool>? revokeApproval(TokenApproval approval) => null;
  Future<String?>? testCreateApproval() => null;
  bool get haveTestAppproval => false;

  TransactionFetcher? get transactionFetcher => null;
  void validateAddress(String address);
  Future<String> addressExplorer();
  Map toJson();
  Future<double> getBalance(bool useCache);
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  });

  Coin? findToken(String symbolOrAddress) {
    if (symbolOrAddress.isEmpty) return null;
    final key = symbolOrAddress.toLowerCase();

    return networkTokens.firstWhereOrNull((t) {
      final sym = t.getSymbol().toLowerCase();
      final contract = t.tokenAddress()?.toLowerCase();

      // Exact symbol match — e.g. "usdc"
      if (sym == key) return true;

      // Exact contract address match — e.g. "0x036cbd..."
      if (contract != null && contract == key) return true;

      // Contract tail match — e.g. key "usdcx" matches ".usdcx"
      if (contract != null && contract.split('.').last == key) return true;

      // Key is a full contract identifier — match by tail
      // e.g. "ST1PQHQ....usdcx" → tail "usdcx" vs sym "usdcx"
      final keyTail = key.split('.').last;
      if (sym == keyTail) return true;
      if (contract != null && contract.split('.').last == keyTail) return true;

      return false;
    });
  }

  String getRampID();
  String getPayScheme();

  /// Sign an x402 payment for [option].
  ///
  /// [version] mirrors the `x402Version` field from the server's 402 response
  /// so each coin implementation can choose the correct typed-data schema:
  ///   0 – legacy draft  (same EIP-3009, legacy JSON key names)
  ///   1 – current spec  (default)
  ///   2 – extended spec (adds native-ETH path, Optimism/Arbitrum networks)
  Future<String?> signX402Payment(
    X402PaymentOption option, {
    int version = 1,
  }) async =>
      null;

  /// Returns true if this coin supports x402 payments.
  bool get supportsX402 => false;
  bool get supportKeystore => false;
  bool get supportPrivateKey => false;
  bool get supportBip39Seed => false;
  bool get isRpcWorking => true;

  Future<bool> needDeploy() async => false;
  Future deployAccount() async {}
  Future<Map> getTransactions() async {
    final address = await getAddress();
    return {
      'trx': jsonDecode(pref.get(savedTransKey())),
      'currentUser': address
    };
  }

  String getGeckoId();
  bool requireMemo() => false;

  Future<double> getMaxTransfer() async {
    return await getBalance(true);
  }

  Future<String?> resolveAddress(String address) async {
    return address;
  }

  String savedTransKey() => '${getExplorer()}${getDefault()} Details';
  Future<String?> stakeToken(String amount) async {
    return null;
  }

  String formatTxHash(String txHash) {
    return getExplorer().replaceFirst(blockExplorerPlaceholder, txHash);
  }

  Future<String?> unstakeToken(String amount) async => null;

  Future<String?> claimRewards(String amount) async => null;

  Future<double?> getTotalStaked() async => null;

  /// Returns null for this coin.
  /// Override in each coin implementation to point to the correct DEX.
  String? getSwapDappUrl() => null;

  /// Returns null for this coin.
  /// Override in each coin implementation to point to the correct staking dApp.
  String? getStakeDappUrl() => null;

  Future<String?> getQuote(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async =>
      null;

  Future<String?> swapTokens(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async =>
      null;

  Widget? getGoalPage() => null;

  Widget? getNFTPage() => null;
  Widget? getStakingPage() => null;

  int decimals();
  String getName();
  String getSymbol();
  String getExplorer();
  String getDefault();
  List<Coin> get networkTokens => [];

  Future<String> getAddress() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);
    return details.address;
  }

  Future<String?> getPublicKey() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);
    return details.publicKey;
  }

  static final Set<String> _dirtyKeys = {};

  static Future<void> flushCache() async {
    if (_dirtyKeys.isEmpty) return;
    await Future.wait(
      _dirtyKeys.map((k) {
        final entry = decodedCache[k];
        if (entry == null) return Future.value();
        return pref.put(k, jsonEncode(entry));
      }),
    );
    _dirtyKeys.clear();
  }

  static Future<AccountData> fromBip39PhraseOrSeedCached({
    required String cacheKey,
    required String bip39PhraseOrSeedHex,
    required Future<Map<String, dynamic>> Function() derive,
    Map<String, dynamic> Function(Map<String, dynamic> keys)? postProcess,
  }) async {
    AccountData toAccount(Map<String, dynamic> keys) {
      final processed = postProcess != null
          ? postProcess(
              Map<String, dynamic>.from(keys)) // copy only if mutating
          : keys; // no postProcess = no copy needed
      return AccountData.fromJson(processed);
    }

    // ── 1. memory cache hit ────────────────────────────────────────────────
    final memEntry = decodedCache[cacheKey];
    if (memEntry != null) {
      final hit = memEntry[bip39PhraseOrSeedHex];
      if (hit != null) return toAccount(Map<String, dynamic>.from(hit));
    }

    // ── 2. hive cache hit → warm memory cache ─────────────────────────────
    if (pref.containsKey(cacheKey)) {
      final decoded = Map<String, dynamic>.from(jsonDecode(pref.get(cacheKey)));
      decodedCache[cacheKey] = decoded;
      final hit = decoded[bip39PhraseOrSeedHex];
      if (hit != null) return toAccount(Map<String, dynamic>.from(hit));
    }

    // ── 3. cold path: derive keys ──────────────────────────────────────────
    final keys = await derive();

    // ── 4. persist to memory + hive (without address — postProcess is caller's concern) ──
    final entry = decodedCache[cacheKey] ??= {};
    entry[bip39PhraseOrSeedHex] = keys;
    _dirtyKeys.add(cacheKey);
    // await pref.put(cacheKey, jsonEncode(entry));

    return toAccount(keys);
  }

  String? getDexScreener(String tokenaddress) {
    return 'https://dexscreener.com/${getGeckoId()}/$tokenaddress';
  }

  Future<bool> get canTransfer async => true;

  Future<double> getTransactionFee(String amount, String to);

  String getImage();
  String? tokenAddress() => null;

  String? get badgeImage => null;

  Future<DeployMeme> deployMemeCoin({
    required String name,
    required String symbol,
    required String initialSupply,
  }) async {
    return const DeployMeme(
      liquidityTx: null,
      tokenAddress: null,
      deployTokenTx: null,
    );
  }

  Future<AccountData> importData(String data) async {
    if (WalletService.isBip39PhraseOrSeedHexKey()) {
      return fromBip39PhraseOrSeed(bip39PhraseOrSeedHex: data);
    } else if (WalletService.isViewKey()) {
      return Future.value(
        AccountData(
          address: data,
        ),
      );
    } else if (WalletService.isPrivateKey()) {
      return fromPrivateKey(data);
    }
    throw Exception('invalid data type');
  }

  Future<AccountData> fromBip39PhraseOrSeed(
      {required String bip39PhraseOrSeedHex});

  Future<AccountData> fromPrivateKey(String privateKey) async {
    throw UnimplementedError('private key derivation not implemented');
  }

  Future<double> getUserBalance({required String address});

  @override
  int get hashCode => super.hashCode + 0;
}

class AccountData {
  final String address;
  final String? privateKey;
  final String? publicKey;
  final String? hex_address;
  final String? tweakedPublicKey; // P2TR only — BIP341 tweaked x-only key

  AccountData({
    required this.address,
    this.privateKey,
    this.publicKey,
    this.hex_address,
    this.tweakedPublicKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'hex_address': hex_address,
      if (tweakedPublicKey != null) 'tweakedPublicKey': tweakedPublicKey,
    };
  }

  factory AccountData.fromJson(Map<dynamic, dynamic> json) {
    return AccountData(
      address: json['address'],
      privateKey: json['privateKey'],
      publicKey: json['publicKey'],
      hex_address: json['hex_address'],
      tweakedPublicKey: json['tweakedPublicKey'] as String?,
    );
  }
}

class DeployMeme {
  final String? liquidityTx;
  final String? tokenAddress;
  final String? deployTokenTx;

  const DeployMeme({
    required this.liquidityTx,
    required this.tokenAddress,
    required this.deployTokenTx,
  });
}

class CustomTokenMeta {
  final String name;
  final String symbol;
  final int decimals;
  final String? iconUrl;

  const CustomTokenMeta({
    required this.name,
    required this.symbol,
    required this.decimals,
    this.iconUrl,
  });
}
