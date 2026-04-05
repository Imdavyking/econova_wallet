// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../service/wallet_service.dart';
import 'package:wallet_app/coins/solana_coin.dart';

import '../../main.dart';
import 'package:solana/solana.dart' as solana;
import '../../utils/app_config.dart';

class SplTokenCoin extends SolanaCoin implements FTExplorer {
  String mint;
  int mintDecimals;

  SplTokenCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.rpc,
    required super.ws,
    required super.chainId,
    required super.geckoID,
    required super.caipReference,
    required this.mint,
    required this.mintDecimals,
  }) : super(rampID: '', payScheme: '');

  /// Inherits all network config from [parent] — only pass token-specific fields.
  factory SplTokenCoin.fromParent({
    required SolanaCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String mint,
    required int mintDecimals,
  }) =>
      SplTokenCoin(
        // ── inherited from parent ──────────────────────────
        blockExplorer: parent.blockExplorer,
        rpc: parent.rpc,
        ws: parent.ws,
        caipReference: parent.caipReference,
        chainId: parent.chainId,
        default_: parent.default_,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        mint: mint,
        mintDecimals: mintDecimals,
      );

  factory SplTokenCoin.fromJson(Map<String, dynamic> json) {
    return SplTokenCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      ws: json['ws'],
      mint: json['mint'],
      mintDecimals: json['mintDecimals'],
      geckoID: json['geckoID'],
      chainId: json['chainId'],
      caipReference: json['caipReference'],
    );
  }

  @override
  String tokenAddress() {
    return mint;
  }

  @override
  String? get badgeImage => getSolanaBlockChains().first.image;

  @override
  String savedTransKey() {
    return 'solanaSplTokenTransfers$mint$rpc';
  }

  static const _splTokenMapKey = 'splCustomTokens';

  Future<bool> addCoinToStore() async {
    final uniqueKey = mint.toLowerCase();
    final raw = pref.get(_splTokenMapKey) as String?;
    final tokenMap = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw))
        : <String, dynamic>{};

    if (tokenMap.containsKey(uniqueKey)) return false;

    tokenMap[uniqueKey] = toJson();
    await pref.put(_splTokenMapKey, jsonEncode(tokenMap));
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['rpc'] = rpc;
    data['image'] = image;
    data['ws'] = ws;
    data['mint'] = mint;
    data['geckoID'] = geckoID;
    data['chainId'] = chainId;
    data['mintDecimals'] = mintDecimals;

    return data;
  }

  @override
  Widget? getNFTPage() => null;

  @override
  Future<double> getUserBalance({required String address}) async {
    final tokenAmount = await getProxy().getTokenBalance(
      owner: solana.Ed25519HDPublicKey.fromBase58(address),
      mint: solana.Ed25519HDPublicKey.fromBase58(mint),
    );
    return double.parse(tokenAmount.uiAmountString!);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'solanaSplAddressBalance$address$rpc$mint';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final balanceInToken = await getUserBalance(address: address);
      await pref.put(key, balanceInToken);

      return balanceInToken;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final tokenToSend = amount.toBigIntDec(mintDecimals);
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );
    solana.Ed25519HDKeyPair solanaKeyPair = keyPair;

    final mintKey = solana.Ed25519HDPublicKey.fromBase58(mint);
    final toKey = solana.Ed25519HDPublicKey.fromBase58(to);

    await findOrCreateTokenAccount(
      funder: solanaKeyPair,
      owner: toKey,
      mintKey: mintKey,
    );

    final txHash = await getProxy().transferSplToken(
      mint: mintKey,
      destination: toKey,
      amount: tokenToSend.toInt(),
      owner: solanaKeyPair,
      memo: memo,
    );
    return (
      txHash: txHash,
      txRaw: null,
    );
  }

  @override
  int decimals() {
    return mintDecimals;
  }

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/tx/$blockExplorerPlaceholder',
      '/address/${tokenAddress()}',
    );
  }

  @override
  String getGeckoId() => geckoID;
}

List<SplTokenCoin> getSplTokens() {
  final parent = getSolanaBlockChains().first;

  final List<SplTokenCoin> blockChains;

  if (enableTestNet) {
    blockChains = [
      SplTokenCoin.fromParent(
        parent: parent,
        name: 'USDC (Devnet)',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        mint: 'USDCoctVLVnvTXBEuP9s8hntucdJokbo17RwHuNXemT',
        mintDecimals: 6,
      ),
    ];
  } else {
    blockChains = [
      SplTokenCoin.fromParent(
        parent: parent,
        name: 'USDC',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        mint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
        mintDecimals: 6,
      ),
      SplTokenCoin.fromParent(
        parent: parent,
        name: 'Bonk',
        symbol: 'Bonk',
        image: 'assets/bonk-logo.png',
        geckoID: 'bonk',
        mint: 'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
        mintDecimals: 6,
      ),
    ];
  }

  final raw = pref.get(SplTokenCoin._splTokenMapKey) as String?;

  if (raw != null && WalletService.isBip39PhraseOrSeedHexKey()) {
    final saved = Map<String, dynamic>.from(jsonDecode(raw));
    blockChains.addAll(
      saved.values.map((e) => SplTokenCoin.fromJson(e as Map<String, dynamic>)),
    );
  }

  return blockChains;
}
