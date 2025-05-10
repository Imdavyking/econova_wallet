///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/genesis.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'types.pb.dart' as $3;
import 'msg.pb.dart' as $1;

class GenesisState extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GenesisState', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'secret.registration.v1beta1'), createEmptyInstance: create)
    ..pc<$3.RegistrationNodeInfo>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'registration', $pb.PbFieldType.PM, subBuilder: $3.RegistrationNodeInfo.create)
    ..aOM<$1.MasterCertificate>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nodeExchMasterCertificate', subBuilder: $1.MasterCertificate.create)
    ..aOM<$1.MasterCertificate>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ioMasterCertificate', subBuilder: $1.MasterCertificate.create)
    ..hasRequiredFields = false
  ;

  GenesisState._() : super();
  factory GenesisState({
    $core.Iterable<$3.RegistrationNodeInfo>? registration,
    $1.MasterCertificate? nodeExchMasterCertificate,
    $1.MasterCertificate? ioMasterCertificate,
  }) {
    final _result = create();
    if (registration != null) {
      _result.registration.addAll(registration);
    }
    if (nodeExchMasterCertificate != null) {
      _result.nodeExchMasterCertificate = nodeExchMasterCertificate;
    }
    if (ioMasterCertificate != null) {
      _result.ioMasterCertificate = ioMasterCertificate;
    }
    return _result;
  }
  factory GenesisState.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenesisState.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenesisState clone() => GenesisState()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenesisState copyWith(void Function(GenesisState) updates) => super.copyWith((message) => updates(message as GenesisState)) as GenesisState; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GenesisState create() => GenesisState._();
  GenesisState createEmptyInstance() => create();
  static $pb.PbList<GenesisState> createRepeated() => $pb.PbList<GenesisState>();
  @$core.pragma('dart2js:noInline')
  static GenesisState getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenesisState>(create);
  static GenesisState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$3.RegistrationNodeInfo> get registration => $_getList(0);

  @$pb.TagNumber(2)
  $1.MasterCertificate get nodeExchMasterCertificate => $_getN(1);
  @$pb.TagNumber(2)
  set nodeExchMasterCertificate($1.MasterCertificate v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNodeExchMasterCertificate() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeExchMasterCertificate() => clearField(2);
  @$pb.TagNumber(2)
  $1.MasterCertificate ensureNodeExchMasterCertificate() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.MasterCertificate get ioMasterCertificate => $_getN(2);
  @$pb.TagNumber(3)
  set ioMasterCertificate($1.MasterCertificate v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasIoMasterCertificate() => $_has(2);
  @$pb.TagNumber(3)
  void clearIoMasterCertificate() => clearField(3);
  @$pb.TagNumber(3)
  $1.MasterCertificate ensureIoMasterCertificate() => $_ensure(2);
}

