import 'package:flutter/material.dart';
import 'package:wallet_app/coins/ontology_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/app_config.dart';

class OntologyFungibleCoin extends OntologyCoin implements FTExplorer {
  OntologyFungibleCoin._({
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

  /// Inherits all network config from [parent] — only pass token-specific fields.
  factory OntologyFungibleCoin.fromParent({
    required OntologyCoin parent,
    required String symbol,
    required String default_,
    required String name,
    required String image,
    required String geckoID,
    required String contractAddress,
    required int coinDecimals,
  }) =>
      OntologyFungibleCoin._(
        // ── inherited from parent ──────────────────────────
        blockExplorer: parent.blockExplorer,
        rpcUrl: parent.rpcUrl,
        isTestnet_: parent.isTestnet_,
        caipReference: parent.caipReference,
        payScheme: parent.payScheme,
        rampID: parent.rampID,
        // ── token-specific ─────────────────────────────────
        symbol: symbol,
        default_: default_,
        name: name,
        image: image,
        geckoID: geckoID,
        contractAddress: contractAddress,
        coinDecimals: coinDecimals,
      );

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
  String savedTransKey() => 'ontologyFungibleTransfers$contractAddress$rpcUrl';

  @override
  Widget? getNFTPage() => null;
}

List<OntologyFungibleCoin> getOntologyFungibleCoins() {
  // Single source of truth — grab the already-constructed parent
  final parent = getOntologyBlockChains().first;

  return [
    OntologyFungibleCoin.fromParent(
      parent: parent,
      name: enableTestNet ? 'Ontology Gas (Testnet)' : 'Ontology Gas',
      symbol: 'ONG',
      default_: 'ONG',
      image: 'assets/ong.png',
      geckoID: 'ong',
      contractAddress: '0000000000000000000000000000000000000002',
      coinDecimals: 9,
    ),
  ];
}
