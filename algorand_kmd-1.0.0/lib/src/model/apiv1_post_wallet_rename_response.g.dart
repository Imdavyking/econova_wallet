// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apiv1_post_wallet_rename_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$APIV1POSTWalletRenameResponse extends APIV1POSTWalletRenameResponse {
  @override
  final bool? error;
  @override
  final String? message;
  @override
  final APIV1Wallet? wallet;

  factory _$APIV1POSTWalletRenameResponse(
          [void Function(APIV1POSTWalletRenameResponseBuilder)? updates]) =>
      (new APIV1POSTWalletRenameResponseBuilder()..update(updates)).build();

  _$APIV1POSTWalletRenameResponse._({this.error, this.message, this.wallet})
      : super._();

  @override
  APIV1POSTWalletRenameResponse rebuild(
          void Function(APIV1POSTWalletRenameResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  APIV1POSTWalletRenameResponseBuilder toBuilder() =>
      new APIV1POSTWalletRenameResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is APIV1POSTWalletRenameResponse &&
        error == other.error &&
        message == other.message &&
        wallet == other.wallet;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, error.hashCode), message.hashCode), wallet.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('APIV1POSTWalletRenameResponse')
          ..add('error', error)
          ..add('message', message)
          ..add('wallet', wallet))
        .toString();
  }
}

class APIV1POSTWalletRenameResponseBuilder
    implements
        Builder<APIV1POSTWalletRenameResponse,
            APIV1POSTWalletRenameResponseBuilder> {
  _$APIV1POSTWalletRenameResponse? _$v;

  bool? _error;
  bool? get error => _$this._error;
  set error(bool? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  APIV1WalletBuilder? _wallet;
  APIV1WalletBuilder get wallet => _$this._wallet ??= new APIV1WalletBuilder();
  set wallet(APIV1WalletBuilder? wallet) => _$this._wallet = wallet;

  APIV1POSTWalletRenameResponseBuilder() {
    APIV1POSTWalletRenameResponse._initializeBuilder(this);
  }

  APIV1POSTWalletRenameResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _wallet = $v.wallet?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(APIV1POSTWalletRenameResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$APIV1POSTWalletRenameResponse;
  }

  @override
  void update(void Function(APIV1POSTWalletRenameResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$APIV1POSTWalletRenameResponse build() {
    _$APIV1POSTWalletRenameResponse _$result;
    try {
      _$result = _$v ??
          new _$APIV1POSTWalletRenameResponse._(
              error: error, message: message, wallet: _wallet?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'wallet';
        _wallet?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'APIV1POSTWalletRenameResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
