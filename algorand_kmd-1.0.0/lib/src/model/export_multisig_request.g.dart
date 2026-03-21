// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_multisig_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportMultisigRequest extends ExportMultisigRequest {
  @override
  final String? address;
  @override
  final String? walletHandleToken;

  factory _$ExportMultisigRequest(
          [void Function(ExportMultisigRequestBuilder)? updates]) =>
      (new ExportMultisigRequestBuilder()..update(updates)).build();

  _$ExportMultisigRequest._({this.address, this.walletHandleToken}) : super._();

  @override
  ExportMultisigRequest rebuild(
          void Function(ExportMultisigRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportMultisigRequestBuilder toBuilder() =>
      new ExportMultisigRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportMultisigRequest &&
        address == other.address &&
        walletHandleToken == other.walletHandleToken;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, address.hashCode), walletHandleToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ExportMultisigRequest')
          ..add('address', address)
          ..add('walletHandleToken', walletHandleToken))
        .toString();
  }
}

class ExportMultisigRequestBuilder
    implements Builder<ExportMultisigRequest, ExportMultisigRequestBuilder> {
  _$ExportMultisigRequest? _$v;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _walletHandleToken;
  String? get walletHandleToken => _$this._walletHandleToken;
  set walletHandleToken(String? walletHandleToken) =>
      _$this._walletHandleToken = walletHandleToken;

  ExportMultisigRequestBuilder() {
    ExportMultisigRequest._initializeBuilder(this);
  }

  ExportMultisigRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address;
      _walletHandleToken = $v.walletHandleToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportMultisigRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ExportMultisigRequest;
  }

  @override
  void update(void Function(ExportMultisigRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ExportMultisigRequest build() {
    final _$result = _$v ??
        new _$ExportMultisigRequest._(
            address: address, walletHandleToken: walletHandleToken);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
