import 'package:flutter/material.dart';
import 'package:starknet/starknet.dart';
import 'package:starknet_provider/starknet_provider.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/service/wallet_service.dart';
import '../../main.dart';

class StarknetTTypes {
  static String v1155 = 'ERC1155';
  static String v721 = 'ERC721';
}

class StarknetNFTCoin extends StarknetCoin {
  String tokenType;
  BigInt tokenId;
  String contractAddress_;

  @override
  Widget? getNFTPage() => null;

  @override
  String tokenAddress() {
    return contractAddress_;
  }

  StarknetNFTCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.classHash,
    required super.api,
    required super.useStarkToken,
    required super.tokenContractAddress,
    required super.multiCallAddress,
    required super.factoryAddress,
    required super.tokenClassHash,
    required this.tokenType,
    required this.tokenId,
    required this.contractAddress_,
  }) : super(
          geckoID: '',
          rampID: '',
          payScheme: '',
        );

  factory StarknetNFTCoin.fromJson(Map<String, dynamic> json) {
    return StarknetNFTCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      tokenType: json['tokenType'],
      tokenId: json['tokenId'],
      contractAddress_: json['contractAddress'],
      classHash: json['classHash'],
      api: json['api'],
      useStarkToken: json['useStarkToken'],
      multiCallAddress: json['multiCallAddress'],
      factoryAddress: json['factoryAddress'],
      tokenContractAddress: json['contractAddress'],
      tokenClassHash: json['tokenClassHash'],
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
    data['tokenType'] = tokenType;
    data['tokenId'] = tokenId;
    data['contractAddress'] = contractAddress_;
    data['classHash'] = classHash;
    data['api'] = api;
    data['useStarkToken'] = useStarkToken;
    data['multiCallAddress'] = multiCallAddress;
    data['factoryAddress'] = factoryAddress;
    data['contractAddress'] = tokenContractAddress;
    data['tokenClassHash'] = tokenClassHash;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  String get badgeImage => starkNetCoins.first.image;

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(walletData);

    final provider = await apiProvider();
    final chainId = await getChainId();
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

    final List<Felt> calldata = [
      Felt.fromHexString(response.address),
      Felt.fromHexString(to),
      ...Uint256.fromBigInt(tokenId).toCalldata(),
      if (tokenType == StarknetTTypes.v1155)
        ...Uint256.fromBigInt(BigInt.from(double.parse(amount))).toCalldata(),
      Felt.fromInt(0),
    ];

    final tx = await fundingAccount.execute(functionCalls: [
      FunctionCall(
        contractAddress: Felt.fromHexString(contractAddress_),
        entryPointSelector: getSelectorByName('safe_transfer_from'),
        calldata: calldata,
      )
    ]);
    return tx.when(
      result: (result) {
        return result.transaction_hash;
      },
      error: (error) {
        throw Exception(
          "Error transfer (${error.code}): ${error.message} ${error.errorData}",
        );
      },
    );
  }

  @override
  Future<double> getBalance(bool useCache) async {
    return 1;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final walletData = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(walletData);

    final provider = await apiProvider();
    final chainId = await getChainId();
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

    final List<Felt> calldata = [
      Felt.fromHexString(response.address),
      Felt.fromHexString(to),
      ...Uint256.fromBigInt(tokenId).toCalldata(),
      if (tokenType == StarknetTTypes.v1155)
        ...Uint256.fromBigInt(BigInt.from(double.parse(amount))).toCalldata(),
      Felt.fromInt(0),
    ];

    final maxFee = await fundingAccount.getEstimateMaxFeeForInvokeTx(
      functionCalls: [
        FunctionCall(
          contractAddress: Felt.fromHexString(contractAddress_),
          entryPointSelector: getSelectorByName("safe_transfer_from"),
          calldata: calldata,
        ),
      ],
    );
    final base = BigInt.from(10);

    return maxFee.maxFee.toBigInt() / base.pow(decimals());
  }

  @override
  String getGeckoId() => '';
}
