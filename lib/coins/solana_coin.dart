// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:solana/dto.dart' hide AccountData;
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/utils/solana_meme.coin.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:solana_name_service/solana_name_service.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import 'package:solana/solana.dart' as solana;
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const solDecimals = 9;

class SolanaCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;
  String ws;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  bool requireMemo() => true;

  @override
  bool get supportPrivateKey => true;

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

  SolanaCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.ws,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory SolanaCoin.fromJson(Map<String, dynamic> json) {
    return SolanaCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      ws: json['ws'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
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
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'solanaDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final privateKeyBytes = HEX.decode(privateKey);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final keys = AccountData(
      address: keyPair.address,
      privateKey: privateKey,
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'solanaCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = SolanaArgs(
      seedRoot: seedPhraseRoot,
    );
    final keys = await compute(calculateSolanaKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  listenForBalanceChange() async {
    final address = await getAddress();
    final subscription = getProxy().createSubscriptionClient();

    subscription.accountSubscribe(address).listen((Account event) {
      // CryptoNotificationsEventBus.instance.fire(
      //   CryptoNotificationEvent(
      //     body: 'ok ',
      //     title: 'cool',
      //   ),
      // );
    });
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final lamports = await getProxy().rpcClient.getBalance(address);

    final base = BigInt.from(10);

    return BigInt.from(lamports.value) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'solanaAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double balanceInSol = await getUserBalance(address: address);
      await pref.put(key, balanceInSol);

      return balanceInSol;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<DeployMeme> deployMemeCoin({
    required String name,
    required String symbol,
    required String initialSupply,
  }) async {
    const imageUrl =
        "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg";
    const description = "A meme token created with Pump.fun";

    Map allCryptoPrice = jsonDecode(
      await getCryptoPrice(useCache: true),
    ) as Map;

    final Map cryptoMarket = allCryptoPrice[geckoID];

    final currPrice = cryptoMarket['usd'] as num;

    final options = PumpfunTokenOptions(
      initialLiquiditySol:
          1 / currPrice, // this determines how much LP is in the pool
      slippageBps: 500, // 5%
      priorityFee: 0,
    );
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final result = await PumpfunTokenManager.launchPumpfunToken(
      solanaClient: getProxy().rpcClient,
      wallet: keyPair,
      tokenName: name,
      tokenTicker: symbol,
      description: description,
      imageUrl: imageUrl,
      options: options,
    );

    return DeployMeme(
      liquidityTx: result.transactionHash,
      tokenAddress: result.mintAddress,
      deployTokenTx: result.transactionHash,
    );
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final lamportToSend = amount.toBigIntDec(solDecimals);
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final signature = await getProxy().transferLamports(
      source: keyPair,
      destination: solana.Ed25519HDPublicKey.fromBase58(to),
      lamports: lamportToSend.toInt(),
      memo: memo,
    );
    return signature;
  }

  @override
  validateAddress(String address) {
    solana.Ed25519HDPublicKey.fromBase58(address);
  }

  @override
  int decimals() {
    return solDecimals;
  }

  @override
  Future<String?> resolveAddress(String address) async {
    if (address.endsWith('.sol')) {
      address = address.substring(0, address.length - 4);
    }
    final publicKey = await findAccountByName(
      address,
      environment: SolanaEnvironment.mainnet,
    );

    if (publicKey == null) {
      return null;
    }

    return publicKey.toBase58();
  }

  solana.SolanaClient getProxy() {
    print('RPC: $rpc');
    return solana.SolanaClient(
      rpcUrl: Uri.parse(rpc),
      websocketUrl: Uri.parse(ws),
    );
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.000005; // TODO: Implement this method
    // final fees = await getProxy().rpcClient.getFeeForMessage(message);
    // return fees.feeCalculator.lamportsPerSignature / pow(10, solDecimals);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<SolanaCoin> getSolanaBlockChains() {
  List<SolanaCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      SolanaCoin(
        name: 'Solana(Devnet)',
        symbol: 'SOL',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder?cluster=devnet',
        image: 'assets/solana.webp',
        rpc: 'https://api.devnet.solana.com',
        ws: 'wss://api.devnet.solana.com',
        geckoID: 'solana',
        rampID: "SOLANA_SOL",
        payScheme: 'solana',
      ),
    );
  } else {
    blockChains.addAll([
      SolanaCoin(
        name: 'Solana',
        symbol: 'SOL',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder',
        image: 'assets/solana.webp',
        rpc: 'https://api.mainnet-beta.solana.com',
        ws: 'wss://api.mainnet-beta.solana.com',
        geckoID: 'solana',
        rampID: "SOLANA_SOL",
        payScheme: 'solana',
      ),
    ]);
  }
  return blockChains;
}

class SolanaArgs {
  final SeedPhraseRoot seedRoot;

  const SolanaArgs({
    required this.seedRoot,
  });
}

Future calculateSolanaKey(SolanaArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;

  final solana.Ed25519HDKeyPair keyPair =
      await solana.Ed25519HDKeyPair.fromSeedWithHdPath(
    seed: seedRoot_.seed,
    hdPath: "m/44'/501'/0'",
  );

  final keyPairData = await keyPair.extract();

  return {
    'address': keyPair.address,
    'privateKey': HEX.encode(keyPairData.bytes),
  };
}
