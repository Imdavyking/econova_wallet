import 'dart:typed_data';

import '../../tonutils.dart';
import '../client/jsonrpc.dart';
import '../dataformat/cell/levelmask.dart';

class RecordGas {
  int gasUsed;

  TupleReader stack;

  RecordGas({required this.gasUsed, required this.stack});
}

class RecordGasExitCode {
  int? gasUsed;
  TupleReader? stack;
  int? exitCode;
  RecordGasExitCode({this.gasUsed, this.stack, this.exitCode});
}

class MasterChainInfo {
  int? initSeqno;
  int latestSeqno;
  String shard;
  int workchain;
  MasterChainInfo(
      {this.initSeqno,
      required this.latestSeqno,
      required this.shard,
      required this.workchain});
}

class WorkchainShards {
  int? workchain;
  String? shard;
  int? seqno;
  WorkchainShards({this.workchain, this.shard, this.seqno});
}

class ShardTransactions {
  InternalAddress? account;
  LastTransactionId? lastTransactionId;
  ShardTransactions({this.account, this.lastTransactionId});
}

class EstimateExternalMessageFee {
  int? forwardFee;
  int? gasFee;
  int? inForwardFee;
  int? storageFee;
  EstimateExternalMessageFee({
    this.forwardFee,
    this.gasFee,
    this.inForwardFee,
    this.storageFee,
  });
}

class RecordContractState {
  BigInt balance;
  String? state;
  Uint8List? code;
  Uint8List? data;
  LastTransactionId? lastTransaction;
  WorkchainShards? blockId;
  int? timestamp;
  RecordContractState({
    required this.balance,
    this.state,
    this.code,
    this.data,
    this.lastTransaction,
    this.blockId,
    this.timestamp,
  });
}

class EmptyRecord {
  EmptyRecord();
}

class ExoticMerkleProof {
  int proofDepth;
  Uint8List proofHash;
  ExoticMerkleProof({required this.proofDepth, required this.proofHash});
}

class ExoticMerkleUpdate {
  int proofDepth1;
  int proofDepth2;
  Uint8List proofHash1;
  Uint8List proofHash2;
  ExoticMerkleUpdate({
    required this.proofDepth1,
    required this.proofDepth2,
    required this.proofHash1,
    required this.proofHash2,
  });
}

class TopologicalSortInt {
  Cell cell;
  List<int> refs;
  TopologicalSortInt({required this.cell, required this.refs});
}

class TopologicalSortString {
  Cell cell;
  List<String> refs;
  TopologicalSortString({required this.cell, required this.refs});
}

class WonderCalculator {
  LevelMask mask;
  List<Uint8List> hashes;
  List<int> depths;
  WonderCalculator({
    required this.mask,
    required this.hashes,
    required this.depths,
  });
}

class ReadCell {
  BitString bits;
  List<int> refs;
  bool exotic;
  ReadCell({required this.bits, required this.refs, required this.exotic});
}

class ParseBoc {
  int size;
  int offBytes;
  int cells;
  int roots;
  int absent;
  int totalCellSize;
  Uint8List? index;
  Uint8List cellData;
  List<int> root;
  ParseBoc({
    required this.size,
    required this.offBytes,
    required this.cells,
    required this.roots,
    required this.absent,
    required this.totalCellSize,
    this.index,
    required this.cellData,
    required this.root,
  });
}

class ForKMap<T> {
  Map<String, T> left;
  Map<String, T> right;
  ForKMap({required this.left, required this.right});
}

class JettonData {
  BigInt totalSupply;
  bool mintable;
  InternalAddress adminAddress;
  Cell content;
  Cell walletCode;
  JettonData({
    required this.totalSupply,
    required this.mintable,
    required this.adminAddress,
    required this.content,
    required this.walletCode,
  });
}

class RoyaltyParams {
  bool init;
  BigInt numerator;
  BigInt denominator;
  InternalAddress? destination;
  RoyaltyParams({
    required this.init,
    required this.numerator,
    required this.denominator,
    this.destination,
  });
}

class NftData {
  bool init;
  BigInt index;
  InternalAddress? collectionAddress;
  InternalAddress? ownerAddress;
  Cell? individualContent;
  NftData({
    required this.init,
    required this.index,
    this.collectionAddress,
    this.ownerAddress,
    this.individualContent,
  });
}

class CollectionData {
  BigInt nextItemIndex;
  Cell? collectionContent;
  InternalAddress? ownerAddress;
  CollectionData(
      {required this.nextItemIndex, this.collectionContent, this.ownerAddress});
}

class NFTContent {
  Cell? fullContent;
  NFTContent({this.fullContent});
}

class NftAddressByIndex {
  InternalAddress? nftAddress;
  NftAddressByIndex({this.nftAddress});
}
