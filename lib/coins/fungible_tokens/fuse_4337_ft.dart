// ignore_for_file: constant_identifier_names

import 'package:cryptowallet/coins/fuse_4337_coin.dart';
import 'package:flutter/material.dart';

import '../../interface/ft_explorer.dart';
import 'package:cryptowallet/utils/app_config.dart';

class FuseFungibleCoin extends FuseCoin implements FTExplorer {
  int mintDecimals;
  FuseFungibleCoin(
      {required String blockExplorer,
      required String symbol,
      required String default_,
      required String image,
      required int coinType,
      required String rpc,
      required int chainId,
      required String name,
      required String geckoID,
      required String rampID,
      required String contractAddress,
      required this.mintDecimals,
      required String payScheme})
      : super(
          blockExplorer: blockExplorer,
          symbol: symbol,
          default_: default_,
          image: image,
          coinType: coinType,
          rpc: rpc,
          chainId: chainId,
          name: name,
          geckoID: geckoID,
          rampID: rampID,
          contractAddress: contractAddress,
          payScheme: payScheme,
        );
  @override
  String tokenAddress() => contractAddress;

  @override
  Widget? getGoalPage() => null;

  @override
  int decimals() => mintDecimals;

  @override
  String get badgeImage => getFUSEBlockchains().first.image;
  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/tx/$blockExplorerPlaceholder',
      '/token/${tokenAddress()}',
    );
  }

  @override
  Widget? getStakingPage() => null;

  @override
  Future<String?> stakeToken(String amount) async {
    return null;
  }

  @override
  Future<String?> unstakeToken(String amount) async {
    return null;
  }
}

List<FuseFungibleCoin> getFUSEFTBlockchains() {
  List<FuseFungibleCoin> blockChains = [];

  blockChains.addAll([
    FuseFungibleCoin(
      name: 'sFUSE',
      rpc: 'https://rpc.fuse.io',
      chainId: 122,
      blockExplorer: 'https://explorer.fuse.io/tx/$blockExplorerPlaceholder',
      symbol: 'sFUSE',
      default_: 'FUSE',
      image: 'assets/sfuse.png',
      coinType: 60,
      geckoID: "liquid-staked-fuse",
      payScheme: 'fuse',
      rampID: '',
      contractAddress: '0xb1DD0B683d9A56525cC096fbF5eec6E60FE79871',
      mintDecimals: 18,
    ),
    FuseFungibleCoin(
      name: 'USDC',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      mintDecimals: 6,
      geckoID: 'usd-coin',
      rpc: 'https://rpc.fuse.io',
      chainId: 122,
      blockExplorer: 'https://explorer.fuse.io/tx/$blockExplorerPlaceholder',
      default_: 'FUSE',
      coinType: 60,
      payScheme: '',
      rampID: '',
      contractAddress: '0x620fd5fa44BE6af63715Ef4E65DDFA0387aD13F5',
    ),
    FuseFungibleCoin(
      name: 'VoltToken',
      symbol: 'VOLT',
      image: 'assets/volt_token.png',
      mintDecimals: 18,
      geckoID: 'fusefi',
      rpc: 'https://rpc.fuse.io',
      chainId: 122,
      blockExplorer: 'https://explorer.fuse.io/tx/$blockExplorerPlaceholder',
      default_: 'FUSE',
      coinType: 60,
      payScheme: '',
      rampID: '',
      contractAddress: '0x34Ef2Cc892a88415e9f02b91BfA9c91fC0bE6bD4',
    ),
  ]);

  return blockChains;
}
