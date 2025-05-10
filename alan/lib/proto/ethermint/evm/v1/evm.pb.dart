///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/evm.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class Params extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Params', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'evmDenom')
    ..aOB(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enableCreate')
    ..aOB(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enableCall')
    ..p<$fixnum.Int64>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'extraEips', $pb.PbFieldType.K6)
    ..aOM<ChainConfig>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'chainConfig', subBuilder: ChainConfig.create)
    ..aOB(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'allowUnprotectedTxs')
    ..hasRequiredFields = false
  ;

  Params._() : super();
  factory Params({
    $core.String? evmDenom,
    $core.bool? enableCreate,
    $core.bool? enableCall,
    $core.Iterable<$fixnum.Int64>? extraEips,
    ChainConfig? chainConfig,
    $core.bool? allowUnprotectedTxs,
  }) {
    final _result = create();
    if (evmDenom != null) {
      _result.evmDenom = evmDenom;
    }
    if (enableCreate != null) {
      _result.enableCreate = enableCreate;
    }
    if (enableCall != null) {
      _result.enableCall = enableCall;
    }
    if (extraEips != null) {
      _result.extraEips.addAll(extraEips);
    }
    if (chainConfig != null) {
      _result.chainConfig = chainConfig;
    }
    if (allowUnprotectedTxs != null) {
      _result.allowUnprotectedTxs = allowUnprotectedTxs;
    }
    return _result;
  }
  factory Params.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Params.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Params clone() => Params()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Params copyWith(void Function(Params) updates) => super.copyWith((message) => updates(message as Params)) as Params; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Params create() => Params._();
  Params createEmptyInstance() => create();
  static $pb.PbList<Params> createRepeated() => $pb.PbList<Params>();
  @$core.pragma('dart2js:noInline')
  static Params getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Params>(create);
  static Params? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get evmDenom => $_getSZ(0);
  @$pb.TagNumber(1)
  set evmDenom($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEvmDenom() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvmDenom() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enableCreate => $_getBF(1);
  @$pb.TagNumber(2)
  set enableCreate($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnableCreate() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnableCreate() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enableCall => $_getBF(2);
  @$pb.TagNumber(3)
  set enableCall($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEnableCall() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnableCall() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$fixnum.Int64> get extraEips => $_getList(3);

  @$pb.TagNumber(5)
  ChainConfig get chainConfig => $_getN(4);
  @$pb.TagNumber(5)
  set chainConfig(ChainConfig v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasChainConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearChainConfig() => clearField(5);
  @$pb.TagNumber(5)
  ChainConfig ensureChainConfig() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.bool get allowUnprotectedTxs => $_getBF(5);
  @$pb.TagNumber(6)
  set allowUnprotectedTxs($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAllowUnprotectedTxs() => $_has(5);
  @$pb.TagNumber(6)
  void clearAllowUnprotectedTxs() => clearField(6);
}

class ChainConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ChainConfig', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'homesteadBlock')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'daoForkBlock')
    ..aOB(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'daoForkSupport')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'eip150Block')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'eip150Hash')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'eip155Block')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'eip158Block')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'byzantiumBlock')
    ..aOS(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'constantinopleBlock')
    ..aOS(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'petersburgBlock')
    ..aOS(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'istanbulBlock')
    ..aOS(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'muirGlacierBlock')
    ..aOS(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'berlinBlock')
    ..aOS(17, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'londonBlock')
    ..aOS(18, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'arrowGlacierBlock')
    ..aOS(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'grayGlacierBlock')
    ..aOS(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mergeNetsplitBlock')
    ..hasRequiredFields = false
  ;

  ChainConfig._() : super();
  factory ChainConfig({
    $core.String? homesteadBlock,
    $core.String? daoForkBlock,
    $core.bool? daoForkSupport,
    $core.String? eip150Block,
    $core.String? eip150Hash,
    $core.String? eip155Block,
    $core.String? eip158Block,
    $core.String? byzantiumBlock,
    $core.String? constantinopleBlock,
    $core.String? petersburgBlock,
    $core.String? istanbulBlock,
    $core.String? muirGlacierBlock,
    $core.String? berlinBlock,
    $core.String? londonBlock,
    $core.String? arrowGlacierBlock,
    $core.String? grayGlacierBlock,
    $core.String? mergeNetsplitBlock,
  }) {
    final _result = create();
    if (homesteadBlock != null) {
      _result.homesteadBlock = homesteadBlock;
    }
    if (daoForkBlock != null) {
      _result.daoForkBlock = daoForkBlock;
    }
    if (daoForkSupport != null) {
      _result.daoForkSupport = daoForkSupport;
    }
    if (eip150Block != null) {
      _result.eip150Block = eip150Block;
    }
    if (eip150Hash != null) {
      _result.eip150Hash = eip150Hash;
    }
    if (eip155Block != null) {
      _result.eip155Block = eip155Block;
    }
    if (eip158Block != null) {
      _result.eip158Block = eip158Block;
    }
    if (byzantiumBlock != null) {
      _result.byzantiumBlock = byzantiumBlock;
    }
    if (constantinopleBlock != null) {
      _result.constantinopleBlock = constantinopleBlock;
    }
    if (petersburgBlock != null) {
      _result.petersburgBlock = petersburgBlock;
    }
    if (istanbulBlock != null) {
      _result.istanbulBlock = istanbulBlock;
    }
    if (muirGlacierBlock != null) {
      _result.muirGlacierBlock = muirGlacierBlock;
    }
    if (berlinBlock != null) {
      _result.berlinBlock = berlinBlock;
    }
    if (londonBlock != null) {
      _result.londonBlock = londonBlock;
    }
    if (arrowGlacierBlock != null) {
      _result.arrowGlacierBlock = arrowGlacierBlock;
    }
    if (grayGlacierBlock != null) {
      _result.grayGlacierBlock = grayGlacierBlock;
    }
    if (mergeNetsplitBlock != null) {
      _result.mergeNetsplitBlock = mergeNetsplitBlock;
    }
    return _result;
  }
  factory ChainConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChainConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChainConfig clone() => ChainConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChainConfig copyWith(void Function(ChainConfig) updates) => super.copyWith((message) => updates(message as ChainConfig)) as ChainConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ChainConfig create() => ChainConfig._();
  ChainConfig createEmptyInstance() => create();
  static $pb.PbList<ChainConfig> createRepeated() => $pb.PbList<ChainConfig>();
  @$core.pragma('dart2js:noInline')
  static ChainConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChainConfig>(create);
  static ChainConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get homesteadBlock => $_getSZ(0);
  @$pb.TagNumber(1)
  set homesteadBlock($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHomesteadBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearHomesteadBlock() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get daoForkBlock => $_getSZ(1);
  @$pb.TagNumber(2)
  set daoForkBlock($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDaoForkBlock() => $_has(1);
  @$pb.TagNumber(2)
  void clearDaoForkBlock() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get daoForkSupport => $_getBF(2);
  @$pb.TagNumber(3)
  set daoForkSupport($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDaoForkSupport() => $_has(2);
  @$pb.TagNumber(3)
  void clearDaoForkSupport() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get eip150Block => $_getSZ(3);
  @$pb.TagNumber(4)
  set eip150Block($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEip150Block() => $_has(3);
  @$pb.TagNumber(4)
  void clearEip150Block() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get eip150Hash => $_getSZ(4);
  @$pb.TagNumber(5)
  set eip150Hash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEip150Hash() => $_has(4);
  @$pb.TagNumber(5)
  void clearEip150Hash() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get eip155Block => $_getSZ(5);
  @$pb.TagNumber(6)
  set eip155Block($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEip155Block() => $_has(5);
  @$pb.TagNumber(6)
  void clearEip155Block() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get eip158Block => $_getSZ(6);
  @$pb.TagNumber(7)
  set eip158Block($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasEip158Block() => $_has(6);
  @$pb.TagNumber(7)
  void clearEip158Block() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get byzantiumBlock => $_getSZ(7);
  @$pb.TagNumber(8)
  set byzantiumBlock($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasByzantiumBlock() => $_has(7);
  @$pb.TagNumber(8)
  void clearByzantiumBlock() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get constantinopleBlock => $_getSZ(8);
  @$pb.TagNumber(9)
  set constantinopleBlock($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasConstantinopleBlock() => $_has(8);
  @$pb.TagNumber(9)
  void clearConstantinopleBlock() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get petersburgBlock => $_getSZ(9);
  @$pb.TagNumber(10)
  set petersburgBlock($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasPetersburgBlock() => $_has(9);
  @$pb.TagNumber(10)
  void clearPetersburgBlock() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get istanbulBlock => $_getSZ(10);
  @$pb.TagNumber(11)
  set istanbulBlock($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasIstanbulBlock() => $_has(10);
  @$pb.TagNumber(11)
  void clearIstanbulBlock() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get muirGlacierBlock => $_getSZ(11);
  @$pb.TagNumber(12)
  set muirGlacierBlock($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasMuirGlacierBlock() => $_has(11);
  @$pb.TagNumber(12)
  void clearMuirGlacierBlock() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get berlinBlock => $_getSZ(12);
  @$pb.TagNumber(13)
  set berlinBlock($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasBerlinBlock() => $_has(12);
  @$pb.TagNumber(13)
  void clearBerlinBlock() => clearField(13);

  @$pb.TagNumber(17)
  $core.String get londonBlock => $_getSZ(13);
  @$pb.TagNumber(17)
  set londonBlock($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(17)
  $core.bool hasLondonBlock() => $_has(13);
  @$pb.TagNumber(17)
  void clearLondonBlock() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get arrowGlacierBlock => $_getSZ(14);
  @$pb.TagNumber(18)
  set arrowGlacierBlock($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(18)
  $core.bool hasArrowGlacierBlock() => $_has(14);
  @$pb.TagNumber(18)
  void clearArrowGlacierBlock() => clearField(18);

  @$pb.TagNumber(20)
  $core.String get grayGlacierBlock => $_getSZ(15);
  @$pb.TagNumber(20)
  set grayGlacierBlock($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(20)
  $core.bool hasGrayGlacierBlock() => $_has(15);
  @$pb.TagNumber(20)
  void clearGrayGlacierBlock() => clearField(20);

  @$pb.TagNumber(21)
  $core.String get mergeNetsplitBlock => $_getSZ(16);
  @$pb.TagNumber(21)
  set mergeNetsplitBlock($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(21)
  $core.bool hasMergeNetsplitBlock() => $_has(16);
  @$pb.TagNumber(21)
  void clearMergeNetsplitBlock() => clearField(21);
}

class State extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'State', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'key')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value')
    ..hasRequiredFields = false
  ;

  State._() : super();
  factory State({
    $core.String? key,
    $core.String? value,
  }) {
    final _result = create();
    if (key != null) {
      _result.key = key;
    }
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory State.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory State.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  State clone() => State()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  State copyWith(void Function(State) updates) => super.copyWith((message) => updates(message as State)) as State; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static State create() => State._();
  State createEmptyInstance() => create();
  static $pb.PbList<State> createRepeated() => $pb.PbList<State>();
  @$core.pragma('dart2js:noInline')
  static State getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<State>(create);
  static State? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class TransactionLogs extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TransactionLogs', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'hash')
    ..pc<Log>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'logs', $pb.PbFieldType.PM, subBuilder: Log.create)
    ..hasRequiredFields = false
  ;

  TransactionLogs._() : super();
  factory TransactionLogs({
    $core.String? hash,
    $core.Iterable<Log>? logs,
  }) {
    final _result = create();
    if (hash != null) {
      _result.hash = hash;
    }
    if (logs != null) {
      _result.logs.addAll(logs);
    }
    return _result;
  }
  factory TransactionLogs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionLogs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionLogs clone() => TransactionLogs()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionLogs copyWith(void Function(TransactionLogs) updates) => super.copyWith((message) => updates(message as TransactionLogs)) as TransactionLogs; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TransactionLogs create() => TransactionLogs._();
  TransactionLogs createEmptyInstance() => create();
  static $pb.PbList<TransactionLogs> createRepeated() => $pb.PbList<TransactionLogs>();
  @$core.pragma('dart2js:noInline')
  static TransactionLogs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionLogs>(create);
  static TransactionLogs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Log> get logs => $_getList(1);
}

class Log extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Log', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..pPS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'topics')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockNumber', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txHash')
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txIndex', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockHash')
    ..a<$fixnum.Int64>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'removed')
    ..hasRequiredFields = false
  ;

  Log._() : super();
  factory Log({
    $core.String? address,
    $core.Iterable<$core.String>? topics,
    $core.List<$core.int>? data,
    $fixnum.Int64? blockNumber,
    $core.String? txHash,
    $fixnum.Int64? txIndex,
    $core.String? blockHash,
    $fixnum.Int64? index,
    $core.bool? removed,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (topics != null) {
      _result.topics.addAll(topics);
    }
    if (data != null) {
      _result.data = data;
    }
    if (blockNumber != null) {
      _result.blockNumber = blockNumber;
    }
    if (txHash != null) {
      _result.txHash = txHash;
    }
    if (txIndex != null) {
      _result.txIndex = txIndex;
    }
    if (blockHash != null) {
      _result.blockHash = blockHash;
    }
    if (index != null) {
      _result.index = index;
    }
    if (removed != null) {
      _result.removed = removed;
    }
    return _result;
  }
  factory Log.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Log.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Log clone() => Log()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Log copyWith(void Function(Log) updates) => super.copyWith((message) => updates(message as Log)) as Log; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Log create() => Log._();
  Log createEmptyInstance() => create();
  static $pb.PbList<Log> createRepeated() => $pb.PbList<Log>();
  @$core.pragma('dart2js:noInline')
  static Log getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Log>(create);
  static Log? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get topics => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get blockNumber => $_getI64(3);
  @$pb.TagNumber(4)
  set blockNumber($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get txHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set txHash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTxHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearTxHash() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get txIndex => $_getI64(5);
  @$pb.TagNumber(6)
  set txIndex($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTxIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearTxIndex() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get blockHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set blockHash($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlockHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHash() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get index => $_getI64(7);
  @$pb.TagNumber(8)
  set index($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearIndex() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get removed => $_getBF(8);
  @$pb.TagNumber(9)
  set removed($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRemoved() => $_has(8);
  @$pb.TagNumber(9)
  void clearRemoved() => clearField(9);
}

class TxResult extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TxResult', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contractAddress')
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'bloom', $pb.PbFieldType.OY)
    ..aOM<TransactionLogs>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txLogs', subBuilder: TransactionLogs.create)
    ..a<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ret', $pb.PbFieldType.OY)
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'reverted')
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'gasUsed', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  TxResult._() : super();
  factory TxResult({
    $core.String? contractAddress,
    $core.List<$core.int>? bloom,
    TransactionLogs? txLogs,
    $core.List<$core.int>? ret,
    $core.bool? reverted,
    $fixnum.Int64? gasUsed,
  }) {
    final _result = create();
    if (contractAddress != null) {
      _result.contractAddress = contractAddress;
    }
    if (bloom != null) {
      _result.bloom = bloom;
    }
    if (txLogs != null) {
      _result.txLogs = txLogs;
    }
    if (ret != null) {
      _result.ret = ret;
    }
    if (reverted != null) {
      _result.reverted = reverted;
    }
    if (gasUsed != null) {
      _result.gasUsed = gasUsed;
    }
    return _result;
  }
  factory TxResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TxResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TxResult clone() => TxResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TxResult copyWith(void Function(TxResult) updates) => super.copyWith((message) => updates(message as TxResult)) as TxResult; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TxResult create() => TxResult._();
  TxResult createEmptyInstance() => create();
  static $pb.PbList<TxResult> createRepeated() => $pb.PbList<TxResult>();
  @$core.pragma('dart2js:noInline')
  static TxResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TxResult>(create);
  static TxResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get contractAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set contractAddress($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContractAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearContractAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get bloom => $_getN(1);
  @$pb.TagNumber(2)
  set bloom($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBloom() => $_has(1);
  @$pb.TagNumber(2)
  void clearBloom() => clearField(2);

  @$pb.TagNumber(3)
  TransactionLogs get txLogs => $_getN(2);
  @$pb.TagNumber(3)
  set txLogs(TransactionLogs v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTxLogs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxLogs() => clearField(3);
  @$pb.TagNumber(3)
  TransactionLogs ensureTxLogs() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.List<$core.int> get ret => $_getN(3);
  @$pb.TagNumber(4)
  set ret($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRet() => $_has(3);
  @$pb.TagNumber(4)
  void clearRet() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get reverted => $_getBF(4);
  @$pb.TagNumber(5)
  set reverted($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReverted() => $_has(4);
  @$pb.TagNumber(5)
  void clearReverted() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get gasUsed => $_getI64(5);
  @$pb.TagNumber(6)
  set gasUsed($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGasUsed() => $_has(5);
  @$pb.TagNumber(6)
  void clearGasUsed() => clearField(6);
}

class AccessTuple extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'AccessTuple', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'address')
    ..pPS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'storageKeys')
    ..hasRequiredFields = false
  ;

  AccessTuple._() : super();
  factory AccessTuple({
    $core.String? address,
    $core.Iterable<$core.String>? storageKeys,
  }) {
    final _result = create();
    if (address != null) {
      _result.address = address;
    }
    if (storageKeys != null) {
      _result.storageKeys.addAll(storageKeys);
    }
    return _result;
  }
  factory AccessTuple.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccessTuple.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AccessTuple clone() => AccessTuple()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AccessTuple copyWith(void Function(AccessTuple) updates) => super.copyWith((message) => updates(message as AccessTuple)) as AccessTuple; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AccessTuple create() => AccessTuple._();
  AccessTuple createEmptyInstance() => create();
  static $pb.PbList<AccessTuple> createRepeated() => $pb.PbList<AccessTuple>();
  @$core.pragma('dart2js:noInline')
  static AccessTuple getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccessTuple>(create);
  static AccessTuple? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get storageKeys => $_getList(1);
}

class TraceConfig extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TraceConfig', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ethermint.evm.v1'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tracer')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timeout')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'reexec', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'disableStack')
    ..aOB(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'disableStorage')
    ..aOB(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'debug')
    ..a<$core.int>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'limit', $pb.PbFieldType.O3)
    ..aOM<ChainConfig>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'overrides', subBuilder: ChainConfig.create)
    ..aOB(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enableMemory')
    ..aOB(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enableReturnData')
    ..hasRequiredFields = false
  ;

  TraceConfig._() : super();
  factory TraceConfig({
    $core.String? tracer,
    $core.String? timeout,
    $fixnum.Int64? reexec,
    $core.bool? disableStack,
    $core.bool? disableStorage,
    $core.bool? debug,
    $core.int? limit,
    ChainConfig? overrides,
    $core.bool? enableMemory,
    $core.bool? enableReturnData,
  }) {
    final _result = create();
    if (tracer != null) {
      _result.tracer = tracer;
    }
    if (timeout != null) {
      _result.timeout = timeout;
    }
    if (reexec != null) {
      _result.reexec = reexec;
    }
    if (disableStack != null) {
      _result.disableStack = disableStack;
    }
    if (disableStorage != null) {
      _result.disableStorage = disableStorage;
    }
    if (debug != null) {
      _result.debug = debug;
    }
    if (limit != null) {
      _result.limit = limit;
    }
    if (overrides != null) {
      _result.overrides = overrides;
    }
    if (enableMemory != null) {
      _result.enableMemory = enableMemory;
    }
    if (enableReturnData != null) {
      _result.enableReturnData = enableReturnData;
    }
    return _result;
  }
  factory TraceConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TraceConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TraceConfig clone() => TraceConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TraceConfig copyWith(void Function(TraceConfig) updates) => super.copyWith((message) => updates(message as TraceConfig)) as TraceConfig; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TraceConfig create() => TraceConfig._();
  TraceConfig createEmptyInstance() => create();
  static $pb.PbList<TraceConfig> createRepeated() => $pb.PbList<TraceConfig>();
  @$core.pragma('dart2js:noInline')
  static TraceConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TraceConfig>(create);
  static TraceConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tracer => $_getSZ(0);
  @$pb.TagNumber(1)
  set tracer($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTracer() => $_has(0);
  @$pb.TagNumber(1)
  void clearTracer() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get timeout => $_getSZ(1);
  @$pb.TagNumber(2)
  set timeout($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimeout() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeout() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get reexec => $_getI64(2);
  @$pb.TagNumber(3)
  set reexec($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReexec() => $_has(2);
  @$pb.TagNumber(3)
  void clearReexec() => clearField(3);

  @$pb.TagNumber(5)
  $core.bool get disableStack => $_getBF(3);
  @$pb.TagNumber(5)
  set disableStack($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasDisableStack() => $_has(3);
  @$pb.TagNumber(5)
  void clearDisableStack() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get disableStorage => $_getBF(4);
  @$pb.TagNumber(6)
  set disableStorage($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasDisableStorage() => $_has(4);
  @$pb.TagNumber(6)
  void clearDisableStorage() => clearField(6);

  @$pb.TagNumber(8)
  $core.bool get debug => $_getBF(5);
  @$pb.TagNumber(8)
  set debug($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(8)
  $core.bool hasDebug() => $_has(5);
  @$pb.TagNumber(8)
  void clearDebug() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get limit => $_getIZ(6);
  @$pb.TagNumber(9)
  set limit($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(9)
  $core.bool hasLimit() => $_has(6);
  @$pb.TagNumber(9)
  void clearLimit() => clearField(9);

  @$pb.TagNumber(10)
  ChainConfig get overrides => $_getN(7);
  @$pb.TagNumber(10)
  set overrides(ChainConfig v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasOverrides() => $_has(7);
  @$pb.TagNumber(10)
  void clearOverrides() => clearField(10);
  @$pb.TagNumber(10)
  ChainConfig ensureOverrides() => $_ensure(7);

  @$pb.TagNumber(11)
  $core.bool get enableMemory => $_getBF(8);
  @$pb.TagNumber(11)
  set enableMemory($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(11)
  $core.bool hasEnableMemory() => $_has(8);
  @$pb.TagNumber(11)
  void clearEnableMemory() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get enableReturnData => $_getBF(9);
  @$pb.TagNumber(12)
  set enableReturnData($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(12)
  $core.bool hasEnableReturnData() => $_has(9);
  @$pb.TagNumber(12)
  void clearEnableReturnData() => clearField(12);
}

