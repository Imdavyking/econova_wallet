// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_transaction_sign_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTTransactionSignResponse
    extends APIV1POSTTransactionSignResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final String? signedTransaction;

  factory _$APIV1POSTTransactionSignResponse(
          [void Function(APIV1POSTTransactionSignResponseBuilder)? updates]) =>
      (new APIV1POSTTransactionSignResponseBuilder()..update(updates)).build();

  _$APIV1POSTTransactionSignResponse._(
      {this.error, this.message, this.signedTransaction})
      : super._();

  @override
  APIV1POSTTransactionSignResponse rebuild(
          void Function(APIV1POSTTransactionSignResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTTransactionSignResponseBuilder toBuilder() =>
      new APIV1POSTTransactionSignResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTTransactionSignResponse &&
        error == other.error &&
        message == other.message &&
        signedTransaction == other.signedTransaction;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, error.hashCode), message.hashCode),
        signedTransaction.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTTransactionSignResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('signedTransaction', signedTransaction))
        .toString();
  }
}

class APIV1POSTTransactionSignResponseBuilder
    implements
        Builder<APIV1POSTTransactionSignResponse,
            APIV1POSTTransactionSignResponseBuilder> {
  _$APIV1POSTTransactionSignResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  String? _signedTransaction;
  String? get signedTransaction => _$this._signedTransaction;
  set signedTransaction(String? signedTransaction) =>
      _$this._signedTransaction = signedTransaction;

  APIV1POSTTransactionSignResponseBuilder() {
    APIV1POSTTransactionSignResponse._initializeBuilder(this);
  }

  APIV1POSTTransactionSignResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _signedTransaction = $v.signedTransaction;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTTransactionSignResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTTransactionSignResponse;
  }

  @override
  void update(void Function(APIV1POSTTransactionSignResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTTransactionSignResponse build() {
    final _$result = _$v ??
        new _$APIV1POSTTransactionSignResponse._(
            error: error,
            message: message,
            signedTransaction: signedTransaction);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
