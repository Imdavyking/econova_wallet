///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'types.pb.dart' as $3;
import '../../../cosmos/base/abci/v1beta1/abci.pb.dart' as $4;

class QueryContractInfoRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractInfoRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractInfoRequest._() : super();
  factory QueryContractInfoRequest({
    $core.List<$core.int>? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryContractInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractInfoRequest clone() => QueryContractInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractInfoRequest copyWith(void Function(QueryContractInfoRequest) updates) => super.copyWith((message) => updates(message as QueryContractInfoRequest)) as QueryContractInfoRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractInfoRequest create() => QueryContractInfoRequest._();
  QueryContractInfoRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractInfoRequest> createRepeated() => $pb.PbList<QueryContractInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractInfoRequest>(create);
  static QueryContractInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryContractInfoResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractInfoResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..aOM<$3.ContractInfo>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ContractInfo', protoName: 'ContractInfo', subBuilder: $3.ContractInfo.create)
    ..hasRequiredFields = false
  ;

  QueryContractInfoResponse._() : super();
  factory QueryContractInfoResponse({
    $core.List<$core.int>? address,
    $3.ContractInfo? contractInfo,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (contractInfo != null) {
      _result.contractInfo = contractInfo;
    }
    return _result;
  }
  factory QueryContractInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractInfoResponse clone() => QueryContractInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractInfoResponse copyWith(void Function(QueryContractInfoResponse) updates) => super.copyWith((message) => updates(message as QueryContractInfoResponse)) as QueryContractInfoResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractInfoResponse create() => QueryContractInfoResponse._();
  QueryContractInfoResponse createEmptyInstance() => create();
  static $pb.PbList<QueryContractInfoResponse> createRepeated() => $pb.PbList<QueryContractInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryContractInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractInfoResponse>(create);
  static QueryContractInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $3.ContractInfo get contractInfo => $_getN(1);
  @$pb.TagNumber(2)
  set contractInfo($3.ContractInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasContractInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearContractInfo() => clearField(2);
  @$pb.TagNumber(2)
  $3.ContractInfo ensureContractInfo() => $_ensure(1);
}

class QueryContractHistoryRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractHistoryRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractHistoryRequest._() : super();
  factory QueryContractHistoryRequest({
    $core.List<$core.int>? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryContractHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractHistoryRequest clone() => QueryContractHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractHistoryRequest copyWith(void Function(QueryContractHistoryRequest) updates) => super.copyWith((message) => updates(message as QueryContractHistoryRequest)) as QueryContractHistoryRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractHistoryRequest create() => QueryContractHistoryRequest._();
  QueryContractHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractHistoryRequest> createRepeated() => $pb.PbList<QueryContractHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractHistoryRequest>(create);
  static QueryContractHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryContractsByCodeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractsByCodeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  QueryContractsByCodeRequest._() : super();
  factory QueryContractsByCodeRequest({
    $fixnum.Int64? codeId,
  }) {
    final _result = create();
    if (codeId != null) {
      _result.codeId = codeId;
    }
    return _result;
  }
  factory QueryContractsByCodeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractsByCodeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractsByCodeRequest clone() => QueryContractsByCodeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractsByCodeRequest copyWith(void Function(QueryContractsByCodeRequest) updates) => super.copyWith((message) => updates(message as QueryContractsByCodeRequest)) as QueryContractsByCodeRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractsByCodeRequest create() => QueryContractsByCodeRequest._();
  QueryContractsByCodeRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractsByCodeRequest> createRepeated() => $pb.PbList<QueryContractsByCodeRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractsByCodeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractsByCodeRequest>(create);
  static QueryContractsByCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get codeId => $_getI64(0);
  @$pb.TagNumber(1)
  set codeId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeId() => clearField(1);
}

class ContractInfoWithAddress extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ContractInfoWithAddress', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..aOM<$3.ContractInfo>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ContractInfo', protoName: 'ContractInfo', subBuilder: $3.ContractInfo.create)
    ..hasRequiredFields = false
  ;

  ContractInfoWithAddress._() : super();
  factory ContractInfoWithAddress({
    $core.List<$core.int>? address,
    $3.ContractInfo? contractInfo,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (contractInfo != null) {
      _result.contractInfo = contractInfo;
    }
    return _result;
  }
  factory ContractInfoWithAddress.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContractInfoWithAddress.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContractInfoWithAddress clone() => ContractInfoWithAddress()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContractInfoWithAddress copyWith(void Function(ContractInfoWithAddress) updates) => super.copyWith((message) => updates(message as ContractInfoWithAddress)) as ContractInfoWithAddress; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ContractInfoWithAddress create() => ContractInfoWithAddress._();
  ContractInfoWithAddress createEmptyInstance() => create();
  static $pb.PbList<ContractInfoWithAddress> createRepeated() => $pb.PbList<ContractInfoWithAddress>();
  @$core.pragma('dart2js:noInline')
  static ContractInfoWithAddress getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContractInfoWithAddress>(create);
  static ContractInfoWithAddress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $3.ContractInfo get contractInfo => $_getN(1);
  @$pb.TagNumber(2)
  set contractInfo($3.ContractInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasContractInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearContractInfo() => clearField(2);
  @$pb.TagNumber(2)
  $3.ContractInfo ensureContractInfo() => $_ensure(1);
}

class QueryContractsByCodeResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractsByCodeResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..pc<ContractInfoWithAddress>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contractInfos', $pb.PbFieldType.PM, subBuilder: ContractInfoWithAddress.create)
    ..hasRequiredFields = false
  ;

  QueryContractsByCodeResponse._() : super();
  factory QueryContractsByCodeResponse({
    $core.Iterable<ContractInfoWithAddress>? contractInfos,
  }) {
    final _result = create();
    if (contractInfos != null) {
      _result.contractInfos.addAll(contractInfos);
    }
    return _result;
  }
  factory QueryContractsByCodeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractsByCodeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractsByCodeResponse clone() => QueryContractsByCodeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractsByCodeResponse copyWith(void Function(QueryContractsByCodeResponse) updates) => super.copyWith((message) => updates(message as QueryContractsByCodeResponse)) as QueryContractsByCodeResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractsByCodeResponse create() => QueryContractsByCodeResponse._();
  QueryContractsByCodeResponse createEmptyInstance() => create();
  static $pb.PbList<QueryContractsByCodeResponse> createRepeated() => $pb.PbList<QueryContractsByCodeResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryContractsByCodeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractsByCodeResponse>(create);
  static QueryContractsByCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ContractInfoWithAddress> get contractInfos => $_getList(0);
}

class QuerySmartContractStateRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QuerySmartContractStateRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'queryData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QuerySmartContractStateRequest._() : super();
  factory QuerySmartContractStateRequest({
    $core.List<$core.int>? address,
    $core.List<$core.int>? queryData,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (queryData != null) {
      _result.queryData = queryData;
    }
    return _result;
  }
  factory QuerySmartContractStateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuerySmartContractStateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuerySmartContractStateRequest clone() => QuerySmartContractStateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuerySmartContractStateRequest copyWith(void Function(QuerySmartContractStateRequest) updates) => super.copyWith((message) => updates(message as QuerySmartContractStateRequest)) as QuerySmartContractStateRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QuerySmartContractStateRequest create() => QuerySmartContractStateRequest._();
  QuerySmartContractStateRequest createEmptyInstance() => create();
  static $pb.PbList<QuerySmartContractStateRequest> createRepeated() => $pb.PbList<QuerySmartContractStateRequest>();
  @$core.pragma('dart2js:noInline')
  static QuerySmartContractStateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuerySmartContractStateRequest>(create);
  static QuerySmartContractStateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get queryData => $_getN(1);
  @$pb.TagNumber(2)
  set queryData($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQueryData() => $_has(1);
  @$pb.TagNumber(2)
  void clearQueryData() => clearField(2);
}

class QueryContractAddressByLabelRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractAddressByLabelRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'label')
    ..hasRequiredFields = false
  ;

  QueryContractAddressByLabelRequest._() : super();
  factory QueryContractAddressByLabelRequest({
    $core.String? label,
  }) {
    final _result = create();
    if (label != null) {
      _result.label = label;
    }
    return _result;
  }
  factory QueryContractAddressByLabelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractAddressByLabelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractAddressByLabelRequest clone() => QueryContractAddressByLabelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractAddressByLabelRequest copyWith(void Function(QueryContractAddressByLabelRequest) updates) => super.copyWith((message) => updates(message as QueryContractAddressByLabelRequest)) as QueryContractAddressByLabelRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractAddressByLabelRequest create() => QueryContractAddressByLabelRequest._();
  QueryContractAddressByLabelRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractAddressByLabelRequest> createRepeated() => $pb.PbList<QueryContractAddressByLabelRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractAddressByLabelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractAddressByLabelRequest>(create);
  static QueryContractAddressByLabelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);
}

class QueryContractKeyRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractKeyRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractKeyRequest._() : super();
  factory QueryContractKeyRequest({
    $core.List<$core.int>? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryContractKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractKeyRequest clone() => QueryContractKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractKeyRequest copyWith(void Function(QueryContractKeyRequest) updates) => super.copyWith((message) => updates(message as QueryContractKeyRequest)) as QueryContractKeyRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractKeyRequest create() => QueryContractKeyRequest._();
  QueryContractKeyRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractKeyRequest> createRepeated() => $pb.PbList<QueryContractKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractKeyRequest>(create);
  static QueryContractKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryContractHashRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractHashRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractHashRequest._() : super();
  factory QueryContractHashRequest({
    $core.List<$core.int>? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryContractHashRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractHashRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractHashRequest clone() => QueryContractHashRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractHashRequest copyWith(void Function(QueryContractHashRequest) updates) => super.copyWith((message) => updates(message as QueryContractHashRequest)) as QueryContractHashRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractHashRequest create() => QueryContractHashRequest._();
  QueryContractHashRequest createEmptyInstance() => create();
  static $pb.PbList<QueryContractHashRequest> createRepeated() => $pb.PbList<QueryContractHashRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryContractHashRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractHashRequest>(create);
  static QueryContractHashRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QuerySmartContractStateResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QuerySmartContractStateResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QuerySmartContractStateResponse._() : super();
  factory QuerySmartContractStateResponse({
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory QuerySmartContractStateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuerySmartContractStateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuerySmartContractStateResponse clone() => QuerySmartContractStateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuerySmartContractStateResponse copyWith(void Function(QuerySmartContractStateResponse) updates) => super.copyWith((message) => updates(message as QuerySmartContractStateResponse)) as QuerySmartContractStateResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QuerySmartContractStateResponse create() => QuerySmartContractStateResponse._();
  QuerySmartContractStateResponse createEmptyInstance() => create();
  static $pb.PbList<QuerySmartContractStateResponse> createRepeated() => $pb.PbList<QuerySmartContractStateResponse>();
  @$core.pragma('dart2js:noInline')
  static QuerySmartContractStateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuerySmartContractStateResponse>(create);
  static QuerySmartContractStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

class QueryCodeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCodeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  QueryCodeRequest._() : super();
  factory QueryCodeRequest({
    $fixnum.Int64? codeId,
  }) {
    final _result = create();
    if (codeId != null) {
      _result.codeId = codeId;
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
  $fixnum.Int64 get codeId => $_getI64(0);
  @$pb.TagNumber(1)
  set codeId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeId() => clearField(1);
}

class CodeInfoResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CodeInfoResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'creator', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dataHash', $pb.PbFieldType.OY)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'source')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'builder')
    ..hasRequiredFields = false
  ;

  CodeInfoResponse._() : super();
  factory CodeInfoResponse({
    $fixnum.Int64? codeId,
    $core.List<$core.int>? creator,
    $core.List<$core.int>? dataHash,
    $core.String? source,
    $core.String? builder,
  }) {
    final _result = create();
    if (codeId != null) {
      _result.codeId = codeId;
    }
    if (creator != null) {
      _result.creator = creator;
    }
    if (dataHash != null) {
      _result.dataHash = dataHash;
    }
    if (source != null) {
      _result.source = source;
    }
    if (builder != null) {
      _result.builder = builder;
    }
    return _result;
  }
  factory CodeInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CodeInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CodeInfoResponse clone() => CodeInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CodeInfoResponse copyWith(void Function(CodeInfoResponse) updates) => super.copyWith((message) => updates(message as CodeInfoResponse)) as CodeInfoResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CodeInfoResponse create() => CodeInfoResponse._();
  CodeInfoResponse createEmptyInstance() => create();
  static $pb.PbList<CodeInfoResponse> createRepeated() => $pb.PbList<CodeInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static CodeInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CodeInfoResponse>(create);
  static CodeInfoResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.List<$core.int> get dataHash => $_getN(2);
  @$pb.TagNumber(3)
  set dataHash($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDataHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get source => $_getSZ(3);
  @$pb.TagNumber(4)
  set source($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearSource() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get builder => $_getSZ(4);
  @$pb.TagNumber(5)
  set builder($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBuilder() => $_has(4);
  @$pb.TagNumber(5)
  void clearBuilder() => clearField(5);
}

class QueryCodeResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCodeResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..aOM<CodeInfoResponse>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeInfo', subBuilder: CodeInfoResponse.create)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryCodeResponse._() : super();
  factory QueryCodeResponse({
    CodeInfoResponse? codeInfo,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (codeInfo != null) {
      _result.codeInfo = codeInfo;
    }
    if (data != null) {
      _result.data = data;
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
  CodeInfoResponse get codeInfo => $_getN(0);
  @$pb.TagNumber(1)
  set codeInfo(CodeInfoResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeInfo() => clearField(1);
  @$pb.TagNumber(1)
  CodeInfoResponse ensureCodeInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class QueryCodesResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryCodesResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..pc<CodeInfoResponse>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeInfos', $pb.PbFieldType.PM, subBuilder: CodeInfoResponse.create)
    ..hasRequiredFields = false
  ;

  QueryCodesResponse._() : super();
  factory QueryCodesResponse({
    $core.Iterable<CodeInfoResponse>? codeInfos,
  }) {
    final _result = create();
    if (codeInfos != null) {
      _result.codeInfos.addAll(codeInfos);
    }
    return _result;
  }
  factory QueryCodesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryCodesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryCodesResponse clone() => QueryCodesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryCodesResponse copyWith(void Function(QueryCodesResponse) updates) => super.copyWith((message) => updates(message as QueryCodesResponse)) as QueryCodesResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryCodesResponse create() => QueryCodesResponse._();
  QueryCodesResponse createEmptyInstance() => create();
  static $pb.PbList<QueryCodesResponse> createRepeated() => $pb.PbList<QueryCodesResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryCodesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryCodesResponse>(create);
  static QueryCodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CodeInfoResponse> get codeInfos => $_getList(0);
}

class QueryContractAddressByLabelResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractAddressByLabelResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractAddressByLabelResponse._() : super();
  factory QueryContractAddressByLabelResponse({
    $core.List<$core.int>? address,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    return _result;
  }
  factory QueryContractAddressByLabelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractAddressByLabelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractAddressByLabelResponse clone() => QueryContractAddressByLabelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractAddressByLabelResponse copyWith(void Function(QueryContractAddressByLabelResponse) updates) => super.copyWith((message) => updates(message as QueryContractAddressByLabelResponse)) as QueryContractAddressByLabelResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractAddressByLabelResponse create() => QueryContractAddressByLabelResponse._();
  QueryContractAddressByLabelResponse createEmptyInstance() => create();
  static $pb.PbList<QueryContractAddressByLabelResponse> createRepeated() => $pb.PbList<QueryContractAddressByLabelResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryContractAddressByLabelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractAddressByLabelResponse>(create);
  static QueryContractAddressByLabelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get address => $_getN(0);
  @$pb.TagNumber(1)
  set address($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class QueryContractKeyResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractKeyResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'key', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractKeyResponse._() : super();
  factory QueryContractKeyResponse({
    $core.List<$core.int>? key,
  }) {
    final _result = create();
    if (key != null) {
      _result.key = key;
    }
    return _result;
  }
  factory QueryContractKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractKeyResponse clone() => QueryContractKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractKeyResponse copyWith(void Function(QueryContractKeyResponse) updates) => super.copyWith((message) => updates(message as QueryContractKeyResponse)) as QueryContractKeyResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractKeyResponse create() => QueryContractKeyResponse._();
  QueryContractKeyResponse createEmptyInstance() => create();
  static $pb.PbList<QueryContractKeyResponse> createRepeated() => $pb.PbList<QueryContractKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryContractKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractKeyResponse>(create);
  static QueryContractKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get key => $_getN(0);
  @$pb.TagNumber(1)
  set key($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);
}

class QueryContractHashResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryContractHashResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeHash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryContractHashResponse._() : super();
  factory QueryContractHashResponse({
    $core.List<$core.int>? codeHash,
  }) {
    final _result = create();
    if (codeHash != null) {
      _result.codeHash = codeHash;
    }
    return _result;
  }
  factory QueryContractHashResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryContractHashResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryContractHashResponse clone() => QueryContractHashResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryContractHashResponse copyWith(void Function(QueryContractHashResponse) updates) => super.copyWith((message) => updates(message as QueryContractHashResponse)) as QueryContractHashResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryContractHashResponse create() => QueryContractHashResponse._();
  QueryContractHashResponse createEmptyInstance() => create();
  static $pb.PbList<QueryContractHashResponse> createRepeated() => $pb.PbList<QueryContractHashResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryContractHashResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryContractHashResponse>(create);
  static QueryContractHashResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get codeHash => $_getN(0);
  @$pb.TagNumber(1)
  set codeHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodeHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodeHash() => clearField(1);
}

class DecryptedAnswer extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DecryptedAnswer', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.compute.v1beta1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'input')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'outputData')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'outputDataAsString')
    ..pc<$4.StringEvent>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'outputLogs', $pb.PbFieldType.PM, subBuilder: $4.StringEvent.create)
    ..a<$core.List<$core.int>>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'outputError', $pb.PbFieldType.OY)
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'plaintextError')
    ..hasRequiredFields = false
  ;

  DecryptedAnswer._() : super();
  factory DecryptedAnswer({
    $core.String? type,
    $core.String? input,
    $core.String? outputData,
    $core.String? outputDataAsString,
    $core.Iterable<$4.StringEvent>? outputLogs,
    $core.List<$core.int>? outputError,
    $core.String? plaintextError,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (input != null) {
      _result.input = input;
    }
    if (outputData != null) {
      _result.outputData = outputData;
    }
    if (outputDataAsString != null) {
      _result.outputDataAsString = outputDataAsString;
    }
    if (outputLogs != null) {
      _result.outputLogs.addAll(outputLogs);
    }
    if (outputError != null) {
      _result.outputError = outputError;
    }
    if (plaintextError != null) {
      _result.plaintextError = plaintextError;
    }
    return _result;
  }
  factory DecryptedAnswer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecryptedAnswer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecryptedAnswer clone() => DecryptedAnswer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecryptedAnswer copyWith(void Function(DecryptedAnswer) updates) => super.copyWith((message) => updates(message as DecryptedAnswer)) as DecryptedAnswer; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DecryptedAnswer create() => DecryptedAnswer._();
  DecryptedAnswer createEmptyInstance() => create();
  static $pb.PbList<DecryptedAnswer> createRepeated() => $pb.PbList<DecryptedAnswer>();
  @$core.pragma('dart2js:noInline')
  static DecryptedAnswer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecryptedAnswer>(create);
  static DecryptedAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get input => $_getSZ(1);
  @$pb.TagNumber(2)
  set input($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInput() => $_has(1);
  @$pb.TagNumber(2)
  void clearInput() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get outputData => $_getSZ(2);
  @$pb.TagNumber(3)
  set outputData($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOutputData() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutputData() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get outputDataAsString => $_getSZ(3);
  @$pb.TagNumber(4)
  set outputDataAsString($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOutputDataAsString() => $_has(3);
  @$pb.TagNumber(4)
  void clearOutputDataAsString() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$4.StringEvent> get outputLogs => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<$core.int> get outputError => $_getN(5);
  @$pb.TagNumber(6)
  set outputError($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOutputError() => $_has(5);
  @$pb.TagNumber(6)
  void clearOutputError() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get plaintextError => $_getSZ(6);
  @$pb.TagNumber(7)
  set plaintextError($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPlaintextError() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlaintextError() => clearField(7);
}

