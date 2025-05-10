///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class QueryEncryptedSeedRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryEncryptedSeedRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pubKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryEncryptedSeedRequest._() : super();
  factory QueryEncryptedSeedRequest({
    $core.List<$core.int>? pubKey,
  }) {
    final _result = create();
    if (pubKey != null) {
      _result.pubKey = pubKey;
    }
    return _result;
  }
  factory QueryEncryptedSeedRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryEncryptedSeedRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryEncryptedSeedRequest clone() => QueryEncryptedSeedRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryEncryptedSeedRequest copyWith(void Function(QueryEncryptedSeedRequest) updates) => super.copyWith((message) => updates(message as QueryEncryptedSeedRequest)) as QueryEncryptedSeedRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryEncryptedSeedRequest create() => QueryEncryptedSeedRequest._();
  QueryEncryptedSeedRequest createEmptyInstance() => create();
  static $pb.PbList<QueryEncryptedSeedRequest> createRepeated() => $pb.PbList<QueryEncryptedSeedRequest>();
  @$core.pragma('dart2js:noInline')
  static QueryEncryptedSeedRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryEncryptedSeedRequest>(create);
  static QueryEncryptedSeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get pubKey => $_getN(0);
  @$pb.TagNumber(1)
  set pubKey($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPubKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubKey() => clearField(1);
}

class QueryEncryptedSeedResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QueryEncryptedSeedResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'encryptedSeed', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  QueryEncryptedSeedResponse._() : super();
  factory QueryEncryptedSeedResponse({
    $core.List<$core.int>? encryptedSeed,
  }) {
    final _result = create();
    if (encryptedSeed != null) {
      _result.encryptedSeed = encryptedSeed;
    }
    return _result;
  }
  factory QueryEncryptedSeedResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QueryEncryptedSeedResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QueryEncryptedSeedResponse clone() => QueryEncryptedSeedResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QueryEncryptedSeedResponse copyWith(void Function(QueryEncryptedSeedResponse) updates) => super.copyWith((message) => updates(message as QueryEncryptedSeedResponse)) as QueryEncryptedSeedResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QueryEncryptedSeedResponse create() => QueryEncryptedSeedResponse._();
  QueryEncryptedSeedResponse createEmptyInstance() => create();
  static $pb.PbList<QueryEncryptedSeedResponse> createRepeated() => $pb.PbList<QueryEncryptedSeedResponse>();
  @$core.pragma('dart2js:noInline')
  static QueryEncryptedSeedResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryEncryptedSeedResponse>(create);
  static QueryEncryptedSeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get encryptedSeed => $_getN(0);
  @$pb.TagNumber(1)
  set encryptedSeed($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptedSeed() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedSeed() => clearField(1);
}

