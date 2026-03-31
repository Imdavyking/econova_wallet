// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_multisig_export_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTMultisigExportResponse
    extends APIV1POSTMultisigExportResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final int? multisigVersion;
  @override
  final BuiltList<BuiltList<int>>? pks;
  @override
  final int? threshold;

  factory _$APIV1POSTMultisigExportResponse(
          [void Function(APIV1POSTMultisigExportResponseBuilder)? updates]) =>
      (new APIV1POSTMultisigExportResponseBuilder()..update(updates)).build();

  _$APIV1POSTMultisigExportResponse._(
      {this.error,
      this.message,
      this.multisigVersion,
      this.pks,
      this.threshold})
      : super._();

  @override
  APIV1POSTMultisigExportResponse rebuild(
          void Function(APIV1POSTMultisigExportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTMultisigExportResponseBuilder toBuilder() =>
      new APIV1POSTMultisigExportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTMultisigExportResponse &&
        error == other.error &&
        message == other.message &&
        multisigVersion == other.multisigVersion &&
        pks == other.pks &&
        threshold == other.threshold;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, error.hashCode), message.hashCode),
                multisigVersion.hashCode),
            pks.hashCode),
        threshold.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTMultisigExportResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('multisigVersion', multisigVersion)
          ..add('pks', pks)
          ..add('threshold', threshold))
        .toString();
  }
}

class APIV1POSTMultisigExportResponseBuilder
    implements
        Builder<APIV1POSTMultisigExportResponse,
            APIV1POSTMultisigExportResponseBuilder> {
  _$APIV1POSTMultisigExportResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  int? _multisigVersion;
  int? get multisigVersion => _$this._multisigVersion;
  set multisigVersion(int? multisigVersion) =>
      _$this._multisigVersion = multisigVersion;

  ListBuilder<BuiltList<int>>? _pks;
  ListBuilder<BuiltList<int>> get pks =>
      _$this._pks ??= new ListBuilder<BuiltList<int>>();
  set pks(ListBuilder<BuiltList<int>>? pks) => _$this._pks = pks;

  int? _threshold;
  int? get threshold => _$this._threshold;
  set threshold(int? threshold) => _$this._threshold = threshold;

  APIV1POSTMultisigExportResponseBuilder() {
    APIV1POSTMultisigExportResponse._initializeBuilder(this);
  }

  APIV1POSTMultisigExportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _multisigVersion = $v.multisigVersion;
      _pks = $v.pks?.toBuilder();
      _threshold = $v.threshold;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTMultisigExportResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTMultisigExportResponse;
  }

  @override
  void update(void Function(APIV1POSTMultisigExportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTMultisigExportResponse build() {
    _$APIV1POSTMultisigExportResponse _$result;
    try {
      _$result = _$v ??
          new _$APIV1POSTMultisigExportResponse._(
              error: error,
              message: message,
              multisigVersion: multisigVersion,
              pks: _pks?.build(),
              threshold: threshold);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pks';
        _pks?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1POSTMultisigExportResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
