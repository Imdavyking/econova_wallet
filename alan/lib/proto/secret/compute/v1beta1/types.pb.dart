///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'types.pbenum.dart';

export 'types.pbenum.dart';

class AccessTypeParam extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AccessTypeParam', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..e<AccessType>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value', $pb.PbFieldType.OE, defaultOrMaker: AccessType.UNDEFINED, valueOf: AccessType.valueOf, enumValues: AccessType.values)
    ..hasRequiredFields = false
  ;

  AccessTypeParam._() : super();
  factory AccessTypeParam({
    AccessType? value,
  }) {
    final _result = create();
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory AccessTypeParam.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessTypeParam.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessTypeParam clone() => AccessTypeParam()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessTypeParam copyWith(void Function(AccessTypeParam) updates) => super.copyWith((message) => updates(message as AccessTypeParam)) as AccessTypeParam; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AccessTypeParam create() => AccessTypeParam._();
  AccessTypeParam createEmptyInstance() => create();
  static $pb.PbList<AccessTypeParam> createRepeated() => $pb.PbList<AccessTypeParam>();
  @$core.pragma('dart2js:noInline')
  static AccessTypeParam getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessTypeParam>(create);
  static AccessTypeParam? _defaultInstance;

  @$pb.TagNumber(1)
  AccessType get value => $_getN(0);
  @$pb.TagNumber(1)
  set value(AccessType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
}

class CodeInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CodeInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'creator', $pb.PbFieldType.OY)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'source')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'builder')
    ..hasRequiredFields = false
  ;

  CodeInfo._() : super();
  factory CodeInfo({
    $core.List<$core.int>? codeHash,
    $core.List<$core.int>? creator,
    $core.String? source,
    $core.String? builder,
  }) {
    final _result = create();
    if (codeHash != null) {
      _result.codeHash = codeHash;
    }
    if (creator != null) {
      _result.creator = creator;
    }
    if (source != null) {
      _result.source = source;
    }
    if (builder != null) {
      _result.builder = builder;
    }
    return _result;
  }
  factory CodeInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CodeInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CodeInfo clone() => CodeInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CodeInfo copyWith(void Function(CodeInfo) updates) => super.copyWith((message) => updates(message as CodeInfo)) as CodeInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CodeInfo create() => CodeInfo._();
  CodeInfo createEmptyInstance() => create();
  static $pb.PbList<CodeInfo> createRepeated() => $pb.PbList<CodeInfo>();
  @$core.pragma('dart2js:noInline')
  static CodeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CodeInfo>(create);
  static CodeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get codeHash => $_getN(0);
  @$pb.TagNumber(1)
  set codeHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get creator => $_getN(1);
  @$pb.TagNumber(2)
  set creator($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCreator() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreator() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get source => $_getSZ(2);
  @$pb.TagNumber(3)
  set source($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearSource() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get builder => $_getSZ(3);
  @$pb.TagNumber(4)
  set builder($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBuilder() => $_has(3);
  @$pb.TagNumber(4)
  void clearBuilder() => clearField(4);
}

class ContractCustomInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractCustomInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enclaveKey', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'label')
    ..hasRequiredFields = false
  ;

  ContractCustomInfo._() : super();
  factory ContractCustomInfo({
    $core.List<$core.int>? enclaveKey,
    $core.String? label,
  }) {
    final _result = create();
    if (enclaveKey != null) {
      _result.enclaveKey = enclaveKey;
    }
    if (label != null) {
      _result.label = label;
    }
    return _result;
  }
  factory ContractCustomInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractCustomInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractCustomInfo clone() => ContractCustomInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractCustomInfo copyWith(void Function(ContractCustomInfo) updates) => super.copyWith((message) => updates(message as ContractCustomInfo)) as ContractCustomInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractCustomInfo create() => ContractCustomInfo._();
  ContractCustomInfo createEmptyInstance() => create();
  static $pb.PbList<ContractCustomInfo> createRepeated() => $pb.PbList<ContractCustomInfo>();
  @$core.pragma('dart2js:noInline')
  static ContractCustomInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractCustomInfo>(create);
  static ContractCustomInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get enclaveKey => $_getN(0);
  @$pb.TagNumber(1)
  set enclaveKey($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnclaveKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnclaveKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);
}

class ContractInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'creator', $pb.PbFieldType.OY)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'label')
    ..aOM<AbsoluteTxPosition>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'created', subBuilder: AbsoluteTxPosition.create)
    ..hasRequiredFields = false
  ;

  ContractInfo._() : super();
  factory ContractInfo({
    $fixnum.Int64? codeId,
    $core.List<$core.int>? creator,
    $core.String? label,
    AbsoluteTxPosition? created,
  }) {
    final _result = create();
    if (codeId != null) {
      _result.codeId = codeId;
    }
    if (creator != null) {
      _result.creator = creator;
    }
    if (label != null) {
      _result.label = label;
    }
    if (created != null) {
      _result.created = created;
    }
    return _result;
  }
  factory ContractInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractInfo clone() => ContractInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractInfo copyWith(void Function(ContractInfo) updates) => super.copyWith((message) => updates(message as ContractInfo)) as ContractInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractInfo create() => ContractInfo._();
  ContractInfo createEmptyInstance() => create();
  static $pb.PbList<ContractInfo> createRepeated() => $pb.PbList<ContractInfo>();
  @$core.pragma('dart2js:noInline')
  static ContractInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractInfo>(create);
  static ContractInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get codeId => $_getI64(0);
  @$pb.TagNumber(1)
  set codeId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get creator => $_getN(1);
  @$pb.TagNumber(2)
  set creator($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCreator() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreator() => clearField(2);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(4)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(4)
  void clearLabel() => clearField(4);

  @$pb.TagNumber(5)
  AbsoluteTxPosition get created => $_getN(3);
  @$pb.TagNumber(5)
  set created(AbsoluteTxPosition v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreated() => $_has(3);
  @$pb.TagNumber(5)
  void clearCreated() => clearField(5);
  @$pb.TagNumber(5)
  AbsoluteTxPosition ensureCreated() => $_ensure(3);
}

class AbsoluteTxPosition extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AbsoluteTxPosition', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..aInt64(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockHeight')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txIndex', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  AbsoluteTxPosition._() : super();
  factory AbsoluteTxPosition({
    $fixnum.Int64? blockHeight,
    $fixnum.Int64? txIndex,
  }) {
    final _result = create();
    if (blockHeight != null) {
      _result.blockHeight = blockHeight;
    }
    if (txIndex != null) {
      _result.txIndex = txIndex;
    }
    return _result;
  }
  factory AbsoluteTxPosition.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbsoluteTxPosition.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AbsoluteTxPosition clone() => AbsoluteTxPosition()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AbsoluteTxPosition copyWith(void Function(AbsoluteTxPosition) updates) => super.copyWith((message) => updates(message as AbsoluteTxPosition)) as AbsoluteTxPosition; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AbsoluteTxPosition create() => AbsoluteTxPosition._();
  AbsoluteTxPosition createEmptyInstance() => create();
  static $pb.PbList<AbsoluteTxPosition> createRepeated() => $pb.PbList<AbsoluteTxPosition>();
  @$core.pragma('dart2js:noInline')
  static AbsoluteTxPosition getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbsoluteTxPosition>(create);
  static AbsoluteTxPosition? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get blockHeight => $_getI64(0);
  @$pb.TagNumber(1)
  set blockHeight($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeight() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get txIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set txIndex($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxIndex() => clearField(2);
}

class Model extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Model', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'Key', $pb.PbFieldType.OY, protoName: 'Key')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'Value', $pb.PbFieldType.OY, protoName: 'Value')
    ..hasRequiredFields = false
  ;

  Model._() : super();
  factory Model({
    $core.List<$core.int>? key,
    $core.List<$core.int>? value,
  }) {
    final _result = create();
    if (key != null) {
      _result.key = key;
    }
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory Model.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Model.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Model clone() => Model()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Model copyWith(void Function(Model) updates) => super.copyWith((message) => updates(message as Model)) as Model; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Model create() => Model._();
  Model createEmptyInstance() => create();
  static $pb.PbList<Model> createRepeated() => $pb.PbList<Model>();
  @$core.pragma('dart2js:noInline')
  static Model getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Model>(create);
  static Model? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

