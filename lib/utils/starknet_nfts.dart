import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<NFT>> getStarknetNFTs({required String address}) async {
  const projectId = '2f6ccf07-7b89-4bf4-be14-7a26f2eae72d';
  address =
      '0x021fe7bd20c21bce7ba4846a55cd672f4da4455c2a70506bf2bc2bc2d92ff983';
  final url = Uri.parse(
      'https://starknet-mainnet.blastapi.io/$projectId/builder/getWalletNFTs?walletAddress=$address');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> nftsData = data['nfts'];
    return nftsData.map((nft) => NFT.fromJson(nft)).toList();
  } else {
    throw Exception('Failed to load NFTs');
  }
}

class NFT {
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
  final String numberOfOwners;
  final String ownerAddress;
  final WalletBalance walletBalance;
  final String tokenUri;
  final String tokenMetadata;
  final String name;
  final String description;
  final List<Attribute> attributes;
  final String? externalLink;
  final String imageUrl;
  final String? animationUrl;

  NFT({
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
    required this.attributes,
    this.externalLink,
    required this.imageUrl,
    this.animationUrl,
  });

  factory NFT.fromJson(Map<String, dynamic> json) {
    return NFT(
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
      attributes: (json['attributes'] as List)
          .map((attr) => Attribute.fromJson(attr))
          .toList(),
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

class Attribute {
  final String traitType;
  final List<String> value;

  Attribute({
    required this.traitType,
    required this.value,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      traitType: json['trait_type'],
      value: List<String>.from(json['value']),
    );
  }
}
