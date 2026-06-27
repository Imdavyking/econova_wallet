// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;
import 'package:wallet_app/coins/stellar_coin.dart';
import 'package:wallet_app/interface/ft_explorer.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';

class StellarFungibleCoin extends StellarCoin implements FTExplorer {
  String issuer;
  String assetCode;
  int mintDecimals;

  StellarFungibleCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.sdk,
    required super.cluster,
    required super.geckoID,
    required super.caipReference,
    required this.issuer,
    required this.assetCode,
    required this.mintDecimals,
  }) : super(rampID: '', payScheme: '');

  /// Inherits network config from [parent] (sdk, cluster, explorer) — only
  /// pass asset-specific fields (code + issuer).
  factory StellarFungibleCoin.fromParent({
    required StellarCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required String issuer,
    required String assetCode,
    required int mintDecimals,
    String? blockExplorerOverride,
  }) =>
      StellarFungibleCoin(
        blockExplorer: blockExplorerOverride ?? parent.blockExplorer,
        sdk: parent.sdk,
        cluster: parent.cluster,
        caipReference: parent.caipReference,
        default_: parent.default_,
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        issuer: issuer,
        assetCode: assetCode,
        mintDecimals: mintDecimals,
      );

  factory StellarFungibleCoin.fromJson(Map<String, dynamic> json) {
    return StellarFungibleCoin(
      sdk: json['sdk'],
      cluster: json['cluster'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      caipReference: json['caipReference'],
      issuer: json['issuer'],
      assetCode: json['assetCode'],
      mintDecimals: json['mintDecimals'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['issuer'] = issuer;
    data['assetCode'] = assetCode;
    data['mintDecimals'] = mintDecimals;
    return data;
  }

  stellar.Asset get _asset {
    if (assetCode.length <= 4) {
      return stellar.AssetTypeCreditAlphaNum4(assetCode, issuer);
    } else {
      return stellar.AssetTypeCreditAlphaNum12(assetCode, issuer);
    }
  }

  @override
  String? tokenAddress() => issuer;

  @override
  String savedTransKey() => 'stellarAssetTransfers$assetCode$issuer';

  @override
  int decimals() => mintDecimals;

  @override
  Widget? getNFTPage() => null;

  @override
  String contractExplorer() {
    return getExplorer()
        .replaceFirst('/transactions/', '/accounts/')
        .replaceFirst(blockExplorerPlaceholder, issuer);
  }

  /// Checks whether the wallet's account already has a trustline for this
  /// asset. Stellar requires this before the account can hold or receive it.
  Future<bool> hasTrustline(String address) async {
    final account = await sdk.accounts.account(address);
    return account.balances.any(
      (b) => b.assetCode == assetCode && b.assetIssuer == issuer,
    );
  }

  /// Establishes a trustline (ChangeTrust operation) for this asset.
  Future<bool> establishTrustline() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final stellarDetails = await importData(data);
    final keyPair = stellar.KeyPair.fromSecretSeed(stellarDetails.privateKey!);

    final sender = await sdk.accounts.account(keyPair.accountId);

    final op = stellar.ChangeTrustOperationBuilder(
      _asset,
      "922337203685.4775807", // max trust limit
    ).build();

    final tx = stellar.TransactionBuilder(sender).addOperation(op).build();
    tx.sign(keyPair, cluster);

    final response = await sdk.submitTransaction(tx);
    return response.success;
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    if (!await hasTrustline(address)) {
      debugPrint('adding trust');
      await establishTrustline();
    }
    final account = await sdk.accounts.account(address);
    for (final balance in account.balances) {
      if (balance.assetCode == assetCode && balance.assetIssuer == issuer) {
        return double.parse(balance.balance);
      }
    }
    return 0;
  }

  @override
  String? get badgeImage => getStellarBlockChains().first.image;

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'stellarAssetBalance$address$assetCode$issuer';
    final storedBalance = pref.get(key);
    double savedBalance = storedBalance ?? 0;

    if (useCache) return savedBalance;

    try {
      final balance = await getUserBalance(address: address);
      await pref.put(key, balance);
      return balance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final stellarDetails = await importData(data);
    final senderKeyPair =
        stellar.KeyPair.fromSecretSeed(stellarDetails.privateKey!);

    final sender = await sdk.accounts.account(senderKeyPair.accountId);

    // Recipient must already have a trustline for this asset, or the
    // payment will fail on-chain (op_no_trust).
    final recipientHasTrustline = await hasTrustline(to);
    if (!recipientHasTrustline) {
      throw Exception(
        'Recipient has no trustline for $assetCode:$issuer — '
        'they must add this asset before they can receive it.',
      );
    }

    final operation = stellar.PaymentOperationBuilder(
      to,
      _asset,
      amount,
    ).build();

    final builder = stellar.TransactionBuilder(sender).addOperation(operation);
    if (memo != null) {
      builder.addMemo(stellar.Memo.text(memo));
    }

    final transaction = builder.build();
    transaction.sign(senderKeyPair, cluster);

    final txRaw = transaction.toEnvelopeXdrBase64();
    final response = await sdk.submitTransaction(transaction);

    if (response.success) {
      return (txHash: response.hash!, txRaw: txRaw);
    }
    throw Exception('could not send asset');
  }

  @override
  String getGeckoId() => geckoID;
}

List<StellarFungibleCoin> getStellarFungibleCoins() {
  final parent = getStellarBlockChains().first;

  if (enableTestNet) {
    return [
      StellarFungibleCoin.fromParent(
        parent: parent,
        name: 'USDC (Testnet)',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        issuer:
            'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5', // Circle testnet issuer
        assetCode: 'USDC',
        mintDecimals: 7, // Stellar assets use 7 decimal places internally
      ),
    ];
  }

  return [
    StellarFungibleCoin.fromParent(
      parent: parent,
      name: 'USDC',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      issuer:
          'GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN', // Circle mainnet issuer
      assetCode: 'USDC',
      mintDecimals: 7,
    ),
  ];
}
