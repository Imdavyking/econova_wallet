// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:wallet_app/coins/fungible_tokens/esdt_ft_coin.dart';
import 'package:wallet_app/model/seed_phrase_root.dart';
import 'package:wallet_app/screens/view_nft_screens.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:multiversx_sdk/multiversx.dart' as multiversx;
import 'package:web3dart/crypto.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/multix_resolver.dart';
import '../utils/app_config.dart';

const multiversxDecimals = 18;

final dio = Dio();

class MultiversxCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;
  String? nftApi;
  String geckoID;
  String rampID;
  String payScheme;
  String caipReference;

  multiversx.ProxyProvider getProxy() {
    return multiversx.ProxyProvider(
      addressRepository: multiversx.AddressRepository(dio, baseUrl: rpc),
      networkRepository: multiversx.NetworkRepository(dio, baseUrl: rpc),
      transactionRepository: multiversx.TransactionRepository(
        dio,
        baseUrl: rpc,
      ),
    );
  }

  @override
  String getExplorer() => blockExplorer;

  @override
  String getDefault() => default_;

  @override
  String getImage() => image;

  @override
  String getName() => name;

  @override
  String getSymbol() => symbol;

  @override
  String get caip2Namespace => 'mvx';
  @override
  String get caip2Reference => caipReference;

  @override
  List<Coin> get networkTokens => getESDTCoins();

  MultiversxCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.caipReference,
    this.nftApi,
  });

  factory MultiversxCoin.fromJson(Map<String, dynamic> json) {
    return MultiversxCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      nftApi: json['nftApi'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      caipReference: json['caipReference'],
    );
  }

  @override
  Future<String?> resolveAddress(String address) async {
    try {
      final result = await get(Uri.parse('$nftApi/usernames/$address'));
      MultiversxResolver resolver =
          MultiversxResolver.fromJson(json.decode(result.body));
      return resolver.address;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget? getNFTPage() => ViewMultixNFTs(coin: this);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['rpc'] = rpc;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['caipReference'] = caipReference;

    return data;
  }

  @override
  bool get supportBip39Seed => true;

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'mutliversxDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final address = egldPrivateKeyToAddress(privateKey);

    final keys = AccountData(
      address: address,
      privateKey: privateKey,
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'multivxDetail${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateMultiversXKey,
          MultiversXDeriveArgs(
            seedRoot: seedPhraseRoot,
          ),
        ),
      );

  @override
  Future<double> getUserBalance({required String address}) async {
    multiversx.Address addressMul = multiversx.Address.fromBech32(address);

    multiversx.Account userAcct = multiversx.Account.withAddress(addressMul);

    userAcct = await userAcct.synchronize(getProxy());

    final base = BigInt.from(10);

    return userAcct.balance.value / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'multiversxAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double fraction = await getUserBalance(address: address);
      await pref.put(key, fraction);

      return fraction;
    } catch (_) {
      return savedBalance;
    }
  }

  Future<String> _sendEgld(TrxCoinParams config) async {
    multiversx.UserSecretKey signer =
        multiversx.UserSecretKey(HEX.decode(config.privateKey));
    multiversx.Wallet wallet = multiversx.Wallet(signer);

    await wallet.synchronize(getProxy());

    String amt = config.amount;

    final amount = amt.toBigIntDec(decimals());

    final txHash = await wallet.sendEgld(
      provider: getProxy(),
      to: multiversx.Address.fromBech32(config.to),
      amount: multiversx.Balance(amount),
    );

    return txHash.hash;
  }

  static multiversx.Transaction signTransaction(
      MultiversDappTransaction config) {
    multiversx.ISigner signer = config.signer;
    multiversx.ISignable transaction = config.transaction;
    return signer.sign(transaction);
  }

  static List<int> signMessage(MultiversDappMessage config) {
    multiversx.UserSecretKey signer = config.signer;
    Uint8List message = config.message;
    return signer.sign(message);
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final sendTransaction = await compute(
      _sendEgld,
      TrxCoinParams(to: to, amount: amount, privateKey: response.privateKey!),
    );

    return (
      txHash: sendTransaction,
      txRaw: null,
    );
  }

  static Uint8List serializeForSigning(String message) {
    Uint8List message_ = ascii.encode(message);
    Uint8List messgSize = ascii.encode(message_.length.toString());

    Uint8List prefix = hexToBytes(
      "17456c726f6e64205369676e6564204d6573736167653a0a",
    );

    return keccak256(Uint8List.fromList(prefix + messgSize + message_));
  }

  @override
  validateAddress(String address) {
    multiversx.Address.fromBech32(address);
  }

  @override
  int decimals() {
    return multiversxDecimals;
  }

  @override
  String savedTransKey() {
    return '$default_$rpc Details';
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.00005;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transactions/', '/accounts/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<MultiversxCoin> getEGLDBlockchains() {
  List<MultiversxCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      MultiversxCoin(
        name: 'MultiversX(Testnet)',
        symbol: 'EGLD',
        default_: 'EGLD',
        blockExplorer:
            'https://testnet-explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/multiversx.webp',
        rpc: 'https://testnet-gateway.multiversx.com/',
        nftApi: 'https://testnet-api.multiversx.com',
        geckoID: "elrond-erd-2",
        payScheme: 'elrond',
        rampID: 'ELROND_EGLD',
        caipReference: 'T',
      ),
    );
  } else {
    blockChains.addAll([
      MultiversxCoin(
        name: 'MultiversX',
        symbol: 'EGLD',
        default_: 'EGLD',
        blockExplorer:
            'https://explorer.multiversx.com/transactions/$blockExplorerPlaceholder',
        image: 'assets/multiversx.webp',
        rpc: 'https://gateway.multiversx.com/',
        nftApi: 'https://api.multiversx.com',
        geckoID: "elrond-erd-2",
        payScheme: 'elrond',
        rampID: 'ELROND_EGLD',
        caipReference: '1',
      ),
    ]);
  }

  return blockChains;
}

String egldPrivateKeyToAddress(String privateKey) {
  multiversx.UserSecretKey signer =
      multiversx.UserSecretKey(HEX.decode(privateKey));
  multiversx.Wallet wallet = multiversx.Wallet(signer);
  return wallet.account.address.bech32;
}

class MultiversXDeriveArgs {
  final SeedPhraseRoot seedRoot;

  const MultiversXDeriveArgs({
    required this.seedRoot,
  });
}

Future<Map<String, dynamic>> calculateMultiversXKey(
  MultiversXDeriveArgs config,
) async {
  const bip44DerivationPrefix = "m/44'/508'/0'/0'";
  int addressIndex = 0;
  final data = await ED25519_HD_KEY.derivePath(
      "$bip44DerivationPrefix/$addressIndex'", config.seedRoot.seed);
  final privateKey = multiversx.UserSecretKey(data.key);
  final publicKey = privateKey.generatePublicKey();
  final address = publicKey.toAddress();

  return {
    'address': address.bech32,
    'privateKey': HEX.encode(privateKey.bytes),
  };
}

class TrxCoinParams {
  final String amount;
  final String to;
  final String privateKey;
  const TrxCoinParams({
    required this.amount,
    required this.to,
    required this.privateKey,
  });
}

class MultiversDappMessage {
  final multiversx.UserSecretKey signer;
  final Uint8List message;
  const MultiversDappMessage({
    required this.signer,
    required this.message,
  });
}

class MultiversDappTransaction {
  final multiversx.ISigner signer;
  final multiversx.ISignable transaction;
  const MultiversDappTransaction({
    required this.signer,
    required this.transaction,
  });
}
