import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:ton_dart/ton_dart.dart';
import '../service/wallet_service.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import 'package:tonutils/tonutils.dart' as ton;
import 'package:http/http.dart' as http;
import '../utils/rpc_urls.dart';

const tonDecimals = 9;
const tonApiKey =
    "c4adfef37aa76ade6c3670ec1a5b0d71d3cbd704edd80443becbfacc21f5ad78";

class TonCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String api;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  Future<String> resolveAddress(String address) async {
    final tnsAddr = await getClient().resolveDomain(address);
    return tnsAddr.toString();
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

  @override
  int decimals() {
    return tonDecimals;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'tonCoinDetails${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = TonArgs(seedRoot: seedPhraseRoot);
    final keys = await compute(calculateTonKey, args);
    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'tonDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final keys = await _TonDerive.fromPrivateKey(
      privateKey: HEX.decode(privateKey),
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  String savedTransKey() {
    return '$default_$api Details';
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);
    var wallet = ton.WalletContractV4R2.create(
      publicKey: HEX.decode(details.publicKey!) as Uint8List,
    );

    var openedContract = getClient().open(wallet);
    var balance = await openedContract.getBalance();
    return balance / BigInt.from(10).pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'tonAddressBalance$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double balTon = await getUserBalance(address: address);
      await pref.put(key, balTon);
      return balTon;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.0055;
  }

  TonCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory TonCoin.fromJson(Map<String, dynamic> json) {
    return TonCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      api: json['api'],
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
    data['image'] = image;
    data['api'] = api;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  ton.TonJsonRpc getClient() {
    return ton.TonJsonRpc(
      api,
      tonApiKey,
    );
  }

  TonProvider getRpc() {
    return TonProvider(
      HTTPProvider(
        tonApiUrl: null,
        tonCenterUrl: '${Uri.parse(api).replace(path: '')}',
        api: TonApiType.tonCenter,
      ),
    );
  }

  @override
  requireMemo() => true;

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final details = await importData(data);

    final decodedPrivateKey = HEX.decode(details.privateKey!);
    final decodedPublicKey = HEX.decode(details.publicKey!);

    final ownerWallet = WalletV4.create(
      chain: TonChain.fromWorkchain(0),
      publicKey: decodedPublicKey,
      bounceableAddress: true,
    );

    final privateKey = TonPrivateKey.fromBytes(decodedPrivateKey);

    final destination = TonAddress(to);
    final transferAmount = amount.toBigIntDec(decimals());

    final txHash = await ownerWallet.sendTransfer(
      params: VersionedTransferParams(
        privateKey: privateKey,
        messages: [
          OutActionSendMsg(
            outMessage: TonHelper.internal(
              amount: transferAmount,
              destination: destination,
              memo: memo,
              bounce: false,
            ),
          )
        ],
      ),
      rpc: getRpc(),
    );

    return txHash;
  }

  @override
  validateAddress(String address) {
    ton.address(address);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

class TonArgs {
  final SeedPhraseRoot seedRoot;

  const TonArgs({
    required this.seedRoot,
  });
}

class _TonDerive {
  static Future<AccountData> fromPrivateKey({
    required List<int> privateKey,
  }) async {
    List<int> publicKey = await ED25519_HD_KEY.getPublicKey(privateKey);

    if (publicKey.length == 33) {
      publicKey = publicKey.sublist(1);
    }

    var wallet = ton.WalletContractV4R2.create(
      publicKey: Uint8List.fromList(publicKey),
    );

    return AccountData(
      address: wallet.address.toString(),
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
    );
  }
}

calculateTonKey(TonArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;

  final derivedKey =
      await ED25519_HD_KEY.derivePath("m/44'/607'/0'", seedRoot_.seed);

  final result = await _TonDerive.fromPrivateKey(privateKey: derivedKey.key);

  return {
    'publicKey': result.publicKey,
    'privateKey': result.privateKey,
    'address': result.address,
  };
}

List<TonCoin> getTonBlockChains() {
  List<TonCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      TonCoin(
        blockExplorer:
            'https://testnet.tonscan.org/tx/$blockExplorerPlaceholder',
        symbol: 'TON',
        name: 'TON(Testnet)',
        default_: 'TON',
        image: 'assets/ton.webp',
        api: 'https://testnet.toncenter.com/api/v2/jsonRPC',
        geckoID: 'the-open-network',
        payScheme: 'ton',
        rampID: '',
      ),
    ]);
  } else {
    blockChains.addAll([
      TonCoin(
        blockExplorer: 'https://tonscan.org/tx/$blockExplorerPlaceholder',
        symbol: 'TON',
        name: 'TON',
        default_: 'TON',
        image: 'assets/ton.webp',
        api: 'https://toncenter.com/api/v2/jsonRPC',
        geckoID: 'the-open-network',
        payScheme: 'ton',
        rampID: '',
      ),
    ]);
  }

  return blockChains;
}

class HTTPProvider implements TonServiceProvider {
  HTTPProvider(
      {this.tonApiUrl,
      this.tonCenterUrl,
      this.api = TonApiType.tonApi,
      http.Client? client,
      this.defaultRequestTimeout = const Duration(seconds: 30)})
      : client = client ?? http.Client();

  final String? tonApiUrl;
  final String? tonCenterUrl;
  final http.Client client;
  final Duration defaultRequestTimeout;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TonRequestDetails params,
      {Duration? timeout}) async {
    final Uri uri = params.apiType == TonApiType.tonApi
        ? params.toUri(tonApiUrl!)
        : params.toUri(tonCenterUrl!);
    final Map<String, String> headers = {
      ...params.headers,
      if (params.apiType.isTonCenter)
        "X-API-Key":
            "d3800f756738ac7b39599914b8a84465960ff869f555c2317664c9a62529baf3",
    };
    if (params.type.isPostRequest) {
      final response = await client
          .post(uri, headers: headers, body: params.body())
          .timeout(timeout ?? defaultRequestTimeout);
      return params.parseResponse(response.bodyBytes, response.statusCode);
    }
    final response = await client
        .get(uri, headers: headers)
        .timeout(timeout ?? defaultRequestTimeout);
    return params.parseResponse(response.bodyBytes, response.statusCode);
  }

  @override
  final TonApiType api;
}
