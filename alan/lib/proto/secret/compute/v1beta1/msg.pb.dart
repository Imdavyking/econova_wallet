///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/msg.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../cosmos/base/v1beta1/coin.pb.dart' as $5;

class MsgStoreCode extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgStoreCode', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sender', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wasmByteCode', $pb.PbFieldType.OY)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'source')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'builder')
    ..hasRequiredFields = false
  ;

  MsgStoreCode._() : super();
  factory MsgStoreCode({
    $core.List<$core.int>? sender,
    $core.List<$core.int>? wasmByteCode,
    $core.String? source,
    $core.String? builder,
  }) {
    final _result = create();
    if (sender != null) {
      _result.sender = sender;
    }
    if (wasmByteCode != null) {
      _result.wasmByteCode = wasmByteCode;
    }
    if (source != null) {
      _result.source = source;
    }
    if (builder != null) {
      _result.builder = builder;
    }
    return _result;
  }
  factory MsgStoreCode.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgStoreCode.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgStoreCode clone() => MsgStoreCode()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgStoreCode copyWith(void Function(MsgStoreCode) updates) => super.copyWith((message) => updates(message as MsgStoreCode)) as MsgStoreCode; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgStoreCode create() => MsgStoreCode._();
  MsgStoreCode createEmptyInstance() => create();
  static $pb.PbList<MsgStoreCode> createRepeated() => $pb.PbList<MsgStoreCode>();
  @$core.pragma('dart2js:noInline')
  static MsgStoreCode getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgStoreCode>(create);
  static MsgStoreCode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get sender => $_getN(0);
  @$pb.TagNumber(1)
  set sender($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSender() => $_has(0);
  @$pb.TagNumber(1)
  void clearSender() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get wasmByteCode => $_getN(1);
  @$pb.TagNumber(2)
  set wasmByteCode($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWasmByteCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearWasmByteCode() => clearField(2);

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

class MsgInstantiateContract extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgInstantiateContract', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sender', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'callbackCodeHash')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'label')
    ..a<$core.List<$core.int>>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'initMsg', $pb.PbFieldType.OY)
    ..pc<$5.Coin>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'initFunds', $pb.PbFieldType.PM, subBuilder: $5.Coin.create)
    ..a<$core.List<$core.int>>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'callbackSig', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  MsgInstantiateContract._() : super();
  factory MsgInstantiateContract({
    $core.List<$core.int>? sender,
    $core.String? callbackCodeHash,
    $fixnum.Int64? codeId,
    $core.String? label,
    $core.List<$core.int>? initMsg,
    $core.Iterable<$5.Coin>? initFunds,
    $core.List<$core.int>? callbackSig,
  }) {
    final _result = create();
    if (sender != null) {
      _result.sender = sender;
    }
    if (callbackCodeHash != null) {
      _result.callbackCodeHash = callbackCodeHash;
    }
    if (codeId != null) {
      _result.codeId = codeId;
    }
    if (label != null) {
      _result.label = label;
    }
    if (initMsg != null) {
      _result.initMsg = initMsg;
    }
    if (initFunds != null) {
      _result.initFunds.addAll(initFunds);
    }
    if (callbackSig != null) {
      _result.callbackSig = callbackSig;
    }
    return _result;
  }
  factory MsgInstantiateContract.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgInstantiateContract.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgInstantiateContract clone() => MsgInstantiateContract()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgInstantiateContract copyWith(void Function(MsgInstantiateContract) updates) => super.copyWith((message) => updates(message as MsgInstantiateContract)) as MsgInstantiateContract; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgInstantiateContract create() => MsgInstantiateContract._();
  MsgInstantiateContract createEmptyInstance() => create();
  static $pb.PbList<MsgInstantiateContract> createRepeated() => $pb.PbList<MsgInstantiateContract>();
  @$core.pragma('dart2js:noInline')
  static MsgInstantiateContract getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgInstantiateContract>(create);
  static MsgInstantiateContract? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get sender => $_getN(0);
  @$pb.TagNumber(1)
  set sender($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSender() => $_has(0);
  @$pb.TagNumber(1)
  void clearSender() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get callbackCodeHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set callbackCodeHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCallbackCodeHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallbackCodeHash() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get codeId => $_getI64(2);
  @$pb.TagNumber(3)
  set codeId($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCodeId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get initMsg => $_getN(4);
  @$pb.TagNumber(5)
  set initMsg($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasInitMsg() => $_has(4);
  @$pb.TagNumber(5)
  void clearInitMsg() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$5.Coin> get initFunds => $_getList(5);

  @$pb.TagNumber(7)
  $core.List<$core.int> get callbackSig => $_getN(6);
  @$pb.TagNumber(7)
  set callbackSig($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCallbackSig() => $_has(6);
  @$pb.TagNumber(7)
  void clearCallbackSig() => clearField(7);
}

class MsgExecuteContract extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgExecuteContract', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sender', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contract', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'msg', $pb.PbFieldType.OY)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'callbackCodeHash')
    ..pc<$5.Coin>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sentFunds', $pb.PbFieldType.PM, subBuilder: $5.Coin.create)
    ..a<$core.List<$core.int>>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'callbackSig', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  MsgExecuteContract._() : super();
  factory MsgExecuteContract({
    $core.List<$core.int>? sender,
    $core.List<$core.int>? contract,
    $core.List<$core.int>? msg,
    $core.String? callbackCodeHash,
    $core.Iterable<$5.Coin>? sentFunds,
    $core.List<$core.int>? callbackSig,
  }) {
    final _result = create();
    if (sender != null) {
      _result.sender = sender;
    }
    if (contract != null) {
      _result.contract = contract;
    }
    if (msg != null) {
      _result.msg = msg;
    }
    if (callbackCodeHash != null) {
      _result.callbackCodeHash = callbackCodeHash;
    }
    if (sentFunds != null) {
      _result.sentFunds.addAll(sentFunds);
    }
    if (callbackSig != null) {
      _result.callbackSig = callbackSig;
    }
    return _result;
  }
  factory MsgExecuteContract.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgExecuteContract.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgExecuteContract clone() => MsgExecuteContract()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgExecuteContract copyWith(void Function(MsgExecuteContract) updates) => super.copyWith((message) => updates(message as MsgExecuteContract)) as MsgExecuteContract; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgExecuteContract create() => MsgExecuteContract._();
  MsgExecuteContract createEmptyInstance() => create();
  static $pb.PbList<MsgExecuteContract> createRepeated() => $pb.PbList<MsgExecuteContract>();
  @$core.pragma('dart2js:noInline')
  static MsgExecuteContract getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgExecuteContract>(create);
  static MsgExecuteContract? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get sender => $_getN(0);
  @$pb.TagNumber(1)
  set sender($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSender() => $_has(0);
  @$pb.TagNumber(1)
  void clearSender() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get contract => $_getN(1);
  @$pb.TagNumber(2)
  set contract($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContract() => $_has(1);
  @$pb.TagNumber(2)
  void clearContract() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get msg => $_getN(2);
  @$pb.TagNumber(3)
  set msg($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMsg() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsg() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get callbackCodeHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set callbackCodeHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCallbackCodeHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearCallbackCodeHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$5.Coin> get sentFunds => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<$core.int> get callbackSig => $_getN(5);
  @$pb.TagNumber(6)
  set callbackSig($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCallbackSig() => $_has(5);
  @$pb.TagNumber(6)
  void clearCallbackSig() => clearField(6);
}

