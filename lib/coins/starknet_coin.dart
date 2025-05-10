import 'dart:convert';

import 'package:cryptowallet/extensions/big_int_ext.dart';
import 'package:cryptowallet/service/wallet_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';

const starkDecimals = 18;

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
    String saveKey =
        'starknetDetailsPrivate$classHash${walletImportType.name}$api';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    debugPrint("getting address from private key");

    final address = Contract.computeAddress(
      classHash: Felt.fromHexString(classHash),
      calldata: [Signer(privateKey: Felt.fromHexString(privateKey)).publicKey],
      salt: Signer(privateKey: Felt.fromHexString(privateKey)).publicKey,
    ).toHexString();

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
    String saveKey = 'StarknetaDetails$classHash${walletImportType.name}$api';
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

      debugPrint('Balance: $userBalance');

      await pref.put(key, userBalance);
      return userBalance;
    } catch (e) {
      debugPrint(e.toString());
      return savedBalance;
    }
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

  @override
  Future<bool> deployAccount() async {
    if (!await needDeploy()) {
      debugPrint('Account already deployed');
      return true;
    }
    final provider = await apiProvider();
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final signer = Signer(privateKey: Felt.fromHexString(response.privateKey!));
    final tx = await Account.deployAccount(
      signer: signer,
      provider: provider,
      constructorCalldata: [signer.publicKey],
      classHash: Felt.fromHexString(classHash),
    );

    final results = tx.when(
      result: (result) => TxResult(
          result.contractAddress, result.transactionHash.toHexString()),
      error: (error) => throw Exception('${error.code}: ${error.message}'),
    );

    debugPrint('Deploying account: ${results.toJson()}');

    bool success = await waitForAcceptance(
      transactionHash: results.transactionHash,
      provider: provider,
    );

    return success;
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
      throw Exception('Invalid $symbol address');
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
            'https://voyager.online/contract/$blockExplorerPlaceholder',
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
            '0x61dac032f228abef9c6626f995015233097ae253a7f72d68552db02f2971b8f',
        contractAddress:
            '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d',
        useStarkToken: true,
      ),
      StarknetCoin(
        blockExplorer:
            'https://voyager.online/contract/$blockExplorerPlaceholder',
        api:
            "https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/gpR0c9Le2dR45Fqit9OXTz6dtpf1HPfa",
        classHash:
            '0x61dac032f228abef9c6626f995015233097ae253a7f72d68552db02f2971b8f',
        contractAddress:
            '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
        symbol: 'ETH',
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
        blockExplorer:
            'https://voyager.online/contract/$blockExplorerPlaceholder',
        symbol: 'STRK',
        name: 'Starknet',
        default_: 'STRK',
        image: 'assets/starknet.png',
        api:
            "https://starknet.g.alchemy.com/starknet/version/rpc/v0_7/gpR0c9Le2dR45Fqit9OXTz6dtpf1HPfa",
        geckoID: "starknet",
        payScheme: 'starknet',
        rampID: '',
        classHash:
            '0x61dac032f228abef9c6626f995015233097ae253a7f72d68552db02f2971b8f',
        contractAddress:
            '0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d',
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

Future<Map> calculateStarknetKey(StarknetDeriveArgs config) async {
  final privateKey = derivePrivateKey(mnemonic: config.mnemonic);

  final address = Contract.computeAddress(
    classHash: Felt.fromHexString(config.classHash),
    calldata: [Signer(privateKey: privateKey).publicKey],
    salt: Signer(privateKey: privateKey).publicKey,
  );
  return {
    'address': address.toHexString(),
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
