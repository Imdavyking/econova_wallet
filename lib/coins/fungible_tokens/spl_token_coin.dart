// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:solana/dto.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../service/wallet_service.dart';
import 'package:cryptowallet/coins/solana_coin.dart';

import '../../main.dart';
import 'package:solana/solana.dart' as solana;
import '../../utils/app_config.dart';

class SplTokenCoin extends SolanaCoin implements FTExplorer {
  String mint;
  int mintDecimals;

  SplTokenCoin({
    required String blockExplorer,
    required String symbol,
    required String default_,
    required String image,
    required String name,
    required String rpc,
    required String ws,
    required String geckoID,
    required this.mint,
    required this.mintDecimals,
  }) : super(
          rampID: '',
          payScheme: '',
          blockExplorer: blockExplorer,
          symbol: symbol,
          default_: default_,
          image: image,
          rpc: rpc,
          name: name,
          ws: ws,
          geckoID: geckoID,
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
    );
  }

  @override
  String tokenAddress() {
    return mint;
  }

  @override
  String? get badgeImage => solanaChains.first.image;

  @override
  String savedTransKey() {
    return 'solanaSplTokenTransfers$mint$rpc';
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
    data['mintDecimals'] = mintDecimals;

    return data;
  }

  @override
  Future listenForBalanceChange() async {
    final address = await getAddress();
    final subscription = getProxy().createSubscriptionClient();

    subscription.accountSubscribe(address).listen((Account event) {
      // final data = TokenInfo.decode(event);

      // CryptoNotificationsEventBus.instance.fire(
      //   CryptoNotificationEvent(
      //     body: 'ok ',
      //     title: 'cool',
      //   ),
      // );
    });
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
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'solanaSplAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final balanceInToken = await getUserBalance(address: address);
      await pref.put(key, balanceInToken);

      return balanceInToken;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<String> transferToken(String amount, String to, {String? memo}) async {
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

    final associatedRecipientAccount =
        await getProxy().getAssociatedTokenAccount(
      owner: toKey,
      mint: mintKey,
      commitment: solana.Commitment.finalized,
    );

    if (associatedRecipientAccount == null) {
      await getProxy().createAssociatedTokenAccount(
        mint: mintKey,
        funder: solanaKeyPair,
        owner: toKey,
        commitment: solana.Commitment.finalized,
      );
    }

    final signature = await getProxy().transferSplToken(
      mint: mintKey,
      destination: toKey,
      amount: tokenToSend.toInt(),
      owner: solanaKeyPair,
      memo: memo,
    );
    return signature;
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
  List<SplTokenCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      SplTokenCoin(
        name: 'USDC (Devnet)',
        symbol: 'USDC',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder?cluster=devnet',
        image: 'assets/wusd.png',
        rpc: 'https://api.devnet.solana.com',
        ws: 'wss://api.devnet.solana.com',
        mint: '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU',
        mintDecimals: 6,
        geckoID: 'usd-coin',
      ),
    );
  } else {
    blockChains.addAll([
      SplTokenCoin(
        name: 'USDC',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        mintDecimals: 6,
        geckoID: 'usd-coin',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder',
        rpc: 'https://solana-api.projectserum.com',
        ws: 'wss://solana-api.projectserum.com',
        mint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      ),
    ]);
  }
  return blockChains;
}
