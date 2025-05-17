// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../service/wallet_service.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../../interface/coin.dart';
import '../../main.dart';
import '../../utils/abis.dart';
import '../../utils/rpc_urls.dart';

class ERCFTTYPES {
  static String v1155 = 'ERC1155';
  static String v721 = 'ERC721';
}

class ERCNFTCoin extends EthereumCoin {
  String tokenType;
  BigInt tokenId;
  String contractAddress_;
  late List parameters_;
  late ContractAbi contrAbi;

  @override
  Widget? getNFTPage() => null;

  @override
  String tokenAddress() {
    return contractAddress_;
  }

  ERCNFTCoin({
    required String blockExplorer,
    required int chainId,
    required String symbol,
    required String default_,
    required String image,
    required int coinType,
    required String rpc,
    required String name,
    required this.tokenType,
    required this.tokenId,
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
          geckoID: '',
          rampID: '',
          payScheme: '',
        ) {
    if (tokenType == ERCFTTYPES.v721) {
      contrAbi = ContractAbi.fromJson(
        json.encode(erc721Abi),
        '',
      );
    } else if (tokenType == ERCFTTYPES.v1155) {
      contrAbi = ContractAbi.fromJson(
        json.encode(erc1155Abi),
        '',
      );
    }
  }

  factory ERCNFTCoin.fromJson(Map<String, dynamic> json) {
    return ERCNFTCoin(
      chainId: json['chainId'],
      rpc: json['rpc'],
      coinType: json['coinType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      tokenType: json['tokenType'],
      tokenId: json['tokenId'],
      contractAddress_: json['contractAddress'],
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
    data['tokenType'] = tokenType;
    data['tokenId'] = tokenId;
    data['contractAddress'] = contractAddress_;

    return data;
  }

  Future<void> fillParameter(String amount, String to) async {
    final address = await getAddress();

    if (tokenType == ERCFTTYPES.v721) {
      parameters_ = [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(to),
        tokenId,
      ];
    } else if (tokenType == ERCFTTYPES.v1155) {
      parameters_ = [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(to),
        tokenId,
        BigInt.from(
          double.parse(amount),
        ),
        Uint8List(1)
      ];
    }
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
  String get badgeImage => evmFromChainId(chainId)!.image;

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
    await fillParameter(amount, to);

    final client = Web3Client(
      rpc,
      Client(),
    );
    final data = WalletService.getActiveKey(walletImportType)!.data;
    AccountData response = await importData(data);
    final credentials = EthPrivateKey.fromHex(response.privateKey!);

    final contract = DeployedContract(
      contrAbi,
      EthereumAddress.fromHex(
        contractAddress_,
      ),
    );

    ContractFunction transfer =
        contract.findFunctionsByName('safeTransferFrom').toList()[0];

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

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    return 1;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    await fillParameter(amount, to);

    String address = roninAddrToEth(await getAddress());

    final sendingAddress = EthereumAddress.fromHex(address);

    final contract = DeployedContract(
      contrAbi,
      EthereumAddress.fromHex(tokenAddress()),
    );

    final transfer =
        contract.findFunctionsByName('safeTransferFrom').toList()[0];

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
  String getGeckoId() => '';
}
