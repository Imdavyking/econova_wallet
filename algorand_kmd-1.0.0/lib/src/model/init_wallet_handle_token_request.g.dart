// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'init_wallet_handle_token_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InitWalletHandleTokenRequest extends InitWalletHandleTokenRequest {
  @override
  final String? walletId;
  @override
  final String? walletPassword;

  factory _$InitWalletHandleTokenRequest(
          [void Function(InitWalletHandleTokenRequestBuilder)? updates]) =>
      (new InitWalletHandleTokenRequestBuilder()..update(updates)).build();

  _$InitWalletHandleTokenRequest._({this.walletId, this.walletPassword})
      : super._();

  @override
  InitWalletHandleTokenRequest rebuild(
          void Function(InitWalletHandleTokenRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InitWalletHandleTokenRequestBuilder toBuilder() =>
      new InitWalletHandleTokenRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InitWalletHandleTokenRequest &&
        walletId == other.walletId &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, walletId.hashCode), walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('InitWalletHandleTokenRequest')
          ..add('walletId', walletId)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class InitWalletHandleTokenRequestBuilder
    implements
        Builder<InitWalletHandleTokenRequest,
            InitWalletHandleTokenRequestBuilder> {
  _$InitWalletHandleTokenRequest? _$v;

  String? _walletId;
  String? get walletId => _$this._walletId;
  set walletId(String? walletId) => _$this._walletId = walletId;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  InitWalletHandleTokenRequestBuilder() {
    InitWalletHandleTokenRequest._initializeBuilder(this);
  }

  InitWalletHandleTokenRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _walletId = $v.walletId;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InitWalletHandleTokenRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$InitWalletHandleTokenRequest;
  }

  @override
  void update(void Function(InitWalletHandleTokenRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$InitWalletHandleTokenRequest build() {
    final _$result = _$v ??
        new _$InitWalletHandleTokenRequest._(
            walletId: walletId, walletPassword: walletPassword);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
