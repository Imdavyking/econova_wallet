// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_multisig_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignMultisigRequest extends SignMultisigRequest {
  @override
  final MultisigSig? partialMultisig;
  @override
  final BuiltList<int>? publicKey;
  @override
  final BuiltList<int>? signer;
  @override
  final String? transaction;
  @override
  final String? walletHandleToken;
  @override
  final String? walletPassword;

  factory _$SignMultisigRequest(
          [void Function(SignMultisigRequestBuilder)? updates]) =>
      (new SignMultisigRequestBuilder()..update(updates)).build();

  _$SignMultisigRequest._(
      {this.partialMultisig,
      this.publicKey,
      this.signer,
      this.transaction,
      this.walletHandleToken,
      this.walletPassword})
      : super._();

  @override
  SignMultisigRequest rebuild(
          void Function(SignMultisigRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignMultisigRequestBuilder toBuilder() =>
      new SignMultisigRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignMultisigRequest &&
        partialMultisig == other.partialMultisig &&
        publicKey == other.publicKey &&
        signer == other.signer &&
        transaction == other.transaction &&
        walletHandleToken == other.walletHandleToken &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, partialMultisig.hashCode), publicKey.hashCode),
                    signer.hashCode),
                transaction.hashCode),
            walletHandleToken.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SignMultisigRequest')
          ..add('partialMultisig', partialMultisig)
          ..add('publicKey', publicKey)
          ..add('signer', signer)
          ..add('transaction', transaction)
          ..add('walletHandleToken', walletHandleToken)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class SignMultisigRequestBuilder
    implements Builder<SignMultisigRequest, SignMultisigRequestBuilder> {
  _$SignMultisigRequest? _$v;

  MultisigSigBuilder? _partialMultisig;
  MultisigSigBuilder get partialMultisig =>
      _$this._partialMultisig ??= new MultisigSigBuilder();
  set partialMultisig(MultisigSigBuilder? partialMultisig) =>
      _$this._partialMultisig = partialMultisig;

  ListBuilder<int>? _publicKey;
  ListBuilder<int> get publicKey =>
      _$this._publicKey ??= new ListBuilder<int>();
  set publicKey(ListBuilder<int>? publicKey) => _$this._publicKey = publicKey;

  ListBuilder<int>? _signer;
  ListBuilder<int> get signer => _$this._signer ??= new ListBuilder<int>();
  set signer(ListBuilder<int>? signer) => _$this._signer = signer;

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

  SignMultisigRequestBuilder() {
    SignMultisigRequest._initializeBuilder(this);
  }

  SignMultisigRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _partialMultisig = $v.partialMultisig?.toBuilder();
      _publicKey = $v.publicKey?.toBuilder();
      _signer = $v.signer?.toBuilder();
      _transaction = $v.transaction;
      _walletHandleToken = $v.walletHandleToken;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignMultisigRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SignMultisigRequest;
  }

  @override
  void update(void Function(SignMultisigRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SignMultisigRequest build() {
    _$SignMultisigRequest _$result;
    try {
      _$result = _$v ??
          new _$SignMultisigRequest._(
              partialMultisig: _partialMultisig?.build(),
              publicKey: _publicKey?.build(),
              signer: _signer?.build(),
              transaction: transaction,
              walletHandleToken: walletHandleToken,
              walletPassword: walletPassword);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'partialMultisig';
        _partialMultisig?.build();
        _$failedField = 'publicKey';
        _publicKey?.build();
        _$failedField = 'signer';
        _signer?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'SignMultisigRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
