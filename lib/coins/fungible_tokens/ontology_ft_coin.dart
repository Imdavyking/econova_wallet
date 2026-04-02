import 'package:flutter/material.dart';
import 'package:wallet_app/coins/ontology_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/app_config.dart';

class OntologyFungibleCoin extends OntologyCoin implements FTExplorer {
  OntologyFungibleCoin({
    required super.blockExplorer,
    required super.rpcUrl,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.geckoID,
    required super.rampID,
    required super.payScheme,
    required super.contractAddress,
    required super.isTestnet_,
    required super.coinDecimals,
    required super.caipReference,
  });

  /// Badge shows the parent ONT chain logo (same pattern as ERC/SPL).
  @override
  String? get badgeImage => getChains<OntologyCoin>().first.image;

  @override
  String tokenAddress() => contractAddress;

  @override
  String contractExplorer() => getExplorer().replaceFirst(
        '/tx/$blockExplorerPlaceholder',
        '/address/$contractAddress',
      );

  @override
  String savedTransKey() =>
      'ontologyFungibleTransfers${contractAddress}$rpcUrl';

  @override
  Widget? getNFTPage() => null;
}

List<OntologyFungibleCoin> getOntologyFungibleCoins() {
  if (enableTestNet) {
    return [
      OntologyFungibleCoin(
        name: 'Ontology Gas (Testnet)',
        symbol: 'ONG',
        default_: 'ONG',
        blockExplorer:
            'https://explorer.ont.io/testnet/tx/$blockExplorerPlaceholder',
        image: 'assets/ong.png',
        rpcUrl: 'http://polaris1.ont.io:20336',
        geckoID: 'ong',
        rampID: '',
        payScheme: 'ontology',
        isTestnet_: true,
        coinDecimals: 9,
        contractAddress: '0000000000000000000000000000000000000002',
        caipReference: '2',
      ),
    ];
  }

  return [
    OntologyFungibleCoin(
      name: 'Ontology Gas',
      symbol: 'ONG',
      default_: 'ONG',
      blockExplorer: 'https://explorer.ont.io/tx/$blockExplorerPlaceholder',
      image: 'assets/ong.png',
      rpcUrl: 'http://dappnode1.ont.io:20336',
      geckoID: 'ong',
      rampID: '',
      payScheme: 'ontology',
      isTestnet_: false,
      coinDecimals: 9,
      contractAddress: '0000000000000000000000000000000000000002',
      caipReference: '1',
    ),
  ];
}
