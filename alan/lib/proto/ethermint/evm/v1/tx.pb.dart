///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/tx.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/any.pb.dart' as $2;
import 'evm.pb.dart' as $3;

class MsgEthereumTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgEthereumTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOM<$2.Any>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', subBuilder: $2.Any.create)
    ..a<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'size', $pb.PbFieldType.OD)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'from')
    ..hasRequiredFields = false
  ;

  MsgEthereumTx._() : super();
  factory MsgEthereumTx({
    $2.Any? data,
    $core.double? size,
    $core.String? hash,
    $core.String? from,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    if (size != null) {
      _result.size = size;
    }
    if (hash != null) {
      _result.hash = hash;
    }
    if (from != null) {
      _result.from = from;
    }
    return _result;
  }
  factory MsgEthereumTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgEthereumTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgEthereumTx clone() => MsgEthereumTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgEthereumTx copyWith(void Function(MsgEthereumTx) updates) => super.copyWith((message) => updates(message as MsgEthereumTx)) as MsgEthereumTx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgEthereumTx create() => MsgEthereumTx._();
  MsgEthereumTx createEmptyInstance() => create();
  static $pb.PbList<MsgEthereumTx> createRepeated() => $pb.PbList<MsgEthereumTx>();
  @$core.pragma('dart2js:noInline')
  static MsgEthereumTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgEthereumTx>(create);
  static MsgEthereumTx? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Any get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($2.Any v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $2.Any ensureData() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.double get size => $_getN(1);
  @$pb.TagNumber(2)
  set size($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearSize() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set hash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get from => $_getSZ(3);
  @$pb.TagNumber(4)
  set from($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFrom() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrom() => clearField(4);
}

class LegacyTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'LegacyTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasPrice')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gas', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'to')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value')
    ..a<$core.List<$core.int>>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'v', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'r', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 's', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  LegacyTx._() : super();
  factory LegacyTx({
    $fixnum.Int64? nonce,
    $core.String? gasPrice,
    $fixnum.Int64? gas,
    $core.String? to,
    $core.String? value,
    $core.List<$core.int>? data,
    $core.List<$core.int>? v,
    $core.List<$core.int>? r,
    $core.List<$core.int>? s,
  }) {
    final _result = create();
    if (nonce != null) {
      _result.nonce = nonce;
    }
    if (gasPrice != null) {
      _result.gasPrice = gasPrice;
    }
    if (gas != null) {
      _result.gas = gas;
    }
    if (to != null) {
      _result.to = to;
    }
    if (value != null) {
      _result.value = value;
    }
    if (data != null) {
      _result.data = data;
    }
    if (v != null) {
      _result.v = v;
    }
    if (r != null) {
      _result.r = r;
    }
    if (s != null) {
      _result.s = s;
    }
    return _result;
  }
  factory LegacyTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LegacyTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LegacyTx clone() => LegacyTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LegacyTx copyWith(void Function(LegacyTx) updates) => super.copyWith((message) => updates(message as LegacyTx)) as LegacyTx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LegacyTx create() => LegacyTx._();
  LegacyTx createEmptyInstance() => create();
  static $pb.PbList<LegacyTx> createRepeated() => $pb.PbList<LegacyTx>();
  @$core.pragma('dart2js:noInline')
  static LegacyTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LegacyTx>(create);
  static LegacyTx? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get nonce => $_getI64(0);
  @$pb.TagNumber(1)
  set nonce($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNonce() => $_has(0);
  @$pb.TagNumber(1)
  void clearNonce() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get gasPrice => $_getSZ(1);
  @$pb.TagNumber(2)
  set gasPrice($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGasPrice() => $_has(1);
  @$pb.TagNumber(2)
  void clearGasPrice() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get gas => $_getI64(2);
  @$pb.TagNumber(3)
  set gas($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGas() => $_has(2);
  @$pb.TagNumber(3)
  void clearGas() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get to => $_getSZ(3);
  @$pb.TagNumber(4)
  set to($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get value => $_getSZ(4);
  @$pb.TagNumber(5)
  set value($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get data => $_getN(5);
  @$pb.TagNumber(6)
  set data($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasData() => $_has(5);
  @$pb.TagNumber(6)
  void clearData() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get v => $_getN(6);
  @$pb.TagNumber(7)
  set v($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasV() => $_has(6);
  @$pb.TagNumber(7)
  void clearV() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get r => $_getN(7);
  @$pb.TagNumber(8)
  set r($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasR() => $_has(7);
  @$pb.TagNumber(8)
  void clearR() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get s => $_getN(8);
  @$pb.TagNumber(9)
  set s($core.List<$core.int> v) { $_setBytes(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasS() => $_has(8);
  @$pb.TagNumber(9)
  void clearS() => clearField(9);
}

class AccessListTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AccessListTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'chainId')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasPrice')
    ..a<$fixnum.Int64>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gas', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'to')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value')
    ..a<$core.List<$core.int>>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..pc<$3.AccessTuple>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accesses', $pb.PbFieldType.PM, subBuilder: $3.AccessTuple.create)
    ..a<$core.List<$core.int>>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'v', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'r', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 's', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  AccessListTx._() : super();
  factory AccessListTx({
    $core.String? chainId,
    $fixnum.Int64? nonce,
    $core.String? gasPrice,
    $fixnum.Int64? gas,
    $core.String? to,
    $core.String? value,
    $core.List<$core.int>? data,
    $core.Iterable<$3.AccessTuple>? accesses,
    $core.List<$core.int>? v,
    $core.List<$core.int>? r,
    $core.List<$core.int>? s,
  }) {
    final _result = create();
    if (chainId != null) {
      _result.chainId = chainId;
    }
    if (nonce != null) {
      _result.nonce = nonce;
    }
    if (gasPrice != null) {
      _result.gasPrice = gasPrice;
    }
    if (gas != null) {
      _result.gas = gas;
    }
    if (to != null) {
      _result.to = to;
    }
    if (value != null) {
      _result.value = value;
    }
    if (data != null) {
      _result.data = data;
    }
    if (accesses != null) {
      _result.accesses.addAll(accesses);
    }
    if (v != null) {
      _result.v = v;
    }
    if (r != null) {
      _result.r = r;
    }
    if (s != null) {
      _result.s = s;
    }
    return _result;
  }
  factory AccessListTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessListTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessListTx clone() => AccessListTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessListTx copyWith(void Function(AccessListTx) updates) => super.copyWith((message) => updates(message as AccessListTx)) as AccessListTx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AccessListTx create() => AccessListTx._();
  AccessListTx createEmptyInstance() => create();
  static $pb.PbList<AccessListTx> createRepeated() => $pb.PbList<AccessListTx>();
  @$core.pragma('dart2js:noInline')
  static AccessListTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessListTx>(create);
  static AccessListTx? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chainId => $_getSZ(0);
  @$pb.TagNumber(1)
  set chainId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChainId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get nonce => $_getI64(1);
  @$pb.TagNumber(2)
  set nonce($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNonce() => $_has(1);
  @$pb.TagNumber(2)
  void clearNonce() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get gasPrice => $_getSZ(2);
  @$pb.TagNumber(3)
  set gasPrice($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGasPrice() => $_has(2);
  @$pb.TagNumber(3)
  void clearGasPrice() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get gas => $_getI64(3);
  @$pb.TagNumber(4)
  set gas($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGas() => $_has(3);
  @$pb.TagNumber(4)
  void clearGas() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get to => $_getSZ(4);
  @$pb.TagNumber(5)
  set to($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTo() => $_has(4);
  @$pb.TagNumber(5)
  void clearTo() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get value => $_getSZ(5);
  @$pb.TagNumber(6)
  set value($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearValue() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get data => $_getN(6);
  @$pb.TagNumber(7)
  set data($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasData() => $_has(6);
  @$pb.TagNumber(7)
  void clearData() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$3.AccessTuple> get accesses => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<$core.int> get v => $_getN(8);
  @$pb.TagNumber(9)
  set v($core.List<$core.int> v) { $_setBytes(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasV() => $_has(8);
  @$pb.TagNumber(9)
  void clearV() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.int> get r => $_getN(9);
  @$pb.TagNumber(10)
  set r($core.List<$core.int> v) { $_setBytes(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasR() => $_has(9);
  @$pb.TagNumber(10)
  void clearR() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<$core.int> get s => $_getN(10);
  @$pb.TagNumber(11)
  set s($core.List<$core.int> v) { $_setBytes(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasS() => $_has(10);
  @$pb.TagNumber(11)
  void clearS() => clearField(11);
}

class DynamicFeeTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DynamicFeeTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'chainId')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasTipCap')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasFeeCap')
    ..a<$fixnum.Int64>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gas', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'to')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value')
    ..a<$core.List<$core.int>>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..pc<$3.AccessTuple>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accesses', $pb.PbFieldType.PM, subBuilder: $3.AccessTuple.create)
    ..a<$core.List<$core.int>>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'v', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'r', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 's', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  DynamicFeeTx._() : super();
  factory DynamicFeeTx({
    $core.String? chainId,
    $fixnum.Int64? nonce,
    $core.String? gasTipCap,
    $core.String? gasFeeCap,
    $fixnum.Int64? gas,
    $core.String? to,
    $core.String? value,
    $core.List<$core.int>? data,
    $core.Iterable<$3.AccessTuple>? accesses,
    $core.List<$core.int>? v,
    $core.List<$core.int>? r,
    $core.List<$core.int>? s,
  }) {
    final _result = create();
    if (chainId != null) {
      _result.chainId = chainId;
    }
    if (nonce != null) {
      _result.nonce = nonce;
    }
    if (gasTipCap != null) {
      _result.gasTipCap = gasTipCap;
    }
    if (gasFeeCap != null) {
      _result.gasFeeCap = gasFeeCap;
    }
    if (gas != null) {
      _result.gas = gas;
    }
    if (to != null) {
      _result.to = to;
    }
    if (value != null) {
      _result.value = value;
    }
    if (data != null) {
      _result.data = data;
    }
    if (accesses != null) {
      _result.accesses.addAll(accesses);
    }
    if (v != null) {
      _result.v = v;
    }
    if (r != null) {
      _result.r = r;
    }
    if (s != null) {
      _result.s = s;
    }
    return _result;
  }
  factory DynamicFeeTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DynamicFeeTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DynamicFeeTx clone() => DynamicFeeTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DynamicFeeTx copyWith(void Function(DynamicFeeTx) updates) => super.copyWith((message) => updates(message as DynamicFeeTx)) as DynamicFeeTx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DynamicFeeTx create() => DynamicFeeTx._();
  DynamicFeeTx createEmptyInstance() => create();
  static $pb.PbList<DynamicFeeTx> createRepeated() => $pb.PbList<DynamicFeeTx>();
  @$core.pragma('dart2js:noInline')
  static DynamicFeeTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DynamicFeeTx>(create);
  static DynamicFeeTx? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chainId => $_getSZ(0);
  @$pb.TagNumber(1)
  set chainId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChainId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get nonce => $_getI64(1);
  @$pb.TagNumber(2)
  set nonce($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNonce() => $_has(1);
  @$pb.TagNumber(2)
  void clearNonce() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get gasTipCap => $_getSZ(2);
  @$pb.TagNumber(3)
  set gasTipCap($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGasTipCap() => $_has(2);
  @$pb.TagNumber(3)
  void clearGasTipCap() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get gasFeeCap => $_getSZ(3);
  @$pb.TagNumber(4)
  set gasFeeCap($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGasFeeCap() => $_has(3);
  @$pb.TagNumber(4)
  void clearGasFeeCap() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get gas => $_getI64(4);
  @$pb.TagNumber(5)
  set gas($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGas() => $_has(4);
  @$pb.TagNumber(5)
  void clearGas() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get to => $_getSZ(5);
  @$pb.TagNumber(6)
  set to($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearTo() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get value => $_getSZ(6);
  @$pb.TagNumber(7)
  set value($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearValue() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get data => $_getN(7);
  @$pb.TagNumber(8)
  set data($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasData() => $_has(7);
  @$pb.TagNumber(8)
  void clearData() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$3.AccessTuple> get accesses => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<$core.int> get v => $_getN(9);
  @$pb.TagNumber(10)
  set v($core.List<$core.int> v) { $_setBytes(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasV() => $_has(9);
  @$pb.TagNumber(10)
  void clearV() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<$core.int> get r => $_getN(10);
  @$pb.TagNumber(11)
  set r($core.List<$core.int> v) { $_setBytes(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasR() => $_has(10);
  @$pb.TagNumber(11)
  void clearR() => clearField(11);

  @$pb.TagNumber(12)
  $core.List<$core.int> get s => $_getN(11);
  @$pb.TagNumber(12)
  set s($core.List<$core.int> v) { $_setBytes(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasS() => $_has(11);
  @$pb.TagNumber(12)
  void clearS() => clearField(12);
}

class ExtensionOptionsEthereumTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ExtensionOptionsEthereumTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  ExtensionOptionsEthereumTx._() : super();
  factory ExtensionOptionsEthereumTx() => create();
  factory ExtensionOptionsEthereumTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExtensionOptionsEthereumTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExtensionOptionsEthereumTx clone() => ExtensionOptionsEthereumTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExtensionOptionsEthereumTx copyWith(void Function(ExtensionOptionsEthereumTx) updates) => super.copyWith((message) => updates(message as ExtensionOptionsEthereumTx)) as ExtensionOptionsEthereumTx; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ExtensionOptionsEthereumTx create() => ExtensionOptionsEthereumTx._();
  ExtensionOptionsEthereumTx createEmptyInstance() => create();
  static $pb.PbList<ExtensionOptionsEthereumTx> createRepeated() => $pb.PbList<ExtensionOptionsEthereumTx>();
  @$core.pragma('dart2js:noInline')
  static ExtensionOptionsEthereumTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExtensionOptionsEthereumTx>(create);
  static ExtensionOptionsEthereumTx? _defaultInstance;
}

class MsgEthereumTxResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgEthereumTxResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash')
    ..pc<$3.Log>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'logs', $pb.PbFieldType.PM, subBuilder: $3.Log.create)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ret', $pb.PbFieldType.OY)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'vmError')
    ..a<$fixnum.Int64>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasUsed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  MsgEthereumTxResponse._() : super();
  factory MsgEthereumTxResponse({
    $core.String? hash,
    $core.Iterable<$3.Log>? logs,
    $core.List<$core.int>? ret,
    $core.String? vmError,
    $fixnum.Int64? gasUsed,
  }) {
    final _result = create();
    if (hash != null) {
      _result.hash = hash;
    }
    if (logs != null) {
      _result.logs.addAll(logs);
    }
    if (ret != null) {
      _result.ret = ret;
    }
    if (vmError != null) {
      _result.vmError = vmError;
    }
    if (gasUsed != null) {
      _result.gasUsed = gasUsed;
    }
    return _result;
  }
  factory MsgEthereumTxResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgEthereumTxResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgEthereumTxResponse clone() => MsgEthereumTxResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgEthereumTxResponse copyWith(void Function(MsgEthereumTxResponse) updates) => super.copyWith((message) => updates(message as MsgEthereumTxResponse)) as MsgEthereumTxResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgEthereumTxResponse create() => MsgEthereumTxResponse._();
  MsgEthereumTxResponse createEmptyInstance() => create();
  static $pb.PbList<MsgEthereumTxResponse> createRepeated() => $pb.PbList<MsgEthereumTxResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgEthereumTxResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgEthereumTxResponse>(create);
  static MsgEthereumTxResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$3.Log> get logs => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get ret => $_getN(2);
  @$pb.TagNumber(3)
  set ret($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRet() => $_has(2);
  @$pb.TagNumber(3)
  void clearRet() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get vmError => $_getSZ(3);
  @$pb.TagNumber(4)
  set vmError($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVmError() => $_has(3);
  @$pb.TagNumber(4)
  void clearVmError() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get gasUsed => $_getI64(4);
  @$pb.TagNumber(5)
  set gasUsed($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGasUsed() => $_has(4);
  @$pb.TagNumber(5)
  void clearGasUsed() => clearField(5);
}

