import 'dart:convert';
import 'dart:math';
import 'package:fraction/fraction.dart';
import 'package:wallet_app/coins/starknet_quote.helper.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/screens/stake_token.dart';
import 'package:wallet_app/screens/view_starknet_nfts.dart';
import 'package:wallet_app/service/ai_agent_service.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/percent.dart';
import 'package:wallet_app/utils/snip12/shortstring.dart';
import 'package:wallet_app/utils/starknet_call.dart';
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
double ekuboTickSize = 1.000001;
int ekuboTickSpacing = 5982;
const ekuboMaxPrice = "0x100000000000000000000000000000000";
const ekuboFeesMultiplicator = ekuboMaxPrice;

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
  String multiCallAddress;
  String factoryAddress;
  String tokenClassHash;

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
    required this.multiCallAddress,
    required this.factoryAddress,
    required this.tokenClassHash,
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
      multiCallAddress: json['multiCallAddress'],
      factoryAddress: json['factoryAddress'],
      tokenClassHash: json['tokenClassHash'],
    );
  }

  int compareVersions(String v1, String v2) {
    List<int> parseVersion(String version) =>
        version.split('.').map(int.parse).toList();

    final parts1 = parseVersion(v1);
    final parts2 = parseVersion(v2);

    final maxLength =
        parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }

  Future<DeclareTransactionResponseResult?> addDeclareDapp(
    AddDeclareTransactionParameters params,
  ) async {
    if (await needDeploy()) {
      await deployAccount();
    }
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(walletData);
    final signer = StarkAccountSigner(
      signer: StarkSigner(
        privateKey: Felt.fromHexString(
          response.privateKey!,
        ),
      ),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();

    // Create the funding account instance
    final fundingAccount = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final compilerVersion = params.contractClass.contractClassVersion;
    final compiledClassHash = BigInt.parse(params.compiledClassHash);
    final entryPoints = params.contractClass.entryPointsByType;

    late DeclareTransactionResponse declareTrxResponse;

    // Determine which contract type to use based on compiler version
    if (compareVersions(compilerVersion, '1.1.0') >= 0) {
      // New CASMCompiledContract
      declareTrxResponse = await fundingAccount.declare(
        compiledContract: CASMCompiledContract(
          bytecode:
              params.contractClass.sierraProgram.map(BigInt.parse).toList(),
          entryPointsByType: CASMEntryPointsByType(
            constructor: entryPoints.constructor
                .map(
                  (e) => CASMEntryPoint(
                      selector: e.selector,
                      offset: e.functionIdx,
                      builtins: []),
                )
                .toList(),
            external: entryPoints.external
                .map(
                  (e) => CASMEntryPoint(
                      selector: e.selector,
                      offset: e.functionIdx,
                      builtins: []),
                )
                .toList(),
            l1Handler: entryPoints.l1Handler
                .map(
                  (e) => CASMEntryPoint(
                      selector: e.selector,
                      offset: e.functionIdx,
                      builtins: []),
                )
                .toList(),
          ),
          compilerVersion: compilerVersion,
          bytecodeSegmentLengths: [], // Provide if available; otherwise, empty
        ),
        compiledClassHash: compiledClassHash,
      );
    } else {
      // Deprecated contract format
      declareTrxResponse = await fundingAccount.declare(
        compiledContract: DeprecatedCompiledContract(
          program: {
            'sierra_program': params.contractClass.sierraProgram
                .map((e) => e.toString())
                .toList(),
          },
          abi: params.contractClass.abi
              .map((ab) => DeprecatedContractAbiEntry.fromJson(
                  ab as Map<String, dynamic>))
              .toList(),
          entryPointsByType: DeprecatedCairoEntryPointsByType(
            constructor: entryPoints.constructor
                .map(
                  (e) => DeprecatedCairoEntryPoint(
                      selector: e.selector, offset: e.functionIdx.toString()),
                )
                .toList(),
            external: entryPoints.external
                .map(
                  (e) => DeprecatedCairoEntryPoint(
                      selector: e.selector, offset: e.functionIdx.toString()),
                )
                .toList(),
            l1Handler: entryPoints.l1Handler
                .map(
                  (e) => DeprecatedCairoEntryPoint(
                      selector: e.selector, offset: e.functionIdx.toString()),
                )
                .toList(),
          ),
        ),
        compiledClassHash: compiledClassHash,
      );
    }

    // Handle the response and extract transaction hash or throw an error
    final declareResult = declareTrxResponse.when(
      result: (result) {
        debugPrint(
            'Account is deployed (tx: ${result.transactionHash.toHexString()})');
        return result;
      },
      error: (error) => throw Exception(
          'Account deploy failed: ${error.code}: ${error.message}'),
    );

    // Wait for transaction acceptance on-chain
    final isAccepted = await waitForAcceptance(
      transactionHash: declareResult.transactionHash.toHexString(),
      provider: provider,
    );

    return isAccepted ? declareResult : null;
  }

  @override
  Widget? getNFTPage() => ViewStarknetNFTs(starknetCoin: this);

  Future<List<StarknetNFT>> getStarknetNFTs({
    required String address,
    required bool useCache,
  }) async {
    final tokenListKey = 'tokenListKey_$api-$address/__$enableTestNet';
    final tokenList = pref.get(tokenListKey);
    List<StarknetNFT> userTokens = [];
    if (tokenList != null) {
      final tokensResponse = jsonDecode(tokenList);
      final List<dynamic> nftsData = tokensResponse['nfts'];
      userTokens = nftsData.map((nft) => StarknetNFT.fromJson(nft)).toList();
    }
    if (useCache) return userTokens;
    try {
      address =
          '0x031c0b3ce1e629066ff59578f212a1bd2db6efda0788d718fb5303df90292772';
      final url = Uri.parse(
          'https://starknet-${enableTestNet ? "mainnet" : "mainnet"}.blastapi.io/$blastApiProjectId/builder/getWalletNFTs?walletAddress=$address');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        await pref.put(tokenListKey, response.body);
        final data = jsonDecode(response.body);
        final List<dynamic> nftsData = data['nfts'];
        return nftsData.map((nft) => StarknetNFT.fromJson(nft)).toList();
      }
      return userTokens;
    } catch (e) {
      return userTokens;
    }
  }

  Future<String?> executeInvokeDapp(List<StarknetCall> calls) async {
    if (await needDeploy()) {
      await deployAccount();
    }
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    final fundingAccount = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final tx = await fundingAccount.execute(
      functionCalls: calls
          .map(
            (call) => FunctionCall(
              contractAddress: Felt.fromHexString(call.contractAddress),
              entryPointSelector: getSelectorByName(call.entryPoint),
              calldata: call.calldata
                  .map((data) => Felt(BigInt.parse(data)))
                  .toList(),
            ),
          )
          .toList(),
    );
    return tx.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception("Error transfer (${error.code}): ${error.message}");
      },
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

    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: privateKeyBytes),
    );

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
    String saveKey = 'CairoStarknetUserAcc${walletImportType.name}$api';
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
  Future<double> getBalance(bool useCache) async {
    String address = await getAddress();

    final key = 'StarknetAddressBalance$address$api$name';

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
      debugPrint(e.toString());
      return savedBalance;
    }
  }

  @override
  String? tokenAddress() =>
      getStarknetBlockchains().first.name == name ? null : contractAddress;

  @override
  Widget? getStakingPage() {
    if (getStarknetBlockchains().first.name != name) return null;
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
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );

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

  Future<List<Quote>> fetchQuotes(QuoteRequest request,
      {String? baseUrl}) async {
    if (request.sellAmount == null && request.buyAmount == null) {
      throw ArgumentError('Sell amount or buy amount is required');
    }

    final url = Uri.parse('${baseUrl ?? 'https://api.avnu.fi'}/swap/v2/quotes')
        .replace(queryParameters: request.toQueryParams());

    final response =
        await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 400 || response.statusCode == 500) {
      final error = jsonDecode(response.body);
      final message = error['messages']?.first ?? 'Unknown error';
      throw Exception(message);
    }

    if (response.statusCode > 400) {
      throw Exception('${response.statusCode} ${response.reasonPhrase}');
    }

    final List<dynamic> responseData = jsonDecode(response.body);
    final unit = pow(10, await getTokenDecimals(request.buyTokenAddress));

    return responseData.map((json) {
      final buyAmount = BigInt.parse(json['buyAmount'].toString());
      json['quoteAmount'] = buyAmount / BigInt.from(unit);
      return Quote.fromJson(json);
    }).toList();
  }

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
    final quote = quotes.reduce((a, b) {
      final aBuyAmount = a.buyAmount;
      final bBuyAmount = b.buyAmount;
      return aBuyAmount > bBuyAmount ? a : b;
    });
    return jsonEncode(quote.toJson());
  }

  Felt get delegationPoolAddress => Felt.fromHexString(
      '0x07134aad6969880f11b2d50e57c6e8d38ceef3a6b02bd9ea44837bd257023f6b');

  Contract getStakingContract(Account account) {
    return Contract(
      account: account,
      address: delegationPoolAddress,
    );
  }

  Contract getStarkContract(Account account) {
    return Contract(
      account: account,
      address: Felt.fromHexString(strkNativeToken),
    );
  }

  Future<String> unStakeAction(Account account) async {
    final delegationPoolContract = getStakingContract(account);
    final unstakeCall = FunctionCall(
      contractAddress: delegationPoolContract.address,
      entryPointSelector: getSelectorByName('exit_delegation_pool_action'),
      calldata: [account.accountAddress],
    );
    final result = await account.execute(functionCalls: [unstakeCall]);
    return result.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception("Error transfer (${error.code}): ${error.message}");
      },
    );
  }

  @override
  Future<String?> claimRewards(String amount) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final delegationPoolContract = getStakingContract(account);
    final claimCall = FunctionCall(
      contractAddress: delegationPoolContract.address,
      entryPointSelector: getSelectorByName('claim_rewards'),
      calldata: [account.accountAddress],
    );
    final rsult = await account.execute(functionCalls: [claimCall]);
    return rsult.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception(
          "Error claiming rewards (${error.code}): ${error.message}",
        );
      },
    );
  }

  @override
  Future<String?> unstakeToken(String amount) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final wei = amount.toBigIntDec(decimals());
    final delegationPoolContract = getStakingContract(account);
    final unstakeCall = FunctionCall(
      contractAddress: delegationPoolContract.address,
      entryPointSelector: getSelectorByName('exit_delegation_pool_intent'),
      calldata: [Felt(wei)],
    );
    final rsult = await account.execute(functionCalls: [unstakeCall]);
    return rsult.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception("Error unstaking (${error.code}): ${error.message}");
      },
    );
  }

  @override
  Future<String?> stakeToken(String amount) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final strkContract = getStarkContract(account);

    final wei = amount.toBigIntDec(decimals());

    final allowanceCall = FunctionCall(
      contractAddress: strkContract.address,
      entryPointSelector: getSelectorByName('approve'),
      calldata: [delegationPoolAddress, Felt(wei), Felt.zero],
    );

    final delegationPoolContract = getStakingContract(account);

    final existingStake = await getStakeInfo(account);

    List<FunctionCall> calls = [];

    if (existingStake == null) {
      debugPrint('No existing stake found');
      calls.addAll([
        allowanceCall,
        FunctionCall(
          contractAddress: delegationPoolContract.address,
          entryPointSelector: getSelectorByName('enter_delegation_pool'),
          calldata: [account.accountAddress, Felt(wei)],
        )
      ]);
    } else {
      calls.addAll([
        allowanceCall,
        FunctionCall(
          contractAddress: delegationPoolContract.address,
          entryPointSelector: getSelectorByName('add_to_delegation_pool'),
          calldata: [account.accountAddress, Felt(wei)],
        )
      ]);
    }

    final rsult = await account.execute(functionCalls: calls);

    return rsult.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception("Error staking (${error.code}): ${error.message}");
      },
    );
  }

  Future<StakeInfo?> getStakeInfo(Account account) async {
    final delegationPoolContract = getStakingContract(account);

    final poolData = await delegationPoolContract.call(
      'pool_member_info_v1',
      [account.accountAddress],
    );

    if (poolData.length == 1) {
      return null;
    }

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

    debugPrint('Pending Unstake: $totalStake');

    return StakeInfo(
      rewardAddress: rewardAddress, // Felt
      stake: stake, // BigInt
      totalStake: totalStake, // BigInt
      pendingRewards: pendingRewards, // BigInt
      pendingUnstake: pendingUnstake, // PendingUnstake?
    );
  }

  @override
  Future<double?> getTotalStaked() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );
    final existingStake = await getStakeInfo(account);

    if (existingStake == null) {
      return 0;
    }
    return existingStake.totalStake / BigInt.from(pow(10, decimals()));
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
      final signer = StarkAccountSigner(
        signer:
            StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
      );
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
    final signer = StarkAccountSigner(
      signer: StarkSigner(privateKey: Felt.fromHexString(response.privateKey!)),
    );

    final userBalance = await getUserBalance(address: response.address);

    if (userBalance == 0) {
      throw Exception('Account has no balance');
    }

    final tx = await Account.deployAccount(
      accountSigner: signer,
      provider: provider,
      classHash: Felt.fromHexString(classHash),
      constructorCalldata: [signer.publicKey],
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
    final checkedAddress = zeroPadAddressTo66(address);
    final isValid = isHexString(checkedAddress);
    final correctLength = checkedAddress.length == 66;

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
    final signer = StarkAccountSigner(
      signer: StarkSigner(
        privateKey: Felt.fromHexString(
          response.privateKey!,
        ),
      ),
    );

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
  String? getDexScreener(String tokenaddress) {
    return null;
  }

  @override
  Future<DeployMeme> deployMemeCoin({
    required String name,
    required String symbol,
    required String initialSupply,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(
        privateKey: Felt.fromHexString(
          response.privateKey!,
        ),
      ),
    );
    final provider = await apiProvider();
    final chainId = await getChainId();
    if (tokenClassHash.isEmpty || factoryAddress.isEmpty) {
      debugPrint('Token class hash or factory address is empty');
      return const DeployMeme(
        tokenAddress: null,
        liquidityTx: null,
        deployTokenTx: null,
      );
    }
    final fundingAccount = Account(
      provider: provider,
      signer: signer,
      accountAddress: Felt.fromHexString(response.address),
      chainId: chainId,
    );

    final salt = Account.getSalt();

    final totalSupplyUint = Uint256(
      low: Felt(initialSupply.toBigIntDec(decimals())),
      high: Felt.zero,
    );

    final constructorCalldata = [
      fundingAccount.accountAddress,
      Felt.fromString(name),
      Felt.fromString(symbol),
      totalSupplyUint.low,
      totalSupplyUint.high,
      salt,
    ];

    final tokenAddress = calculateContractAddressFromHash(
      classHash: Felt.fromHexString(tokenClassHash),
      calldata: constructorCalldata.sublist(0, constructorCalldata.length - 1),
      salt: salt,
      deployerAddress: Felt.fromHexString(factoryAddress),
    );

    final dployTx = FunctionCall(
      contractAddress: Felt.fromHexString(factoryAddress),
      entryPointSelector: getSelectorByName('create_memecoin'),
      calldata: constructorCalldata,
    );

    final tx = await fundingAccount.execute(functionCalls: [dployTx]);

    final deployTokenTx = tx.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception(
          "Error transfer (${error.code}): ${error.message}  ${error.errorData}",
        );
      },
    );

    final isAccepted = await waitForAcceptance(
      transactionHash: deployTokenTx,
      provider: provider,
    );

    if (!isAccepted) {
      return const DeployMeme(
        tokenAddress: null,
        liquidityTx: null,
        deployTokenTx: null,
      );
    }

    final tenPercentSupply = totalSupplyUint.toBigInt() *
        BigInt.from(10) ~/
        BigInt.from(100) ~/
        BigInt.from(10).pow(18);

    debugPrint('waiting for token deployment ${tokenAddress.toHexString()}');

    await waitForContractDeployment(contractAddress: tokenAddress);

    debugPrint('contract deployed at ${tokenAddress.toHexString()}');

    final liquidityTx = await launchOnEkubo(
      LaunchParameters(
        starknetAccount: fundingAccount,
        memecoinAddress: tokenAddress.toHexString(),
        startingMarketCap: 1,
        holdLimit: '2.5',
        fees: '0.5',
        antiBotPeriodInSecs: 3600,
        currencyAddress: strkEthNativeToken,
        teamAllocations: [
          TeamAllocation(
            address: fundingAccount.accountAddress.toHexString(),
            amount: tenPercentSupply,
          )
        ],
      ),
    );
    return DeployMeme(
      liquidityTx: liquidityTx,
      deployTokenTx: deployTokenTx,
      tokenAddress: tokenAddress.toHexString(),
    );
  }

  Future<void> waitForContractDeployment({
    required Felt contractAddress,
  }) async {
    Duration timeout = const Duration(seconds: 60);
    Duration interval = const Duration(seconds: 2);
    final provider = await apiProvider();
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      try {
        final result = await provider.getClassHashAt(
          contractAddress: contractAddress,
          blockId: BlockId.latest,
        );

        final isDeployed = result.when(
          result: (hash) => true,
          error: (_) => false,
        );

        if (isDeployed) {
          debugPrint(
              '✅ Contract deployed and available at: ${contractAddress.toHexString()}');
          return;
        }
      } catch (e) {
        debugPrint(
          'Error checking contract deployment: $e',
        );
      }

      await Future.delayed(interval);
    }

    throw Exception(
      '❌ Contract at ${contractAddress.toHexString()} not visible on-chain after ${timeout.inSeconds} seconds.',
    );
  }

  Future<String?> launchOnEkubo(
    LaunchParameters params,
  ) async {
    final memecoin = await getMemecoin(params.memecoinAddress);
    if (memecoin == null) {
      throw Exception('Invalid memecoin address');
    }
    final provider = await apiProvider();
    final chainId = await getChainId();
    final chainIdHex = chainId.toHexString();
    final quoteToken =
        StarknetHelper.quoteTokens[chainIdHex]?[params.currencyAddress];
    if (quoteToken == null) {
      throw Exception('Invalid quote token address');
    }
    final data = EkuboLaunchData(
      quoteToken: quoteToken,
      startingMarketCap: params.startingMarketCap,
      antiBotPeriod: params.antiBotPeriodInSecs * 60,
      holdLimit: convertPercentageStringToPercent(params.holdLimit),
      teamAllocations: params.teamAllocations,
      fees: convertPercentageStringToPercent(params.fees),
      amm: 'Ekubo',
    );

    List<FunctionCall> calls = await getEkuboLaunchCalldata(memecoin, data);

    final res = await params.starknetAccount.execute(functionCalls: calls);
    final txHash = res.when(
      result: (result) {
        debugPrint(
          '(tx: ${result.transaction_hash})',
        );
        return result.transaction_hash;
      },
      error: (error) => throw Exception(
        'Token launch failed: ${error.code}: ${error.message} ${error.errorData}',
      ),
    );

    final isAccepted = await waitForAcceptance(
      transactionHash: txHash,
      provider: provider,
    );
    if (!isAccepted) {
      final receipt =
          await provider.getTransactionReceipt(Felt.fromHexString(txHash));
      prettyPrintJson(receipt.toJson());
      throw Exception("error launching token");
    }
    return txHash;
  }

  Future<DeploymentDataResult> getDeploymentData() async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = StarkAccountSigner(
      signer: StarkSigner(
        privateKey: Felt.fromHexString(
          response.privateKey!,
        ),
      ),
    );
    final pubKey = signer.publicKey.toHexString();
    return DeploymentDataResult(
      classHash: classHash,
      constructorCalldata: [pubKey],
      addressSalt: pubKey,
      contractAddress: response.address,
      version: 1,
    );
  }

  Future<List<FunctionCall>> getEkuboLaunchCalldata(
    (TokenMetadata, MemeLaunchData?)? memecoin,
    EkuboLaunchData data,
  ) async {
    Fraction quoteTokenPrice = await getPairPrice(data.quoteToken!.usdcPair);

    BigInt teamAllocationFraction = data.teamAllocations.fold(
      BigInt.zero,
      (BigInt acc, element) => acc + element.amount,
    );
    BigInt totalSupply = memecoin!.$1.totalSupply.toBigInt();

    Percent teamAllocationPercentage = Percent(
      teamAllocationFraction,
      BigInt.from(totalSupply / BigInt.from(10).pow(decimals())),
    );

    double startingMarketCap = data.startingMarketCap.toDouble();
    double quoteTokenPriceDouble = quoteTokenPrice.toDouble();
    double teamAllocationPercentageDouble = teamAllocationPercentage.toDouble();
    double feesMultiplier = data.fees.toDouble() + 1;

    double teamAllocationQuoteAmount =
        (startingMarketCap / quoteTokenPriceDouble) *
            teamAllocationPercentageDouble *
            feesMultiplier;

    double scale = decimalsScale(data.quoteToken!.decimals).toDouble();
    double rawAmount = teamAllocationQuoteAmount.toDouble() * scale;
    Uint256 uint256TeamAllocationQuoteAmount =
        Uint256.fromBigInt(BigInt.from(rawAmount.floor()));

    final initialPrice = (data.startingMarketCap /
        quoteTokenPrice.toDouble() *
        decimalsScale(decimals()).toDouble() /
        memecoin.$1.totalSupply.toBigInt().toDouble());

    final startingTickMag = getStartingTick(initialPrice);

    I129StartingTickParameters i129StartingTick = I129StartingTickParameters(
      mag: startingTickMag.abs(),
      sign: startingTickMag < 0,
    );

    final feesFrac = (data.fees.numerator / data.fees.denominator) *
        BigInt.parse(ekuboFeesMultiplicator).toDouble();

    final fees = Felt.fromDouble(feesFrac);

    final initialHolders = data.teamAllocations
        .map((allocation) => Felt.fromHexString(allocation.address))
        .toList();
    final initialHoldersAmounts_ = data.teamAllocations
        .map((allocation) => Uint256(
            low: Felt(allocation.amount * BigInt.from(scale)), high: Felt.zero))
        .toList();
    List<Felt> initialHoldersAmounts = [
      Felt.fromInt(initialHoldersAmounts_.length)
    ];

    for (int i = 0; i < initialHoldersAmounts_.length; i++) {
      final amount = initialHoldersAmounts_[i];
      initialHoldersAmounts.add(amount.low);
      initialHoldersAmounts.add(amount.high);
    }

    final transferCalldata = FunctionCall(
      calldata: [
        Felt.fromHexString(factoryAddress),
        uint256TeamAllocationQuoteAmount.low,
        uint256TeamAllocationQuoteAmount.high,
      ],
      contractAddress: Felt.fromHexString(data.quoteToken!.address),
      entryPointSelector: getSelectorByName('transfer'),
    );

    double holdLimitPercent = (data.holdLimit.numerator.toDouble() /
            data.holdLimit.denominator.toDouble()) *
        100;
    int ekuboBound = getStartingTick(BigInt.parse(ekuboMaxPrice).toDouble());

    final calldata = [
      Felt.fromHexString(memecoin.$1.address),
      Felt.fromInt(data.antiBotPeriod),
      Felt.fromDouble(holdLimitPercent * 100),
      Felt.fromHexString(data.quoteToken!.address),
      ...initialHolders.toCalldata(),
      ...initialHoldersAmounts,
      fees,
      Felt.fromInt(ekuboTickSpacing),
      Felt.fromInt(i129StartingTick.mag),
      Felt.fromInt(i129StartingTick.sign ? 1 : 0),
      Felt.fromInt(ekuboBound),
    ];

    final launchCalldata = FunctionCall(
      calldata: calldata,
      contractAddress: Felt.fromHexString(factoryAddress),
      entryPointSelector: getSelectorByName('launch_on_ekubo'),
    );

    return [
      transferCalldata,
      launchCalldata,
    ];
  }

  Future<Fraction> getPairPrice(UsdcPair? pair) async {
    final provider = await apiProvider();
    if (pair == null) {
      return Fraction(1, 1);
    }
    final reserveCall = await provider.call(
      request: FunctionCall(
        contractAddress: Felt.fromHexString(pair.address),
        entryPointSelector: getSelectorByName('get_reserves'),
        calldata: [],
      ),
      blockId: BlockId.latest,
    );
    final result = reserveCall.when(
      result: (result) {
        return result;
      },
      error: (error) {
        throw Exception(error);
      },
    );

    final [reserve0Low, reserve0High, reserve1Low, reserve1High, _] = result;
    final numerator = Uint256(low: reserve1Low, high: reserve1High).toBigInt();
    final denominator =
        Uint256(low: reserve0Low, high: reserve0High).toBigInt();

    Fraction pairPrice = Fraction.fromDouble(numerator / denominator);

    if (pair.reversed) {
      pairPrice = pairPrice.inverse();
    }
    pairPrice = pairPrice * Fraction.fromDouble(decimalsScale(12).toDouble());

    return pairPrice;
  }

  BigInt decimalsScale(int decimals) {
    return BigInt.from(10).pow(decimals);
  }

  Future<(TokenMetadata, MemeLaunchData?)?> getMemecoin(
    String memecoinAddress,
  ) async {
    validateAddress(memecoinAddress);
    final baseMemecoin = await getBaseMemecoin(memecoinAddress);
    if (baseMemecoin == null) return null;
    final launchData = await getMemecoinLaunchData(memecoinAddress);
    return (baseMemecoin, launchData);
  }

  Future<TokenMetadata?> getBaseMemecoin(String memecoinAddress) async {
    final result = await multiCallContract([
      FunctionCall(
        contractAddress: Felt.fromHexString(factoryAddress),
        entryPointSelector: getSelectorByName('is_memecoin'),
        calldata: [
          Felt.fromHexString(memecoinAddress),
        ],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoinAddress),
        entryPointSelector: getSelectorByName('name'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoinAddress),
        entryPointSelector: getSelectorByName('symbol'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoinAddress),
        entryPointSelector: getSelectorByName('owner'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoinAddress),
        entryPointSelector: getSelectorByName('total_supply'),
        calldata: [],
      ),
    ]);
    final [[isMemecoin], [name], [symbol], [owner], totalSupply] = result;
    if (isMemecoin == Felt.zero) return null;

    return TokenMetadata(
      address: memecoinAddress,
      name: decodeShortString(name.toHexString()), // String
      symbol: decodeShortString(symbol.toHexString()),
      owner: owner.toHexString(),
      decimals: 18,
      totalSupply: Uint256(low: totalSupply[0], high: totalSupply[1]),
    );
  }

  Future<MemeLaunchData?> getMemecoinLaunchData(String memecoin) async {
    final result = await multiCallContract([
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoin),
        entryPointSelector: getSelectorByName('get_team_allocation'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoin),
        entryPointSelector: getSelectorByName('launched_at_block_number'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoin),
        entryPointSelector: getSelectorByName('is_launched'),
        calldata: [],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(factoryAddress),
        entryPointSelector: getSelectorByName('locked_liquidity'),
        calldata: [Felt.fromHexString(memecoin)],
      ),
      FunctionCall(
        contractAddress: Felt.fromHexString(memecoin),
        entryPointSelector:
            getSelectorByName('launched_with_liquidity_parameters'),
        calldata: [],
      ),
    ]);

    final teamAllocation = result[0];
    final launchBlockNumber =
        (result[1] as List).isNotEmpty ? result[1][0] : null;
    final launched = (result[2] as List).isNotEmpty ? result[2][0] : null;

    final fourth = result[3];
    final dontHaveLiq = fourth.isNotEmpty ? fourth[0] : null;
    final lockManager = fourth.length > 1 ? fourth[1] : null;
    final liqTypeIndex = fourth.length > 2 ? fourth[2] : null;
    final ekuboId = fourth.length > 3 ? fourth[3] : null;
    final launchParams = result[4];

    final liquidityType =
        liqTypeIndex != null ? getLiquidityType(liqTypeIndex.toInt()) : null;
    final isLaunched = dontHaveLiq == Felt.zero &&
        launched == Felt.fromInt(1) &&
        launchParams[0] == Felt.zero &&
        liquidityType != null;
    if (!isLaunched) {
      return null;
    }
    late LiquidityQuoteToken liquidityQuote;
    JediLockDetails? jediLockDetails;
    EkuboLockDetails? ekuboLockDetails;
    switch (liquidityType) {
      case 'STARKDEFI_ERC20':
      case 'JEDISWAP_ERC20':
        final baseLiquidity = BaseLiquidity(
          type: liquidityType,
          lockManager: lockManager!,
          lockPosition: launchParams[5],
          quoteToken: launchParams[2],
          quoteAmount: Uint256(
            low: launchParams[3],
            high: launchParams[4],
          ).toBigInt(),
        );
        liquidityQuote = LiquidityQuoteToken(quoteToken: launchParams[2]);
        await getJediswapLiquidityLockPosition(baseLiquidity);
        break;
      case 'EKUBO_NFT':
        final ekuboLiquidity = EkuboLiquidity(
            type: liquidityType, // String?
            lockManager: lockManager!, // Felt
            ekuboId: ekuboId!, // Felt
            quoteToken: launchParams[7], // Felt
            startingTick: launchParams[4].toInt() *
                (launchParams[5] == Felt.fromInt(1) ? -1 : 1) // Felt
            );
        liquidityQuote = LiquidityQuoteToken(quoteToken: launchParams[7]);
        ekuboLockDetails = await getEkuboLiquidityLockPosition(ekuboLiquidity);
        break;
      default:
        throw Exception('Unknown liquidity type: $liquidityType');
    }

    final chainId = await getChainId();

    return MemeLaunchData(
      jediLockDetails: jediLockDetails, // JediLockDetails?
      ekuboLockDetails: ekuboLockDetails, // EkuboLockDetails?
      isLaunched: true, // bool
      quoteToken: StarknetHelper.quoteTokens[chainId.toHexString()]![
          liquidityQuote.quoteToken.toHexString()],
      launch: Launch(
        teamAllocation: Uint256(
          low: teamAllocation[0],
          high: teamAllocation[1],
        ).toBigInt(), // BigInt
        blockNumber: launchBlockNumber!.toBigInt(), // BigInt
      ),
      liquidity: liquidityQuote, // LiquidityQuote
    );
  }

  Future<JediLockDetails> getJediswapLiquidityLockPosition(
      BaseLiquidity liquidity) async {
    final provider = await apiProvider();
    final liqCall = await provider.call(
      request: FunctionCall(
        contractAddress: liquidity.lockManager,
        entryPointSelector: getSelectorByName('get_lock_details'),
        calldata: [liquidity.lockPosition],
      ),
      blockId: BlockId.latest,
    );
    final result = liqCall.when<List<Felt>>(
      error: (error) {
        throw Exception(error);
      },
      result: (result) {
        return result;
      },
    );
    return JediLockDetails(
      owner: result[3],
      unlockTime: result[4].toBigInt(),
    );
  }

  Future<EkuboLockDetails> getEkuboLiquidityLockPosition(
    EkuboLiquidity liquidity,
  ) async {
    BigInt liquidityLockForeverTimestamp = BigInt.from(9999999999);
    final provider = await apiProvider();
    final liqCall = await provider.call(
      request: FunctionCall(
        contractAddress: liquidity.lockManager,
        entryPointSelector: getSelectorByName('liquidity_position_details'),
        calldata: [liquidity.ekuboId],
      ),
      blockId: BlockId.latest,
    );
    final result = liqCall.when<List<Felt>>(
      error: (error) {
        throw Exception(error);
      },
      result: (result) {
        return result;
      },
    );

    return EkuboLockDetails(
      unlockTime: liquidityLockForeverTimestamp,
      owner: result[1],
      poolKey: PoolKey(
        token0: result[2],
        token1: result[3],
        fee: result[4],
        tickSpacing: result[5],
        extension: result[6],
      ),
      bounds: Bounds(
        lower: Bound(
          mag: result[7].toInt(),
          sign: result[8] == Felt.fromInt(1),
        ),
        upper: Bound(
          mag: result[9].toInt(),
          sign: result[10] == Felt.fromInt(1),
        ),
      ),
    );
  }

  String? getLiquidityType(int? liqTypeIndex) {
    switch (liqTypeIndex) {
      case 0:
        return 'JEDISWAP_ERC20';
      case 1:
        return 'STARKDEFI_ERC20';
      case 2:
        return 'EKUBO_NFT';
      default:
        return null;
    }
  }

  Future<List<List<Felt>>> multiCallContract(List<FunctionCall> calls) async {
    final provider = await apiProvider();
    Call providerCall = await provider.call(
      request: FunctionCall(
        contractAddress: Felt.fromHexString(multiCallAddress),
        entryPointSelector: getSelectorByName('aggregate'),
        calldata: functionCallsToCalldata(functionCalls: calls),
      ),
      blockId: BlockId.latest,
    );
    List<Felt> rawResult = providerCall.when(
      error: (error) {
        throw Exception(error);
      },
      result: (result) {
        return result;
      },
    );
    List<Felt> raw = rawResult.sublist(2);
    List<List<Felt>> result = [];
    int idx = 0;
    for (int i = 0; i < raw.length; i += idx + 1) {
      idx = int.parse(raw[i].toHexString());
      result.add(raw.sublist(i + 1, i + 1 + idx));
    }
    return result;
  }

  Felt calculateContractAddressFromHash({
    required Felt classHash,
    required List<Felt> calldata,
    required Felt salt,
    required Felt deployerAddress,
  }) {
    final constructorCalldataHash =
        computeHashOnElements(calldata.map((e) => e.toBigInt()).toList());
    final contractAddressPrefix = Felt.fromHexString(
      "0x535441524b4e45545f434f4e54524143545f41444452455353",
    );
    final hash = computeHashOnElements([
      contractAddressPrefix.toBigInt(),
      deployerAddress.toBigInt(),
      salt.toBigInt(),
      classHash.toBigInt(),
      constructorCalldataHash,
    ]);
    final BigInt maxStorageItemSize = BigInt.from(256);
    final BigInt modulus = (BigInt.two.pow(251)) - maxStorageItemSize;
    final BigInt address = hash % modulus;
    return Felt(address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;

  static String zeroPadAddressTo66(String address) {
    // Remove the '0x' prefix if present
    String hex = address.startsWith('0x') ? address.substring(2) : address;

    // Pad left with zeros to length 64 (32 bytes * 2 hex chars)
    String paddedHex = hex.padLeft(64, '0');

    // Add '0x' prefix back
    return '0x$paddedHex';
  }
}

List<StarknetCoin> getStarknetBlockchains() {
  List<StarknetCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      StarknetCoin(
        multiCallAddress:
            '0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a',
        blockExplorer:
            'https://sepolia.starkscan.co/tx/$blockExplorerPlaceholder',
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
        tokenClassHash: '',
        factoryAddress: '',
      ),
      StarknetCoin(
        multiCallAddress:
            '0x04d0390b777b424e43839cd1e744799f3de6c176c7e32c1812a41dbd9c19db6a',
        blockExplorer:
            'https://sepolia.starkscan.co/tx/$blockExplorerPlaceholder',
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
        tokenClassHash: '',
        factoryAddress: '',
      ),
    ]);
  } else {
    blockChains.addAll([
      StarknetCoin(
        multiCallAddress:
            '0x01a33330996310a1e3fa1df5b16c1e07f0491fdd20c441126e02613b948f0225',
        blockExplorer: 'https://starkscan.co/tx/$blockExplorerPlaceholder',
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
        tokenClassHash:
            '0x063ee878d3559583ceae80372c6088140e1180d9893aa65fbefc81f45ddaaa17',
        factoryAddress:
            '0x01a46467a9246f45c8c340f1f155266a26a71c07bd55d36e8d1c7d0d438a2dbc',
      ),
      StarknetCoin(
        multiCallAddress:
            '0x01a33330996310a1e3fa1df5b16c1e07f0491fdd20c441126e02613b948f0225',
        blockExplorer: 'https://starkscan.co/tx/$blockExplorerPlaceholder',
        api: "https://starknet-mainnet.public.blastapi.io/rpc/v0_7",
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
        tokenClassHash:
            '0x063ee878d3559583ceae80372c6088140e1180d9893aa65fbefc81f45ddaaa17',
        factoryAddress:
            '0x01a46467a9246f45c8c340f1f155266a26a71c07bd55d36e8d1c7d0d438a2dbc',
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

Future<Map> calculateStarknetKey(StarknetDeriveArgs config) async {
  final privateKey = derivePrivateKey(mnemonic: config.mnemonic);
  final signer = StarkAccountSigner(
    signer: StarkSigner(privateKey: privateKey),
  );

  final address = Contract.computeAddress(
    classHash: Felt.fromHexString(config.classHash),
    calldata: [signer.publicKey],
    salt: signer.publicKey,
  );

  return {
    'address': StarknetCoin.zeroPadAddressTo66(address.toHexString()),
    'privateKey': privateKey.toHexString(),
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
  final double quoteAmount;
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
    required this.quoteAmount,
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
      'quoteAmount': quoteAmount.toString(),
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
      quoteAmount: double.parse(json['quoteAmount'].toString()),
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

class DeployMeme {
  final String? liquidityTx;
  final String? tokenAddress;
  final String? deployTokenTx;
  const DeployMeme({
    required this.liquidityTx,
    required this.tokenAddress,
    required this.deployTokenTx,
  });
}

class SierraEntryPoint {
  final Felt selector;
  final int functionIdx;

  SierraEntryPoint({
    required this.selector,
    required this.functionIdx,
  });

  factory SierraEntryPoint.fromJson(Map<String, dynamic> json) {
    return SierraEntryPoint(
      selector: Felt.fromHexString(json['selector']),
      functionIdx: json['function_idx'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selector': selector,
      'function_idx': functionIdx,
    };
  }
}

class EntryPointsByType {
  final List<SierraEntryPoint> constructor;
  final List<SierraEntryPoint> external;
  final List<SierraEntryPoint> l1Handler;

  EntryPointsByType({
    required this.constructor,
    required this.external,
    required this.l1Handler,
  });

  factory EntryPointsByType.fromJson(Map<String, dynamic> json) {
    return EntryPointsByType(
      constructor: (json['CONSTRUCTOR'] as List)
          .map((e) => SierraEntryPoint.fromJson(e))
          .toList(),
      external: (json['EXTERNAL'] as List)
          .map((e) => SierraEntryPoint.fromJson(e))
          .toList(),
      l1Handler: (json['L1_HANDLER'] as List)
          .map((e) => SierraEntryPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CONSTRUCTOR': constructor.map((e) => e.toJson()).toList(),
      'EXTERNAL': external.map((e) => e.toJson()).toList(),
      'L1_HANDLER': l1Handler.map((e) => e.toJson()).toList(),
    };
  }
}

class ContractClass {
  final List<String> sierraProgram;
  final String contractClassVersion;
  final EntryPointsByType entryPointsByType;
  final List<dynamic> abi;

  ContractClass({
    required this.sierraProgram,
    required this.contractClassVersion,
    required this.entryPointsByType,
    required this.abi,
  });

  factory ContractClass.fromJson(Map<String, dynamic> json) {
    return ContractClass(
      sierraProgram: List<String>.from(json['sierra_program']),
      contractClassVersion: json['contract_class_version'] as String,
      entryPointsByType:
          EntryPointsByType.fromJson(json['entry_points_by_type']),
      abi: json['abi'] is String
          ? jsonDecode(json['abi']) as List<dynamic>
          : json['abi'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sierra_program': sierraProgram,
      'contract_class_version': contractClassVersion,
      'entry_points_by_type': entryPointsByType.toJson(),
      'abi': abi,
    };
  }
}

class AddDeclareTransactionParameters {
  final ContractClass contractClass;
  final String compiledClassHash;
  final String? classHash;

  AddDeclareTransactionParameters({
    required this.contractClass,
    required this.compiledClassHash,
    this.classHash,
  });

  factory AddDeclareTransactionParameters.fromJson(Map<String, dynamic> json) {
    return AddDeclareTransactionParameters(
      contractClass: ContractClass.fromJson(json['contract_class']),
      compiledClassHash: json['compiled_class_hash'] as String,
      classHash: json['class_hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, Object> map = {
      'contract_class': contractClass.toJson(),
      'compiled_class_hash': compiledClassHash,
    };
    if (classHash != null) {
      map['class_hash'] = classHash as Object;
    }
    return map;
  }

  // Utility to parse from JSON-encoded string
  static AddDeclareTransactionParameters fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return AddDeclareTransactionParameters.fromJson(jsonMap);
  }

  // Utility to convert object to JSON-encoded string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class LaunchParameters {
  final Account starknetAccount;
  final String memecoinAddress;
  final int startingMarketCap;
  final String holdLimit;
  final String fees;
  final int antiBotPeriodInSecs;
  final int? liquidityLockPeriod;
  final String currencyAddress;
  final List<TeamAllocation> teamAllocations;

  LaunchParameters({
    required this.starknetAccount,
    required this.memecoinAddress,
    required this.startingMarketCap,
    required this.holdLimit,
    required this.fees,
    required this.antiBotPeriodInSecs,
    this.liquidityLockPeriod,
    required this.currencyAddress,
    required this.teamAllocations,
  });

  Map<String, dynamic> toJson() => {
        'starknetAccount': starknetAccount.accountAddress.toHexString(),
        'memecoinAddress': memecoinAddress,
        'startingMarketCap': startingMarketCap,
        'holdLimit': holdLimit,
        'fees': fees,
        'antiBotPeriodInSecs': antiBotPeriodInSecs,
        if (liquidityLockPeriod != null)
          'liquidityLockPeriod': liquidityLockPeriod,
        'currencyAddress': currencyAddress,
        'teamAllocations': teamAllocations.map((t) => t.toJson()).toList(),
      };
}

class TeamAllocation {
  final String address;
  final BigInt amount;

  TeamAllocation({required this.address, required this.amount});

  Map<String, dynamic> toJson() => {
        'address': address,
        'amount': amount,
      };
}

class TokenMetadata {
  final String address;
  final String name;
  final String symbol;
  final String owner;
  final int decimals;
  final Uint256 totalSupply;

  TokenMetadata({
    required this.address,
    required this.name,
    required this.symbol,
    required this.owner,
    this.decimals = 18,
    required this.totalSupply,
  });

  factory TokenMetadata.fromStarknetData({
    required Felt memecoinAddress,
    required Felt name,
    required Felt symbol,
    required Felt owner,
    required List<Felt> totalSupply,
  }) {
    return TokenMetadata(
      address: memecoinAddress.toHexString(),
      name: decodeShortString(name.toHexString()),
      symbol: decodeShortString(symbol.toHexString()),
      owner: owner.toHexString(),
      totalSupply: Uint256(low: totalSupply[0], high: totalSupply[1]),
    );
  }
}

class BaseLiquidity {
  final String? type; // Nullable string
  final Felt lockManager;
  final Felt lockPosition;
  final Felt quoteToken;
  final BigInt quoteAmount;

  BaseLiquidity({
    required this.type,
    required this.lockManager,
    required this.lockPosition,
    required this.quoteToken,
    required this.quoteAmount,
  });

  factory BaseLiquidity.fromLaunchParams({
    required String? liquidityType,
    required Felt lockManager,
    required List<Felt> launchParams,
  }) {
    return BaseLiquidity(
      type: liquidityType,
      lockManager: lockManager,
      lockPosition: launchParams[5],
      quoteToken: launchParams[2],
      quoteAmount: Uint256(
        low: launchParams[3],
        high: launchParams[4],
      ).toBigInt(),
    );
  }
}

class JediLockDetails {
  final BigInt unlockTime;
  final Felt owner;

  JediLockDetails({
    required this.unlockTime,
    required this.owner,
  });
}

class EkuboLiquidity {
  final String? type; // Nullable string
  final Felt lockManager;
  final Felt ekuboId;
  final Felt quoteToken;
  final int startingTick;

  EkuboLiquidity({
    required this.type,
    required this.lockManager,
    required this.ekuboId,
    required this.quoteToken,
    required this.startingTick,
  });
}

class EkuboLockDetails {
  final BigInt unlockTime;
  final Felt owner;
  final PoolKey poolKey;
  final Bounds bounds;

  EkuboLockDetails({
    required this.unlockTime,
    required this.owner,
    required this.poolKey,
    required this.bounds,
  });
}

class PoolKey {
  final Felt token0;
  final Felt token1;
  final Felt fee;
  final Felt tickSpacing;
  final Felt extension;

  PoolKey({
    required this.token0,
    required this.token1,
    required this.fee,
    required this.tickSpacing,
    required this.extension,
  });
}

class Bounds {
  final Bound lower;
  final Bound upper;

  Bounds({
    required this.lower,
    required this.upper,
  });
}

class Bound {
  final int mag;
  final bool sign;

  Bound({
    required this.mag,
    required this.sign,
  });
}

class LiquidityQuoteToken {
  final Felt quoteToken;
  const LiquidityQuoteToken({
    required this.quoteToken,
  });
}

class MemeLaunchData {
  final bool isLaunched;
  final TokenInfo? quoteToken;
  final Launch launch;
  final LiquidityQuoteToken liquidity;
  final JediLockDetails? jediLockDetails;
  final EkuboLockDetails? ekuboLockDetails;

  MemeLaunchData({
    required this.isLaunched,
    required this.quoteToken,
    required this.launch,
    required this.liquidity,
    this.jediLockDetails,
    this.ekuboLockDetails,
  });
}

class Launch {
  final BigInt teamAllocation;
  final BigInt blockNumber;

  Launch({
    required this.teamAllocation,
    required this.blockNumber,
  });
}

class EkuboLaunchData {
  final String amm;
  final int antiBotPeriod;
  final Percent fees;
  final Percent holdLimit;
  final TokenInfo? quoteToken;
  final int startingMarketCap;
  final List<TeamAllocation> teamAllocations;

  EkuboLaunchData({
    required this.amm,
    required this.antiBotPeriod,
    required this.fees,
    required this.holdLimit,
    required this.quoteToken,
    required this.startingMarketCap,
    required this.teamAllocations,
  });

  Map<String, dynamic> toJson() {
    return {
      'amm': amm,
      'antiBotPeriod': antiBotPeriod,
      'fees': fees.toJson(),
      'holdLimit': holdLimit.toJson(),
      'quoteToken': quoteToken?.toJson(),
      'startingMarketCap': startingMarketCap,
      'teamAllocations': teamAllocations.map((t) => t.toJson()).toList(),
    };
  }
}

class I129StartingTickParameters {
  final int mag;
  final bool sign;

  I129StartingTickParameters({
    required this.mag,
    required this.sign,
  });
}

int getStartingTick(num initialPrice) {
  final double logInitialPrice = log(initialPrice);
  double ekuboTickSizeLog = log(ekuboTickSize);
  final double division = logInitialPrice / ekuboTickSizeLog / ekuboTickSpacing;
  final int floored = division.floor();
  return floored * ekuboTickSpacing;
}

class DeploymentDataResult {
  final String classHash;
  final List<String> constructorCalldata;
  final String addressSalt;
  final String contractAddress;
  final int version;

  const DeploymentDataResult({
    required this.classHash,
    required this.constructorCalldata,
    required this.addressSalt,
    required this.version,
    required this.contractAddress,
  });
}

class StarknetNFT {
  final String contractAddress;
  final String contractName;
  final String contractSymbol;
  final String contractType;
  final String tokenId;
  final String minterAddress;
  final int mintBlockNumber;
  final int mintTimestamp;
  final String mintTransactionHash;
  final String numberOfTokens;
  final int numberOfOwners;
  final String ownerAddress;
  final WalletBalance walletBalance;
  final String tokenUri;
  final String tokenMetadata;
  final String name;
  final String description;
  final String? externalLink;
  final String imageUrl;
  final String? animationUrl;

  StarknetNFT({
    required this.contractAddress,
    required this.contractName,
    required this.contractSymbol,
    required this.contractType,
    required this.tokenId,
    required this.minterAddress,
    required this.mintBlockNumber,
    required this.mintTimestamp,
    required this.mintTransactionHash,
    required this.numberOfTokens,
    required this.numberOfOwners,
    required this.ownerAddress,
    required this.walletBalance,
    required this.tokenUri,
    required this.tokenMetadata,
    required this.name,
    required this.description,
    this.externalLink,
    required this.imageUrl,
    this.animationUrl,
  });

  factory StarknetNFT.fromJson(Map<String, dynamic> json) {
    return StarknetNFT(
      contractAddress: json['contractAddress'],
      contractName: json['contractName'],
      contractSymbol: json['contractSymbol'],
      contractType: json['contractType'],
      tokenId: json['tokenId'],
      minterAddress: json['minterAddress'],
      mintBlockNumber: json['mintBlockNumber'],
      mintTimestamp: json['mintTimestamp'],
      mintTransactionHash: json['mintTransactionHash'],
      numberOfTokens: json['numberOfTokens'],
      numberOfOwners: json['numberOfOwners'],
      ownerAddress: json['ownerAddress'],
      walletBalance: WalletBalance.fromJson(json['walletBalance']),
      tokenUri: json['tokenUri'],
      tokenMetadata: json['tokenMetadata'],
      name: json['name'],
      description: json['description'],
      externalLink: json['externalLink'],
      imageUrl: json['imageUrl'],
      animationUrl: json['animationUrl'],
    );
  }
}

class WalletBalance {
  final String contractAddress;
  final String contractType;
  final String tokenId;
  final String walletAddress;
  final String tokenBalance;

  WalletBalance({
    required this.contractAddress,
    required this.contractType,
    required this.tokenId,
    required this.walletAddress,
    required this.tokenBalance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      contractAddress: json['contractAddress'],
      contractType: json['contractType'],
      tokenId: json['tokenId'],
      walletAddress: json['walletAddress'],
      tokenBalance: json['tokenBalance'],
    );
  }
}
