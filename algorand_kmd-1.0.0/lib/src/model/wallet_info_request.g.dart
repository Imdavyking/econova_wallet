// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_info_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WalletInfoRequest extends WalletInfoRequest {
  @override
  final String? walletHandleToken;

  factory _$WalletInfoRequest(
          [void Function(WalletInfoRequestBuilder)? updates]) =>
      (new WalletInfoRequestBuilder()..update(updates)).build();

  _$WalletInfoRequest._({this.walletHandleToken}) : super._();

  @override
  WalletInfoRequest rebuild(void Function(WalletInfoRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WalletInfoRequestBuilder toBuilder() =>
      new WalletInfoRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WalletInfoRequest &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf($jc(0, walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('WalletInfoRequest')
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class WalletInfoRequestBuilder
    implements Builder<WalletInfoRequest, WalletInfoRequestBuilder> {
  _$WalletInfoRequest? _$v;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  WalletInfoRequestBuilder() {
    WalletInfoRequest._initializeBuilder(this);
  }

  WalletInfoRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WalletInfoRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$WalletInfoRequest;
  }

  @override
  void update(void Function(WalletInfoRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$WalletInfoRequest build() {
    final _$result =
        _$v ?? new _$WalletInfoRequest._(walletHandleToken: walletHandleToken);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
