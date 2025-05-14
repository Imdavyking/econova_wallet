// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:hex/hex.dart';

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
import '../screens/view_multix_nfts.dart';
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
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

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

    return data;
  }

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
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'multivxDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = MultiversXDeriveArgs(
      mnemonic: mnemonic,
    );

    final keys = await compute(calculateMultiversXKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    multiversx.Address addressMul = multiversx.Address.fromBech32(address);

    multiversx.Account userAcct = multiversx.Account.withAddress(addressMul);

    userAcct = await userAcct.synchronize(getProxy());

    final base = BigInt.from(10);

    return userAcct.balance.value / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'multiversxAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      double fraction = await getUserBalance(address: address);
      await pref.put(key, fraction);

      return fraction;
    } catch (_) {
      return savedBalance;
    }
  }

  Future<String> trnsTok(_TrxCoinParams config) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    multiversx.UserSecretKey signer =
        multiversx.UserSecretKey(HEX.decode(response.privateKey!));
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

  static multiversx.Transaction signTransaction(Map config) {
    multiversx.ISigner signer = config['signer'];
    multiversx.ISignable transaction = config['transaction'];
    return signer.sign(transaction);
  }

  static List<int> signMessage(Map config) {
    multiversx.UserSecretKey signer = config['signer'];
    Uint8List message = config['message'];
    return signer.sign(message);
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final sendTransaction = await compute(
      trnsTok,
      _TrxCoinParams(
        to: to,
        amount: amount,
      ),
    );

    return sendTransaction;
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

List<MultiversxCoin> getEGLBBlockchains() {
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
  final String mnemonic;

  const MultiversXDeriveArgs({
    required this.mnemonic,
  });
}

Future calculateMultiversXKey(MultiversXDeriveArgs config) async {
  multiversx.Wallet wallet = await multiversx.Wallet.fromSeed(config.mnemonic);

  multiversx.UserSigner signer = wallet.signer as multiversx.UserSigner;

  return {
    'address': wallet.account.address.bech32,
    'privateKey': HEX.encode(signer.secretKey.bytes),
  };
}

class _TrxCoinParams {
  final String amount;
  final String to;
  const _TrxCoinParams({
    required this.amount,
    required this.to,
  });
}
