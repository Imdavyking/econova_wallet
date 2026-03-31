// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_wallet.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1Wallet extends APIV1Wallet {
  @override
  final String? driverName;
  @override
  final int? driverVersion;
  @override
  final String? id;
  @override
  final bool? mnemonicUx;
  @override
  final String? name;
  @override
  final BuiltList<String>? supportedTxs;

  factory _$APIV1Wallet([void Function(APIV1WalletBuilder)? updates]) =>
      (new APIV1WalletBuilder()..update(updates)).build();

  _$APIV1Wallet._(
      {this.driverName,
      this.driverVersion,
      this.id,
      this.mnemonicUx,
      this.name,
      this.supportedTxs})
      : super._();

  @override
  APIV1Wallet rebuild(void Function(APIV1WalletBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1WalletBuilder toBuilder() => new APIV1WalletBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1Wallet &&
        driverName == other.driverName &&
        driverVersion == other.driverVersion &&
        id == other.id &&
        mnemonicUx == other.mnemonicUx &&
        name == other.name &&
        supportedTxs == other.supportedTxs;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, driverName.hashCode), driverVersion.hashCode),
                    id.hashCode),
                mnemonicUx.hashCode),
            name.hashCode),
        supportedTxs.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1Wallet')
          ..add('driverName', driverName)
          ..add('driverVersion', driverVersion)
          ..add('id', id)
          ..add('mnemonicUx', mnemonicUx)
          ..add('name', name)
          ..add('supportedTxs', supportedTxs))
        .toString();
  }
}

class APIV1WalletBuilder implements Builder<APIV1Wallet, APIV1WalletBuilder> {
  _$APIV1Wallet? _$v;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  int? _driverVersion;
  int? get driverVersion => _$this._driverVersion;
  set driverVersion(int? driverVersion) =>
      _$this._driverVersion = driverVersion;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _mnemonicUx;
  bool? get mnemonicUx => _$this._mnemonicUx;
  set mnemonicUx(bool? mnemonicUx) => _$this._mnemonicUx = mnemonicUx;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<String>? _supportedTxs;
  ListBuilder<String> get supportedTxs =>
      _$this._supportedTxs ??= new ListBuilder<String>();
  set supportedTxs(ListBuilder<String>? supportedTxs) =>
      _$this._supportedTxs = supportedTxs;

  APIV1WalletBuilder() {
    APIV1Wallet._initializeBuilder(this);
  }

  APIV1WalletBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverName = $v.driverName;
      _driverVersion = $v.driverVersion;
      _id = $v.id;
      _mnemonicUx = $v.mnemonicUx;
      _name = $v.name;
      _supportedTxs = $v.supportedTxs?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1Wallet other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1Wallet;
  }

  @override
  void update(void Function(APIV1WalletBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1Wallet build() {
    _$APIV1Wallet _$result;
    try {
      _$result = _$v ??
          new _$APIV1Wallet._(
              driverName: driverName,
              driverVersion: driverVersion,
              id: id,
              mnemonicUx: mnemonicUx,
              name: name,
              supportedTxs: _supportedTxs?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'supportedTxs';
        _supportedTxs?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1Wallet', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
