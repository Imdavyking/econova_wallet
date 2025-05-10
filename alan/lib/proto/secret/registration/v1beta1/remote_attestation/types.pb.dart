///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/remote_attestation/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class QuoteReport extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QuoteReport', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'version', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isvEnclaveQuoteStatus')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'platformInfoBlob')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isvEnclaveQuoteBody')
    ..pPS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'advisoryIds')
    ..hasRequiredFields = false
  ;

  QuoteReport._() : super();
  factory QuoteReport({
    $core.String? id,
    $core.String? timestamp,
    $fixnum.Int64? version,
    $core.String? isvEnclaveQuoteStatus,
    $core.String? platformInfoBlob,
    $core.String? isvEnclaveQuoteBody,
    $core.Iterable<$core.String>? advisoryIds,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    if (version != null) {
      _result.version = version;
    }
    if (isvEnclaveQuoteStatus != null) {
      _result.isvEnclaveQuoteStatus = isvEnclaveQuoteStatus;
    }
    if (platformInfoBlob != null) {
      _result.platformInfoBlob = platformInfoBlob;
    }
    if (isvEnclaveQuoteBody != null) {
      _result.isvEnclaveQuoteBody = isvEnclaveQuoteBody;
    }
    if (advisoryIds != null) {
      _result.advisoryIds.addAll(advisoryIds);
    }
    return _result;
  }
  factory QuoteReport.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuoteReport.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuoteReport clone() => QuoteReport()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuoteReport copyWith(void Function(QuoteReport) updates) => super.copyWith((message) => updates(message as QuoteReport)) as QuoteReport; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QuoteReport create() => QuoteReport._();
  QuoteReport createEmptyInstance() => create();
  static $pb.PbList<QuoteReport> createRepeated() => $pb.PbList<QuoteReport>();
  @$core.pragma('dart2js:noInline')
  static QuoteReport getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuoteReport>(create);
  static QuoteReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get timestamp => $_getSZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get version => $_getI64(2);
  @$pb.TagNumber(3)
  set version($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get isvEnclaveQuoteStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set isvEnclaveQuoteStatus($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsvEnclaveQuoteStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsvEnclaveQuoteStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get platformInfoBlob => $_getSZ(4);
  @$pb.TagNumber(5)
  set platformInfoBlob($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPlatformInfoBlob() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlatformInfoBlob() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get isvEnclaveQuoteBody => $_getSZ(5);
  @$pb.TagNumber(6)
  set isvEnclaveQuoteBody($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsvEnclaveQuoteBody() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsvEnclaveQuoteBody() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.String> get advisoryIds => $_getList(6);
}

class QuoteReportBody extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QuoteReportBody', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mrEnclave')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mrSigner')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'reportData')
    ..hasRequiredFields = false
  ;

  QuoteReportBody._() : super();
  factory QuoteReportBody({
    $core.String? mrEnclave,
    $core.String? mrSigner,
    $core.String? reportData,
  }) {
    final _result = create();
    if (mrEnclave != null) {
      _result.mrEnclave = mrEnclave;
    }
    if (mrSigner != null) {
      _result.mrSigner = mrSigner;
    }
    if (reportData != null) {
      _result.reportData = reportData;
    }
    return _result;
  }
  factory QuoteReportBody.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuoteReportBody.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuoteReportBody clone() => QuoteReportBody()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuoteReportBody copyWith(void Function(QuoteReportBody) updates) => super.copyWith((message) => updates(message as QuoteReportBody)) as QuoteReportBody; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QuoteReportBody create() => QuoteReportBody._();
  QuoteReportBody createEmptyInstance() => create();
  static $pb.PbList<QuoteReportBody> createRepeated() => $pb.PbList<QuoteReportBody>();
  @$core.pragma('dart2js:noInline')
  static QuoteReportBody getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuoteReportBody>(create);
  static QuoteReportBody? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mrEnclave => $_getSZ(0);
  @$pb.TagNumber(1)
  set mrEnclave($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMrEnclave() => $_has(0);
  @$pb.TagNumber(1)
  void clearMrEnclave() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get mrSigner => $_getSZ(1);
  @$pb.TagNumber(2)
  set mrSigner($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMrSigner() => $_has(1);
  @$pb.TagNumber(2)
  void clearMrSigner() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get reportData => $_getSZ(2);
  @$pb.TagNumber(3)
  set reportData($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReportData() => $_has(2);
  @$pb.TagNumber(3)
  void clearReportData() => clearField(3);
}

class QuoteReportData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'QuoteReportData', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'version', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signType', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<QuoteReportBody>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'reportBody', subBuilder: QuoteReportBody.create)
    ..hasRequiredFields = false
  ;

  QuoteReportData._() : super();
  factory QuoteReportData({
    $fixnum.Int64? version,
    $fixnum.Int64? signType,
    QuoteReportBody? reportBody,
  }) {
    final _result = create();
    if (version != null) {
      _result.version = version;
    }
    if (signType != null) {
      _result.signType = signType;
    }
    if (reportBody != null) {
      _result.reportBody = reportBody;
    }
    return _result;
  }
  factory QuoteReportData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory QuoteReportData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  QuoteReportData clone() => QuoteReportData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  QuoteReportData copyWith(void Function(QuoteReportData) updates) => super.copyWith((message) => updates(message as QuoteReportData)) as QuoteReportData; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static QuoteReportData create() => QuoteReportData._();
  QuoteReportData createEmptyInstance() => create();
  static $pb.PbList<QuoteReportData> createRepeated() => $pb.PbList<QuoteReportData>();
  @$core.pragma('dart2js:noInline')
  static QuoteReportData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QuoteReportData>(create);
  static QuoteReportData? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get version => $_getI64(0);
  @$pb.TagNumber(1)
  set version($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get signType => $_getI64(1);
  @$pb.TagNumber(2)
  set signType($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignType() => clearField(2);

  @$pb.TagNumber(3)
  QuoteReportBody get reportBody => $_getN(2);
  @$pb.TagNumber(3)
  set reportBody(QuoteReportBody v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasReportBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearReportBody() => clearField(3);
  @$pb.TagNumber(3)
  QuoteReportBody ensureReportBody() => $_ensure(2);
}

class EndorsedAttestationReport extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EndorsedAttestationReport', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'report', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signature', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'signingCert', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  EndorsedAttestationReport._() : super();
  factory EndorsedAttestationReport({
    $core.List<$core.int>? report,
    $core.List<$core.int>? signature,
    $core.List<$core.int>? signingCert,
  }) {
    final _result = create();
    if (report != null) {
      _result.report = report;
    }
    if (signature != null) {
      _result.signature = signature;
    }
    if (signingCert != null) {
      _result.signingCert = signingCert;
    }
    return _result;
  }
  factory EndorsedAttestationReport.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EndorsedAttestationReport.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EndorsedAttestationReport clone() => EndorsedAttestationReport()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EndorsedAttestationReport copyWith(void Function(EndorsedAttestationReport) updates) => super.copyWith((message) => updates(message as EndorsedAttestationReport)) as EndorsedAttestationReport; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EndorsedAttestationReport create() => EndorsedAttestationReport._();
  EndorsedAttestationReport createEmptyInstance() => create();
  static $pb.PbList<EndorsedAttestationReport> createRepeated() => $pb.PbList<EndorsedAttestationReport>();
  @$core.pragma('dart2js:noInline')
  static EndorsedAttestationReport getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EndorsedAttestationReport>(create);
  static EndorsedAttestationReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get report => $_getN(0);
  @$pb.TagNumber(1)
  set report($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signingCert => $_getN(2);
  @$pb.TagNumber(3)
  set signingCert($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSigningCert() => $_has(2);
  @$pb.TagNumber(3)
  void clearSigningCert() => clearField(3);
}

class SGXEC256Signature extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SGXEC256Signature', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gx')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gy')
    ..hasRequiredFields = false
  ;

  SGXEC256Signature._() : super();
  factory SGXEC256Signature({
    $core.String? gx,
    $core.String? gy,
  }) {
    final _result = create();
    if (gx != null) {
      _result.gx = gx;
    }
    if (gy != null) {
      _result.gy = gy;
    }
    return _result;
  }
  factory SGXEC256Signature.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SGXEC256Signature.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SGXEC256Signature clone() => SGXEC256Signature()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SGXEC256Signature copyWith(void Function(SGXEC256Signature) updates) => super.copyWith((message) => updates(message as SGXEC256Signature)) as SGXEC256Signature; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SGXEC256Signature create() => SGXEC256Signature._();
  SGXEC256Signature createEmptyInstance() => create();
  static $pb.PbList<SGXEC256Signature> createRepeated() => $pb.PbList<SGXEC256Signature>();
  @$core.pragma('dart2js:noInline')
  static SGXEC256Signature getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SGXEC256Signature>(create);
  static SGXEC256Signature? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get gx => $_getSZ(0);
  @$pb.TagNumber(1)
  set gx($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGx() => $_has(0);
  @$pb.TagNumber(1)
  void clearGx() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get gy => $_getSZ(1);
  @$pb.TagNumber(2)
  set gy($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGy() => $_has(1);
  @$pb.TagNumber(2)
  void clearGy() => clearField(2);
}

class PlatformInfoBlob extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PlatformInfoBlob', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1.remote_attestation'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sgxEpidGroupFlags', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sgxTcbEvaluationFlags', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pseEvaluationFlags', $pb.PbFieldType.OU3)
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'latestEquivalentTcbPsvn')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'latestPseIsvsvn')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'latestPsdaSvn')
    ..a<$core.int>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'xeid', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gid', $pb.PbFieldType.OU3)
    ..aOM<SGXEC256Signature>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sgxEc256SignatureT', subBuilder: SGXEC256Signature.create)
    ..hasRequiredFields = false
  ;

  PlatformInfoBlob._() : super();
  factory PlatformInfoBlob({
    $core.int? sgxEpidGroupFlags,
    $core.int? sgxTcbEvaluationFlags,
    $core.int? pseEvaluationFlags,
    $core.String? latestEquivalentTcbPsvn,
    $core.String? latestPseIsvsvn,
    $core.String? latestPsdaSvn,
    $core.int? xeid,
    $core.int? gid,
    SGXEC256Signature? sgxEc256SignatureT,
  }) {
    final _result = create();
    if (sgxEpidGroupFlags != null) {
      _result.sgxEpidGroupFlags = sgxEpidGroupFlags;
    }
    if (sgxTcbEvaluationFlags != null) {
      _result.sgxTcbEvaluationFlags = sgxTcbEvaluationFlags;
    }
    if (pseEvaluationFlags != null) {
      _result.pseEvaluationFlags = pseEvaluationFlags;
    }
    if (latestEquivalentTcbPsvn != null) {
      _result.latestEquivalentTcbPsvn = latestEquivalentTcbPsvn;
    }
    if (latestPseIsvsvn != null) {
      _result.latestPseIsvsvn = latestPseIsvsvn;
    }
    if (latestPsdaSvn != null) {
      _result.latestPsdaSvn = latestPsdaSvn;
    }
    if (xeid != null) {
      _result.xeid = xeid;
    }
    if (gid != null) {
      _result.gid = gid;
    }
    if (sgxEc256SignatureT != null) {
      _result.sgxEc256SignatureT = sgxEc256SignatureT;
    }
    return _result;
  }
  factory PlatformInfoBlob.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlatformInfoBlob.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlatformInfoBlob clone() => PlatformInfoBlob()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlatformInfoBlob copyWith(void Function(PlatformInfoBlob) updates) => super.copyWith((message) => updates(message as PlatformInfoBlob)) as PlatformInfoBlob; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PlatformInfoBlob create() => PlatformInfoBlob._();
  PlatformInfoBlob createEmptyInstance() => create();
  static $pb.PbList<PlatformInfoBlob> createRepeated() => $pb.PbList<PlatformInfoBlob>();
  @$core.pragma('dart2js:noInline')
  static PlatformInfoBlob getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlatformInfoBlob>(create);
  static PlatformInfoBlob? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sgxEpidGroupFlags => $_getIZ(0);
  @$pb.TagNumber(1)
  set sgxEpidGroupFlags($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSgxEpidGroupFlags() => $_has(0);
  @$pb.TagNumber(1)
  void clearSgxEpidGroupFlags() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get sgxTcbEvaluationFlags => $_getIZ(1);
  @$pb.TagNumber(2)
  set sgxTcbEvaluationFlags($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSgxTcbEvaluationFlags() => $_has(1);
  @$pb.TagNumber(2)
  void clearSgxTcbEvaluationFlags() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get pseEvaluationFlags => $_getIZ(2);
  @$pb.TagNumber(3)
  set pseEvaluationFlags($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPseEvaluationFlags() => $_has(2);
  @$pb.TagNumber(3)
  void clearPseEvaluationFlags() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get latestEquivalentTcbPsvn => $_getSZ(3);
  @$pb.TagNumber(4)
  set latestEquivalentTcbPsvn($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLatestEquivalentTcbPsvn() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatestEquivalentTcbPsvn() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get latestPseIsvsvn => $_getSZ(4);
  @$pb.TagNumber(5)
  set latestPseIsvsvn($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLatestPseIsvsvn() => $_has(4);
  @$pb.TagNumber(5)
  void clearLatestPseIsvsvn() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get latestPsdaSvn => $_getSZ(5);
  @$pb.TagNumber(6)
  set latestPsdaSvn($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLatestPsdaSvn() => $_has(5);
  @$pb.TagNumber(6)
  void clearLatestPsdaSvn() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get xeid => $_getIZ(6);
  @$pb.TagNumber(7)
  set xeid($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasXeid() => $_has(6);
  @$pb.TagNumber(7)
  void clearXeid() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get gid => $_getIZ(7);
  @$pb.TagNumber(8)
  set gid($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasGid() => $_has(7);
  @$pb.TagNumber(8)
  void clearGid() => clearField(8);

  @$pb.TagNumber(9)
  SGXEC256Signature get sgxEc256SignatureT => $_getN(8);
  @$pb.TagNumber(9)
  set sgxEc256SignatureT(SGXEC256Signature v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasSgxEc256SignatureT() => $_has(8);
  @$pb.TagNumber(9)
  void clearSgxEc256SignatureT() => clearField(9);
  @$pb.TagNumber(9)
  SGXEC256Signature ensureSgxEc256SignatureT() => $_ensure(8);
}

