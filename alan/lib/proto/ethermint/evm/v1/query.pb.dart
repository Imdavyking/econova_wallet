///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../cosmos/base/query/v1beta1/pagination.pb.dart' as $4;
import 'evm.pb.dart' as $3;
import 'tx.pb.dart' as $0;
import '../../../google/protobuf/timestamp.pb.dart' as $5;

class QueryAccountRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryAccountRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..hasRequiredFields = false
  ;

  QueryAccountRequest._() : super();
  factory QueryAccountRequest({
    $core.String? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryAccountRequest clone() => QueryAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryAccountRequest copyWith(void Function(QueryAccountRequest) updates) => super.copyWith((message) => updates(message as QueryAccountRequest)) as QueryAccountRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryAccountRequest create() => QueryAccountRequest._();
  QueryAccountRequest createEmptyInstance() => create();
  static $pb.PbList<QueryAccountRequest> createRepeated() => $pb.PbList<QueryAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryAccountRequest>(create);
  static QueryAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryAccountResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryAccountResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'balance')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeHash')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  QueryAccountResponse._() : super();
  factory QueryAccountResponse({
    $core.String? balance,
    $core.String? codeHash,
    $fixnum.Int64? nonce,
  }) {
    final _result = create();
    if (balance != null) {
      _result.balance = balance;
    }
    if (codeHash != null) {
      _result.codeHash = codeHash;
    }
    if (nonce != null) {
      _result.nonce = nonce;
    }
    return _result;
  }
  factory QueryAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryAccountResponse clone() => QueryAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryAccountResponse copyWith(void Function(QueryAccountResponse) updates) => super.copyWith((message) => updates(message as QueryAccountResponse)) as QueryAccountResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryAccountResponse create() => QueryAccountResponse._();
  QueryAccountResponse createEmptyInstance() => create();
  static $pb.PbList<QueryAccountResponse> createRepeated() => $pb.PbList<QueryAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryAccountResponse>(create);
  static QueryAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get balance => $_getSZ(0);
  @$pb.TagNumber(1)
  set balance($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBalance() => $_has(0);
  @$pb.TagNumber(1)
  void clearBalance() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get codeHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set codeHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCodeHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCodeHash() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get nonce => $_getI64(2);
  @$pb.TagNumber(3)
  set nonce($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNonce() => $_has(2);
  @$pb.TagNumber(3)
  void clearNonce() => clearField(3);
}

class QueryCosmosAccountRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCosmosAccountRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..hasRequiredFields = false
  ;

  QueryCosmosAccountRequest._() : super();
  factory QueryCosmosAccountRequest({
    $core.String? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryCosmosAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryCosmosAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryCosmosAccountRequest clone() => QueryCosmosAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryCosmosAccountRequest copyWith(void Function(QueryCosmosAccountRequest) updates) => super.copyWith((message) => updates(message as QueryCosmosAccountRequest)) as QueryCosmosAccountRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryCosmosAccountRequest create() => QueryCosmosAccountRequest._();
  QueryCosmosAccountRequest createEmptyInstance() => create();
  static $pb.PbList<QueryCosmosAccountRequest> createRepeated() => $pb.PbList<QueryCosmosAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryCosmosAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryCosmosAccountRequest>(create);
  static QueryCosmosAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryCosmosAccountResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCosmosAccountResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'cosmosAddress')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sequence', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accountNumber', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  QueryCosmosAccountResponse._() : super();
  factory QueryCosmosAccountResponse({
    $core.String? cosmosAddress,
    $fixnum.Int64? sequence,
    $fixnum.Int64? accountNumber,
  }) {
    final _result = create();
    if (cosmosAddress != null) {
      _result.cosmosAddress = cosmosAddress;
    }
    if (sequence != null) {
      _result.sequence = sequence;
    }
    if (accountNumber != null) {
      _result.accountNumber = accountNumber;
    }
    return _result;
  }
  factory QueryCosmosAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryCosmosAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryCosmosAccountResponse clone() => QueryCosmosAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryCosmosAccountResponse copyWith(void Function(QueryCosmosAccountResponse) updates) => super.copyWith((message) => updates(message as QueryCosmosAccountResponse)) as QueryCosmosAccountResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryCosmosAccountResponse create() => QueryCosmosAccountResponse._();
  QueryCosmosAccountResponse createEmptyInstance() => create();
  static $pb.PbList<QueryCosmosAccountResponse> createRepeated() => $pb.PbList<QueryCosmosAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryCosmosAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryCosmosAccountResponse>(create);
  static QueryCosmosAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cosmosAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set cosmosAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCosmosAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearCosmosAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sequence => $_getI64(1);
  @$pb.TagNumber(2)
  set sequence($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearSequence() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get accountNumber => $_getI64(2);
  @$pb.TagNumber(3)
  set accountNumber($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountNumber() => clearField(3);
}

class QueryValidatorAccountRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryValidatorAccountRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'consAddress')
    ..hasRequiredFields = false
  ;

  QueryValidatorAccountRequest._() : super();
  factory QueryValidatorAccountRequest({
    $core.String? consAddress,
  }) {
    final _result = create();
    if (consAddress != null) {
      _result.consAddress = consAddress;
    }
    return _result;
  }
  factory QueryValidatorAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryValidatorAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryValidatorAccountRequest clone() => QueryValidatorAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryValidatorAccountRequest copyWith(void Function(QueryValidatorAccountRequest) updates) => super.copyWith((message) => updates(message as QueryValidatorAccountRequest)) as QueryValidatorAccountRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryValidatorAccountRequest create() => QueryValidatorAccountRequest._();
  QueryValidatorAccountRequest createEmptyInstance() => create();
  static $pb.PbList<QueryValidatorAccountRequest> createRepeated() => $pb.PbList<QueryValidatorAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryValidatorAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryValidatorAccountRequest>(create);
  static QueryValidatorAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get consAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set consAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConsAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearConsAddress() => clearField(1);
}

class QueryValidatorAccountResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryValidatorAccountResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accountAddress')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sequence', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accountNumber', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  QueryValidatorAccountResponse._() : super();
  factory QueryValidatorAccountResponse({
    $core.String? accountAddress,
    $fixnum.Int64? sequence,
    $fixnum.Int64? accountNumber,
  }) {
    final _result = create();
    if (accountAddress != null) {
      _result.accountAddress = accountAddress;
    }
    if (sequence != null) {
      _result.sequence = sequence;
    }
    if (accountNumber != null) {
      _result.accountNumber = accountNumber;
    }
    return _result;
  }
  factory QueryValidatorAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryValidatorAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryValidatorAccountResponse clone() => QueryValidatorAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryValidatorAccountResponse copyWith(void Function(QueryValidatorAccountResponse) updates) => super.copyWith((message) => updates(message as QueryValidatorAccountResponse)) as QueryValidatorAccountResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryValidatorAccountResponse create() => QueryValidatorAccountResponse._();
  QueryValidatorAccountResponse createEmptyInstance() => create();
  static $pb.PbList<QueryValidatorAccountResponse> createRepeated() => $pb.PbList<QueryValidatorAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryValidatorAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryValidatorAccountResponse>(create);
  static QueryValidatorAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accountAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set accountAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccountAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccountAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sequence => $_getI64(1);
  @$pb.TagNumber(2)
  set sequence($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearSequence() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get accountNumber => $_getI64(2);
  @$pb.TagNumber(3)
  set accountNumber($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountNumber() => clearField(3);
}

class QueryBalanceRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryBalanceRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..hasRequiredFields = false
  ;

  QueryBalanceRequest._() : super();
  factory QueryBalanceRequest({
    $core.String? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryBalanceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryBalanceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryBalanceRequest clone() => QueryBalanceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryBalanceRequest copyWith(void Function(QueryBalanceRequest) updates) => super.copyWith((message) => updates(message as QueryBalanceRequest)) as QueryBalanceRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryBalanceRequest create() => QueryBalanceRequest._();
  QueryBalanceRequest createEmptyInstance() => create();
  static $pb.PbList<QueryBalanceRequest> createRepeated() => $pb.PbList<QueryBalanceRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryBalanceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryBalanceRequest>(create);
  static QueryBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryBalanceResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryBalanceResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'balance')
    ..hasRequiredFields = false
  ;

  QueryBalanceResponse._() : super();
  factory QueryBalanceResponse({
    $core.String? balance,
  }) {
    final _result = create();
    if (balance != null) {
      _result.balance = balance;
    }
    return _result;
  }
  factory QueryBalanceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryBalanceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryBalanceResponse clone() => QueryBalanceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryBalanceResponse copyWith(void Function(QueryBalanceResponse) updates) => super.copyWith((message) => updates(message as QueryBalanceResponse)) as QueryBalanceResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryBalanceResponse create() => QueryBalanceResponse._();
  QueryBalanceResponse createEmptyInstance() => create();
  static $pb.PbList<QueryBalanceResponse> createRepeated() => $pb.PbList<QueryBalanceResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryBalanceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryBalanceResponse>(create);
  static QueryBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get balance => $_getSZ(0);
  @$pb.TagNumber(1)
  set balance($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBalance() => $_has(0);
  @$pb.TagNumber(1)
  void clearBalance() => clearField(1);
}

class QueryStorageRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryStorageRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'key')
    ..hasRequiredFields = false
  ;

  QueryStorageRequest._() : super();
  factory QueryStorageRequest({
    $core.String? address,
    $core.String? key,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (key != null) {
      _result.key = key;
    }
    return _result;
  }
  factory QueryStorageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryStorageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryStorageRequest clone() => QueryStorageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryStorageRequest copyWith(void Function(QueryStorageRequest) updates) => super.copyWith((message) => updates(message as QueryStorageRequest)) as QueryStorageRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryStorageRequest create() => QueryStorageRequest._();
  QueryStorageRequest createEmptyInstance() => create();
  static $pb.PbList<QueryStorageRequest> createRepeated() => $pb.PbList<QueryStorageRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryStorageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryStorageRequest>(create);
  static QueryStorageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => clearField(2);
}

class QueryStorageResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryStorageResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value')
    ..hasRequiredFields = false
  ;

  QueryStorageResponse._() : super();
  factory QueryStorageResponse({
    $core.String? value,
  }) {
    final _result = create();
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory QueryStorageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryStorageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryStorageResponse clone() => QueryStorageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryStorageResponse copyWith(void Function(QueryStorageResponse) updates) => super.copyWith((message) => updates(message as QueryStorageResponse)) as QueryStorageResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryStorageResponse create() => QueryStorageResponse._();
  QueryStorageResponse createEmptyInstance() => create();
  static $pb.PbList<QueryStorageResponse> createRepeated() => $pb.PbList<QueryStorageResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryStorageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryStorageResponse>(create);
  static QueryStorageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
}

class QueryCodeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCodeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..hasRequiredFields = false
  ;

  QueryCodeRequest._() : super();
  factory QueryCodeRequest({
    $core.String? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryCodeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryCodeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryCodeRequest clone() => QueryCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryCodeRequest copyWith(void Function(QueryCodeRequest) updates) => super.copyWith((message) => updates(message as QueryCodeRequest)) as QueryCodeRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryCodeRequest create() => QueryCodeRequest._();
  QueryCodeRequest createEmptyInstance() => create();
  static $pb.PbList<QueryCodeRequest> createRepeated() => $pb.PbList<QueryCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryCodeRequest>(create);
  static QueryCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryCodeResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCodeResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryCodeResponse._() : super();
  factory QueryCodeResponse({
    $core.List<$core.int>? code,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    return _result;
  }
  factory QueryCodeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryCodeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryCodeResponse clone() => QueryCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryCodeResponse copyWith(void Function(QueryCodeResponse) updates) => super.copyWith((message) => updates(message as QueryCodeResponse)) as QueryCodeResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryCodeResponse create() => QueryCodeResponse._();
  QueryCodeResponse createEmptyInstance() => create();
  static $pb.PbList<QueryCodeResponse> createRepeated() => $pb.PbList<QueryCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryCodeResponse>(create);
  static QueryCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get code => $_getN(0);
  @$pb.TagNumber(1)
  set code($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);
}

class QueryTxLogsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTxLogsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash')
    ..aOM<$4.PageRequest>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pagination', subBuilder: $4.PageRequest.create)
    ..hasRequiredFields = false
  ;

  QueryTxLogsRequest._() : super();
  factory QueryTxLogsRequest({
    $core.String? hash,
    $4.PageRequest? pagination,
  }) {
    final _result = create();
    if (hash != null) {
      _result.hash = hash;
    }
    if (pagination != null) {
      _result.pagination = pagination;
    }
    return _result;
  }
  factory QueryTxLogsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTxLogsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTxLogsRequest clone() => QueryTxLogsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTxLogsRequest copyWith(void Function(QueryTxLogsRequest) updates) => super.copyWith((message) => updates(message as QueryTxLogsRequest)) as QueryTxLogsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTxLogsRequest create() => QueryTxLogsRequest._();
  QueryTxLogsRequest createEmptyInstance() => create();
  static $pb.PbList<QueryTxLogsRequest> createRepeated() => $pb.PbList<QueryTxLogsRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryTxLogsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTxLogsRequest>(create);
  static QueryTxLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $4.PageRequest get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($4.PageRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => clearField(2);
  @$pb.TagNumber(2)
  $4.PageRequest ensurePagination() => $_ensure(1);
}

class QueryTxLogsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTxLogsResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..pc<$3.Log>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'logs', $pb.PbFieldType.PM, subBuilder: $3.Log.create)
    ..aOM<$4.PageResponse>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pagination', subBuilder: $4.PageResponse.create)
    ..hasRequiredFields = false
  ;

  QueryTxLogsResponse._() : super();
  factory QueryTxLogsResponse({
    $core.Iterable<$3.Log>? logs,
    $4.PageResponse? pagination,
  }) {
    final _result = create();
    if (logs != null) {
      _result.logs.addAll(logs);
    }
    if (pagination != null) {
      _result.pagination = pagination;
    }
    return _result;
  }
  factory QueryTxLogsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTxLogsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTxLogsResponse clone() => QueryTxLogsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTxLogsResponse copyWith(void Function(QueryTxLogsResponse) updates) => super.copyWith((message) => updates(message as QueryTxLogsResponse)) as QueryTxLogsResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTxLogsResponse create() => QueryTxLogsResponse._();
  QueryTxLogsResponse createEmptyInstance() => create();
  static $pb.PbList<QueryTxLogsResponse> createRepeated() => $pb.PbList<QueryTxLogsResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryTxLogsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTxLogsResponse>(create);
  static QueryTxLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$3.Log> get logs => $_getList(0);

  @$pb.TagNumber(2)
  $4.PageResponse get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($4.PageResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => clearField(2);
  @$pb.TagNumber(2)
  $4.PageResponse ensurePagination() => $_ensure(1);
}

class QueryParamsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryParamsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  QueryParamsRequest._() : super();
  factory QueryParamsRequest() => create();
  factory QueryParamsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryParamsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryParamsRequest clone() => QueryParamsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryParamsRequest copyWith(void Function(QueryParamsRequest) updates) => super.copyWith((message) => updates(message as QueryParamsRequest)) as QueryParamsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryParamsRequest create() => QueryParamsRequest._();
  QueryParamsRequest createEmptyInstance() => create();
  static $pb.PbList<QueryParamsRequest> createRepeated() => $pb.PbList<QueryParamsRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryParamsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryParamsRequest>(create);
  static QueryParamsRequest? _defaultInstance;
}

class QueryParamsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryParamsResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOM<$3.Params>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'params', subBuilder: $3.Params.create)
    ..hasRequiredFields = false
  ;

  QueryParamsResponse._() : super();
  factory QueryParamsResponse({
    $3.Params? params,
  }) {
    final _result = create();
    if (params != null) {
      _result.params = params;
    }
    return _result;
  }
  factory QueryParamsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryParamsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryParamsResponse clone() => QueryParamsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryParamsResponse copyWith(void Function(QueryParamsResponse) updates) => super.copyWith((message) => updates(message as QueryParamsResponse)) as QueryParamsResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryParamsResponse create() => QueryParamsResponse._();
  QueryParamsResponse createEmptyInstance() => create();
  static $pb.PbList<QueryParamsResponse> createRepeated() => $pb.PbList<QueryParamsResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryParamsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryParamsResponse>(create);
  static QueryParamsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $3.Params get params => $_getN(0);
  @$pb.TagNumber(1)
  set params($3.Params v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasParams() => $_has(0);
  @$pb.TagNumber(1)
  void clearParams() => clearField(1);
  @$pb.TagNumber(1)
  $3.Params ensureParams() => $_ensure(0);
}

class EthCallRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EthCallRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'args', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasCap', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  EthCallRequest._() : super();
  factory EthCallRequest({
    $core.List<$core.int>? args,
    $fixnum.Int64? gasCap,
  }) {
    final _result = create();
    if (args != null) {
      _result.args = args;
    }
    if (gasCap != null) {
      _result.gasCap = gasCap;
    }
    return _result;
  }
  factory EthCallRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EthCallRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EthCallRequest clone() => EthCallRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EthCallRequest copyWith(void Function(EthCallRequest) updates) => super.copyWith((message) => updates(message as EthCallRequest)) as EthCallRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EthCallRequest create() => EthCallRequest._();
  EthCallRequest createEmptyInstance() => create();
  static $pb.PbList<EthCallRequest> createRepeated() => $pb.PbList<EthCallRequest>();
  @$core.pragma('dart2js:noInline')
  static EthCallRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EthCallRequest>(create);
  static EthCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get args => $_getN(0);
  @$pb.TagNumber(1)
  set args($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasArgs() => $_has(0);
  @$pb.TagNumber(1)
  void clearArgs() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get gasCap => $_getI64(1);
  @$pb.TagNumber(2)
  set gasCap($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGasCap() => $_has(1);
  @$pb.TagNumber(2)
  void clearGasCap() => clearField(2);
}

class EstimateGasResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EstimateGasResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gas', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  EstimateGasResponse._() : super();
  factory EstimateGasResponse({
    $fixnum.Int64? gas,
  }) {
    final _result = create();
    if (gas != null) {
      _result.gas = gas;
    }
    return _result;
  }
  factory EstimateGasResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateGasResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateGasResponse clone() => EstimateGasResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateGasResponse copyWith(void Function(EstimateGasResponse) updates) => super.copyWith((message) => updates(message as EstimateGasResponse)) as EstimateGasResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EstimateGasResponse create() => EstimateGasResponse._();
  EstimateGasResponse createEmptyInstance() => create();
  static $pb.PbList<EstimateGasResponse> createRepeated() => $pb.PbList<EstimateGasResponse>();
  @$core.pragma('dart2js:noInline')
  static EstimateGasResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateGasResponse>(create);
  static EstimateGasResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get gas => $_getI64(0);
  @$pb.TagNumber(1)
  set gas($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGas() => $_has(0);
  @$pb.TagNumber(1)
  void clearGas() => clearField(1);
}

class QueryTraceTxRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTraceTxRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOM<$0.MsgEthereumTx>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'msg', subBuilder: $0.MsgEthereumTx.create)
    ..aOM<$3.TraceConfig>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'traceConfig', subBuilder: $3.TraceConfig.create)
    ..pc<$0.MsgEthereumTx>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'predecessors', $pb.PbFieldType.PM, subBuilder: $0.MsgEthereumTx.create)
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockNumber')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockHash')
    ..aOM<$5.Timestamp>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockTime', subBuilder: $5.Timestamp.create)
    ..hasRequiredFields = false
  ;

  QueryTraceTxRequest._() : super();
  factory QueryTraceTxRequest({
    $0.MsgEthereumTx? msg,
    $3.TraceConfig? traceConfig,
    $core.Iterable<$0.MsgEthereumTx>? predecessors,
    $fixnum.Int64? blockNumber,
    $core.String? blockHash,
    $5.Timestamp? blockTime,
  }) {
    final _result = create();
    if (msg != null) {
      _result.msg = msg;
    }
    if (traceConfig != null) {
      _result.traceConfig = traceConfig;
    }
    if (predecessors != null) {
      _result.predecessors.addAll(predecessors);
    }
    if (blockNumber != null) {
      _result.blockNumber = blockNumber;
    }
    if (blockHash != null) {
      _result.blockHash = blockHash;
    }
    if (blockTime != null) {
      _result.blockTime = blockTime;
    }
    return _result;
  }
  factory QueryTraceTxRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTraceTxRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTraceTxRequest clone() => QueryTraceTxRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTraceTxRequest copyWith(void Function(QueryTraceTxRequest) updates) => super.copyWith((message) => updates(message as QueryTraceTxRequest)) as QueryTraceTxRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTraceTxRequest create() => QueryTraceTxRequest._();
  QueryTraceTxRequest createEmptyInstance() => create();
  static $pb.PbList<QueryTraceTxRequest> createRepeated() => $pb.PbList<QueryTraceTxRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryTraceTxRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTraceTxRequest>(create);
  static QueryTraceTxRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.MsgEthereumTx get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg($0.MsgEthereumTx v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);
  @$pb.TagNumber(1)
  $0.MsgEthereumTx ensureMsg() => $_ensure(0);

  @$pb.TagNumber(3)
  $3.TraceConfig get traceConfig => $_getN(1);
  @$pb.TagNumber(3)
  set traceConfig($3.TraceConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTraceConfig() => $_has(1);
  @$pb.TagNumber(3)
  void clearTraceConfig() => clearField(3);
  @$pb.TagNumber(3)
  $3.TraceConfig ensureTraceConfig() => $_ensure(1);

  @$pb.TagNumber(4)
  $core.List<$0.MsgEthereumTx> get predecessors => $_getList(2);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockNumber => $_getI64(3);
  @$pb.TagNumber(5)
  set blockNumber($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockNumber() => $_has(3);
  @$pb.TagNumber(5)
  void clearBlockNumber() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(4);
  @$pb.TagNumber(6)
  set blockHash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(4);
  @$pb.TagNumber(6)
  void clearBlockHash() => clearField(6);

  @$pb.TagNumber(7)
  $5.Timestamp get blockTime => $_getN(5);
  @$pb.TagNumber(7)
  set blockTime($5.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(5);
  @$pb.TagNumber(7)
  void clearBlockTime() => clearField(7);
  @$pb.TagNumber(7)
  $5.Timestamp ensureBlockTime() => $_ensure(5);
}

class QueryTraceTxResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTraceTxResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryTraceTxResponse._() : super();
  factory QueryTraceTxResponse({
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory QueryTraceTxResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTraceTxResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTraceTxResponse clone() => QueryTraceTxResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTraceTxResponse copyWith(void Function(QueryTraceTxResponse) updates) => super.copyWith((message) => updates(message as QueryTraceTxResponse)) as QueryTraceTxResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTraceTxResponse create() => QueryTraceTxResponse._();
  QueryTraceTxResponse createEmptyInstance() => create();
  static $pb.PbList<QueryTraceTxResponse> createRepeated() => $pb.PbList<QueryTraceTxResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryTraceTxResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTraceTxResponse>(create);
  static QueryTraceTxResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class QueryTraceBlockRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTraceBlockRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..pc<$0.MsgEthereumTx>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txs', $pb.PbFieldType.PM, subBuilder: $0.MsgEthereumTx.create)
    ..aOM<$3.TraceConfig>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'traceConfig', subBuilder: $3.TraceConfig.create)
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockNumber')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockHash')
    ..aOM<$5.Timestamp>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockTime', subBuilder: $5.Timestamp.create)
    ..hasRequiredFields = false
  ;

  QueryTraceBlockRequest._() : super();
  factory QueryTraceBlockRequest({
    $core.Iterable<$0.MsgEthereumTx>? txs,
    $3.TraceConfig? traceConfig,
    $fixnum.Int64? blockNumber,
    $core.String? blockHash,
    $5.Timestamp? blockTime,
  }) {
    final _result = create();
    if (txs != null) {
      _result.txs.addAll(txs);
    }
    if (traceConfig != null) {
      _result.traceConfig = traceConfig;
    }
    if (blockNumber != null) {
      _result.blockNumber = blockNumber;
    }
    if (blockHash != null) {
      _result.blockHash = blockHash;
    }
    if (blockTime != null) {
      _result.blockTime = blockTime;
    }
    return _result;
  }
  factory QueryTraceBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTraceBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTraceBlockRequest clone() => QueryTraceBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTraceBlockRequest copyWith(void Function(QueryTraceBlockRequest) updates) => super.copyWith((message) => updates(message as QueryTraceBlockRequest)) as QueryTraceBlockRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTraceBlockRequest create() => QueryTraceBlockRequest._();
  QueryTraceBlockRequest createEmptyInstance() => create();
  static $pb.PbList<QueryTraceBlockRequest> createRepeated() => $pb.PbList<QueryTraceBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryTraceBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTraceBlockRequest>(create);
  static QueryTraceBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.MsgEthereumTx> get txs => $_getList(0);

  @$pb.TagNumber(3)
  $3.TraceConfig get traceConfig => $_getN(1);
  @$pb.TagNumber(3)
  set traceConfig($3.TraceConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTraceConfig() => $_has(1);
  @$pb.TagNumber(3)
  void clearTraceConfig() => clearField(3);
  @$pb.TagNumber(3)
  $3.TraceConfig ensureTraceConfig() => $_ensure(1);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockNumber => $_getI64(2);
  @$pb.TagNumber(5)
  set blockNumber($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockNumber() => $_has(2);
  @$pb.TagNumber(5)
  void clearBlockNumber() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(6)
  set blockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(6)
  void clearBlockHash() => clearField(6);

  @$pb.TagNumber(7)
  $5.Timestamp get blockTime => $_getN(4);
  @$pb.TagNumber(7)
  set blockTime($5.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockTime() => $_has(4);
  @$pb.TagNumber(7)
  void clearBlockTime() => clearField(7);
  @$pb.TagNumber(7)
  $5.Timestamp ensureBlockTime() => $_ensure(4);
}

class QueryTraceBlockResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryTraceBlockResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryTraceBlockResponse._() : super();
  factory QueryTraceBlockResponse({
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory QueryTraceBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryTraceBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryTraceBlockResponse clone() => QueryTraceBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryTraceBlockResponse copyWith(void Function(QueryTraceBlockResponse) updates) => super.copyWith((message) => updates(message as QueryTraceBlockResponse)) as QueryTraceBlockResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryTraceBlockResponse create() => QueryTraceBlockResponse._();
  QueryTraceBlockResponse createEmptyInstance() => create();
  static $pb.PbList<QueryTraceBlockResponse> createRepeated() => $pb.PbList<QueryTraceBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryTraceBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryTraceBlockResponse>(create);
  static QueryTraceBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class QueryBaseFeeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryBaseFeeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  QueryBaseFeeRequest._() : super();
  factory QueryBaseFeeRequest() => create();
  factory QueryBaseFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryBaseFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryBaseFeeRequest clone() => QueryBaseFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryBaseFeeRequest copyWith(void Function(QueryBaseFeeRequest) updates) => super.copyWith((message) => updates(message as QueryBaseFeeRequest)) as QueryBaseFeeRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryBaseFeeRequest create() => QueryBaseFeeRequest._();
  QueryBaseFeeRequest createEmptyInstance() => create();
  static $pb.PbList<QueryBaseFeeRequest> createRepeated() => $pb.PbList<QueryBaseFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryBaseFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryBaseFeeRequest>(create);
  static QueryBaseFeeRequest? _defaultInstance;
}

class QueryBaseFeeResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryBaseFeeResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baseFee')
    ..hasRequiredFields = false
  ;

  QueryBaseFeeResponse._() : super();
  factory QueryBaseFeeResponse({
    $core.String? baseFee,
  }) {
    final _result = create();
    if (baseFee != null) {
      _result.baseFee = baseFee;
    }
    return _result;
  }
  factory QueryBaseFeeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryBaseFeeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryBaseFeeResponse clone() => QueryBaseFeeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryBaseFeeResponse copyWith(void Function(QueryBaseFeeResponse) updates) => super.copyWith((message) => updates(message as QueryBaseFeeResponse)) as QueryBaseFeeResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryBaseFeeResponse create() => QueryBaseFeeResponse._();
  QueryBaseFeeResponse createEmptyInstance() => create();
  static $pb.PbList<QueryBaseFeeResponse> createRepeated() => $pb.PbList<QueryBaseFeeResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryBaseFeeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryBaseFeeResponse>(create);
  static QueryBaseFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get baseFee => $_getSZ(0);
  @$pb.TagNumber(1)
  set baseFee($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBaseFee() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseFee() => clearField(1);
}

