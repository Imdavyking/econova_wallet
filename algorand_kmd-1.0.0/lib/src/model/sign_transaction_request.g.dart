// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_transaction_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignTransactionRequest extends SignTransactionRequest {
  @override
  final BuiltList<int>? publicKey;
  @override
  final String? transaction;
  @override
  final String? walletHandleToken;
  @override
  final String? walletPassword;

  factory _$SignTransactionRequest(
          [void Function(SignTransactionRequestBuilder)? updates]) =>
      (new SignTransactionRequestBuilder()..update(updates)).build();

  _$SignTransactionRequest._(
      {this.publicKey,
      this.transaction,
      this.walletHandleToken,
      this.walletPassword})
      : super._();

  @override
  SignTransactionRequest rebuild(
          void Function(SignTransactionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignTransactionRequestBuilder toBuilder() =>
      new SignTransactionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignTransactionRequest &&
        publicKey == other.publicKey &&
        transaction == other.transaction &&
        walletHandleToken == other.walletHandleToken &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, publicKey.hashCode), transaction.hashCode),
            walletHandleToken.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SignTransactionRequest')
          ..add('publicKey', publicKey)
          ..add('transaction', transaction)
          ..add('walletHandleToken', walletHandleToken)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class SignTransactionRequestBuilder
    implements Builder<SignTransactionRequest, SignTransactionRequestBuilder> {
  _$SignTransactionRequest? _$v;

  ListBuilder<int>? _publicKey;
  ListBuilder<int> get publicKey =>
      _$this._publicKey ??= new ListBuilder<int>();
  set publicKey(ListBuilder<int>? publicKey) => _$this._publicKey = publicKey;

  String? _transaction;
  String? get transaction => _$this._transaction;
  set transaction(String? transaction) => _$this._transaction = transaction;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  SignTransactionRequestBuilder() {
    SignTransactionRequest._initializeBuilder(this);
  }

  SignTransactionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publicKey = $v.publicKey?.toBuilder();
      _transaction = $v.transaction;
      _walletHandleToken = $v.walletHandleToken;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignTransactionRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SignTransactionRequest;
  }

  @override
  void update(void Function(SignTransactionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SignTransactionRequest build() {
    _$SignTransactionRequest _$result;
    try {
      _$result = _$v ??
          new _$SignTransactionRequest._(
              publicKey: _publicKey?.build(),
              transaction: transaction,
              walletHandleToken: walletHandleToken,
              walletPassword: walletPassword);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'publicKey';
        _publicKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'SignTransactionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
