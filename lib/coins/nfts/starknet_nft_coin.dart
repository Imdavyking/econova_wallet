import 'package:flutter/material.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import '../../main.dart';

class StarknetTTypes {
  static String v1155 = 'erc1155';
  static String v721 = 'erc721';
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
    required super.contractAddress,
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
      contractAddress: json['contractAddress'],
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
    data['contractAddress'] = contractAddress;
    data['tokenClassHash'] = tokenClassHash;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  String get badgeImage => starkNetCoins.first.image;

  // Future<void> fillParameter(String amount, String to) async {
  // final address = await getAddress();

  // if (tokenType == ERCFTTYPES.v721) {
  //     parameters_ = [
  //       EthereumAddress.fromHex(address),
  //       EthereumAddress.fromHex(to),
  //       tokenId,
  //     ];
  //   } else if (tokenType == ERCFTTYPES.v1155) {
  //     parameters_ = [
  //       EthereumAddress.fromHex(address),
  //       EthereumAddress.fromHex(to),
  //       tokenId,
  //       BigInt.from(
  //         double.parse(amount),
  //       ),
  //       Uint8List(1)
  //     ];
  //   }
  // }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    return '';
    // await fillParameter(amount, to);

    // final client = Web3Client(
    //   rpc,
    //   Client(),
    // );
    // final data = WalletService.getActiveKey(walletImportType)!.data;
    // AccountData response = await importData(data);
    // final credentials = EthPrivateKey.fromHex(response.privateKey!);

    // final contract = DeployedContract(
    //   contrAbi,
    //   EthereumAddress.fromHex(
    //     contractAddress_,
    //   ),
    // );

    // ContractFunction transfer =
    //     contract.findFunctionsByName('safeTransferFrom').toList()[0];

    // final trans = await client.signTransaction(
    //   credentials,
    //   Transaction.callContract(
    //     contract: contract,
    //     function: transfer,
    //     parameters: parameters_,
    //   ),
    //   chainId: chainId,
    // );

    // final transactionHash = await client.sendRawTransaction(trans);

    // await client.dispose();
    // return transactionHash;
  }

  @override
  Future<double> getBalance(bool useCache) async {
    return 1;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
    // await fillParameter(amount, to);

    // String address = roninAddrToEth(await getAddress());

    // final sendingAddress = EthereumAddress.fromHex(address);

    // final contract = DeployedContract(
    //   contrAbi,
    //   EthereumAddress.fromHex(tokenAddress()),
    // );

    // final transfer =
    //     contract.findFunctionsByName('safeTransferFrom').toList()[0];

    // Uint8List contractData = transfer.encodeCall(parameters_);

    // final transactionFee = await getEtherTransactionFee(
    //   rpc,
    //   contractData,
    //   sendingAddress,
    //   EthereumAddress.fromHex(
    //     tokenAddress(),
    //   ),
    // );

    // return transactionFee / pow(10, etherDecimals);
  }

  @override
  String getGeckoId() => '';
}
