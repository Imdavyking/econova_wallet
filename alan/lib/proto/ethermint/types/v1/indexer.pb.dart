///
//  Generated code. Do not modify.
//  source: ethermint/types/v1/indexer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class TxResult extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TxResult', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.types.v1'), createEmptyInstance: create)
    ..aInt64(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'height')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txIndex', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'msgIndex', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ethTxIndex', $pb.PbFieldType.O3)
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'failed')
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasUsed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'cumulativeGasUsed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  TxResult._() : super();
  factory TxResult({
    $fixnum.Int64? height,
    $core.int? txIndex,
    $core.int? msgIndex,
    $core.int? ethTxIndex,
    $core.bool? failed,
    $fixnum.Int64? gasUsed,
    $fixnum.Int64? cumulativeGasUsed,
  }) {
    final _result = create();
    if (height != null) {
      _result.height = height;
    }
    if (txIndex != null) {
      _result.txIndex = txIndex;
    }
    if (msgIndex != null) {
      _result.msgIndex = msgIndex;
    }
    if (ethTxIndex != null) {
      _result.ethTxIndex = ethTxIndex;
    }
    if (failed != null) {
      _result.failed = failed;
    }
    if (gasUsed != null) {
      _result.gasUsed = gasUsed;
    }
    if (cumulativeGasUsed != null) {
      _result.cumulativeGasUsed = cumulativeGasUsed;
    }
    return _result;
  }
  factory TxResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxResult clone() => TxResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxResult copyWith(void Function(TxResult) updates) => super.copyWith((message) => updates(message as TxResult)) as TxResult; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TxResult create() => TxResult._();
  TxResult createEmptyInstance() => create();
  static $pb.PbList<TxResult> createRepeated() => $pb.PbList<TxResult>();
  @$core.pragma('dart2js:noInline')
  static TxResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxResult>(create);
  static TxResult? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get height => $_getI64(0);
  @$pb.TagNumber(1)
  set height($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get txIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set txIndex($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get msgIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set msgIndex($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMsgIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsgIndex() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get ethTxIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set ethTxIndex($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEthTxIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearEthTxIndex() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get failed => $_getBF(4);
  @$pb.TagNumber(5)
  set failed($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFailed() => $_has(4);
  @$pb.TagNumber(5)
  void clearFailed() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get gasUsed => $_getI64(5);
  @$pb.TagNumber(6)
  set gasUsed($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGasUsed() => $_has(5);
  @$pb.TagNumber(6)
  void clearGasUsed() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get cumulativeGasUsed => $_getI64(6);
  @$pb.TagNumber(7)
  set cumulativeGasUsed($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCumulativeGasUsed() => $_has(6);
  @$pb.TagNumber(7)
  void clearCumulativeGasUsed() => clearField(7);
}

