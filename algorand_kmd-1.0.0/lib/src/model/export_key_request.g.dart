// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_key_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportKeyRequest extends ExportKeyRequest {
  @override
  final String? address;
  @override
  final String? walletHandleToken;
  @override
  final String? walletPassword;

  factory _$ExportKeyRequest(
          [void Function(ExportKeyRequestBuilder)? updates]) =>
      (new ExportKeyRequestBuilder()..update(updates)).build();

  _$ExportKeyRequest._(
      {this.address, this.walletHandleToken, this.walletPassword})
      : super._();

  @override
  ExportKeyRequest rebuild(void Function(ExportKeyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportKeyRequestBuilder toBuilder() =>
      new ExportKeyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportKeyRequest &&
        address == other.address &&
        walletHandleToken == other.walletHandleToken &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, address.hashCode), walletHandleToken.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ExportKeyRequest')
          ..add('address', address)
          ..add('walletHandleToken', walletHandleToken)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class ExportKeyRequestBuilder
    implements Builder<ExportKeyRequest, ExportKeyRequestBuilder> {
  _$ExportKeyRequest? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  ExportKeyRequestBuilder() {
    ExportKeyRequest._initializeBuilder(this);
  }

  ExportKeyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _walletHandleToken = $v.walletHandleToken;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportKeyRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ExportKeyRequest;
  }

  @override
  void update(void Function(ExportKeyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ExportKeyRequest build() {
    final _$result = _$v ??
        new _$ExportKeyRequest._(
            address: address,
            walletHandleToken: walletHandleToken,
            walletPassword: walletPassword);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
