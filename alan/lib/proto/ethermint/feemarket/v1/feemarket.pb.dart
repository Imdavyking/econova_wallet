///
//  Generated code. Do not modify.
//  source: ethermint/feemarket/v1/feemarket.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class Params extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Params', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.feemarket.v1'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'noBaseFee')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baseFeeChangeDenominator', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'elasticityMultiplier', $pb.PbFieldType.OU3)
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enableHeight')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baseFee')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'minGasPrice')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'minGasMultiplier')
    ..hasRequiredFields = false
  ;

  Params._() : super();
  factory Params({
    $core.bool? noBaseFee,
    $core.int? baseFeeChangeDenominator,
    $core.int? elasticityMultiplier,
    $fixnum.Int64? enableHeight,
    $core.String? baseFee,
    $core.String? minGasPrice,
    $core.String? minGasMultiplier,
  }) {
    final _result = create();
    if (noBaseFee != null) {
      _result.noBaseFee = noBaseFee;
    }
    if (baseFeeChangeDenominator != null) {
      _result.baseFeeChangeDenominator = baseFeeChangeDenominator;
    }
    if (elasticityMultiplier != null) {
      _result.elasticityMultiplier = elasticityMultiplier;
    }
    if (enableHeight != null) {
      _result.enableHeight = enableHeight;
    }
    if (baseFee != null) {
      _result.baseFee = baseFee;
    }
    if (minGasPrice != null) {
      _result.minGasPrice = minGasPrice;
    }
    if (minGasMultiplier != null) {
      _result.minGasMultiplier = minGasMultiplier;
    }
    return _result;
  }
  factory Params.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Params.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Params clone() => Params()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Params copyWith(void Function(Params) updates) => super.copyWith((message) => updates(message as Params)) as Params; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Params create() => Params._();
  Params createEmptyInstance() => create();
  static $pb.PbList<Params> createRepeated() => $pb.PbList<Params>();
  @$core.pragma('dart2js:noInline')
  static Params getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Params>(create);
  static Params? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get noBaseFee => $_getBF(0);
  @$pb.TagNumber(1)
  set noBaseFee($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNoBaseFee() => $_has(0);
  @$pb.TagNumber(1)
  void clearNoBaseFee() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get baseFeeChangeDenominator => $_getIZ(1);
  @$pb.TagNumber(2)
  set baseFeeChangeDenominator($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBaseFeeChangeDenominator() => $_has(1);
  @$pb.TagNumber(2)
  void clearBaseFeeChangeDenominator() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get elasticityMultiplier => $_getIZ(2);
  @$pb.TagNumber(3)
  set elasticityMultiplier($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasElasticityMultiplier() => $_has(2);
  @$pb.TagNumber(3)
  void clearElasticityMultiplier() => clearField(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get enableHeight => $_getI64(3);
  @$pb.TagNumber(5)
  set enableHeight($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasEnableHeight() => $_has(3);
  @$pb.TagNumber(5)
  void clearEnableHeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get baseFee => $_getSZ(4);
  @$pb.TagNumber(6)
  set baseFee($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasBaseFee() => $_has(4);
  @$pb.TagNumber(6)
  void clearBaseFee() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get minGasPrice => $_getSZ(5);
  @$pb.TagNumber(7)
  set minGasPrice($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(7)
  $core.bool hasMinGasPrice() => $_has(5);
  @$pb.TagNumber(7)
  void clearMinGasPrice() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get minGasMultiplier => $_getSZ(6);
  @$pb.TagNumber(8)
  set minGasMultiplier($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasMinGasMultiplier() => $_has(6);
  @$pb.TagNumber(8)
  void clearMinGasMultiplier() => clearField(8);
}

