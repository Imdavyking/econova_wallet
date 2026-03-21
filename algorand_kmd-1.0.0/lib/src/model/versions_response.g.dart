// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'versions_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VersionsResponse extends VersionsResponse {
  @override
  final BuiltList<String>? versions;

  factory _$VersionsResponse(
          [void Function(VersionsResponseBuilder)? updates]) =>
      (new VersionsResponseBuilder()..update(updates)).build();

  _$VersionsResponse._({this.versions}) : super._();

  @override
  VersionsResponse rebuild(void Function(VersionsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VersionsResponseBuilder toBuilder() =>
      new VersionsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VersionsResponse && versions == other.versions;
  }

  @override
  int get hashCode {
    return $jf($jc(0, versions.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('VersionsResponse')
          ..add('versions', versions))
        .toString();
  }
}

class VersionsResponseBuilder
    implements Builder<VersionsResponse, VersionsResponseBuilder> {
  _$VersionsResponse? _$v;

  ListBuilder<String>? _versions;
  ListBuilder<String> get versions =>
      _$this._versions ??= new ListBuilder<String>();
  set versions(ListBuilder<String>? versions) => _$this._versions = versions;

  VersionsResponseBuilder() {
    VersionsResponse._initializeBuilder(this);
  }

  VersionsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _versions = $v.versions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VersionsResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$VersionsResponse;
  }

  @override
  void update(void Function(VersionsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$VersionsResponse build() {
    _$VersionsResponse _$result;
    try {
      _$result = _$v ?? new _$VersionsResponse._(versions: _versions?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'versions';
        _versions?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'VersionsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
