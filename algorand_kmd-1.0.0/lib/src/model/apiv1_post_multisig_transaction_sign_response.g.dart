// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_multisig_transaction_sign_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTMultisigTransactionSignResponse
    extends APIV1POSTMultisigTransactionSignResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final String? multisig;

  factory _$APIV1POSTMultisigTransactionSignResponse(
          [void Function(APIV1POSTMultisigTransactionSignResponseBuilder)?
              updates]) =>
      (new APIV1POSTMultisigTransactionSignResponseBuilder()..update(updates))
          .build();

  _$APIV1POSTMultisigTransactionSignResponse._(
      {this.error, this.message, this.multisig})
      : super._();

  @override
  APIV1POSTMultisigTransactionSignResponse rebuild(
          void Function(APIV1POSTMultisigTransactionSignResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTMultisigTransactionSignResponseBuilder toBuilder() =>
      new APIV1POSTMultisigTransactionSignResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTMultisigTransactionSignResponse &&
        error == other.error &&
        message == other.message &&
        multisig == other.multisig;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, error.hashCode), message.hashCode), multisig.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            'APIV1POSTMultisigTransactionSignResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('multisig', multisig))
        .toString();
  }
}

class APIV1POSTMultisigTransactionSignResponseBuilder
    implements
        Builder<APIV1POSTMultisigTransactionSignResponse,
            APIV1POSTMultisigTransactionSignResponseBuilder> {
  _$APIV1POSTMultisigTransactionSignResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  String? _multisig;
  String? get multisig => _$this._multisig;
  set multisig(String? multisig) => _$this._multisig = multisig;

  APIV1POSTMultisigTransactionSignResponseBuilder() {
    APIV1POSTMultisigTransactionSignResponse._initializeBuilder(this);
  }

  APIV1POSTMultisigTransactionSignResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _multisig = $v.multisig;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTMultisigTransactionSignResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTMultisigTransactionSignResponse;
  }

  @override
  void update(
      void Function(APIV1POSTMultisigTransactionSignResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTMultisigTransactionSignResponse build() {
    final _$result = _$v ??
        new _$APIV1POSTMultisigTransactionSignResponse._(
            error: error, message: message, multisig: multisig);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
