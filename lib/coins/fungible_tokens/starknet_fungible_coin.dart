import 'package:flutter/material.dart';
import 'package:wallet_app/coins/stack_coin.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/utils/app_config.dart';

class StarknetFungibleCoin extends StarknetCoin implements FTExplorer {
  int mintDecimals;

  StarknetFungibleCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.geckoID,
    required super.api,
    required super.classHash,
    required super.tokenContractAddress,
    required super.useStarkToken,
    required super.multiCallAddress,
    required super.factoryAddress,
    required super.tokenClassHash,
    required super.caipReference,
    required this.mintDecimals,
  }) : super(
          rampID: '',
          payScheme: '',
        );

  /// Inherits all network infrastructure from [parent] — only pass
  /// token-specific fields. Use [blockExplorerOverride] when a token uses a
  /// different explorer than the parent chain (e.g. Starkscan vs Voyager).
  factory StarknetFungibleCoin.fromParent({
    required StarknetCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String tokenContractAddress,
    required int mintDecimals,
    String? blockExplorerOverride,
  }) =>
      StarknetFungibleCoin(
        // ── inherited from parent ──────────────────────────
        blockExplorer: blockExplorerOverride ?? parent.blockExplorer,
        api: parent.api,
        classHash: parent.classHash,
        tokenClassHash: parent.tokenClassHash,
        factoryAddress: parent.factoryAddress,
        multiCallAddress: parent.multiCallAddress,
        caipReference: parent.caipReference,
        default_: parent.default_,
        useStarkToken: false, // always false for fungible tokens
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        tokenContractAddress: tokenContractAddress,
        mintDecimals: mintDecimals,
      );

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/tx/$blockExplorerPlaceholder',
      '/contract/${tokenAddress()}',
    );
  }

  @override
  String savedTransKey() {
    return 'starknetTokenTransfers$tokenContractAddress$api';
  }

  @override
  int decimals() => mintDecimals;

  @override
  Widget? getNFTPage() => null;

  @override
  String? tokenAddress() => tokenContractAddress;

  @override
  String? get badgeImage => getStacksBlockchains().first.image;
}

List<StarknetFungibleCoin> getStarknetFungibleCoins() {
  final parent = getStarknetBlockchains().first;

  if (enableTestNet) {
    return [
      StarknetFungibleCoin.fromParent(
        parent: parent,
        name: 'Ethereum (STRK)',
        symbol: 'ETH (STRK)',
        image: 'assets/ethereum_logo.png',
        geckoID: 'ethereum',
        tokenContractAddress: StarknetMainAddress.ethAddress,
        mintDecimals: 18,
      ),
    ];
  }

  return [
    StarknetFungibleCoin.fromParent(
      parent: parent,
      name: 'Ethereum (STRK)',
      symbol: 'ETH (STRK)',
      image: 'assets/ethereum_logo.png',
      geckoID: 'ethereum',
      tokenContractAddress: StarknetMainAddress.ethAddress,
      mintDecimals: 18,
      // ETH(STRK) uses voyager — same as parent, no override needed
    ),
    StarknetFungibleCoin.fromParent(
      parent: parent,
      name: 'USDC',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      tokenContractAddress: StarknetMainAddress.usdcAddress,
      mintDecimals: 6,
      blockExplorerOverride:
          'https://starkscan.co/tx/$blockExplorerPlaceholder',
    ),
  ];
}
