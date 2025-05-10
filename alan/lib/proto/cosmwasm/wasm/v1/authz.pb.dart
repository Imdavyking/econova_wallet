///
//  Generated code. Do not modify.
//  source: cosmwasm/wasm/v1/authz.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'types.pb.dart' as $3;
import '../../../google/protobuf/any.pb.dart' as $2;
import '../../../cosmos/base/v1beta1/coin.pb.dart' as $4;

class StoreCodeAuthorization extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'StoreCodeAuthorization', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..pc<CodeGrant>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'grants', $pb.PbFieldType.PM, subBuilder: CodeGrant.create)
    ..hasRequiredFields = false
  ;

  StoreCodeAuthorization._() : super();
  factory StoreCodeAuthorization({
    $core.Iterable<CodeGrant>? grants,
  }) {
    final _result = create();
    if (grants != null) {
      _result.grants.addAll(grants);
    }
    return _result;
  }
  factory StoreCodeAuthorization.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoreCodeAuthorization.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoreCodeAuthorization clone() => StoreCodeAuthorization()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoreCodeAuthorization copyWith(void Function(StoreCodeAuthorization) updates) => super.copyWith((message) => updates(message as StoreCodeAuthorization)) as StoreCodeAuthorization; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static StoreCodeAuthorization create() => StoreCodeAuthorization._();
  StoreCodeAuthorization createEmptyInstance() => create();
  static $pb.PbList<StoreCodeAuthorization> createRepeated() => $pb.PbList<StoreCodeAuthorization>();
  @$core.pragma('dart2js:noInline')
  static StoreCodeAuthorization getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreCodeAuthorization>(create);
  static StoreCodeAuthorization? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CodeGrant> get grants => $_getList(0);
}

class ContractExecutionAuthorization extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractExecutionAuthorization', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..pc<ContractGrant>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'grants', $pb.PbFieldType.PM, subBuilder: ContractGrant.create)
    ..hasRequiredFields = false
  ;

  ContractExecutionAuthorization._() : super();
  factory ContractExecutionAuthorization({
    $core.Iterable<ContractGrant>? grants,
  }) {
    final _result = create();
    if (grants != null) {
      _result.grants.addAll(grants);
    }
    return _result;
  }
  factory ContractExecutionAuthorization.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractExecutionAuthorization.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractExecutionAuthorization clone() => ContractExecutionAuthorization()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractExecutionAuthorization copyWith(void Function(ContractExecutionAuthorization) updates) => super.copyWith((message) => updates(message as ContractExecutionAuthorization)) as ContractExecutionAuthorization; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractExecutionAuthorization create() => ContractExecutionAuthorization._();
  ContractExecutionAuthorization createEmptyInstance() => create();
  static $pb.PbList<ContractExecutionAuthorization> createRepeated() => $pb.PbList<ContractExecutionAuthorization>();
  @$core.pragma('dart2js:noInline')
  static ContractExecutionAuthorization getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractExecutionAuthorization>(create);
  static ContractExecutionAuthorization? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ContractGrant> get grants => $_getList(0);
}

class ContractMigrationAuthorization extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractMigrationAuthorization', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..pc<ContractGrant>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'grants', $pb.PbFieldType.PM, subBuilder: ContractGrant.create)
    ..hasRequiredFields = false
  ;

  ContractMigrationAuthorization._() : super();
  factory ContractMigrationAuthorization({
    $core.Iterable<ContractGrant>? grants,
  }) {
    final _result = create();
    if (grants != null) {
      _result.grants.addAll(grants);
    }
    return _result;
  }
  factory ContractMigrationAuthorization.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractMigrationAuthorization.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractMigrationAuthorization clone() => ContractMigrationAuthorization()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractMigrationAuthorization copyWith(void Function(ContractMigrationAuthorization) updates) => super.copyWith((message) => updates(message as ContractMigrationAuthorization)) as ContractMigrationAuthorization; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractMigrationAuthorization create() => ContractMigrationAuthorization._();
  ContractMigrationAuthorization createEmptyInstance() => create();
  static $pb.PbList<ContractMigrationAuthorization> createRepeated() => $pb.PbList<ContractMigrationAuthorization>();
  @$core.pragma('dart2js:noInline')
  static ContractMigrationAuthorization getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractMigrationAuthorization>(create);
  static ContractMigrationAuthorization? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ContractGrant> get grants => $_getList(0);
}

class CodeGrant extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CodeGrant', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeHash', $pb.PbFieldType.OY)
    ..aOM<$3.AccessConfig>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'instantiatePermission', subBuilder: $3.AccessConfig.create)
    ..hasRequiredFields = false
  ;

  CodeGrant._() : super();
  factory CodeGrant({
    $core.List<$core.int>? codeHash,
    $3.AccessConfig? instantiatePermission,
  }) {
    final _result = create();
    if (codeHash != null) {
      _result.codeHash = codeHash;
    }
    if (instantiatePermission != null) {
      _result.instantiatePermission = instantiatePermission;
    }
    return _result;
  }
  factory CodeGrant.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CodeGrant.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CodeGrant clone() => CodeGrant()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CodeGrant copyWith(void Function(CodeGrant) updates) => super.copyWith((message) => updates(message as CodeGrant)) as CodeGrant; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CodeGrant create() => CodeGrant._();
  CodeGrant createEmptyInstance() => create();
  static $pb.PbList<CodeGrant> createRepeated() => $pb.PbList<CodeGrant>();
  @$core.pragma('dart2js:noInline')
  static CodeGrant getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CodeGrant>(create);
  static CodeGrant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get codeHash => $_getN(0);
  @$pb.TagNumber(1)
  set codeHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeHash() => clearField(1);

  @$pb.TagNumber(2)
  $3.AccessConfig get instantiatePermission => $_getN(1);
  @$pb.TagNumber(2)
  set instantiatePermission($3.AccessConfig v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasInstantiatePermission() => $_has(1);
  @$pb.TagNumber(2)
  void clearInstantiatePermission() => clearField(2);
  @$pb.TagNumber(2)
  $3.AccessConfig ensureInstantiatePermission() => $_ensure(1);
}

class ContractGrant extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractGrant', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contract')
    ..aOM<$2.Any>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'limit', subBuilder: $2.Any.create)
    ..aOM<$2.Any>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'filter', subBuilder: $2.Any.create)
    ..hasRequiredFields = false
  ;

  ContractGrant._() : super();
  factory ContractGrant({
    $core.String? contract,
    $2.Any? limit,
    $2.Any? filter,
  }) {
    final _result = create();
    if (contract != null) {
      _result.contract = contract;
    }
    if (limit != null) {
      _result.limit = limit;
    }
    if (filter != null) {
      _result.filter = filter;
    }
    return _result;
  }
  factory ContractGrant.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractGrant.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractGrant clone() => ContractGrant()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractGrant copyWith(void Function(ContractGrant) updates) => super.copyWith((message) => updates(message as ContractGrant)) as ContractGrant; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractGrant create() => ContractGrant._();
  ContractGrant createEmptyInstance() => create();
  static $pb.PbList<ContractGrant> createRepeated() => $pb.PbList<ContractGrant>();
  @$core.pragma('dart2js:noInline')
  static ContractGrant getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractGrant>(create);
  static ContractGrant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contract => $_getSZ(0);
  @$pb.TagNumber(1)
  set contract($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContract() => $_has(0);
  @$pb.TagNumber(1)
  void clearContract() => clearField(1);

  @$pb.TagNumber(2)
  $2.Any get limit => $_getN(1);
  @$pb.TagNumber(2)
  set limit($2.Any v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);
  @$pb.TagNumber(2)
  $2.Any ensureLimit() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.Any get filter => $_getN(2);
  @$pb.TagNumber(3)
  set filter($2.Any v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasFilter() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilter() => clearField(3);
  @$pb.TagNumber(3)
  $2.Any ensureFilter() => $_ensure(2);
}

class MaxCallsLimit extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MaxCallsLimit', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'remaining', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  MaxCallsLimit._() : super();
  factory MaxCallsLimit({
    $fixnum.Int64? remaining,
  }) {
    final _result = create();
    if (remaining != null) {
      _result.remaining = remaining;
    }
    return _result;
  }
  factory MaxCallsLimit.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MaxCallsLimit.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MaxCallsLimit clone() => MaxCallsLimit()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MaxCallsLimit copyWith(void Function(MaxCallsLimit) updates) => super.copyWith((message) => updates(message as MaxCallsLimit)) as MaxCallsLimit; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MaxCallsLimit create() => MaxCallsLimit._();
  MaxCallsLimit createEmptyInstance() => create();
  static $pb.PbList<MaxCallsLimit> createRepeated() => $pb.PbList<MaxCallsLimit>();
  @$core.pragma('dart2js:noInline')
  static MaxCallsLimit getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MaxCallsLimit>(create);
  static MaxCallsLimit? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get remaining => $_getI64(0);
  @$pb.TagNumber(1)
  set remaining($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRemaining() => $_has(0);
  @$pb.TagNumber(1)
  void clearRemaining() => clearField(1);
}

class MaxFundsLimit extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MaxFundsLimit', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..pc<$4.Coin>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'amounts', $pb.PbFieldType.PM, subBuilder: $4.Coin.create)
    ..hasRequiredFields = false
  ;

  MaxFundsLimit._() : super();
  factory MaxFundsLimit({
    $core.Iterable<$4.Coin>? amounts,
  }) {
    final _result = create();
    if (amounts != null) {
      _result.amounts.addAll(amounts);
    }
    return _result;
  }
  factory MaxFundsLimit.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MaxFundsLimit.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MaxFundsLimit clone() => MaxFundsLimit()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MaxFundsLimit copyWith(void Function(MaxFundsLimit) updates) => super.copyWith((message) => updates(message as MaxFundsLimit)) as MaxFundsLimit; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MaxFundsLimit create() => MaxFundsLimit._();
  MaxFundsLimit createEmptyInstance() => create();
  static $pb.PbList<MaxFundsLimit> createRepeated() => $pb.PbList<MaxFundsLimit>();
  @$core.pragma('dart2js:noInline')
  static MaxFundsLimit getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MaxFundsLimit>(create);
  static MaxFundsLimit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$4.Coin> get amounts => $_getList(0);
}

class CombinedLimit extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CombinedLimit', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'callsRemaining', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<$4.Coin>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'amounts', $pb.PbFieldType.PM, subBuilder: $4.Coin.create)
    ..hasRequiredFields = false
  ;

  CombinedLimit._() : super();
  factory CombinedLimit({
    $fixnum.Int64? callsRemaining,
    $core.Iterable<$4.Coin>? amounts,
  }) {
    final _result = create();
    if (callsRemaining != null) {
      _result.callsRemaining = callsRemaining;
    }
    if (amounts != null) {
      _result.amounts.addAll(amounts);
    }
    return _result;
  }
  factory CombinedLimit.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinedLimit.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinedLimit clone() => CombinedLimit()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinedLimit copyWith(void Function(CombinedLimit) updates) => super.copyWith((message) => updates(message as CombinedLimit)) as CombinedLimit; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CombinedLimit create() => CombinedLimit._();
  CombinedLimit createEmptyInstance() => create();
  static $pb.PbList<CombinedLimit> createRepeated() => $pb.PbList<CombinedLimit>();
  @$core.pragma('dart2js:noInline')
  static CombinedLimit getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinedLimit>(create);
  static CombinedLimit? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get callsRemaining => $_getI64(0);
  @$pb.TagNumber(1)
  set callsRemaining($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCallsRemaining() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallsRemaining() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$4.Coin> get amounts => $_getList(1);
}

class AllowAllMessagesFilter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AllowAllMessagesFilter', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  AllowAllMessagesFilter._() : super();
  factory AllowAllMessagesFilter() => create();
  factory AllowAllMessagesFilter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AllowAllMessagesFilter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AllowAllMessagesFilter clone() => AllowAllMessagesFilter()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AllowAllMessagesFilter copyWith(void Function(AllowAllMessagesFilter) updates) => super.copyWith((message) => updates(message as AllowAllMessagesFilter)) as AllowAllMessagesFilter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AllowAllMessagesFilter create() => AllowAllMessagesFilter._();
  AllowAllMessagesFilter createEmptyInstance() => create();
  static $pb.PbList<AllowAllMessagesFilter> createRepeated() => $pb.PbList<AllowAllMessagesFilter>();
  @$core.pragma('dart2js:noInline')
  static AllowAllMessagesFilter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllowAllMessagesFilter>(create);
  static AllowAllMessagesFilter? _defaultInstance;
}

class AcceptedMessageKeysFilter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AcceptedMessageKeysFilter', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..pPS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'keys')
    ..hasRequiredFields = false
  ;

  AcceptedMessageKeysFilter._() : super();
  factory AcceptedMessageKeysFilter({
    $core.Iterable<$core.String>? keys,
  }) {
    final _result = create();
    if (keys != null) {
      _result.keys.addAll(keys);
    }
    return _result;
  }
  factory AcceptedMessageKeysFilter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AcceptedMessageKeysFilter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AcceptedMessageKeysFilter clone() => AcceptedMessageKeysFilter()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AcceptedMessageKeysFilter copyWith(void Function(AcceptedMessageKeysFilter) updates) => super.copyWith((message) => updates(message as AcceptedMessageKeysFilter)) as AcceptedMessageKeysFilter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AcceptedMessageKeysFilter create() => AcceptedMessageKeysFilter._();
  AcceptedMessageKeysFilter createEmptyInstance() => create();
  static $pb.PbList<AcceptedMessageKeysFilter> createRepeated() => $pb.PbList<AcceptedMessageKeysFilter>();
  @$core.pragma('dart2js:noInline')
  static AcceptedMessageKeysFilter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptedMessageKeysFilter>(create);
  static AcceptedMessageKeysFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get keys => $_getList(0);
}

class AcceptedMessagesFilter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AcceptedMessagesFilter', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'cosmwasm.wasm.v1'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'messages', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  AcceptedMessagesFilter._() : super();
  factory AcceptedMessagesFilter({
    $core.Iterable<$core.List<$core.int>>? messages,
  }) {
    final _result = create();
    if (messages != null) {
      _result.messages.addAll(messages);
    }
    return _result;
  }
  factory AcceptedMessagesFilter.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AcceptedMessagesFilter.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AcceptedMessagesFilter clone() => AcceptedMessagesFilter()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AcceptedMessagesFilter copyWith(void Function(AcceptedMessagesFilter) updates) => super.copyWith((message) => updates(message as AcceptedMessagesFilter)) as AcceptedMessagesFilter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AcceptedMessagesFilter create() => AcceptedMessagesFilter._();
  AcceptedMessagesFilter createEmptyInstance() => create();
  static $pb.PbList<AcceptedMessagesFilter> createRepeated() => $pb.PbList<AcceptedMessagesFilter>();
  @$core.pragma('dart2js:noInline')
  static AcceptedMessagesFilter getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AcceptedMessagesFilter>(create);
  static AcceptedMessagesFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get messages => $_getList(0);
}

