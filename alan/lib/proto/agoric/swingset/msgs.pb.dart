///
//  Generated code. Do not modify.
//  source: agoric/swingset/msgs.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class MsgDeliverInbound extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgDeliverInbound', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..pPS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'messages')
    ..p<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nums', $pb.PbFieldType.KU6)
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ack', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'submitter', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  MsgDeliverInbound._() : super();
  factory MsgDeliverInbound({
    $core.Iterable<$core.String>? messages,
    $core.Iterable<$fixnum.Int64>? nums,
    $fixnum.Int64? ack,
    $core.List<$core.int>? submitter,
  }) {
    final _result = create();
    if (messages != null) {
      _result.messages.addAll(messages);
    }
    if (nums != null) {
      _result.nums.addAll(nums);
    }
    if (ack != null) {
      _result.ack = ack;
    }
    if (submitter != null) {
      _result.submitter = submitter;
    }
    return _result;
  }
  factory MsgDeliverInbound.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgDeliverInbound.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgDeliverInbound clone() => MsgDeliverInbound()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgDeliverInbound copyWith(void Function(MsgDeliverInbound) updates) => super.copyWith((message) => updates(message as MsgDeliverInbound)) as MsgDeliverInbound; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgDeliverInbound create() => MsgDeliverInbound._();
  MsgDeliverInbound createEmptyInstance() => create();
  static $pb.PbList<MsgDeliverInbound> createRepeated() => $pb.PbList<MsgDeliverInbound>();
  @$core.pragma('dart2js:noInline')
  static MsgDeliverInbound getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgDeliverInbound>(create);
  static MsgDeliverInbound? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$fixnum.Int64> get nums => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get ack => $_getI64(2);
  @$pb.TagNumber(3)
  set ack($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAck() => $_has(2);
  @$pb.TagNumber(3)
  void clearAck() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get submitter => $_getN(3);
  @$pb.TagNumber(4)
  set submitter($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSubmitter() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubmitter() => clearField(4);
}

class MsgDeliverInboundResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgDeliverInboundResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  MsgDeliverInboundResponse._() : super();
  factory MsgDeliverInboundResponse() => create();
  factory MsgDeliverInboundResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgDeliverInboundResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgDeliverInboundResponse clone() => MsgDeliverInboundResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgDeliverInboundResponse copyWith(void Function(MsgDeliverInboundResponse) updates) => super.copyWith((message) => updates(message as MsgDeliverInboundResponse)) as MsgDeliverInboundResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgDeliverInboundResponse create() => MsgDeliverInboundResponse._();
  MsgDeliverInboundResponse createEmptyInstance() => create();
  static $pb.PbList<MsgDeliverInboundResponse> createRepeated() => $pb.PbList<MsgDeliverInboundResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgDeliverInboundResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgDeliverInboundResponse>(create);
  static MsgDeliverInboundResponse? _defaultInstance;
}

class MsgWalletAction extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgWalletAction', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'owner', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'action')
    ..hasRequiredFields = false
  ;

  MsgWalletAction._() : super();
  factory MsgWalletAction({
    $core.List<$core.int>? owner,
    $core.String? action,
  }) {
    final _result = create();
    if (owner != null) {
      _result.owner = owner;
    }
    if (action != null) {
      _result.action = action;
    }
    return _result;
  }
  factory MsgWalletAction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgWalletAction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgWalletAction clone() => MsgWalletAction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgWalletAction copyWith(void Function(MsgWalletAction) updates) => super.copyWith((message) => updates(message as MsgWalletAction)) as MsgWalletAction; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgWalletAction create() => MsgWalletAction._();
  MsgWalletAction createEmptyInstance() => create();
  static $pb.PbList<MsgWalletAction> createRepeated() => $pb.PbList<MsgWalletAction>();
  @$core.pragma('dart2js:noInline')
  static MsgWalletAction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgWalletAction>(create);
  static MsgWalletAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get owner => $_getN(0);
  @$pb.TagNumber(1)
  set owner($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => clearField(2);
}

class MsgWalletActionResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgWalletActionResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  MsgWalletActionResponse._() : super();
  factory MsgWalletActionResponse() => create();
  factory MsgWalletActionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgWalletActionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgWalletActionResponse clone() => MsgWalletActionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgWalletActionResponse copyWith(void Function(MsgWalletActionResponse) updates) => super.copyWith((message) => updates(message as MsgWalletActionResponse)) as MsgWalletActionResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgWalletActionResponse create() => MsgWalletActionResponse._();
  MsgWalletActionResponse createEmptyInstance() => create();
  static $pb.PbList<MsgWalletActionResponse> createRepeated() => $pb.PbList<MsgWalletActionResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgWalletActionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgWalletActionResponse>(create);
  static MsgWalletActionResponse? _defaultInstance;
}

class MsgWalletSpendAction extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgWalletSpendAction', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'owner', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'spendAction')
    ..hasRequiredFields = false
  ;

  MsgWalletSpendAction._() : super();
  factory MsgWalletSpendAction({
    $core.List<$core.int>? owner,
    $core.String? spendAction,
  }) {
    final _result = create();
    if (owner != null) {
      _result.owner = owner;
    }
    if (spendAction != null) {
      _result.spendAction = spendAction;
    }
    return _result;
  }
  factory MsgWalletSpendAction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgWalletSpendAction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgWalletSpendAction clone() => MsgWalletSpendAction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgWalletSpendAction copyWith(void Function(MsgWalletSpendAction) updates) => super.copyWith((message) => updates(message as MsgWalletSpendAction)) as MsgWalletSpendAction; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgWalletSpendAction create() => MsgWalletSpendAction._();
  MsgWalletSpendAction createEmptyInstance() => create();
  static $pb.PbList<MsgWalletSpendAction> createRepeated() => $pb.PbList<MsgWalletSpendAction>();
  @$core.pragma('dart2js:noInline')
  static MsgWalletSpendAction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgWalletSpendAction>(create);
  static MsgWalletSpendAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get owner => $_getN(0);
  @$pb.TagNumber(1)
  set owner($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get spendAction => $_getSZ(1);
  @$pb.TagNumber(2)
  set spendAction($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSpendAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpendAction() => clearField(2);
}

class MsgWalletSpendActionResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgWalletSpendActionResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  MsgWalletSpendActionResponse._() : super();
  factory MsgWalletSpendActionResponse() => create();
  factory MsgWalletSpendActionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgWalletSpendActionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgWalletSpendActionResponse clone() => MsgWalletSpendActionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgWalletSpendActionResponse copyWith(void Function(MsgWalletSpendActionResponse) updates) => super.copyWith((message) => updates(message as MsgWalletSpendActionResponse)) as MsgWalletSpendActionResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgWalletSpendActionResponse create() => MsgWalletSpendActionResponse._();
  MsgWalletSpendActionResponse createEmptyInstance() => create();
  static $pb.PbList<MsgWalletSpendActionResponse> createRepeated() => $pb.PbList<MsgWalletSpendActionResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgWalletSpendActionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgWalletSpendActionResponse>(create);
  static MsgWalletSpendActionResponse? _defaultInstance;
}

class MsgProvision extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgProvision', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nickname')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address', $pb.PbFieldType.OY)
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'powerFlags')
    ..a<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'submitter', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  MsgProvision._() : super();
  factory MsgProvision({
    $core.String? nickname,
    $core.List<$core.int>? address,
    $core.Iterable<$core.String>? powerFlags,
    $core.List<$core.int>? submitter,
  }) {
    final _result = create();
    if (nickname != null) {
      _result.nickname = nickname;
    }
    if (address != null) {
      _result.address = address;
    }
    if (powerFlags != null) {
      _result.powerFlags.addAll(powerFlags);
    }
    if (submitter != null) {
      _result.submitter = submitter;
    }
    return _result;
  }
  factory MsgProvision.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgProvision.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgProvision clone() => MsgProvision()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgProvision copyWith(void Function(MsgProvision) updates) => super.copyWith((message) => updates(message as MsgProvision)) as MsgProvision; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgProvision create() => MsgProvision._();
  MsgProvision createEmptyInstance() => create();
  static $pb.PbList<MsgProvision> createRepeated() => $pb.PbList<MsgProvision>();
  @$core.pragma('dart2js:noInline')
  static MsgProvision getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgProvision>(create);
  static MsgProvision? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nickname => $_getSZ(0);
  @$pb.TagNumber(1)
  set nickname($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNickname() => $_has(0);
  @$pb.TagNumber(1)
  void clearNickname() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get address => $_getN(1);
  @$pb.TagNumber(2)
  set address($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get powerFlags => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$core.int> get submitter => $_getN(3);
  @$pb.TagNumber(4)
  set submitter($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSubmitter() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubmitter() => clearField(4);
}

class MsgProvisionResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgProvisionResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  MsgProvisionResponse._() : super();
  factory MsgProvisionResponse() => create();
  factory MsgProvisionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgProvisionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgProvisionResponse clone() => MsgProvisionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgProvisionResponse copyWith(void Function(MsgProvisionResponse) updates) => super.copyWith((message) => updates(message as MsgProvisionResponse)) as MsgProvisionResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgProvisionResponse create() => MsgProvisionResponse._();
  MsgProvisionResponse createEmptyInstance() => create();
  static $pb.PbList<MsgProvisionResponse> createRepeated() => $pb.PbList<MsgProvisionResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgProvisionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgProvisionResponse>(create);
  static MsgProvisionResponse? _defaultInstance;
}

class MsgInstallBundle extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgInstallBundle', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bundle')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'submitter', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'compressedBundle', $pb.PbFieldType.OY)
    ..aInt64(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'uncompressedSize')
    ..hasRequiredFields = false
  ;

  MsgInstallBundle._() : super();
  factory MsgInstallBundle({
    $core.String? bundle,
    $core.List<$core.int>? submitter,
    $core.List<$core.int>? compressedBundle,
    $fixnum.Int64? uncompressedSize,
  }) {
    final _result = create();
    if (bundle != null) {
      _result.bundle = bundle;
    }
    if (submitter != null) {
      _result.submitter = submitter;
    }
    if (compressedBundle != null) {
      _result.compressedBundle = compressedBundle;
    }
    if (uncompressedSize != null) {
      _result.uncompressedSize = uncompressedSize;
    }
    return _result;
  }
  factory MsgInstallBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgInstallBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgInstallBundle clone() => MsgInstallBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgInstallBundle copyWith(void Function(MsgInstallBundle) updates) => super.copyWith((message) => updates(message as MsgInstallBundle)) as MsgInstallBundle; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgInstallBundle create() => MsgInstallBundle._();
  MsgInstallBundle createEmptyInstance() => create();
  static $pb.PbList<MsgInstallBundle> createRepeated() => $pb.PbList<MsgInstallBundle>();
  @$core.pragma('dart2js:noInline')
  static MsgInstallBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgInstallBundle>(create);
  static MsgInstallBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get bundle => $_getSZ(0);
  @$pb.TagNumber(1)
  set bundle($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBundle() => $_has(0);
  @$pb.TagNumber(1)
  void clearBundle() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get submitter => $_getN(1);
  @$pb.TagNumber(2)
  set submitter($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSubmitter() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubmitter() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get compressedBundle => $_getN(2);
  @$pb.TagNumber(3)
  set compressedBundle($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCompressedBundle() => $_has(2);
  @$pb.TagNumber(3)
  void clearCompressedBundle() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get uncompressedSize => $_getI64(3);
  @$pb.TagNumber(4)
  set uncompressedSize($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUncompressedSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearUncompressedSize() => clearField(4);
}

class MsgInstallBundleResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'MsgInstallBundleResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'agoric.swingset'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  MsgInstallBundleResponse._() : super();
  factory MsgInstallBundleResponse() => create();
  factory MsgInstallBundleResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MsgInstallBundleResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MsgInstallBundleResponse clone() => MsgInstallBundleResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MsgInstallBundleResponse copyWith(void Function(MsgInstallBundleResponse) updates) => super.copyWith((message) => updates(message as MsgInstallBundleResponse)) as MsgInstallBundleResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MsgInstallBundleResponse create() => MsgInstallBundleResponse._();
  MsgInstallBundleResponse createEmptyInstance() => create();
  static $pb.PbList<MsgInstallBundleResponse> createRepeated() => $pb.PbList<MsgInstallBundleResponse>();
  @$core.pragma('dart2js:noInline')
  static MsgInstallBundleResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MsgInstallBundleResponse>(create);
  static MsgInstallBundleResponse? _defaultInstance;
}

