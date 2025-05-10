import '../_utils/records_class.dart';
import '../dataformat/address/api.dart' show InternalAddress;
import '../dataformat/cell/api.dart' show Cell;
import '../dataformat/contract/api.dart'
    show Contract, ContractABI, ContractInit, ContractProvider;
import '../dataformat/tuple/api.dart' show TiCell, TiInt;

/// Represents a collection of NFT items
/// IMPORTANT: Initialize the [provider] to use
class NftCollection implements Contract {
  @override
  ContractABI? abi; // required from 'implements Contract', unused here

  @override
  InternalAddress address;

  @override
  ContractInit? init;

  @override
  ContractProvider? provider; // don't forget to initialize to use

  /// Constructs an instance of the NftCollection contract
  /// [address] — address of the contract
  /// [init] — optional initialization data for the contract's code and data
  NftCollection(this.address, [this.init]);

  /// Returns a new NftCollection from the InternalAddress
  static NftCollection createFromAddress(InternalAddress address) {
    return NftCollection(address);
  }

  /// Returns the collection data from the contract as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   BigInt nextItemIndex,
  ///   Cell? collectionContent,
  ///   InternalAddress? ownerAddress,
  /// })>
  /// ```
  ///
  /// Throws 'ContractProvider field was not initialized' if [provider] is null
  Future<CollectionData> getCollectionData() async {
    if (provider == null) {
      throw 'ContractProvider field was not initialized';
    }
    final res = await provider!.get('get_collection_data', []);
    var nextItemIndex = res.stack.readBigInt();
    var collectionContent = res.stack.readCellOrNull();
    var ownerAddress = res.stack.readAddressOrNull();

    return CollectionData(
      nextItemIndex: nextItemIndex,
      collectionContent: collectionContent,
      ownerAddress: ownerAddress,
    );
  }

  /// Returns the NFT address by it's index as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   InternalAddress? nftAddress,
  /// })>
  /// ```
  ///
  /// Throws 'ContractProvider field was not initialized' if [provider] is null
  Future<NftAddressByIndex> getNftAddressByIndex(
    BigInt index,
  ) async {
    if (provider == null) {
      throw 'ContractProvider field was not initialized';
    }
    final res = await provider!.get('get_nft_address_by_index', [TiInt(index)]);
    var nftAddress = res.stack.readAddressOrNull();

    return NftAddressByIndex(nftAddress: nftAddress);
  }

  /// Returns the NFT content from the contract as a record, wrapped in a Future:
  /// ```dart
  /// Future<({
  ///   Cell? fullContent,
  /// })>
  /// ```
  ///
  /// Throws 'ContractProvider field was not initialized' if [provider] is null
  Future<NFTContent> getNftContent(
    BigInt index,
    Cell individualContent,
  ) async {
    if (provider == null) {
      throw 'ContractProvider field was not initialized';
    }
    final res = await provider!.get('get_nft_content', [
      TiInt(index),
      TiCell(individualContent),
    ]);
    var fullContent = res.stack.readCellOrNull();

    return NFTContent(fullContent: fullContent);
  }
}
