import 'package:flutter/material.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
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
    required this.mintDecimals,
  }) : super(
          rampID: '',
          payScheme: '',
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
  String? get badgeImage => starkNetCoins.first.image;
}

List<StarknetFungibleCoin> getStarknetFungibleCoins() {
  List<StarknetFungibleCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll([
      StarknetFungibleCoin(
        multiCallAddress:
            '0x01a33330996310a1e3fa1df5b16c1e07f0491fdd20c441126e02613b948f0225',
        blockExplorer: 'https://starkscan.co/tx/$blockExplorerPlaceholder',
        api: "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        tokenContractAddress: StarknetMainAddress.ethAddress,
        symbol: 'ETH (STRK)',
        name: 'Ethereum (STRK)',
        default_: 'STRK',
        image: 'assets/ethereum_logo.png',
        geckoID: "ethereum",
        useStarkToken: false,
        tokenClassHash:
            '0x063ee878d3559583ceae80372c6088140e1180d9893aa65fbefc81f45ddaaa17',
        factoryAddress:
            '0x01a46467a9246f45c8c340f1f155266a26a71c07bd55d36e8d1c7d0d438a2dbc',
        mintDecimals: 18,
      ),
    ]);
  } else {
    blockChains.addAll([
      StarknetFungibleCoin(
        multiCallAddress:
            '0x01a33330996310a1e3fa1df5b16c1e07f0491fdd20c441126e02613b948f0225',
        blockExplorer: 'https://starkscan.co/tx/$blockExplorerPlaceholder',
        api: "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        tokenContractAddress: StarknetMainAddress.ethAddress,
        symbol: 'ETH (STRK)',
        name: 'Ethereum (STRK)',
        default_: 'STRK',
        image: 'assets/ethereum_logo.png',
        geckoID: "ethereum",
        useStarkToken: false,
        tokenClassHash:
            '0x063ee878d3559583ceae80372c6088140e1180d9893aa65fbefc81f45ddaaa17',
        factoryAddress:
            '0x01a46467a9246f45c8c340f1f155266a26a71c07bd55d36e8d1c7d0d438a2dbc',
        mintDecimals: 18,
      ),
      StarknetFungibleCoin(
        name: 'USDC',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        multiCallAddress:
            '0x01a33330996310a1e3fa1df5b16c1e07f0491fdd20c441126e02613b948f0225',
        blockExplorer: 'https://starkscan.co/tx/$blockExplorerPlaceholder',
        api: "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        tokenContractAddress: StarknetMainAddress.usdcAddress,
        default_: 'STRK',
        useStarkToken: false,
        tokenClassHash:
            '0x063ee878d3559583ceae80372c6088140e1180d9893aa65fbefc81f45ddaaa17',
        factoryAddress:
            '0x01a46467a9246f45c8c340f1f155266a26a71c07bd55d36e8d1c7d0d438a2dbc',
        mintDecimals: 6,
      ),
    ]);
  }

  return blockChains;
}
