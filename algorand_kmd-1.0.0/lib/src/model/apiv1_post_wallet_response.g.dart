// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_wallet_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTWalletResponse extends APIV1POSTWalletResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final APIV1Wallet? wallet;

  factory _$APIV1POSTWalletResponse(
          [void Function(APIV1POSTWalletResponseBuilder)? updates]) =>
      (new APIV1POSTWalletResponseBuilder()..update(updates)).build();

  _$APIV1POSTWalletResponse._({this.error, this.message, this.wallet})
      : super._();

  @override
  APIV1POSTWalletResponse rebuild(
          void Function(APIV1POSTWalletResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTWalletResponseBuilder toBuilder() =>
      new APIV1POSTWalletResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTWalletResponse &&
        error == other.error &&
        message == other.message &&
        wallet == other.wallet;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, error.hashCode), message.hashCode), wallet.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTWalletResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('wallet', wallet))
        .toString();
  }
}

class APIV1POSTWalletResponseBuilder
    implements
        Builder<APIV1POSTWalletResponse, APIV1POSTWalletResponseBuilder> {
  _$APIV1POSTWalletResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  APIV1WalletBuilder? _wallet;
  APIV1WalletBuilder get wallet => _$this._wallet ??= new APIV1WalletBuilder();
  set wallet(APIV1WalletBuilder? wallet) => _$this._wallet = wallet;

  APIV1POSTWalletResponseBuilder() {
    APIV1POSTWalletResponse._initializeBuilder(this);
  }

  APIV1POSTWalletResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _wallet = $v.wallet?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTWalletResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTWalletResponse;
  }

  @override
  void update(void Function(APIV1POSTWalletResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTWalletResponse build() {
    _$APIV1POSTWalletResponse _$result;
    try {
      _$result = _$v ??
          new _$APIV1POSTWalletResponse._(
              error: error, message: message, wallet: _wallet?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'wallet';
        _wallet?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1POSTWalletResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
