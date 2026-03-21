// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_key_export_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTKeyExportResponse extends APIV1POSTKeyExportResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final BuiltList<int>? privateKey;

  factory _$APIV1POSTKeyExportResponse(
          [void Function(APIV1POSTKeyExportResponseBuilder)? updates]) =>
      (new APIV1POSTKeyExportResponseBuilder()..update(updates)).build();

  _$APIV1POSTKeyExportResponse._({this.error, this.message, this.privateKey})
      : super._();

  @override
  APIV1POSTKeyExportResponse rebuild(
          void Function(APIV1POSTKeyExportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTKeyExportResponseBuilder toBuilder() =>
      new APIV1POSTKeyExportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTKeyExportResponse &&
        error == other.error &&
        message == other.message &&
        privateKey == other.privateKey;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(0, error.hashCode), message.hashCode), privateKey.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTKeyExportResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('privateKey', privateKey))
        .toString();
  }
}

class APIV1POSTKeyExportResponseBuilder
    implements
        Builder<APIV1POSTKeyExportResponse, APIV1POSTKeyExportResponseBuilder> {
  _$APIV1POSTKeyExportResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ListBuilder<int>? _privateKey;
  ListBuilder<int> get privateKey =>
      _$this._privateKey ??= new ListBuilder<int>();
  set privateKey(ListBuilder<int>? privateKey) =>
      _$this._privateKey = privateKey;

  APIV1POSTKeyExportResponseBuilder() {
    APIV1POSTKeyExportResponse._initializeBuilder(this);
  }

  APIV1POSTKeyExportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _privateKey = $v.privateKey?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTKeyExportResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTKeyExportResponse;
  }

  @override
  void update(void Function(APIV1POSTKeyExportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTKeyExportResponse build() {
    _$APIV1POSTKeyExportResponse _$result;
    try {
      _$result = _$v ??
          new _$APIV1POSTKeyExportResponse._(
              error: error, message: message, privateKey: _privateKey?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'privateKey';
        _privateKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1POSTKeyExportResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
