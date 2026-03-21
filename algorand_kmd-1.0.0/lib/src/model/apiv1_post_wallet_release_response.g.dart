// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_wallet_release_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTWalletReleaseResponse extends APIV1POSTWalletReleaseResponse {
  @override
  final bool? error;
  @override
  final String? message;

  factory _$APIV1POSTWalletReleaseResponse(
          [void Function(APIV1POSTWalletReleaseResponseBuilder)? updates]) =>
      (new APIV1POSTWalletReleaseResponseBuilder()..update(updates)).build();

  _$APIV1POSTWalletReleaseResponse._({this.error, this.message}) : super._();

  @override
  APIV1POSTWalletReleaseResponse rebuild(
          void Function(APIV1POSTWalletReleaseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTWalletReleaseResponseBuilder toBuilder() =>
      new APIV1POSTWalletReleaseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTWalletReleaseResponse &&
        error == other.error &&
        message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, error.hashCode), message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTWalletReleaseResponse')
          ..add('error', error)
          ..add('message', message))
        .toString();
  }
}

class APIV1POSTWalletReleaseResponseBuilder
    implements
        Builder<APIV1POSTWalletReleaseResponse,
            APIV1POSTWalletReleaseResponseBuilder> {
  _$APIV1POSTWalletReleaseResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  APIV1POSTWalletReleaseResponseBuilder() {
    APIV1POSTWalletReleaseResponse._initializeBuilder(this);
  }

  APIV1POSTWalletReleaseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTWalletReleaseResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTWalletReleaseResponse;
  }

  @override
  void update(void Function(APIV1POSTWalletReleaseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTWalletReleaseResponse build() {
    final _$result = _$v ??
        new _$APIV1POSTWalletReleaseResponse._(error: error, message: message);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
