// ignore_for_file: non_constant_identifier_names

import 'package:agent_dart/agent_dart.dart';
import 'package:agent_dart/wallet/ledger.dart';
import 'package:flutter/foundation.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../extensions/big_int_ext.dart';

const icpDecimals = 8;

class ICPCoin extends Coin {
  String api;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;
  String canisterID;

  ICPCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.payScheme,
    required this.rampID,
    required this.canisterID,
  });

  factory ICPCoin.fromJson(Map<String, dynamic> json) {
    return ICPCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      canisterID: json['canisterID'],
    );
  }

  @override
  bool requireMemo() => true;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['payScheme'] = payScheme;
    data['rampID'] = rampID;
    data['canisterID'] = canisterID;

    return data;
  }

  @override
  bool get supportBip39Seed => true;

  @override
  String get caip2Namespace => 'icp';
  @override
  String get caip2Reference => '737ba355e855bd4b61f5f5c522f2a6d3';

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'ICPDetails${walletImportType.name}$api',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateICPKey,
          ICPDeriveArgs(
            seedRoot: seedPhraseRoot,
          ),
        ),
      );

  @override
  Future<double> getUserBalance({required String address}) async {
    AgentFactory agent = await AgentFactory.createAgent(
      canisterId: canisterID,
      url: api,
      idl: ledgerIdl,
      debug: kDebugMode,
    );

    ICPTs bigIntBalance =
        await Ledger.getBalance(agent: agent, accountId: address);
    final base = BigInt.from(10);
    return bigIntBalance.e8s / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    String address = await getAddress();

    final key = 'ICPAddressBalance$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final userBalance = await getUserBalance(address: address);
      await pref.put(key, userBalance);

      return userBalance;
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
    ICPSigner signer = ICPSigner.fromSeed(
      seedPhraseRoot.seed,
      curveType: CurveType.secp256k1,
    );
    final agent = await AgentFactory.createAgent(
      canisterId: canisterID,
      url: api,
      idl: ledgerIdl,
      identity: signer.account.ecIdentity,
      debug: kDebugMode,
    );

    final blockHeight = await Ledger.send(
      agent: agent,
      to: to,
      amount: amount.toBigIntDec(decimals()),
      sendOpts: SendOpts()
        ..fee = _defaultFee()
        ..memo = memo?.plainToHex().hexToBn(),
    );

    return (
      txHash: blockHeight.toHex(),
      txRaw: null,
    );
  }

  @override
  validateAddress(String address) {
    RegExp icpAddress = RegExp(r"(?![0-9]+$)(?![a-fA-F]+$)[0-9A-Fa-f]{64,64}$");
    if (!icpAddress.hasMatch(address)) {
      throw 'Invalid $symbol address';
    }
  }

  @override
  int decimals() {
    return icpDecimals;
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

  BigInt _defaultFee() => BigInt.from(10000);

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final base = BigInt.from(10);
    return _defaultFee() / base.pow(decimals());
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transaction/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<ICPCoin> getICPBlockchains() {
  List<ICPCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.add(
      ICPCoin(
        blockExplorer:
            'http://127.0.0.1:4943/transaction/$blockExplorerPlaceholder',
        symbol: 'ICP',
        name: 'ICP(Testnet)',
        default_: 'ICP',
        image: 'assets/icp.png',
        api: "http://127.0.0.1:4943/",
        geckoID: "internet-computer",
        payScheme: 'internet_computer',
        rampID: '',
        canisterID: 'r7inp-6aaaa-aaaaa-aaabq-cai',
      ),
    );
  } else {
    blockChains.addAll([
      ICPCoin(
        blockExplorer:
            'https://dashboard.internetcomputer.org/transaction/$blockExplorerPlaceholder',
        symbol: 'ICP',
        name: 'ICP',
        default_: 'ICP',
        image: 'assets/icp.png',
        api: "https://icp-api.io/",
        geckoID: "internet-computer",
        payScheme: 'internet_computer',
        rampID: '',
        canisterID: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
      ),
    ]);
  }
  return blockChains;
}

class ICPDeriveArgs {
  final SeedPhraseRoot seedRoot;

  const ICPDeriveArgs({
    required this.seedRoot,
  });
}

Future<Map<String, dynamic>> calculateICPKey(ICPDeriveArgs config) async {
  ICPSigner signer = ICPSigner.fromSeed(
    config.seedRoot.seed,
    curveType: CurveType.secp256k1,
  );
  String signerecKey = signer.account.ecKeys!.ecPrivateKey!.toHex();
  String signerecChecksumAddress = signer.ecChecksumAddress!;

  return {
    'address': signerecChecksumAddress,
    'privateKey': signerecKey,
  };
}
