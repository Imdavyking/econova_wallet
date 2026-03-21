// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_program_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignProgramRequest extends SignProgramRequest {
  @override
  final String? address;
  @override
  final String? data;
  @override
  final String? walletHandleToken;
  @override
  final String? walletPassword;

  factory _$SignProgramRequest(
          [void Function(SignProgramRequestBuilder)? updates]) =>
      (new SignProgramRequestBuilder()..update(updates)).build();

  _$SignProgramRequest._(
      {this.address, this.data, this.walletHandleToken, this.walletPassword})
      : super._();

  @override
  SignProgramRequest rebuild(
          void Function(SignProgramRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignProgramRequestBuilder toBuilder() =>
      new SignProgramRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignProgramRequest &&
        address == other.address &&
        data == other.data &&
        walletHandleToken == other.walletHandleToken &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, address.hashCode), data.hashCode),
            walletHandleToken.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SignProgramRequest')
          ..add('address', address)
          ..add('data', data)
          ..add('walletHandleToken', walletHandleToken)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class SignProgramRequestBuilder
    implements Builder<SignProgramRequest, SignProgramRequestBuilder> {
  _$SignProgramRequest? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _data;
  String? get data => _$this._data;
  set data(String? data) => _$this._data = data;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  SignProgramRequestBuilder() {
    SignProgramRequest._initializeBuilder(this);
  }

  SignProgramRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _data = $v.data;
      _walletHandleToken = $v.walletHandleToken;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignProgramRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SignProgramRequest;
  }

  @override
  void update(void Function(SignProgramRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SignProgramRequest build() {
    final _$result = _$v ??
        new _$SignProgramRequest._(
            address: address,
            data: data,
            walletHandleToken: walletHandleToken,
            walletPassword: walletPassword);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
