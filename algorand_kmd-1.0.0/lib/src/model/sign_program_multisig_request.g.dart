// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_program_multisig_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignProgramMultisigRequest extends SignProgramMultisigRequest {
  @override
  final String? address;
  @override
  final String? data;
  @override
  final MultisigSig? partialMultisig;
  @override
  final BuiltList<int>? publicKey;
  @override
  final String? walletHandleToken;
  @override
  final String? walletPassword;

  factory _$SignProgramMultisigRequest(
          [void Function(SignProgramMultisigRequestBuilder)? updates]) =>
      (new SignProgramMultisigRequestBuilder()..update(updates)).build();

  _$SignProgramMultisigRequest._(
      {this.address,
      this.data,
      this.partialMultisig,
      this.publicKey,
      this.walletHandleToken,
      this.walletPassword})
      : super._();

  @override
  SignProgramMultisigRequest rebuild(
          void Function(SignProgramMultisigRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignProgramMultisigRequestBuilder toBuilder() =>
      new SignProgramMultisigRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignProgramMultisigRequest &&
        address == other.address &&
        data == other.data &&
        partialMultisig == other.partialMultisig &&
        publicKey == other.publicKey &&
        walletHandleToken == other.walletHandleToken &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, address.hashCode), data.hashCode),
                    partialMultisig.hashCode),
                publicKey.hashCode),
            walletHandleToken.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SignProgramMultisigRequest')
          ..add('address', address)
          ..add('data', data)
          ..add('partialMultisig', partialMultisig)
          ..add('publicKey', publicKey)
          ..add('walletHandleToken', walletHandleToken)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class SignProgramMultisigRequestBuilder
    implements
        Builder<SignProgramMultisigRequest, SignProgramMultisigRequestBuilder> {
  _$SignProgramMultisigRequest? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _data;
  String? get data => _$this._data;
  set data(String? data) => _$this._data = data;

  MultisigSigBuilder? _partialMultisig;
  MultisigSigBuilder get partialMultisig =>
      _$this._partialMultisig ??= new MultisigSigBuilder();
  set partialMultisig(MultisigSigBuilder? partialMultisig) =>
      _$this._partialMultisig = partialMultisig;

  ListBuilder<int>? _publicKey;
  ListBuilder<int> get publicKey =>
      _$this._publicKey ??= new ListBuilder<int>();
  set publicKey(ListBuilder<int>? publicKey) => _$this._publicKey = publicKey;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  SignProgramMultisigRequestBuilder() {
    SignProgramMultisigRequest._initializeBuilder(this);
  }

  SignProgramMultisigRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _data = $v.data;
      _partialMultisig = $v.partialMultisig?.toBuilder();
      _publicKey = $v.publicKey?.toBuilder();
      _walletHandleToken = $v.walletHandleToken;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignProgramMultisigRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SignProgramMultisigRequest;
  }

  @override
  void update(void Function(SignProgramMultisigRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SignProgramMultisigRequest build() {
    _$SignProgramMultisigRequest _$result;
    try {
      _$result = _$v ??
          new _$SignProgramMultisigRequest._(
              address: address,
              data: data,
              partialMultisig: _partialMultisig?.build(),
              publicKey: _publicKey?.build(),
              walletHandleToken: walletHandleToken,
              walletPassword: walletPassword);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'partialMultisig';
        _partialMultisig?.build();
        _$failedField = 'publicKey';
        _publicKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'SignProgramMultisigRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
