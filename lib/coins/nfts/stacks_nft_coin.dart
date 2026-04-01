// coins/nft/stacks_nft_coin.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

import '../../coins/stack_coin.dart';
import '../../main.dart';
import '../../service/wallet_service.dart';
import '../../utils/c32check.dart';
import '../../utils/rpc_urls.dart';
import '../../utils/stack_tx_utils.dart';

class StacksNFTCoin extends StacksCoin {
  final String contractAddress;
  final String contractName;
  final BigInt tokenId;
  final String description;
  final String? tokenImageUrl;

  StacksNFTCoin({
    required super.isTestnet,
    required super.derivationPath,
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.geckoID,
    required super.rampID,
    required super.payScheme,
    required super.caipReference,
    required this.contractAddress,
    required this.contractName,
    required this.tokenId,
    required this.description,
    this.tokenImageUrl,
  });

  @override
  String tokenAddress() => '$contractAddress.$contractName';

  @override
  String? get badgeImage => getStacksBlockchains().first.image;

  @override
  Widget? getNFTPage() => null;

  @override
  String getGeckoId() => '';

  @override
  String savedTransKey() => '${tokenAddress()}${tokenId}Details';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'contractAddress': contractAddress,
        'contractName': contractName,
        'tokenId': tokenId.toString(),
        'description': description,
        'tokenImageUrl': tokenImageUrl,
      };

  factory StacksNFTCoin.fromJson(Map<String, dynamic> json) => StacksNFTCoin(
        isTestnet: json['isTestnet'] as bool,
        blockExplorer: json['blockExplorer'] as String,
        symbol: json['symbol'] as String,
        default_: json['default'] as String,
        image: json['image'] as String,
        name: json['name'] as String,
        geckoID: json['geckoID'] as String? ?? '',
        rampID: json['rampID'] as String? ?? '',
        payScheme: json['payScheme'] as String? ?? 'stacks',
        derivationPath: json['derivationPath'] as String,
        contractAddress: json['contractAddress'] as String,
        contractName: json['contractName'] as String,
        tokenId: BigInt.parse(json['tokenId'] as String),
        description: json['description'] as String? ?? '',
        tokenImageUrl: json['tokenImageUrl'] as String?,
        caipReference: json['caipReference'] as String,
      );

  @override
  Future<double> getBalance(bool useCache) async {
    try {
      final address = await getAddress();
      final owner = await _getOwner();
      return owner == address ? 1.0 : 0.0;
    } catch (_) {
      return 1.0;
    }
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final owner = await _getOwner();
    return owner == address ? 1.0 : 0.0;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final ratePerByte = await stacksFetchFeeRate(isTestnet);
    return (ratePerByte * stacksEstimatedContractCallBytes) / stacksMicroPerStx;
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);

    final privBytes = txDataToUintList(keyPair.privateKey!);
    final senderHash160 = hash160(compressedPubKey(privBytes));
    final nonce = await stacksFetchNonce(isTestnet, keyPair.address);
    final feeRate = await stacksFetchFeeRate(isTestnet);
    final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);

    final senderDecoded = c32checkDecode(keyPair.address.substring(1));
    final senderHash =
        Uint8List.fromList(HEX.decode(senderDecoded[1] as String));

    final recipDecoded = c32checkDecode(to.substring(1));
    final recipHash = Uint8List.fromList(HEX.decode(recipDecoded[1] as String));

    final contractDecoded = c32checkDecode(contractAddress.substring(1));
    final contractHash160 =
        Uint8List.fromList(HEX.decode(contractDecoded[1] as String));

    final payload = stacksBuildContractCallPayload(
      contractVersion: contractDecoded[0] as int,
      contractHash160: contractHash160,
      contractName: contractName,
      functionName: 'safe-transfer-from',
      args: [
        clarityUInt(tokenId),
        clarityStandardPrincipal(senderDecoded[0] as int, senderHash),
        clarityStandardPrincipal(recipDecoded[0] as int, recipHash),
      ],
    );

    final txBytes = stacksBuildSignedTx(
      txVersion: stacksTxVersion(isTestnet),
      chainId: stacksChainId(isTestnet),
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: payload,
    );

    final res = await http.post(
      Uri.parse('${stacksApiUrl(isTestnet)}/v2/transactions'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: txBytes,
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('SIP-009 transfer failed: ${res.body}');
    }
    return (
      txHash: jsonDecode(res.body) as String,
      txRaw: HEX.encode(txBytes),
    );
  }

  Future<String?> _getOwner() async {
    try {
      final res = await http.post(
        Uri.parse(
            '${stacksApiUrl(isTestnet)}/v2/contracts/call-read/$contractAddress/$contractName/get-owner'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': contractAddress,
          'arguments': ['0x${clarityUIntHex(tokenId)}'],
        }),
      );
      if (res.statusCode ~/ 100 != 2) return null;
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (decoded['okay'] != true) return null;
      return clarityParsePrincipal(decoded['result'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMetadata() async {
    try {
      final res = await http.post(
        Uri.parse(
            '${stacksApiUrl(isTestnet)}/v2/contracts/call-read/$contractAddress/$contractName/get-token-uri'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': contractAddress,
          'arguments': ['0x${clarityUIntHex(tokenId)}'],
        }),
      );
      if (res.statusCode ~/ 100 != 2) return null;
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (decoded['okay'] != true) return null;
      final uri = clarityParseString(decoded['result'] as String? ?? '');
      if (uri == null || uri.isEmpty) return null;
      final metaRes = await http.get(Uri.parse(uri));
      if (metaRes.statusCode ~/ 100 != 2) return null;
      return jsonDecode(metaRes.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

Future<List<StacksNFTCoin>> getStacksNFTs({
  required String address,
  bool isTestnet = false,
  int limit = 50,
  int offset = 0,
}) async {
  final res = await http.get(
    Uri.parse(
        '${stacksApiUrl(isTestnet)}/extended/v1/address/$address/nft_events?limit=$limit&offset=$offset'),
  );
  if (res.statusCode ~/ 100 != 2) return [];

  final events = (jsonDecode(res.body)['nft_events'] as List?) ?? [];
  final seen = <String>{};
  final coins = <StacksNFTCoin>[];

  for (final event in events) {
    try {
      final assetId = event['asset_identifier'] as String;
      final value = event['value']?['repr'] as String? ?? '0';
      final key = '$assetId:$value';
      if (seen.contains(key)) continue;
      seen.add(key);

      final dotDot = assetId.split('::').first;
      final lastDot = dotDot.lastIndexOf('.');
      if (lastDot == -1) continue;

      final contractAddress = dotDot.substring(0, lastDot);
      final contractName = dotDot.substring(lastDot + 1);
      final tokenIdStr = value.replaceAll('(u', '').replaceAll(')', '').trim();
      final tokenId = BigInt.tryParse(tokenIdStr) ?? BigInt.zero;
      final baseCoin = getStacksBlockchains().first;

      coins.add(StacksNFTCoin(
        isTestnet: isTestnet,
        derivationPath: baseCoin.derivationPath,
        blockExplorer: baseCoin.blockExplorer,
        symbol: contractName,
        default_: 'STX',
        image: baseCoin.image,
        name: contractName,
        geckoID: '',
        rampID: '',
        payScheme: 'stacks',
        contractAddress: contractAddress,
        contractName: contractName,
        tokenId: tokenId,
        caipReference: '',
        description: '$contractName #$tokenId',
      ));
    } catch (_) {
      continue;
    }
  }
  return coins;
}
