// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../service/wallet_service.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../../interface/coin.dart';
import '../../main.dart';
import '../../utils/abis.dart';
import '../../utils/rpc_urls.dart';

class ERCFungibleCoin extends EthereumCoin implements FTExplorer {
  late String contractAddress_;

  late ContractAbi _contrAbi;
  int mintDecimals;

  @override
  Widget? getNFTPage() => null;

  @override
  String tokenAddress() => contractAddress_;

  @override
  String contractExplorer() {
    return getExplorer().replaceFirst(
      '/tx/$blockExplorerPlaceholder',
      '/token/${tokenAddress()}',
    );
  }

  @override
  int decimals() => mintDecimals;

  ERCFungibleCoin({
    required String blockExplorer,
    required int chainId,
    required String symbol,
    required String default_,
    required String image,
    required int coinType,
    required String rpc,
    required String name,
    required String geckoID,
    required this.mintDecimals,
    required this.contractAddress_,
  }) : super(
          blockExplorer: blockExplorer,
          chainId: chainId,
          symbol: symbol,
          default_: default_,
          image: image,
          coinType: coinType,
          rpc: rpc,
          name: name,
          geckoID: geckoID,
          rampID: '',
          payScheme: '',
        ) {
    _contrAbi = ContractAbi.fromJson(
      json.encode(erc20Abi),
      '',
    );
  }

  static String get _tokenMapKey => 'ethFTStore$enableTestNet';

  static List<ERCFungibleCoin> getCoinsInStore() {
    List<ERCFungibleCoin> blockChains = [];
    final prefToken = pref.get(_tokenMapKey);

    if (prefToken != null && WalletService.isPharseKey()) {
      final tokenList = Map.from(jsonDecode(prefToken)).values.toList();

      blockChains.addAll([
        ...tokenList.map(
          (e) => ERCFungibleCoin.fromJson(e),
        ),
      ]);
    }
    return blockChains;
  }

  Future<bool> addCoinToStore() async {
    Map tokenMap = {};
    final savedJsonImports = pref.get(_tokenMapKey);
    final uniqueKey = '$contractAddress_$chainId';

    if (savedJsonImports != null) {
      tokenMap = Map.from(jsonDecode(savedJsonImports));
    }

    if (tokenMap.containsKey(uniqueKey)) {
      return false;
    }

    Map details = {
      uniqueKey: toJson(),
    };

    tokenMap.addAll(details);

    await pref.put(
      _tokenMapKey,
      jsonEncode(tokenMap),
    );

    return true;
  }

  factory ERCFungibleCoin.fromJson(Map<String, dynamic> json) {
    return ERCFungibleCoin(
      chainId: json['chainId'],
      rpc: json['rpc'],
      coinType: json['coinType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      contractAddress_: json['contractAddress'],
      mintDecimals: json['mintDecimals'],
      geckoID: json['geckoID'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;
    data['rpc'] = rpc;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['coinType'] = coinType;
    data['image'] = image;
    data['contractAddress'] = contractAddress_;
    data['mintDecimals'] = mintDecimals;
    data['geckoID'] = geckoID;

    return data;
  }

  @override
  String savedTransKey() {
    return '$contractAddress_$rpc Details';
  }

  final roninChainIds = [2020, 2021];
  @override
  void validateAddress(String address) {
    if (_isRonin()) {
      super.validateAddress(roninAddrToEth(address));
      return;
    }
    super.validateAddress(address);
  }

  bool _isRonin() {
    return roninChainIds.contains(chainId);
  }

  @override
  String? get badgeImage => evmFromChainId(chainId)?.image;

  @override
  Future<AccountData> importData(String data) async {
    if (_isRonin()) {
      final details = await super.importData(data);
      return AccountData.fromJson({
        ...details.toJson(),
        'address': ethAddrToRonin(details.address),
      });
    }

    return await super.importData(data);
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final sendAmt = amount.toBigIntDec(decimals());
    final parameters_ = [EthereumAddress.fromHex(to), sendAmt];

    final client = Web3Client(
      rpc,
      Client(),
    );
    final data = WalletService.getActiveKey(walletImportType)!.data;
    AccountData response = await importData(data);
    final credentials = EthPrivateKey.fromHex(response.privateKey!);

    final contract = DeployedContract(
      _contrAbi,
      EthereumAddress.fromHex(
        contractAddress_,
      ),
    );

    ContractFunction transfer = contract.function('transfer');

    final trans = await client.signTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transfer,
        parameters: parameters_,
      ),
      chainId: chainId,
    );

    final transactionHash = await client.sendRawTransaction(trans);

    await client.dispose();
    return transactionHash;
  }

  Future<_ERC20Meta?> getERC20Meta() async {
    final client = Web3Client(
      rpc,
      Client(),
    );

    final contract = DeployedContract(
      _contrAbi,
      EthereumAddress.fromHex(tokenAddress()),
    );

    final nameFunction = contract.function('name');
    final symbolFunction = contract.function('symbol');
    final decimalsFunction = contract.function('decimals');

    final name = await client
        .call(contract: contract, function: nameFunction, params: []);

    final symbol = await client
        .call(contract: contract, function: symbolFunction, params: []);
    final decimals = await client
        .call(contract: contract, function: decimalsFunction, params: []);

    BigInt dec = decimals.first;

    return _ERC20Meta(
      decimals: dec.toInt(),
      name: name.first,
      symbol: symbol.first,
    );
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final contract = DeployedContract(
      _contrAbi,
      EthereumAddress.fromHex(
        tokenAddress(),
      ),
    );

    Web3Client client = Web3Client(
      rpc,
      Client(),
    );

    final sendingAddress = EthereumAddress.fromHex(
      address,
    );

    final balanceFunc = contract.function('balanceOf');

    final balCall = await client.call(
      contract: contract,
      function: balanceFunc,
      params: [sendingAddress],
    );
    BigInt balance = balCall.first;

    await client.dispose();

    final base = BigInt.from(10);

    return balance / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    String address = roninAddrToEth(await getAddress());

    final balanceKey = '$chainId${tokenAddress()}${address}ercBalance';
    final storedBalance = pref.get(balanceKey);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final fraction = getUserBalance(address: address);
      await pref.put(balanceKey, fraction);

      return fraction;
    } catch (e, _) {
      return savedBalance;
    }
  }

  Future getERC20Allowance({
    required String owner,
    required String spender,
  }) async {
    Web3Client client = Web3Client(
      rpc,
      Client(),
    );

    final contract = DeployedContract(
      _contrAbi,
      EthereumAddress.fromHex(tokenAddress()),
    );

    final allowanceFunction = contract.function('allowance');

    final callAllowance = await client.call(
      contract: contract,
      function: allowanceFunction,
      params: [
        EthereumAddress.fromHex(owner),
        EthereumAddress.fromHex(spender),
      ],
    );

    final allowance = callAllowance.first;

    return allowance;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final sendAmt = amount.toBigIntDec(decimals());
    final parameters_ = [EthereumAddress.fromHex(to), sendAmt];

    String address = roninAddrToEth(await getAddress());

    final sendingAddress = EthereumAddress.fromHex(address);

    final contract = DeployedContract(
      _contrAbi,
      EthereumAddress.fromHex(tokenAddress()),
    );

    final transfer = contract.function('transfer');

    Uint8List contractData = transfer.encodeCall(parameters_);

    final transactionFee = await getEtherTransactionFee(
      rpc,
      contractData,
      sendingAddress,
      EthereumAddress.fromHex(
        tokenAddress(),
      ),
    );

    return transactionFee / pow(10, etherDecimals);
  }

  @override
  String getGeckoId() => geckoID;
}

List<ERCFungibleCoin> getERC20Coins() {
  List<ERCFungibleCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      ERCFungibleCoin(
        contractAddress_: '0x9a2f19121f2f72ab77f6e4a2391a7b858df60c64',
        name: 'ECLA Eco(Testnet)',
        symbol: "ECLA",
        mintDecimals: 18,
        rpc: 'https://data-seed-prebsc-2-s3.binance.org:8545/',
        chainId: 97,
        blockExplorer:
            'https://testnet.bscscan.com/tx/$blockExplorerPlaceholder',
        default_: 'BNB',
        image: 'assets/ethereum-2.png',
        coinType: 60,
        geckoID: '',
      ),
    );
  } else {
    blockChains.add(
      ERCFungibleCoin(
        contractAddress_: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
        name: 'BUSD Token',
        symbol: "BUSD",
        mintDecimals: 18,
        rpc: 'https://bsc-dataseed.binance.org/',
        chainId: 56,
        blockExplorer: 'https://bscscan.com/tx/$blockExplorerPlaceholder',
        default_: 'BNB',
        image: 'assets/busd.png',
        coinType: 60,
        geckoID: "binance-usd",
      ),
    );
  }

  blockChains.addAll(ERCFungibleCoin.getCoinsInStore());

  return blockChains;
}

class _ERC20Meta {
  String name;
  String symbol;
  int decimals;

  _ERC20Meta({
    required this.name,
    required this.symbol,
    required this.decimals,
  });
}
