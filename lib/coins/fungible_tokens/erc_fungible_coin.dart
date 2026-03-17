// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:wallet_app/utils/c32check.dart';

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
    required super.blockExplorer,
    required super.chainId,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.coinType,
    required super.rpc,
    required super.name,
    required super.geckoID,
    required this.mintDecimals,
    required this.contractAddress_,
  }) : super(
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
  Future<double> getBalance(bool useCache) async {
    String address = roninAddrToEth(await getAddress());

    final balanceKey = '$chainId${tokenAddress()}${address}ercBalance';
    final storedBalance = pref.get(balanceKey);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      final fraction = await getUserBalance(address: address);
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
  // Contracts
  static const _xReserveTestnet = '0x008888878f94C0d87defdf0B07f46B93C1934442';
  static const _xReserveMainnet = '0x008888878f94C0d87defdf0B07f46B93C1934442';
  static const _stacksDomain = 10003;

  /// Encodes a Stacks address to bytes32 for depositToRemote.
  /// Mirrors encodeStacksAddress() from helper.ts:
  ///   strip 'S' → c32checkDecode → [version(1 byte) + hash160(20 bytes)] → right-pad to 32
  static Uint8List _encodeStacksAddress(String stacksAddress) {
    // c32checkDecode expects the string without the leading 'S'
    final decoded = c32checkDecode(stacksAddress.substring(1));
    final version = decoded[0] as int;
    final hash160 = HEX.decode(decoded[1] as String);

    final bytes = Uint8List(32);
    bytes[0] = version;
    bytes.setRange(
      1,
      21,
      hash160,
    ); // bytes 1-20 = hash160, 21-31 = zero padding
    return bytes;
  }

  /// Bridges USDC (Ethereum/Sepolia) → USDCx (Stacks) via xReserve.
  /// Two on-chain txs: approve + depositToRemote.
  /// Returns (approveTxHash, depositTxHash).
  Future<(String, String)> mintUSDCx({
    required String stacksRecipient,
    required String amount,
  }) async {
    final client = Web3Client(rpc, Client());
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final accountData = await importData(walletData);
    final credentials = EthPrivateKey.fromHex(accountData.privateKey!);

    final value = amount.toBigIntDec(decimals()); // 6 decimals
    final xReserve = EthereumAddress.fromHex(
      chainId == 11155111 ? _xReserveTestnet : _xReserveMainnet,
    );
    final usdcContract = EthereumAddress.fromHex(contractAddress_);
    final remoteRecipient = _encodeStacksAddress(stacksRecipient);

    // ── Step 1: approve ────────────────────────────────────────────────────────
    final approveAbi = ContractAbi.fromJson(
        jsonEncode([
          {
            'name': 'approve',
            'type': 'function',
            'stateMutability': 'nonpayable',
            'inputs': [
              {'name': 'spender', 'type': 'address'},
              {'name': 'amount', 'type': 'uint256'},
            ],
            'outputs': [],
          }
        ]),
        '');

    final approveContract = DeployedContract(approveAbi, usdcContract);
    final approveFn = approveContract.function('approve');

    final approveTx = await client.signTransaction(
      credentials,
      Transaction.callContract(
        contract: approveContract,
        function: approveFn,
        parameters: [xReserve, value],
      ),
      chainId: chainId,
    );
    final approveTxHash = await client.sendRawTransaction(approveTx);

    // Wait for approval confirmation before depositing
    await client.dispose();
    await _waitForTx(approveTxHash);

    // ── Step 2: depositToRemote ────────────────────────────────────────────────
    final depositClient = Web3Client(rpc, Client());
    final depositAbi = ContractAbi.fromJson(
        jsonEncode([
          {
            'name': 'depositToRemote',
            'type': 'function',
            'stateMutability': 'nonpayable',
            'inputs': [
              {'name': 'value', 'type': 'uint256'},
              {'name': 'remoteDomain', 'type': 'uint32'},
              {'name': 'remoteRecipient', 'type': 'bytes32'},
              {'name': 'localToken', 'type': 'address'},
              {'name': 'maxFee', 'type': 'uint256'},
              {'name': 'hookData', 'type': 'bytes'},
            ],
            'outputs': [],
          }
        ]),
        '');

    final depositContract = DeployedContract(depositAbi, xReserve);
    final depositFn = depositContract.function('depositToRemote');

    final depositTx = await depositClient.signTransaction(
      credentials,
      Transaction.callContract(
        contract: depositContract,
        function: depositFn,
        parameters: [
          value,
          BigInt.from(_stacksDomain),
          remoteRecipient,
          usdcContract,
          BigInt.zero, // maxFee = 0
          Uint8List(0), // hookData = 0x
        ],
      ),
      chainId: chainId,
    );
    final depositTxHash = await depositClient.sendRawTransaction(depositTx);
    await depositClient.dispose();

    return (approveTxHash, depositTxHash);
  }

  Future<void> _waitForTx(String txHash) async {
    final client = Web3Client(rpc, Client());
    while (true) {
      try {
        final receipt = await client.getTransactionReceipt(txHash);
        if (receipt != null) break;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 3));
    }
    await client.dispose();
  }
}

List<ERCFungibleCoin> getERC20Coins() {
  List<ERCFungibleCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll([
      ERCFungibleCoin(
        contractAddress_: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
        name: 'USD Coin',
        symbol: 'USDC',
        mintDecimals: 6,
        rpc: 'https://sepolia.infura.io/v3/$infuraApiKey',
        chainId: 11155111,
        blockExplorer:
            'https://sepolia.etherscan.io/tx/$blockExplorerPlaceholder',
        default_: 'ETH',
        image: 'assets/wusd.png',
        coinType: 60,
        geckoID: 'usd-coin',
      ),
    ]);
  } else {
    blockChains.addAll([
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
      ERCFungibleCoin(
        contractAddress_: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
        name: 'USD Coin',
        symbol: 'USDC',
        mintDecimals: 6,
        rpc: 'https://mainnet.base.org',
        chainId: 8453,
        blockExplorer: 'https://explorer.base.org/tx/$blockExplorerPlaceholder',
        default_: 'ETH',
        image: 'assets/wusd.png',
        coinType: 60,
        geckoID: 'usd-coin',
      ),
      ERCFungibleCoin(
        contractAddress_: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
        name: 'USD Coin',
        symbol: 'USDC',
        mintDecimals: 6,
        rpc: 'https://mainnet.infura.io/v3/$infuraApiKey',
        chainId: 1,
        blockExplorer: 'https://etherscan.io/tx/$blockExplorerPlaceholder',
        default_: 'ETH',
        image: 'assets/wusd.png',
        coinType: 60,
        geckoID: 'usd-coin',
      ),
    ]);
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
