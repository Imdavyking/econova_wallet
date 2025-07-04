// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:solana/dto.dart';

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
    required super.geckoID,
    required this.mint,
    required this.mintDecimals,
  }) : super(
          rampID: '',
          payScheme: '',
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

    subscription.accountSubscribe(address).listen((Account event) {});
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
    final key = 'solanaSplAddressBalance$address$rpc';

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
    //    export const MINTS: { [key in TokenID]: PublicKey } = {
//   [TokenID.APT]: new PublicKey('APTtJyaRX5yGTsJU522N4VYWg3vCvSb65eam5GrPT5Rt'),
//   [TokenID.BTC]: new PublicKey('9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E'),
//   [TokenID.ETH]: new PublicKey('2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk'),
//   [TokenID.SOL]: new PublicKey('So11111111111111111111111111111111111111112'),
//   [TokenID.mSOL]: new PublicKey('mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So'),
//   [TokenID.RAY]: new PublicKey('4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R'),
//   [TokenID.SRM]: new PublicKey('SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt'),
//   [TokenID.USDT]: new PublicKey('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB'),
//   [TokenID.USDC]: new PublicKey('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'),
//   [TokenID.UST]: new PublicKey('CXLBjMMcwkc17GfJtBos6rQCo1ypeH6eDbB82Kby4MRm'),
//   [TokenID.PAI]: new PublicKey('Ea5SjE2Y6yvCeW5dYTn7PYMuW5ikXkvbGdcmSnXeaLjS'),
//   [TokenID.SBR]: new PublicKey('Saber2gLauYim4Mvftnrasomsv6NvAuncvMEZwcLpD1'),
//   [TokenID.ORCA]: new PublicKey('orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE'),
//   [TokenID.USTv2]: new PublicKey('9vMJfxuKxXBoEa7rM12mYLMwTacLMLDJqHozw96WQL8i'),
//   [TokenID.MNDE]: new PublicKey('MNDEFzGvMt87ueuHvVU9VcTqsAP5b3fTGPsHuuPA5ey'),
//   [TokenID.FTT]: new PublicKey('AGFEad2et2ZJif9jaGpdMixQqvW5i81aBdvKe7PHNfz3'),
//   [TokenID.stSOL]: new PublicKey('7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj'),
//   [TokenID.whETH]: new PublicKey('7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs'),
//   [TokenID.scnSOL]: new PublicKey('5oVNBeEEQvYi1cX3ir8Dx5n1P7pdxydbGF2X4TxVusJm'),
// };
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
        rpc: 'https://api.mainnet-beta.solana.com',
        ws: 'wss://solana-api.projectserum.com',
        mint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      ),
    ]);
  }
  return blockChains;
}
