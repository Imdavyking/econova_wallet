// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_master_key_export_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTMasterKeyExportResponse
    extends APIV1POSTMasterKeyExportResponse {
  @override
  final bool? error;
  @override
  final BuiltList<int>? masterDerivationKey;
  @override
  final String? message;

  factory _$APIV1POSTMasterKeyExportResponse(
          [void Function(APIV1POSTMasterKeyExportResponseBuilder)? updates]) =>
      (new APIV1POSTMasterKeyExportResponseBuilder()..update(updates)).build();

  _$APIV1POSTMasterKeyExportResponse._(
      {this.error, this.masterDerivationKey, this.message})
      : super._();

  @override
  APIV1POSTMasterKeyExportResponse rebuild(
          void Function(APIV1POSTMasterKeyExportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTMasterKeyExportResponseBuilder toBuilder() =>
      new APIV1POSTMasterKeyExportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTMasterKeyExportResponse &&
        error == other.error &&
        masterDerivationKey == other.masterDerivationKey &&
        message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, error.hashCode), masterDerivationKey.hashCode),
        message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTMasterKeyExportResponse')
          ..add('error', error)
          ..add('masterDerivationKey', masterDerivationKey)
          ..add('message', message))
        .toString();
  }
}

class APIV1POSTMasterKeyExportResponseBuilder
    implements
        Builder<APIV1POSTMasterKeyExportResponse,
            APIV1POSTMasterKeyExportResponseBuilder> {
  _$APIV1POSTMasterKeyExportResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  ListBuilder<int>? _masterDerivationKey;
  ListBuilder<int> get masterDerivationKey =>
      _$this._masterDerivationKey ??= new ListBuilder<int>();
  set masterDerivationKey(ListBuilder<int>? masterDerivationKey) =>
      _$this._masterDerivationKey = masterDerivationKey;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  APIV1POSTMasterKeyExportResponseBuilder() {
    APIV1POSTMasterKeyExportResponse._initializeBuilder(this);
  }

  APIV1POSTMasterKeyExportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _masterDerivationKey = $v.masterDerivationKey?.toBuilder();
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTMasterKeyExportResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTMasterKeyExportResponse;
  }

  @override
  void update(void Function(APIV1POSTMasterKeyExportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTMasterKeyExportResponse build() {
    _$APIV1POSTMasterKeyExportResponse _$result;
    try {
      _$result = _$v ??
          new _$APIV1POSTMasterKeyExportResponse._(
              error: error,
              masterDerivationKey: _masterDerivationKey?.build(),
              message: message);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'masterDerivationKey';
        _masterDerivationKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1POSTMasterKeyExportResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
