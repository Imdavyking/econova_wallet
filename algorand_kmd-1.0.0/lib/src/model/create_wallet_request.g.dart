// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_wallet_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateWalletRequest extends CreateWalletRequest {
  @override
  final BuiltList<int>? masterDerivationKey;
  @override
  final String? walletDriverName;
  @override
  final String? walletName;
  @override
  final String? walletPassword;

  factory _$CreateWalletRequest(
          [void Function(CreateWalletRequestBuilder)? updates]) =>
      (new CreateWalletRequestBuilder()..update(updates)).build();

  _$CreateWalletRequest._(
      {this.masterDerivationKey,
      this.walletDriverName,
      this.walletName,
      this.walletPassword})
      : super._();

  @override
  CreateWalletRequest rebuild(
          void Function(CreateWalletRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateWalletRequestBuilder toBuilder() =>
      new CreateWalletRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateWalletRequest &&
        masterDerivationKey == other.masterDerivationKey &&
        walletDriverName == other.walletDriverName &&
        walletName == other.walletName &&
        walletPassword == other.walletPassword;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc(0, masterDerivationKey.hashCode),
                walletDriverName.hashCode),
            walletName.hashCode),
        walletPassword.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CreateWalletRequest')
          ..add('masterDerivationKey', masterDerivationKey)
          ..add('walletDriverName', walletDriverName)
          ..add('walletName', walletName)
          ..add('walletPassword', walletPassword))
        .toString();
  }
}

class CreateWalletRequestBuilder
    implements Builder<CreateWalletRequest, CreateWalletRequestBuilder> {
  _$CreateWalletRequest? _$v;

  ListBuilder<int>? _masterDerivationKey;
  ListBuilder<int> get masterDerivationKey =>
      _$this._masterDerivationKey ??= new ListBuilder<int>();
  set masterDerivationKey(ListBuilder<int>? masterDerivationKey) =>
      _$this._masterDerivationKey = masterDerivationKey;

  String? _walletDriverName;
  String? get walletDriverName => _$this._walletDriverName;
  set walletDriverName(String? walletDriverName) =>
      _$this._walletDriverName = walletDriverName;

  String? _walletName;
  String? get walletName => _$this._walletName;
  set walletName(String? walletName) => _$this._walletName = walletName;

  String? _walletPassword;
  String? get walletPassword => _$this._walletPassword;
  set walletPassword(String? walletPassword) =>
      _$this._walletPassword = walletPassword;

  CreateWalletRequestBuilder() {
    CreateWalletRequest._initializeBuilder(this);
  }

  CreateWalletRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _masterDerivationKey = $v.masterDerivationKey?.toBuilder();
      _walletDriverName = $v.walletDriverName;
      _walletName = $v.walletName;
      _walletPassword = $v.walletPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateWalletRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CreateWalletRequest;
  }

  @override
  void update(void Function(CreateWalletRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CreateWalletRequest build() {
    _$CreateWalletRequest _$result;
    try {
      _$result = _$v ??
          new _$CreateWalletRequest._(
              masterDerivationKey: _masterDerivationKey?.build(),
              walletDriverName: walletDriverName,
              walletName: walletName,
              walletPassword: walletPassword);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'masterDerivationKey';
        _masterDerivationKey?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'CreateWalletRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
