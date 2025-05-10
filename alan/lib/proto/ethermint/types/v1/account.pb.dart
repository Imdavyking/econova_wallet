///
//  Generated code. Do not modify.
//  source: ethermint/types/v1/account.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../../cosmos/auth/v1beta1/auth.pb.dart' as $0;

class EthAccount extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EthAccount', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.types.v1'), createEmptyInstance: create)
    ..aOM<$0.BaseAccount>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baseAccount', subBuilder: $0.BaseAccount.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'codeHash')
    ..hasRequiredFields = false
  ;

  EthAccount._() : super();
  factory EthAccount({
    $0.BaseAccount? baseAccount,
    $core.String? codeHash,
  }) {
    final _result = create();
    if (baseAccount != null) {
      _result.baseAccount = baseAccount;
    }
    if (codeHash != null) {
      _result.codeHash = codeHash;
    }
    return _result;
  }
  factory EthAccount.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EthAccount.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EthAccount clone() => EthAccount()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EthAccount copyWith(void Function(EthAccount) updates) => super.copyWith((message) => updates(message as EthAccount)) as EthAccount; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EthAccount create() => EthAccount._();
  EthAccount createEmptyInstance() => create();
  static $pb.PbList<EthAccount> createRepeated() => $pb.PbList<EthAccount>();
  @$core.pragma('dart2js:noInline')
  static EthAccount getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EthAccount>(create);
  static EthAccount? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BaseAccount get baseAccount => $_getN(0);
  @$pb.TagNumber(1)
  set baseAccount($0.BaseAccount v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBaseAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAccount() => clearField(1);
  @$pb.TagNumber(1)
  $0.BaseAccount ensureBaseAccount() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get codeHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set codeHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCodeHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCodeHash() => clearField(2);
}

