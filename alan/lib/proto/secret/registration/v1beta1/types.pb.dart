///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SeedConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SeedConfig', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'masterCert')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'encryptedKey')
    ..hasRequiredFields = false
  ;

  SeedConfig._() : super();
  factory SeedConfig({
    $core.String? masterCert,
    $core.String? encryptedKey,
  }) {
    final _result = create();
    if (masterCert != null) {
      _result.masterCert = masterCert;
    }
    if (encryptedKey != null) {
      _result.encryptedKey = encryptedKey;
    }
    return _result;
  }
  factory SeedConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SeedConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SeedConfig clone() => SeedConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SeedConfig copyWith(void Function(SeedConfig) updates) => super.copyWith((message) => updates(message as SeedConfig)) as SeedConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SeedConfig create() => SeedConfig._();
  SeedConfig createEmptyInstance() => create();
  static $pb.PbList<SeedConfig> createRepeated() => $pb.PbList<SeedConfig>();
  @$core.pragma('dart2js:noInline')
  static SeedConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SeedConfig>(create);
  static SeedConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get masterCert => $_getSZ(0);
  @$pb.TagNumber(1)
  set masterCert($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMasterCert() => $_has(0);
  @$pb.TagNumber(1)
  void clearMasterCert() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptedKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptedKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptedKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedKey() => clearField(2);
}

class RegistrationNodeInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'RegistrationNodeInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'certificate', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'encryptedSeed', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  RegistrationNodeInfo._() : super();
  factory RegistrationNodeInfo({
    $core.List<$core.int>? certificate,
    $core.List<$core.int>? encryptedSeed,
  }) {
    final _result = create();
    if (certificate != null) {
      _result.certificate = certificate;
    }
    if (encryptedSeed != null) {
      _result.encryptedSeed = encryptedSeed;
    }
    return _result;
  }
  factory RegistrationNodeInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegistrationNodeInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegistrationNodeInfo clone() => RegistrationNodeInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegistrationNodeInfo copyWith(void Function(RegistrationNodeInfo) updates) => super.copyWith((message) => updates(message as RegistrationNodeInfo)) as RegistrationNodeInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RegistrationNodeInfo create() => RegistrationNodeInfo._();
  RegistrationNodeInfo createEmptyInstance() => create();
  static $pb.PbList<RegistrationNodeInfo> createRepeated() => $pb.PbList<RegistrationNodeInfo>();
  @$core.pragma('dart2js:noInline')
  static RegistrationNodeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegistrationNodeInfo>(create);
  static RegistrationNodeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get certificate => $_getN(0);
  @$pb.TagNumber(1)
  set certificate($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCertificate() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertificate() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedSeed => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedSeed($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptedSeed() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedSeed() => clearField(2);
}

