// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_delete_key_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1DELETEKeyResponse extends APIV1DELETEKeyResponse {
  @override
  final bool? error;
  @override
  final String? message;

  factory _$APIV1DELETEKeyResponse(
          [void Function(APIV1DELETEKeyResponseBuilder)? updates]) =>
      (new APIV1DELETEKeyResponseBuilder()..update(updates)).build();

  _$APIV1DELETEKeyResponse._({this.error, this.message}) : super._();

  @override
  APIV1DELETEKeyResponse rebuild(
          void Function(APIV1DELETEKeyResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1DELETEKeyResponseBuilder toBuilder() =>
      new APIV1DELETEKeyResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1DELETEKeyResponse &&
        error == other.error &&
        message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, error.hashCode), message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1DELETEKeyResponse')
          ..add('error', error)
          ..add('message', message))
        .toString();
  }
}

class APIV1DELETEKeyResponseBuilder
    implements Builder<APIV1DELETEKeyResponse, APIV1DELETEKeyResponseBuilder> {
  _$APIV1DELETEKeyResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  APIV1DELETEKeyResponseBuilder() {
    APIV1DELETEKeyResponse._initializeBuilder(this);
  }

  APIV1DELETEKeyResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1DELETEKeyResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1DELETEKeyResponse;
  }

  @override
  void update(void Function(APIV1DELETEKeyResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1DELETEKeyResponse build() {
    final _$result =
        _$v ?? new _$APIV1DELETEKeyResponse._(error: error, message: message);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
