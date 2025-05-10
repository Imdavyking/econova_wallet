///
//  Generated code. Do not modify.
//  source: ethermint/types/v1/web3.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ExtensionOptionsWeb3Tx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ExtensionOptionsWeb3Tx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.types.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'typedDataChainId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'feePayer')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'feePayerSig', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  ExtensionOptionsWeb3Tx._() : super();
  factory ExtensionOptionsWeb3Tx({
    $fixnum.Int64? typedDataChainId,
    $core.String? feePayer,
    $core.List<$core.int>? feePayerSig,
  }) {
    final _result = create();
    if (typedDataChainId != null) {
      _result.typedDataChainId = typedDataChainId;
    }
    if (feePayer != null) {
      _result.feePayer = feePayer;
    }
    if (feePayerSig != null) {
      _result.feePayerSig = feePayerSig;
    }
    return _result;
  }
  factory ExtensionOptionsWeb3Tx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExtensionOptionsWeb3Tx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExtensionOptionsWeb3Tx clone() => ExtensionOptionsWeb3Tx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExtensionOptionsWeb3Tx copyWith(void Function(ExtensionOptionsWeb3Tx) updates) => super.copyWith((message) => updates(message as ExtensionOptionsWeb3Tx)) as ExtensionOptionsWeb3Tx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ExtensionOptionsWeb3Tx create() => ExtensionOptionsWeb3Tx._();
  ExtensionOptionsWeb3Tx createEmptyInstance() => create();
  static $pb.PbList<ExtensionOptionsWeb3Tx> createRepeated() => $pb.PbList<ExtensionOptionsWeb3Tx>();
  @$core.pragma('dart2js:noInline')
  static ExtensionOptionsWeb3Tx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExtensionOptionsWeb3Tx>(create);
  static ExtensionOptionsWeb3Tx? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get typedDataChainId => $_getI64(0);
  @$pb.TagNumber(1)
  set typedDataChainId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTypedDataChainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTypedDataChainId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get feePayer => $_getSZ(1);
  @$pb.TagNumber(2)
  set feePayer($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeePayer() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeePayer() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get feePayerSig => $_getN(2);
  @$pb.TagNumber(3)
  set feePayerSig($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeePayerSig() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeePayerSig() => clearField(3);
}

