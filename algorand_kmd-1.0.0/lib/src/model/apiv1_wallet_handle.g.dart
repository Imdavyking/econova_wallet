// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_wallet_handle.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1WalletHandle extends APIV1WalletHandle {
  @override
  final int? expiresSeconds;
  @override
  final APIV1Wallet? wallet;

  factory _$APIV1WalletHandle(
          [void Function(APIV1WalletHandleBuilder)? updates]) =>
      (new APIV1WalletHandleBuilder()..update(updates)).build();

  _$APIV1WalletHandle._({this.expiresSeconds, this.wallet}) : super._();

  @override
  APIV1WalletHandle rebuild(void Function(APIV1WalletHandleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1WalletHandleBuilder toBuilder() =>
      new APIV1WalletHandleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1WalletHandle &&
        expiresSeconds == other.expiresSeconds &&
        wallet == other.wallet;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, expiresSeconds.hashCode), wallet.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1WalletHandle')
          ..add('expiresSeconds', expiresSeconds)
          ..add('wallet', wallet))
        .toString();
  }
}

class APIV1WalletHandleBuilder
    implements Builder<APIV1WalletHandle, APIV1WalletHandleBuilder> {
  _$APIV1WalletHandle? _$v;

  int? _expiresSeconds;
  int? get expiresSeconds => _$this._expiresSeconds;
  set expiresSeconds(int? expiresSeconds) =>
      _$this._expiresSeconds = expiresSeconds;

  APIV1WalletBuilder? _wallet;
  APIV1WalletBuilder get wallet => _$this._wallet ??= new APIV1WalletBuilder();
  set wallet(APIV1WalletBuilder? wallet) => _$this._wallet = wallet;

  APIV1WalletHandleBuilder() {
    APIV1WalletHandle._initializeBuilder(this);
  }

  APIV1WalletHandleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresSeconds = $v.expiresSeconds;
      _wallet = $v.wallet?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1WalletHandle other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1WalletHandle;
  }

  @override
  void update(void Function(APIV1WalletHandleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1WalletHandle build() {
    _$APIV1WalletHandle _$result;
    try {
      _$result = _$v ??
          new _$APIV1WalletHandle._(
              expiresSeconds: expiresSeconds, wallet: _wallet?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'wallet';
        _wallet?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1WalletHandle', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
