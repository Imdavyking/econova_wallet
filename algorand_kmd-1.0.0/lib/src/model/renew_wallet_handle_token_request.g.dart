// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renew_wallet_handle_token_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RenewWalletHandleTokenRequest extends RenewWalletHandleTokenRequest {
  @override
  final String? walletHandleToken;

  factory _$RenewWalletHandleTokenRequest(
          [void Function(RenewWalletHandleTokenRequestBuilder)? updates]) =>
      (new RenewWalletHandleTokenRequestBuilder()..update(updates)).build();

  _$RenewWalletHandleTokenRequest._({this.walletHandleToken}) : super._();

  @override
  RenewWalletHandleTokenRequest rebuild(
          void Function(RenewWalletHandleTokenRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RenewWalletHandleTokenRequestBuilder toBuilder() =>
      new RenewWalletHandleTokenRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RenewWalletHandleTokenRequest &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf($jc(0, walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('RenewWalletHandleTokenRequest')
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class RenewWalletHandleTokenRequestBuilder
    implements
        Builder<RenewWalletHandleTokenRequest,
            RenewWalletHandleTokenRequestBuilder> {
  _$RenewWalletHandleTokenRequest? _$v;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  RenewWalletHandleTokenRequestBuilder() {
    RenewWalletHandleTokenRequest._initializeBuilder(this);
  }

  RenewWalletHandleTokenRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RenewWalletHandleTokenRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$RenewWalletHandleTokenRequest;
  }

  @override
  void update(void Function(RenewWalletHandleTokenRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$RenewWalletHandleTokenRequest build() {
    final _$result = _$v ??
        new _$RenewWalletHandleTokenRequest._(
            walletHandleToken: walletHandleToken);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
