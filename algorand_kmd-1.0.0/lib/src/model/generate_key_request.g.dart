// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_key_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GenerateKeyRequest extends GenerateKeyRequest {
  @override
  final bool? displayMnemonic;
  @override
  final String? walletHandleToken;

  factory _$GenerateKeyRequest(
          [void Function(GenerateKeyRequestBuilder)? updates]) =>
      (new GenerateKeyRequestBuilder()..update(updates)).build();

  _$GenerateKeyRequest._({this.displayMnemonic, this.walletHandleToken})
      : super._();

  @override
  GenerateKeyRequest rebuild(
          void Function(GenerateKeyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GenerateKeyRequestBuilder toBuilder() =>
      new GenerateKeyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GenerateKeyRequest &&
        displayMnemonic == other.displayMnemonic &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc(0, displayMnemonic.hashCode), walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('GenerateKeyRequest')
          ..add('displayMnemonic', displayMnemonic)
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class GenerateKeyRequestBuilder
    implements Builder<GenerateKeyRequest, GenerateKeyRequestBuilder> {
  _$GenerateKeyRequest? _$v;

  bool? _displayMnemonic;
  bool? get displayMnemonic => _$this._displayMnemonic;
  set displayMnemonic(bool? displayMnemonic) =>
      _$this._displayMnemonic = displayMnemonic;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  GenerateKeyRequestBuilder() {
    GenerateKeyRequest._initializeBuilder(this);
  }

  GenerateKeyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayMnemonic = $v.displayMnemonic;
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GenerateKeyRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GenerateKeyRequest;
  }

  @override
  void update(void Function(GenerateKeyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$GenerateKeyRequest build() {
    final _$result = _$v ??
        new _$GenerateKeyRequest._(
            displayMnemonic: displayMnemonic,
            walletHandleToken: walletHandleToken);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
