// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_multisig_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportMultisigRequest extends ImportMultisigRequest {
  @override
  final int? multisigVersion;
  @override
  final BuiltList<BuiltList<int>>? pks;
  @override
  final int? threshold;
  @override
  final String? walletHandleToken;

  factory _$ImportMultisigRequest(
          [void Function(ImportMultisigRequestBuilder)? updates]) =>
      (new ImportMultisigRequestBuilder()..update(updates)).build();

  _$ImportMultisigRequest._(
      {this.multisigVersion, this.pks, this.threshold, this.walletHandleToken})
      : super._();

  @override
  ImportMultisigRequest rebuild(
          void Function(ImportMultisigRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportMultisigRequestBuilder toBuilder() =>
      new ImportMultisigRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportMultisigRequest &&
        multisigVersion == other.multisigVersion &&
        pks == other.pks &&
        threshold == other.threshold &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, multisigVersion.hashCode), pks.hashCode),
            threshold.hashCode),
        walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ImportMultisigRequest')
          ..add('multisigVersion', multisigVersion)
          ..add('pks', pks)
          ..add('threshold', threshold)
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class ImportMultisigRequestBuilder
    implements Builder<ImportMultisigRequest, ImportMultisigRequestBuilder> {
  _$ImportMultisigRequest? _$v;

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

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  ImportMultisigRequestBuilder() {
    ImportMultisigRequest._initializeBuilder(this);
  }

  ImportMultisigRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _multisigVersion = $v.multisigVersion;
      _pks = $v.pks?.toBuilder();
      _threshold = $v.threshold;
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportMultisigRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ImportMultisigRequest;
  }

  @override
  void update(void Function(ImportMultisigRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ImportMultisigRequest build() {
    _$ImportMultisigRequest _$result;
    try {
      _$result = _$v ??
          new _$ImportMultisigRequest._(
              multisigVersion: multisigVersion,
              pks: _pks?.build(),
              threshold: threshold,
              walletHandleToken: walletHandleToken);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pks';
        _pks?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ImportMultisigRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
