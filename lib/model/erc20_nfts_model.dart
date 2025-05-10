import '../utils/rpc_urls.dart';

class ERC20NftDetails {
  final ContractMetadata contractMetadata;
  final Id id;
  final Contract contract;
  final Metadata metadata;
  final String? description;
  final String balance;

  ERC20NftDetails({
    required this.id,
    required this.contract,
    required this.balance,
    required this.contractMetadata,
    required this.metadata,
    this.description,
  });

  factory ERC20NftDetails.fromMap(Map<String, dynamic> nftDetails) {
    return ERC20NftDetails(
      contractMetadata:
          ContractMetadata.fromMap(nftDetails['contractMetadata']),
      id: Id.fromMap(nftDetails['id']),
      contract: Contract.fromMap(nftDetails['contract']),
      metadata: Metadata.fromMap(nftDetails['metadata']),
      description: nftDetails['description'] ?? '',
      balance: nftDetails['balance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contractMetadata': contractMetadata.toMap(),
      'id': id.toMap(),
      'contract': contract.toMap(),
      'metadata': metadata.toMap(),
      'description': description,
      'balance': balance,
    };
  }
}

class ContractMetadata {
  final String? name;
  final String? symbol;
  final String? tokenType;

  ContractMetadata({
    required this.name,
    required this.symbol,
    required this.tokenType,
  });

  factory ContractMetadata.fromMap(Map<String, dynamic> map) {
    return ContractMetadata(
      name: map['name'] ?? 'NFT',
      symbol: map['symbol'] ?? 'NFT',
      tokenType: map['tokenType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'symbol': symbol,
      'tokenType': tokenType,
    };
  }
}

class Id {
  final BigInt tokenId;

  Id({
    required this.tokenId,
  });

  factory Id.fromMap(Map<String, dynamic> map) {
    return Id(
      tokenId: BigInt.parse(map['tokenId']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId.toString(),
    };
  }
}

class Contract {
  final String address;

  Contract({
    required this.address,
  });

  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
    };
  }
}

class Metadata {
  final String? image;

  Metadata({
    this.image,
  });

  factory Metadata.fromMap(Map<String, dynamic> map) {
    String imageUrl = '';
    try {
      imageUrl = ipfsTohttp(map['image']);
    } catch (_) {}
    return Metadata(
      image: imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
    };
  }
}
