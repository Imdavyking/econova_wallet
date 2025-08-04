import 'dart:convert';

import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';

const _mnemonicListKey = 'mnemonics_List';
const _currentMnemonicKey = 'mmemomic_mnemonic';
const _viewListKey = 'view_List';
const _currentViewKey = 'view_current';
const _privateListKey = 'privateKey_List';
const _currentPrivateKey = 'privateKey_current';
const _coinTypeIndexKey = 'coinType---mnemonic--privateKey--view';

abstract class WalletParams {
  final String data;
  final String? defaultCoin;
  final String? coinName;
  String name;
  WalletParams({
    required this.data,
    this.defaultCoin,
    this.coinName,
    required this.name,
  });
  Map<String, dynamic> toJson();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalletParams) return false;

    if (other is SeedPhraseParams) {
      return data == other.data && name == other.name;
    }

    return data == other.data &&
        defaultCoin == other.defaultCoin &&
        coinName == other.coinName;
  }

  @override
  int get hashCode => super.hashCode + 0;
}

class PrivateKeyParams extends WalletParams {
  PrivateKeyParams({
    required super.data,
    super.defaultCoin,
    required super.name,
    super.coinName,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'privateKey': data,
      'default': defaultCoin,
      'name': name,
      'coinName': coinName,
    };
  }

  factory PrivateKeyParams.fromJson(Map<String, dynamic> json) {
    return PrivateKeyParams(
      data: json['privateKey'],
      defaultCoin: json['default'],
      name: json['name'],
      coinName: json['coinName'],
    );
  }
}

class SeedPhraseParams extends WalletParams {
  SeedPhraseParams({required super.data, required super.name})
      : super(
          defaultCoin: null,
          coinName: null,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'phrase': data,
      'name': name,
    };
  }

  factory SeedPhraseParams.fromJson(Map<String, dynamic> json) {
    return SeedPhraseParams(
      data: json['phrase'],
      name: json['name'],
    );
  }
}

class ViewKeyParams extends WalletParams {
  ViewKeyParams({
    required super.data,
    super.defaultCoin,
    required super.name,
    super.coinName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'address': data,
      'default': defaultCoin,
      'name': name,
      'coinName': coinName,
    };
  }

  factory ViewKeyParams.fromJson(Map<String, dynamic> json) {
    return ViewKeyParams(
      data: json['address'],
      defaultCoin: json['default'],
      name: json['name'],
      coinName: json['coinName'],
    );
  }
}

class WalletService {
  static String _getCurrentKeyPref(WalletType type) {
    switch (type) {
      case WalletType.secretPhrase:
        return _currentMnemonicKey;
      case WalletType.privateKey:
        return _currentPrivateKey;
      case WalletType.viewKey:
        return _currentViewKey;
    }
  }

  static String _getListKeyPref(WalletType type) {
    switch (type) {
      case WalletType.secretPhrase:
        return _mnemonicListKey;
      case WalletType.privateKey:
        return _privateListKey;
      case WalletType.viewKey:
        return _viewListKey;
    }
  }

  static WalletParams? getActiveKey(WalletType type) {
    final data = pref.get(_getCurrentKeyPref(type));
    if (data == null) return null;
    switch (type) {
      case WalletType.secretPhrase:
        return SeedPhraseParams.fromJson(json.decode(data));
      case WalletType.privateKey:
        return PrivateKeyParams.fromJson(json.decode(data));
      case WalletType.viewKey:
        return ViewKeyParams.fromJson(json.decode(data));
    }
  }

  static bool removeCoin(Coin coin) {
    final isSingleWallet =
        WalletService.isViewKey() || WalletService.isPrivateKey();

    WalletParams? walletParams = WalletService.getActiveKey(walletImportType);
    if (isSingleWallet) {
      if (walletParams == null) return true;
      // final isSameName = coin.name_() == walletParams.coinName;
      final isSameDefaultCoin = coin.getDefault() == walletParams.defaultCoin;
      bool isCurrent = isSameDefaultCoin;
      if (!isCurrent) return true;
    }
    return false;
  }

  static Future<void> setActiveKey(
    WalletType type,
    WalletParams currentKey,
  ) async {
    bool isValidType = false;
    switch (type) {
      case WalletType.secretPhrase:
        isValidType = currentKey is SeedPhraseParams;
        break;
      case WalletType.privateKey:
        isValidType = currentKey is PrivateKeyParams;
        break;
      case WalletType.viewKey:
        isValidType = currentKey is ViewKeyParams;
        break;
    }
    if (!isValidType) {
      throw Exception('Invalid data type for the specified wallet type');
    }

    String data = jsonEncode(currentKey.toJson());
    await pref.put(_getCurrentKeyPref(type), data);
    await setType(type);
    // try to decode the data
    final previousList = getActiveKeys(type);
    final selection =
        previousList.firstWhereOrNull((element) => element == currentKey);

    if (selection == null) previousList.add(currentKey);

    await _setActiveKeys(type, previousList);
  }

  static List<WalletParams?> getActiveKeys(WalletType type) {
    String jsonList = pref.get(_getListKeyPref(type)) ?? '[]';
    List<dynamic> jsonData = json.decode(jsonList);

    switch (type) {
      case WalletType.secretPhrase:
        return jsonData.map((item) => SeedPhraseParams.fromJson(item)).toList();
      case WalletType.privateKey:
        return jsonData.map((item) => PrivateKeyParams.fromJson(item)).toList();
      case WalletType.viewKey:
        return jsonData.map((item) => ViewKeyParams.fromJson(item)).toList();
    }
  }

  static Future<void> _setActiveKeys(
    WalletType type,
    List<WalletParams?> keysList,
  ) async {
    String jsonList = jsonEncode(keysList);
    await pref.put(_getListKeyPref(type), jsonList);
  }

  static Future<void> setType(WalletType type) async {
    await pref.put(_coinTypeIndexKey, type.index);
    walletImportType = type;
  }

  static bool isPharseKey() {
    return walletImportType == WalletType.secretPhrase;
  }

  static bool isPrivateKey() {
    return walletImportType == WalletType.privateKey;
  }

  static bool isViewKey() {
    return walletImportType == WalletType.viewKey;
  }

  static WalletType getType() {
    final index = pref.get(_coinTypeIndexKey) ?? 0;
    return WalletType.values[index];
  }

  static Future<void> deleteData(
    WalletType type,
    WalletParams anyKey,
  ) async {
    final previousList = getActiveKeys(type);
    previousList.removeWhere((element) => element == anyKey);

    await _setActiveKeys(type, previousList);
  }

  static Future<void> editName(
    WalletType type,
    WalletParams anyKey,
    String newUserName,
  ) async {
    final previousList = getActiveKeys(type);
    for (var key in previousList) {
      if (key == anyKey) {
        key!.name = newUserName;
        break;
      }
    }
    await _setActiveKeys(type, previousList);
  }
}
