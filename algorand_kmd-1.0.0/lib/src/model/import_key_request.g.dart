// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_key_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportKeyRequest extends ImportKeyRequest {
  @override
  final BuiltList<int>? privateKey;
  @override
  final String? walletHandleToken;

  factory _$ImportKeyRequest(
          [void Function(ImportKeyRequestBuilder)? updates]) =>
      (new ImportKeyRequestBuilder()..update(updates)).build();

  _$ImportKeyRequest._({this.privateKey, this.walletHandleToken}) : super._();

  @override
  ImportKeyRequest rebuild(void Function(ImportKeyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportKeyRequestBuilder toBuilder() =>
      new ImportKeyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportKeyRequest &&
        privateKey == other.privateKey &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, privateKey.hashCode), walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ImportKeyRequest')
          ..add('privateKey', privateKey)
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class ImportKeyRequestBuilder
    implements Builder<ImportKeyRequest, ImportKeyRequestBuilder> {
  _$ImportKeyRequest? _$v;

  ListBuilder<int>? _privateKey;
  ListBuilder<int> get privateKey =>
      _$this._privateKey ??= new ListBuilder<int>();
  set privateKey(ListBuilder<int>? privateKey) =>
      _$this._privateKey = privateKey;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  ImportKeyRequestBuilder() {
    ImportKeyRequest._initializeBuilder(this);
  }

  ImportKeyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _privateKey = $v.privateKey?.toBuilder();
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportKeyRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ImportKeyRequest;
  }

  @override
  void update(void Function(ImportKeyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ImportKeyRequest build() {
    _$ImportKeyRequest _$result;
    try {
      _$result = _$v ??
          new _$ImportKeyRequest._(
              privateKey: _privateKey?.build(),
              walletHandleToken: walletHandleToken);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'privateKey';
        _privateKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ImportKeyRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
