// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:wallet_app/coins/tron_coin.dart';
import 'package:http/http.dart';
import 'package:on_chain/on_chain.dart';
import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../service/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/crypto.dart';
import '../../main.dart';
import '../../utils/abis.dart';
import '../../utils/app_config.dart';

class TRCFTTYPES {
  static String v10 = 'TRC10';
  static String v20 = 'TRC20';
}

class TronFungibleCoin extends TronCoin implements FTExplorer {
  String tokenID;
  String type;
  int mintDecimals;

  TronFungibleCoin({
    required String blockExplorer,
    required String symbol,
    required String default_,
    required String image,
    required String name,
    required String api,
    required this.type,
    required this.mintDecimals,
    required this.tokenID,
    required String geckoID,
  }) : super(
          rampID: '',
          payScheme: '',
          blockExplorer: blockExplorer,
          symbol: symbol,
          default_: default_,
          image: image,
          api: api,
          name: name,
          geckoID: geckoID,
        );

  factory TronFungibleCoin.fromJson(Map<String, dynamic> json) {
    return TronFungibleCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      mintDecimals: json['mintDecimals'],
      tokenID: json['tokenID'],
      type: json['type'],
      geckoID: json['geckoID'],
    );
  }

  @override
  String? get badgeImage => tronChains.first.image;
  @override
  String savedTransKey() => '$tokenID$api FTDetails';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['mintDecimals'] = mintDecimals;
    data['tokenID'] = tokenID;
    data['type'] = type;
    data['geckoID'] = geckoID;
    return data;
  }

  @override
  int decimals() => mintDecimals;

  Future<double> _getBalanceV10(bool skipNetworkRequest) async {
    final address = await getAddress();

    final key = 'TronFTBalance$type$tokenID$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final rpc = TronProvider(TronHTTPProvider(url: api));
      final trc10 = await rpc.request(
        TronRequestGetAccount(
          address: TronAddress(address),
        ),
      );

      final trc10tokens = trc10?.assetV2;

      for (final asset in trc10tokens!) {
        if (asset.key != tokenID) continue;
        final base = BigInt.from(10);
        BigInt balance = asset.value;

        double fraction = balance / base.pow(decimals());
        await pref.put(key, fraction);
        return fraction;
      }

      return savedBalance;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/transaction/$blockExplorerPlaceholder',
      '/${type == TRCFTTYPES.v10 ? 'token' : 'token20'}/${contractAddress()}/transfers',
    );
  }

  String contractAddress() => tokenID;

  Future<double> _getBalanceV20(bool skipNetworkRequest) async {
    final address = await getAddress();

    final key = 'TronAddressBalance$type$tokenID$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final address = await getAddress();
      final ownerAddress = TronAddress(address);
      final rpc = EthereumProvider(
        RPCHttpService("$api/jsonrpc"),
      );
      final contract = ContractABI.fromJson(trc20Abi);
      final result = await rpc.request(
        EthereumRequestCall.fromMethod(
          contractAddress: TronAddress(tokenID).toAddress(false),
          function: contract.functionFromName("balanceOf"),
          params: [ownerAddress],
        ),
      );

      BigInt balance = (result as List)[0];
      final base = BigInt.from(10);
      double fraction = balance / base.pow(decimals());
      // Convert the balance to a double and return it
      await pref.put(key, fraction);

      return fraction;
    } catch (_, __) {
      return savedBalance;
    }
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    return getBalance(false);
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    if (type == TRCFTTYPES.v10) {
      return await _getBalanceV10(skipNetworkRequest);
    } else if (type == TRCFTTYPES.v20) {
      return await _getBalanceV20(skipNetworkRequest);
    }

    throw Exception('unknown tron type');
  }

  Future<String?> _transferV20(String amount, String to, {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tronDetails = await importData(data);

    final sendAmt = amount.toBigIntDec(decimals());

    final contractAbi = ContractABI.fromJson(trc20Abi);
    final toAddress = TronAddress(to);
    final binary = contractAbi
        .functionFromName('transfer')
        .encode([toAddress, sendAmt], true);

    final ownerAddress = TronAddress(tronDetails.address);

    final contract = TriggerSmartContract(
      ownerAddress: ownerAddress,
      contractAddress: TronAddress(tokenID),
      data: binary,
    );

    final any = Any(typeUrl: contract.typeURL, value: contract);
    final transactionContract =
        TransactionContract(type: contract.contractType, parameter: any);
    final rpc = TronProvider(TronHTTPProvider(url: api));
    final block = await rpc.request(TronRequestGetNowBlock());
    const expSeconds = 60 * 60;
    final rawTr = TransactionRaw(
      refBlockBytes: block.blockHeader.rawData.refBlockBytes,
      refBlockHash: block.blockHeader.rawData.refBlockHash,
      expiration: block.blockHeader.rawData.timestamp + BigInt.from(expSeconds),
      contract: [transactionContract],
      timestamp: block.blockHeader.rawData.timestamp,
      feeLimit: BigInt.from(14000000000),
      data: memo != null ? utf8.encode(memo) : null,
    );

    Uint8List privateKey =
        Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
    Uint8List txID = Uint8List.fromList(HEX.decode(rawTr.txID));
    final signatureEC = sign(txID, privateKey);
    final recid = signatureEC.v - 27;
    final signature = '${HEX.encode([
          ...signatureEC.r.toUint8List(),
          ...signatureEC.s.toUint8List(),
        ])}0$recid';

    final transaction =
        Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);

    final raw = BytesUtils.toHexString(transaction.toBuffer());

    final result = await rpc.request(TronRequestBroadcastHex(transaction: raw));

    if (result.isSuccess) {
      return result.txId;
    }
    throw Exception('sending failed');
  }

  Future<String?> _transferV10(String amount, String to, {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tronDetails = await importData(data);

    final sendAmt = amount.toBigIntDec(decimals());

    final ownerAddress = TronAddress(tronDetails.address);
    final toAddress = TronAddress(to);

    final contract = TransferAssetContract(
      ownerAddress: ownerAddress,
      toAddress: toAddress,
      amount: sendAmt,
      assetName: utf8.encode(tokenID),
    );

    final any = Any(typeUrl: contract.typeURL, value: contract);
    final transactionContract =
        TransactionContract(type: contract.contractType, parameter: any);
    final rpc = TronProvider(TronHTTPProvider(url: api));
    final block = await rpc.request(TronRequestGetNowBlock());
    const expSeconds = 60 * 60;
    final rawTr = TransactionRaw(
      refBlockBytes: block.blockHeader.rawData.refBlockBytes,
      refBlockHash: block.blockHeader.rawData.refBlockHash,
      expiration: block.blockHeader.rawData.timestamp + BigInt.from(expSeconds),
      contract: [transactionContract],
      timestamp: block.blockHeader.rawData.timestamp,
      feeLimit: BigInt.parse("10"),
      data: memo != null ? utf8.encode(memo) : null,
    );

    Uint8List privateKey =
        Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
    Uint8List txID = Uint8List.fromList(HEX.decode(rawTr.txID));
    final signatureEC = sign(txID, privateKey);
    final recid = signatureEC.v - 27;
    final signature = '${HEX.encode([
          ...signatureEC.r.toUint8List(),
          ...signatureEC.s.toUint8List(),
        ])}0$recid';

    final transaction =
        Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);

    final raw = BytesUtils.toHexString(transaction.toBuffer());

    final result = await rpc.request(TronRequestBroadcastHex(transaction: raw));

    if (result.isSuccess) {
      return result.txId;
    }
    throw Exception('sending failed');
  }

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    if (type == TRCFTTYPES.v10) {
      return await _transferV10(amount, to, memo: memo);
    } else if (type == TRCFTTYPES.v20) {
      return await _transferV20(amount, to, memo: memo);
    }

    throw Exception('unknown tron type');
  }

  @override
  String getGeckoId() => geckoID;
}

List<TronFungibleCoin> getTronFungibleCoins() {
  List<TronFungibleCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      TronFungibleCoin(
        name: 'PRIME (TestnetV20)',
        symbol: 'PRM',
        default_: 'TRX',
        blockExplorer:
            'https://shasta.tronscan.org/#/transaction/$blockExplorerPlaceholder',
        image: 'assets/logo.png',
        api: 'https://api.shasta.trongrid.io',
        tokenID: 'TTFd5kQ8r34XPtUjK3Lk5Eh8rLBjynsX1k',
        mintDecimals: 6,
        type: TRCFTTYPES.v20,
        geckoID: '',
      ),
      TronFungibleCoin(
        name: 'PRIME (Testnet)',
        symbol: 'PRM',
        default_: 'TRX',
        blockExplorer:
            'https://shasta.tronscan.org/#/transaction/$blockExplorerPlaceholder',
        image: 'assets/logo.png',
        api: 'https://api.shasta.trongrid.io',
        tokenID: '1001465',
        mintDecimals: 6,
        type: TRCFTTYPES.v10,
        geckoID: '',
      )
    ]);
  } else {
    blockChains.addAll([
      TronFungibleCoin(
        name: 'BitTorrent Old',
        symbol: 'BTTOLD',
        default_: 'TRX',
        blockExplorer:
            'https://tronscan.org/#/transaction/$blockExplorerPlaceholder',
        image: 'assets/btt.png',
        api: 'https://api.trongrid.io',
        tokenID: '1002000',
        mintDecimals: 6,
        type: TRCFTTYPES.v10,
        geckoID: 'bittorrent-old',
      ),
      TronFungibleCoin(
        name: 'BitTorrent',
        symbol: 'BTT',
        default_: 'TRX',
        blockExplorer:
            'https://tronscan.org/#/transaction/$blockExplorerPlaceholder',
        image: 'assets/btt.png',
        api: 'https://api.trongrid.io',
        tokenID: 'TAFjULxiVgT4qWk6UZwjqwZXTSaGaqnVp4',
        mintDecimals: 18,
        type: TRCFTTYPES.v20,
        geckoID: 'bittorrent',
      ),
      TronFungibleCoin(
        name: 'USDC',
        symbol: 'USDC',
        default_: 'TRX',
        blockExplorer:
            'https://tronscan.org/#/transaction/$blockExplorerPlaceholder',
        image: 'assets/wusd.png',
        api: 'https://api.trongrid.io',
        tokenID: 'TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8',
        mintDecimals: 6,
        type: TRCFTTYPES.v20,
        geckoID: 'usd-coin',
      ),
    ]);
  }

  return blockChains;
}

class RPCHttpService with EthereumServiceProvider {
  RPCHttpService(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  final String url;
  final Client client;
  final Duration defaultTimeOut;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(EthereumRequestDetails params,
      {Duration? timeout}) async {
    final response = await client
        .post(params.toUri(url), headers: params.headers, body: params.body())
        .timeout(timeout ?? defaultTimeOut);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
