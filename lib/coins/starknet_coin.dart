import 'dart:convert';
import 'dart:math';
import 'package:cryptowallet/extensions/big_int_ext.dart';
import 'package:cryptowallet/screens/stake_token.dart';
import 'package:cryptowallet/service/ai_agent_service.dart';
import 'package:cryptowallet/service/wallet_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';
import 'package:http/http.dart' as http;

const starkDecimals = 18;
const strkNativeToken =
    '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d';

const strkEthNativeToken =
    '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7';
const maxFeeWei = 10000000000000;
final maxFeeEth = maxFeeWei / pow(10, 18);

class StarknetCoin extends Coin {
  String api;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;
  String classHash;
  String contractAddress;
  bool useStarkToken;

  StarknetCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.payScheme,
    required this.rampID,
    required this.classHash,
    required this.contractAddress,
    required this.useStarkToken,
  });

  factory StarknetCoin.fromJson(Map<String, dynamic> json) {
    return StarknetCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      classHash: json['classHash'],
      contractAddress: json['contractAddress'],
      useStarkToken: json['useStarkToken'],
    );
  }

  @override
  bool get supportPrivateKey => true;

  @override
  Future<bool> needDeploy() async {
    try {
      final address = await getAddress();
      final saveKey = 'StarknetAccountDetails$address';

      if (pref.containsKey(saveKey)) {
        final accountJson = pref.get(saveKey);
        if (accountJson != null) {
          final accountMap = Map<String, dynamic>.from(jsonDecode(accountJson));

          if (accountMap['deployed'].runtimeType == bool &&
              accountMap['deployed'] == true) {
            return false;
          }
        }
      }

      final provider = await apiProvider();

      final classHash = await provider.getClassHashAt(
        contractAddress: Felt.fromHexString(address),
        blockId: BlockId.latest,
      );
      bool isDeployed = classHash.when(
        result: (result) => true,
        error: (error) => false,
      );

      if (!isDeployed) {
        throw Exception("account not deployed");
      }
      await pref.put(saveKey, jsonEncode({'deployed': true}));
      return false;
    } catch (e) {
      debugPrint('needDeployment error: $e');
      return true;
    }
  }

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
    data['classHash'] = classHash;
    data['contractAddress'] = contractAddress;
    data['useStarkToken'] = useStarkToken;

    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'CairoStarknetAccPrivate${walletImportType.name}$api';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }
    final privateKeyHex =
        privateKey.startsWith("0x") ? privateKey : "0x$privateKey";

    final privateKeyBytes = Felt.fromHexString(privateKeyHex);

    final signer = Signer(privateKey: privateKeyBytes);

    final address = Contract.computeAddress(
      classHash: Felt.fromHexString(classHash),
      calldata: [signer.publicKey],
      salt: signer.publicKey,
    );

    final keys = AccountData(
      address: address.toHexString(),
      privateKey: privateKeyHex,
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey = 'CairoStarknetAcc${walletImportType.name}$api';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = StarknetDeriveArgs(
      mnemonic: mnemonic,
      classHash: classHash,
    );

    final keys = await compute(calculateStarknetKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  @override
  Future<String?> resolveAddress(String address) async {
    final url = 'https://api.starknet.id/domain_to_addr?domain=$address';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['addr'];
    } else {
      throw Exception('Failed to resolve address');
    }
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final provider = await apiProvider();
    final providerCall = await provider.call(
      request: FunctionCall(
        contractAddress: Felt.fromHexString(contractAddress),
        entryPointSelector: getSelectorByName('balanceOf'),
        calldata: [Felt.fromHexString(address)],
      ),
      blockId: BlockId.latest,
    );

    final userBalance = providerCall.when<double>(
      error: (error) {
        throw Exception(error);
      },
      result: (result) {
        final strkBalance = Uint256.fromFeltList(result).toBigInt() /
            BigInt.from(10).pow(decimals());
        return strkBalance;
      },
    );

    return userBalance;
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    String address = await getAddress();

    final key = 'StarknetAddressBalance$address$api$name';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

    try {
      final userBalance = await getUserBalance(address: address);

      await pref.put(key, userBalance);
      return userBalance;
    } catch (e) {
      debugPrint(e.toString());
      return savedBalance;
    }
  }

  @override
  String? tokenAddress() =>
      getStarknetBlockchains().first.name == name ? null : contractAddress;

  @override
  Widget? getStakingPage() {
    return StakeToken(
      tokenData: this,
    );
  }

  @override
  String? get badgeImage => getStarknetBlockchains().first.name == name
      ? null
      : getStarknetBlockchains().first.image;

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final needDeployment = await needDeploy();
    if (needDeployment) {
      await deployAccount();
    }
    final provider = await apiProvider();
    final chainId = await getChainId();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = Signer(privateKey: Felt.fromHexString(response.privateKey!));

    final fundingAccount = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final wei = amount.toBigIntDec(decimals());

    final txHash = await fundingAccount.send(
      recipient: Felt.fromHexString(to),
      amount: Uint256(
        low: Felt(
          wei,
        ),
        high: Felt.zero,
      ),
      useSTRKtoken: useStarkToken,
    );

    return txHash;
  }

  Future<int> getTokenDecimals(String tokenAddress) async {
    final provider = await apiProvider();

    final decimalsReq = await provider.call(
      request: FunctionCall(
        contractAddress: Felt.fromHexString(tokenAddress),
        entryPointSelector: getSelectorByName('decimals'),
        calldata: [],
      ),
      blockId: const BlockId.blockTag('latest'),
    );
    return decimalsReq
        .when(
          error: (error) {
            throw Exception(error);
          },
          result: (result) {
            return result;
          },
        )
        .first
        .toInt();
  }

  String get swapUrl => enableTestNet
      ? 'https://sepolia.api.avnu.fi'
      : 'https://starknet.api.avnu.fi';

  @override
  Future<String?> getQuote(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async {
    if (tokenIn == AIAgentService.defaultCoinTokenAddress) {
      tokenIn = strkNativeToken;
    } else if (tokenOut == AIAgentService.defaultCoinTokenAddress) {
      tokenOut = strkNativeToken;
    }
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final wei = amount.toBigIntDec(await getTokenDecimals(tokenIn));

    final quotes = await fetchQuotes(
      QuoteRequest(
        sellTokenAddress: tokenIn,
        buyTokenAddress: tokenOut,
        sellAmount: wei,
        takerAddress: response.address,
      ),
      baseUrl: swapUrl,
    );
    final quote = quotes[0];
    final unit = pow(10, await getTokenDecimals(quote.buyTokenAddress));
    return jsonEncode(
        {...quote.toJson(), 'buyAmount': quote.buyAmount / BigInt.from(unit)});
  }

  Felt get delegationPoolAddress => Felt.fromHexString(
      '0x07134aad6969880f11b2d50e57c6e8d38ceef3a6b02bd9ea44837bd257023f6b');
  Felt get starkAddress => Felt.fromHexString(
      '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d');

  Contract getStakingContract(Account account) {
    return Contract(
      account: account,
      address: delegationPoolAddress,
    );
  }

  Contract getStarkContract(Account account) {
    return Contract(
      account: account,
      address: starkAddress,
    );
  }

  @override
  Future<String?> stakeToken(String amount) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = Signer(privateKey: Felt.fromHexString(response.privateKey!));
    final provider = await apiProvider();
    final chainId = await getChainId();
    final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final strkContract = getStarkContract(account);

    final allowanceCall = FunctionCall(
      contractAddress: strkContract.address,
      entryPointSelector: getSelectorByName('approve'),
      calldata: [delegationPoolAddress, Felt(amount.toBigIntDec(decimals()))],
    );

    final delegationPoolContract = getStakingContract(account);

    final existingStake = await getStakeInfo(account);

    List<FunctionCall> calls = [];

    if (existingStake != null) {
      calls.addAll([
        allowanceCall,
        FunctionCall(
          contractAddress: delegationPoolContract.address,
          entryPointSelector: getSelectorByName('enter_delegation_pool'),
          calldata: [
            account.accountAddress,
            Felt(amount.toBigIntDec(decimals()))
          ],
        )
      ]);
    } else {
      calls.addAll([
        allowanceCall,
        FunctionCall(
          contractAddress: delegationPoolContract.address,
          entryPointSelector: getSelectorByName('add_to_delegation_pool'),
          calldata: [
            account.accountAddress,
            Felt(amount.toBigIntDec(decimals()))
          ],
        )
      ]);
    }

    final rsult = await account.execute(functionCalls: calls);

    return rsult.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception("Error transfer (${error.code}): ${error.message}");
      },
    );
  }

  Future<StakeInfo?> getStakeInfo(Account account) async {
    final delegationPoolContract = getStakingContract(account);
    final poolData = await delegationPoolContract.call(
      'get_pool_member_info',
      [delegationPoolContract.account.accountAddress],
    );

    final unwrappedRes = PoolMember.fromJson(poolData);

    final rewardAddress = unwrappedRes.rewardAddress;
    final stake = unwrappedRes.amount.toBigInt();
    final pendingUnstakeAmount = unwrappedRes.unpoolAmount.toBigInt();
    final totalStake = stake + pendingUnstakeAmount;
    final pendingRewards = unwrappedRes.unclaimedRewards.toBigInt();
    final unwrappedUnpoolTimestamp = unwrappedRes.unpoolTime;
    DateTime? unlockDate = unwrappedUnpoolTimestamp != Felt.zero
        ? DateTime.fromMillisecondsSinceEpoch(
            unwrappedUnpoolTimestamp.toInt() * 1000)
        : null;
    PendingUnstake? pendingUnstake;

    if (pendingUnstakeAmount > BigInt.zero && unlockDate != null) {
      pendingUnstake = PendingUnstake(
        amount: pendingUnstakeAmount,
        unlockDate: unlockDate,
        unlocked: DateTime.now().isAfter(unlockDate),
      );
    }

    return StakeInfo(
      rewardAddress: rewardAddress, // Felt
      stake: stake, // BigInt
      totalStake: totalStake, // BigInt
      pendingRewards: pendingRewards, // BigInt
      pendingUnstake: pendingUnstake, // PendingUnstake?
    );
  }

  @override
  Future<String?> swapTokens(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async {
    if (tokenIn == AIAgentService.defaultCoinTokenAddress) {
      tokenIn = strkNativeToken;
    } else if (tokenOut == AIAgentService.defaultCoinTokenAddress) {
      tokenOut = strkNativeToken;
    }
    await deployAccount();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final quoteResult = await getQuote(tokenIn, tokenOut, amount);

    if (quoteResult == null) {
      throw Exception('Failed to get quote');
    }

    final Quote quote = Quote.fromJson(jsonDecode(quoteResult));

    final body = {
      'quoteId': quote.quoteId,
      'takerAddress': response.address,
      'slippage': 0.01,
      'includeApprove': true,
    };

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final apiResponse = await http.post(
      Uri.parse('$swapUrl/swap/v2/build'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (apiResponse.statusCode == 200) {
      final responseBody = jsonDecode(apiResponse.body);

      final calls = responseBody['calls'] as List<dynamic>;
      final functionCalls = calls.map((call) {
        final data = CallData.fromJson(call);
        return FunctionCall(
          contractAddress: Felt.fromHexString(data.contractAddress),
          entryPointSelector: getSelectorByName(data.entrypoint),
          calldata: data.calldata
              .map(
                (e) => Felt.fromHexString(e),
              )
              .toList(),
        );
      }).toList();

      final signer =
          Signer(privateKey: Felt.fromHexString(response.privateKey!));
      final provider = await apiProvider();
      final chainId = await getChainId();
      final fundingAccount = Account(
        provider: provider,
        signer: signer,
        accountAddress: Felt.fromHexString(response.address),
        chainId: chainId,
      );

      final rsult = await fundingAccount.execute(functionCalls: functionCalls);

      return rsult.when(
        result: (result) {
          return result.transaction_hash;
        },
        error: (error) {
          throw Exception("Error transfer (${error.code}): ${error.message}");
        },
      );
    } else {
      throw Exception('Failed to swap tokens');
    }
  }

  @override
  Future<bool> deployAccount() async {
    if (!await needDeploy()) {
      debugPrint('Account already deployed');
      return true;
    }
    final provider = await apiProvider();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final address = response.address;

    final userBalance = await getUserBalance(address: address);

    if (userBalance < maxFeeEth / pow(10, 18)) {
      throw Exception('Need $maxFeeEth STRK ETH to deploy');
    }

    final signer = Signer(privateKey: Felt.fromHexString(response.privateKey!));

    final tx = await Account.deployAccount(
      signer: signer,
      provider: provider,
      classHash: Felt.fromHexString(classHash),
      constructorCalldata: [signer.publicKey],
      max_fee: Felt.fromInt(maxFeeWei),
    );
    final txHash = tx.when(
      result: (result) {
        debugPrint(
          'Account is deployed at ${result.contractAddress.toHexString()} (tx: ${result.transactionHash.toHexString()})',
        );
        return result.transactionHash;
      },
      error: (error) => throw Exception(
        'Account deploy failed: ${error.code}: ${error.message}',
      ),
    );
    final isAccepted = await waitForAcceptance(
      transactionHash: txHash.toHexString(),
      provider: provider,
    );

    if (!isAccepted) {
      final receipt = await provider.getTransactionReceipt(txHash);
      prettyPrintJson(receipt.toJson());
      throw Exception("error deploying account");
    }

    return isAccepted;
  }

  Future<JsonRpcProvider> apiProvider() async {
    return JsonRpcProvider(nodeUri: Uri.parse(api));
  }

  Future<Felt> getChainId() async {
    final provider = await apiProvider();
    final chainId = await provider.chainId();
    return chainId.when(
      result: (result) => Felt.fromHexString(result),
      error: (error) => throw Exception(error),
    );
  }

  @override
  validateAddress(String address) {
    if (!address.startsWith('0x')) {
      address = '0x$address';
    }
    final isValid = isHexString(address);
    final correctLength = address.length >= 65 && address.length <= 66;

    if (!isValid) {
      throw Exception('Invalid $symbol address: $address');
    }

    if (!correctLength) {
      throw Exception('Invalid $symbol address');
    }
  }

  @override
  int decimals() {
    return starkDecimals;
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

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final base = BigInt.from(10);
    final provider = await apiProvider();
    final chainId = await getChainId();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = Signer(privateKey: Felt.fromHexString(response.privateKey!));

    final fundingAccount = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final wei = amount.toBigIntDec(decimals());

    final maxFee = await fundingAccount.getEstimateMaxFeeForInvokeTx(
      functionCalls: [
        FunctionCall(
          contractAddress: Felt.fromHexString(contractAddress),
          entryPointSelector: getSelectorByName("transfer"),
          calldata: [
            Felt.fromHexString(to),
            Felt(wei),
            Felt.zero,
          ],
        ),
      ],
      useSTRKFee: useStarkToken,
    );

    return maxFee.maxFee.toBigInt() / base.pow(decimals());
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/contract/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<StarknetCoin> getStarknetBlockchains() {
  List<StarknetCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      StarknetCoin(
        blockExplorer:
            'https://sepolia.voyager.online/tx/$blockExplorerPlaceholder',
        symbol: 'STRK',
        name: 'Starknet (Testnet)',
        default_: 'STRK',
        image: 'assets/starknet.png',
        api:
            "https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/gpR0c9Le2dR45Fqit9OXTz6dtpf1HPfa",
        geckoID: "starknet",
        payScheme: 'starknet',
        rampID: '',
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        contractAddress: strkNativeToken,
        useStarkToken: true,
      ),
      StarknetCoin(
        blockExplorer:
            'https://sepolia.voyager.online/tx/$blockExplorerPlaceholder',
        api: "https://starknet-sepolia.public.blastapi.io/rpc/v0_7",
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        contractAddress: strkEthNativeToken,
        symbol: 'ETH (STRK)',
        name: 'Ethereum (STRK)',
        default_: 'ETH',
        image: 'assets/ethereum_logo.png',
        geckoID: "ethereum",
        payScheme: 'ethereum',
        rampID: 'ETH_ETH',
        useStarkToken: false,
      ),
    ]);
  } else {
    blockChains.addAll([
      StarknetCoin(
        blockExplorer: 'https://voyager.online/tx/$blockExplorerPlaceholder',
        symbol: 'STRK',
        name: 'Starknet',
        default_: 'STRK',
        image: 'assets/starknet.png',
        api: "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
        geckoID: "starknet",
        payScheme: 'starknet',
        rampID: '',
        classHash:
            '0x05b4b537eaa2399e3aa99c4e2e0208ebd6c71bc1467938cd52c798c601e43564',
        contractAddress: strkNativeToken,
        useStarkToken: true,
      ),
    ]);
  }
  return blockChains;
}

class StarknetDeriveArgs {
  final String mnemonic;
  final String classHash;

  const StarknetDeriveArgs({
    required this.mnemonic,
    required this.classHash,
  });
}

// 0x050d4da9f66589eadaa1d5e31cf73b08ac1a67c8b4dcd88e6fd4fe501c628af2

Future<Map> calculateStarknetKey(StarknetDeriveArgs config) async {
  final privateKey = derivePrivateKey(mnemonic: config.mnemonic);
  final signer = Signer(privateKey: privateKey);

  final address = Contract.computeAddress(
    classHash: Felt.fromHexString(config.classHash),
    calldata: [signer.publicKey],
    salt: signer.publicKey,
  );
  return {
    'address': address.toHexString(),
    'privateKey': signer.privateKey.toHexString(),
  };
}

class TxResult {
  final Felt contractAddress;
  final String transactionHash;

  Map<String, dynamic> toJson() {
    return {
      'contractAddress': contractAddress.toHexString(),
      'transactionHash': transactionHash,
    };
  }

  factory TxResult.fromJson(Map<dynamic, dynamic> json) {
    return TxResult(
      Felt.fromHexString(json['contractAddress']!),
      json['transactionHash'],
    );
  }

  TxResult(this.contractAddress, this.transactionHash);
}

class QuoteRequest {
  final String sellTokenAddress;
  final String buyTokenAddress;
  final BigInt? sellAmount;
  final BigInt? buyAmount;
  final String? takerAddress;
  final int? size;
  final List<String>? excludeSources;
  final BigInt? integratorFees;
  final String? integratorFeeRecipient;
  final String? integratorName;

  QuoteRequest({
    required this.sellTokenAddress,
    required this.buyTokenAddress,
    this.sellAmount,
    this.buyAmount,
    this.takerAddress,
    this.size,
    this.excludeSources,
    this.integratorFees,
    this.integratorFeeRecipient,
    this.integratorName,
  });

  Map<String, dynamic> toQueryParams() {
    final params = {
      'sellTokenAddress': sellTokenAddress,
      'buyTokenAddress': buyTokenAddress,
      if (sellAmount != null)
        'sellAmount': '0x${sellAmount!.toRadixString(16)}',
      if (buyAmount != null) 'buyAmount': '0x${buyAmount!.toRadixString(16)}',
      if (takerAddress != null) 'takerAddress': takerAddress,
      if (size != null) 'size': size.toString(),
      if (excludeSources != null) 'excludeSources': excludeSources,
      if (integratorFees != null)
        'integratorFees': '0x${integratorFees!.toRadixString(16)}',
      if (integratorFeeRecipient != null)
        'integratorFeeRecipient': integratorFeeRecipient,
      if (integratorName != null) 'integratorName': integratorName,
    };
    return params;
  }
}

class Gasless {
  final bool active;
  final List<GasTokenPrice> gasTokenPrices;

  Gasless({required this.active, required this.gasTokenPrices});

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'gasTokenPrices': gasTokenPrices.map((e) => e.toJson()).toList(),
    };
  }

  factory Gasless.fromJson(Map<String, dynamic> json) {
    return Gasless(
      active: json['active'],
      gasTokenPrices: (json['gasTokenPrices'] as List)
          .map((e) => GasTokenPrice.fromJson(e))
          .toList(),
    );
  }
}

class GasTokenPrice {
  final String tokenAddress;
  final double gasFeesInUsd;
  final BigInt gasFeesInGasToken;

  GasTokenPrice({
    required this.tokenAddress,
    required this.gasFeesInUsd,
    required this.gasFeesInGasToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenAddress': tokenAddress,
      'gasFeesInUsd': gasFeesInUsd,
      'gasFeesInGasToken': gasFeesInGasToken.toString(),
    };
  }

  factory GasTokenPrice.fromJson(Map<String, dynamic> json) {
    return GasTokenPrice(
      tokenAddress: json['tokenAddress'],
      gasFeesInUsd: json['gasFeesInUsd'],
      gasFeesInGasToken: BigInt.parse(json['gasFeesInGasToken'].toString()),
    );
  }
}

class Route {
  final String name;
  final String address;
  final double percent;
  final String sellTokenAddress;
  final String buyTokenAddress;
  final Map<String, String>? routeInfo;
  final List<Route> routes;

  Route({
    required this.name,
    required this.address,
    required this.percent,
    required this.sellTokenAddress,
    required this.buyTokenAddress,
    this.routeInfo,
    required this.routes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'percent': percent,
      'sellTokenAddress': sellTokenAddress,
      'buyTokenAddress': buyTokenAddress,
      'routeInfo': routeInfo,
      'routes': routes.map((e) => e.toJson()).toList(),
    };
  }

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      name: json['name'],
      address: json['address'],
      percent: json['percent'],
      sellTokenAddress: json['sellTokenAddress'],
      buyTokenAddress: json['buyTokenAddress'],
      routeInfo: json['routeInfo'] != null
          ? Map<String, String>.from(json['routeInfo'])
          : null,
      routes: (json['routes'] as List).map((e) => Route.fromJson(e)).toList(),
    );
  }
}

class Quote {
  final String quoteId;
  final String sellTokenAddress;
  final BigInt sellAmount;
  final double sellAmountInUsd;
  final String buyTokenAddress;
  final BigInt buyAmount;
  final double buyAmountInUsd;
  final BigInt buyAmountWithoutFees;
  final double buyAmountWithoutFeesInUsd;
  final int? blockNumber;
  final String chainId;
  final int? expiry;
  final List<Route> routes;
  final BigInt gasFees;
  final double gasFeesInUsd;
  final BigInt avnuFees;
  final double avnuFeesInUsd;
  final BigInt avnuFeesBps;
  final BigInt integratorFees;
  final double integratorFeesInUsd;
  final BigInt integratorFeesBps;
  final double priceRatioUsd;
  final double? sellTokenPriceInUsd;
  final double? buyTokenPriceInUsd;
  final String liquiditySource;
  final Gasless gasless;
  final bool? exactTokenTo;

  Quote({
    required this.quoteId,
    required this.sellTokenAddress,
    required this.sellAmount,
    required this.sellAmountInUsd,
    required this.buyTokenAddress,
    required this.buyAmount,
    required this.buyAmountInUsd,
    required this.buyAmountWithoutFees,
    required this.buyAmountWithoutFeesInUsd,
    this.blockNumber,
    required this.chainId,
    this.expiry,
    required this.routes,
    required this.gasFees,
    required this.gasFeesInUsd,
    required this.avnuFees,
    required this.avnuFeesInUsd,
    required this.avnuFeesBps,
    required this.integratorFees,
    required this.integratorFeesInUsd,
    required this.integratorFeesBps,
    required this.priceRatioUsd,
    this.sellTokenPriceInUsd,
    this.buyTokenPriceInUsd,
    required this.liquiditySource,
    required this.gasless,
    this.exactTokenTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'quoteId': quoteId,
      'sellTokenAddress': sellTokenAddress,
      'sellAmount': sellAmount.toString(),
      'sellAmountInUsd': sellAmountInUsd,
      'buyTokenAddress': buyTokenAddress,
      'buyAmount': buyAmount.toString(),
      'buyAmountInUsd': buyAmountInUsd,
      'buyAmountWithoutFees': buyAmountWithoutFees.toString(),
      'buyAmountWithoutFeesInUsd': buyAmountWithoutFeesInUsd,
      'blockNumber': blockNumber,
      'chainId': chainId,
      'expiry': expiry,
      'routes': routes.map((e) => e.toJson()).toList(),
      'gasFees': gasFees.toString(),
      'gasFeesInUsd': gasFeesInUsd,
      'avnuFees': avnuFees.toString(),
      'avnuFeesInUsd': avnuFeesInUsd,
      'avnuFeesBps': avnuFeesBps.toString(),
      'integratorFees': integratorFees.toString(),
      'integratorFeesInUsd': integratorFeesInUsd,
      'integratorFeesBps': integratorFeesBps.toString(),
      'priceRatioUsd': priceRatioUsd,
      'sellTokenPriceInUsd': sellTokenPriceInUsd,
      'buyTokenPriceInUsd': buyTokenPriceInUsd,
      'liquiditySource': liquiditySource,
      'gasless': gasless.toJson(),
      if (exactTokenTo != null) 'exactTokenTo': exactTokenTo,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quoteId: json['quoteId'],
      sellTokenAddress: json['sellTokenAddress'],
      sellAmount: BigInt.parse(json['sellAmount'].toString()),
      sellAmountInUsd: json['sellAmountInUsd'].toDouble(),
      buyTokenAddress: json['buyTokenAddress'],
      buyAmount: BigInt.parse(json['buyAmount'].toString()),
      buyAmountInUsd: json['buyAmountInUsd'].toDouble(),
      buyAmountWithoutFees:
          BigInt.parse(json['buyAmountWithoutFees'].toString()),
      buyAmountWithoutFeesInUsd: json['buyAmountWithoutFeesInUsd'].toDouble(),
      blockNumber: json['blockNumber'].runtimeType == String
          ? int.parse(json['blockNumber'])
          : json['blockNumber'],
      chainId: json['chainId'],
      expiry: json['expiry'],
      routes: (json['routes'] as List).map((e) => Route.fromJson(e)).toList(),
      gasFees: BigInt.parse(json['gasFees'].toString()),
      gasFeesInUsd: json['gasFeesInUsd'].toDouble(),
      avnuFees: BigInt.parse(json['avnuFees'].toString()),
      avnuFeesInUsd: json['avnuFeesInUsd'].toDouble(),
      avnuFeesBps: BigInt.parse(json['avnuFeesBps'].toString()),
      integratorFees: BigInt.parse(json['integratorFees'].toString()),
      integratorFeesInUsd: json['integratorFeesInUsd'].toDouble(),
      integratorFeesBps: BigInt.parse(json['integratorFeesBps'].toString()),
      priceRatioUsd: json['priceRatioUsd'].toDouble(),
      sellTokenPriceInUsd: json['sellTokenPriceInUsd']?.toDouble(),
      buyTokenPriceInUsd: json['buyTokenPriceInUsd']?.toDouble(),
      liquiditySource: json['liquiditySource'],
      gasless: Gasless.fromJson(json['gasless']),
      exactTokenTo: json['exactTokenTo'],
    );
  }
}

Future<List<Quote>> fetchQuotes(QuoteRequest request, {String? baseUrl}) async {
  if (request.sellAmount == null && request.buyAmount == null) {
    throw ArgumentError('Sell amount or buy amount is required');
  }

  final url = Uri.parse('${baseUrl ?? 'https://api.avnu.fi'}/swap/v2/quotes')
      .replace(queryParameters: request.toQueryParams());

  final response = await http.get(url, headers: {'Accept': 'application/json'});

  if (response.statusCode == 400 || response.statusCode == 500) {
    final error = jsonDecode(response.body);
    final message = error['messages']?.first ?? 'Unknown error';
    throw Exception(message);
  }

  if (response.statusCode > 400) {
    throw Exception('${response.statusCode} ${response.reasonPhrase}');
  }

  final List<dynamic> responseData = jsonDecode(response.body);

  return responseData.map((json) => Quote.fromJson(json)).toList();
}

class CallData {
  final String contractAddress;
  final String entrypoint;
  final List<String> calldata;

  CallData({
    required this.contractAddress,
    required this.entrypoint,
    required this.calldata,
  });

  factory CallData.fromJson(Map<String, dynamic> json) {
    return CallData(
      contractAddress: json['contractAddress'],
      entrypoint: json['entrypoint'],
      calldata: List<String>.from(json['calldata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractAddress': contractAddress,
      'entrypoint': entrypoint,
      'calldata': calldata,
    };
  }
}

class PoolMember {
  final Felt rewardAddress;
  final Felt amount;
  final Felt index;
  final Felt unclaimedRewards;
  final Felt commission;
  final Felt unpoolAmount;
  final Felt unpoolTime;
  const PoolMember({
    required this.rewardAddress,
    required this.amount,
    required this.index,
    required this.unclaimedRewards,
    required this.commission,
    required this.unpoolAmount,
    required this.unpoolTime,
  });

  factory PoolMember.fromJson(List<Felt> poolData) {
    return PoolMember(
      rewardAddress: poolData[0],
      amount: poolData[1],
      index: poolData[2],
      unclaimedRewards: poolData[3],
      commission: poolData[4],
      unpoolAmount: poolData[5],
      unpoolTime: poolData[6],
    );
  }
}

class PendingUnstake {
  final BigInt amount;
  final DateTime? unlockDate;
  final bool unlocked;
  const PendingUnstake({
    required this.amount,
    this.unlockDate,
    required this.unlocked,
  });
}

class StakeInfo {
  final Felt rewardAddress;
  final BigInt stake;
  final BigInt totalStake;
  final BigInt pendingRewards;
  final PendingUnstake? pendingUnstake;
  const StakeInfo({
    required this.rewardAddress,
    required this.stake,
    required this.totalStake,
    required this.pendingRewards,
    this.pendingUnstake,
  });
}
