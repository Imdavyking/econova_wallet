// ignore_for_file: constant_identifier_names

import 'package:wallet_app/coins/fuse_4337_coin.dart';
import 'package:flutter/material.dart';

import '../../interface/ft_explorer.dart';
import 'package:wallet_app/utils/app_config.dart';

class FuseFungibleCoin extends FuseCoin implements FTExplorer {
  int mintDecimals;

  FuseFungibleCoin._({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.coinType,
    required super.rpc,
    required super.chainId,
    required super.name,
    required super.geckoID,
    required super.rampID,
    required super.contractAddress,
    required super.payScheme,
    required this.mintDecimals,
  });

  /// Inherits all network config from [parent] — only pass token-specific fields.
  factory FuseFungibleCoin.fromParent({
    required FuseCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String contractAddress,
    required int mintDecimals,
  }) =>
      FuseFungibleCoin._(
        // ── inherited from parent ──────────────────────────
        blockExplorer: parent.blockExplorer,
        rpc: parent.rpc,
        chainId: parent.chainId,
        coinType: parent.coinType,
        payScheme: parent.payScheme,
        rampID: parent.rampID,
        default_: parent.default_,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        contractAddress: contractAddress,
        mintDecimals: mintDecimals,
      );

  @override
  String tokenAddress() => contractAddress;

  @override
  Widget? getGoalPage() => null;

  @override
  int decimals() => mintDecimals;

  @override
  String? get badgeImage => getFUSEBlockchains().first.image;

  @override
  String contractExplorer() => getExplorer().replaceFirst(
        '/tx/$blockExplorerPlaceholder',
        '/token/${tokenAddress()}',
      );

  @override
  Widget? getStakingPage() => null;

  @override
  Future<String?> stakeToken(String amount) async => null;

  @override
  Future<String?> unstakeToken(String amount) async => null;
}

List<FuseFungibleCoin> getFUSEFTBlockchains() {
  if (enableTestNet) return [];
  final parent = getFUSEBlockchains().first;

  return [
    FuseFungibleCoin.fromParent(
      parent: parent,
      name: 'sFUSE',
      symbol: 'sFUSE',
      image: 'assets/sfuse.png',
      geckoID: 'liquid-staked-fuse',
      contractAddress: '0xb1DD0B683d9A56525cC096fbF5eec6E60FE79871',
      mintDecimals: 18,
    ),
    FuseFungibleCoin.fromParent(
      parent: parent,
      name: 'USDC',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      contractAddress: '0x620fd5fa44BE6af63715Ef4E65DDFA0387aD13F5',
      mintDecimals: 6,
    ),
    FuseFungibleCoin.fromParent(
      parent: parent,
      name: 'VoltToken',
      symbol: 'VOLT',
      image: 'assets/volt_token.png',
      geckoID: 'fusefi',
      contractAddress: '0x34Ef2Cc892a88415e9f02b91BfA9c91fC0bE6bD4',
      mintDecimals: 18,
    ),
  ];
}
