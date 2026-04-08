import 'dart:convert';
import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/bloom_filter.dart';

const _mnemonicListKey = 'mnemonics_List';
const _currentMnemonicKey = 'mmemomic_mnemonic';
const _viewListKey = 'view_List';
const _currentViewKey = 'view_current';
const _privateListKey = 'privateKey_List';
const _currentPrivateKey = 'privateKey_current';
const _coinTypeIndexKey = 'coinType---mnemonic--privateKey--view';

// ── Wallet params ─────────────────────────────────────────────────────────────

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
    if (other is BIP39PhraseOrSeedHEXParams) {
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
  Map<String, dynamic> toJson() => {
        'privateKey': data,
        'default': defaultCoin,
        'name': name,
        'coinName': coinName,
      };

  factory PrivateKeyParams.fromJson(Map<String, dynamic> json) =>
      PrivateKeyParams(
        data: json['privateKey'],
        defaultCoin: json['default'],
        name: json['name'],
        coinName: json['coinName'],
      );
}

class BIP39PhraseOrSeedHEXParams extends WalletParams {
  BIP39PhraseOrSeedHEXParams({required super.data, required super.name})
      : super(defaultCoin: null, coinName: null);

  @override
  Map<String, dynamic> toJson() => {'phrase': data, 'name': name};

  factory BIP39PhraseOrSeedHEXParams.fromJson(Map<String, dynamic> json) =>
      BIP39PhraseOrSeedHEXParams(data: json['phrase'], name: json['name']);
}

class ViewKeyParams extends WalletParams {
  ViewKeyParams({
    required super.data,
    super.defaultCoin,
    required super.name,
    super.coinName,
  });

  @override
  Map<String, dynamic> toJson() => {
        'address': data,
        'default': defaultCoin,
        'name': name,
        'coinName': coinName,
      };

  factory ViewKeyParams.fromJson(Map<String, dynamic> json) => ViewKeyParams(
        data: json['address'],
        defaultCoin: json['default'],
        name: json['name'],
        coinName: json['coinName'],
      );
}

// ── WalletService ─────────────────────────────────────────────────────────────

class WalletService {
  WalletService._();

  static String _getCurrentKeyPref(WalletType type) => switch (type) {
        WalletType.bip39PhraseOrSeedHex => _currentMnemonicKey,
        WalletType.privateKey => _currentPrivateKey,
        WalletType.viewKey => _currentViewKey,
      };

  static String _getListKeyPref(WalletType type) => switch (type) {
        WalletType.bip39PhraseOrSeedHex => _mnemonicListKey,
        WalletType.privateKey => _privateListKey,
        WalletType.viewKey => _viewListKey,
      };

  // ── Read ──────────────────────────────────────────────────────────────────

  static WalletParams? getActiveKey(WalletType type) {
    final data = pref.get(_getCurrentKeyPref(type));
    if (data == null) return null;
    return switch (type) {
      WalletType.bip39PhraseOrSeedHex =>
        BIP39PhraseOrSeedHEXParams.fromJson(json.decode(data)),
      WalletType.privateKey => PrivateKeyParams.fromJson(json.decode(data)),
      WalletType.viewKey => ViewKeyParams.fromJson(json.decode(data)),
    };
  }

  static List<WalletParams> getActiveKeys(WalletType type) {
    final jsonList = pref.get(_getListKeyPref(type)) ?? '[]';
    final jsonData = json.decode(jsonList) as List<dynamic>;
    return switch (type) {
      WalletType.bip39PhraseOrSeedHex =>
        jsonData.map((e) => BIP39PhraseOrSeedHEXParams.fromJson(e)).toList(),
      WalletType.privateKey =>
        jsonData.map((e) => PrivateKeyParams.fromJson(e)).toList(),
      WalletType.viewKey =>
        jsonData.map((e) => ViewKeyParams.fromJson(e)).toList(),
    };
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Sets the active key AND switches the wallet type in one atomic operation.
  /// Never call [setType] separately before this — it is already handled here.
  static Future<void> setActiveKey(
    WalletType type,
    WalletParams currentKey,
  ) async {
    _assertParamType(type, currentKey);

    await pref.put(_getCurrentKeyPref(type), jsonEncode(currentKey.toJson()));
    await _persistType(type);

    final list = getActiveKeys(type);
    final existing = list.firstWhereOrNull((e) => e == currentKey);
    if (existing == null) {
      list.add(currentKey);
      // Register only the new name — no full re-seed needed.
      WalletNameFilter.register(currentKey.name);
    }
    await _persistKeys(type, list);
  }

  static Future<void> deleteData(WalletType type, WalletParams key) async {
    final list = getActiveKeys(type)..removeWhere((e) => e == key);
    await _persistKeys(type, list);
    // After deletion the name might still appear in the bloom filter
    // (false positive), but doesNameExist() will catch it via linear scan.
    // Full re-seed is triggered lazily on next [doesNameExist] call if needed.
    WalletNameFilter.invalidate();
  }

  static Future<void> editName(
    WalletType type,
    WalletParams key,
    String newName,
  ) async {
    final list = getActiveKeys(type);
    for (final w in list) {
      if (w == key) {
        w.name = newName;
        break;
      }
    }
    await _persistKeys(type, list);
    WalletNameFilter.invalidate(); // old name may linger; force re-seed
  }

  // ── Type ──────────────────────────────────────────────────────────────────

  /// Only call this when you need to switch active type WITHOUT changing the
  /// active key (rare). Prefer [setActiveKey] which handles both.
  static Future<void> setType(WalletType type) => _persistType(type);

  static WalletType getType() {
    final index = pref.get(_coinTypeIndexKey) ?? 0;
    return WalletType.values[index];
  }

  static bool isBip39PhraseOrSeedHexKey() =>
      walletImportType == WalletType.bip39PhraseOrSeedHex;
  static bool isPrivateKey() => walletImportType == WalletType.privateKey;
  static bool isViewKey() => walletImportType == WalletType.viewKey;

  // ── Misc ──────────────────────────────────────────────────────────────────

  static bool removeCoin(Coin coin) {
    final isSingleWallet = isViewKey() || isPrivateKey();
    if (!isSingleWallet) return false;
    final active = getActiveKey(walletImportType);
    if (active == null) return true;
    return coin.getDefault() == active.defaultCoin;
  }

  /// Cross-type duplicate name check. Fast path via bloom filter,
  /// confirmed by linear scan to eliminate false positives.
  static bool doesNameExist(String name) {
    final normalized = name.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    if (!WalletNameFilter.mightExist(normalized)) return false;
    for (final type in WalletType.values) {
      if (getActiveKeys(type).any(
        (k) => k.name.toLowerCase().trim() == normalized,
      )) return true;
    }
    return false;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<void> _persistType(WalletType type) async {
    await pref.put(_coinTypeIndexKey, type.index);
    walletImportType = type;
  }

  static Future<void> _persistKeys(
    WalletType type,
    List<WalletParams> list,
  ) async {
    await pref.put(_getListKeyPref(type), jsonEncode(list));
  }

  static void _assertParamType(WalletType type, WalletParams key) {
    final valid = switch (type) {
      WalletType.bip39PhraseOrSeedHex => key is BIP39PhraseOrSeedHEXParams,
      WalletType.privateKey => key is PrivateKeyParams,
      WalletType.viewKey => key is ViewKeyParams,
    };
    if (!valid) throw ArgumentError('WalletParams type mismatch for $type');
  }
}

// ── WalletNameFilter ──────────────────────────────────────────────────────────

/// Probabilistic cross-type name uniqueness filter.
/// Always confirm positives with [WalletService.doesNameExist].
class WalletNameFilter {
  WalletNameFilter._();

  static final BloomFilter _filter = BloomFilter();
  static bool _seeded = false;

  static void _seed() {
    _filter.reset();
    for (final type in WalletType.values) {
      for (final k in WalletService.getActiveKeys(type)) {
        _filter.add(k.name.toLowerCase().trim());
      }
    }
    _seeded = true;
  }

  static void _ensureSeeded() {
    if (!_seeded) _seed();
  }

  /// Returns true if the name is *definitely not* taken (fast reject).
  /// Returns true (false positive possible) if it might be taken — always
  /// confirm with [WalletService.doesNameExist].
  static bool mightExist(String name) {
    _ensureSeeded();
    return _filter.mightContain(name.toLowerCase().trim());
  }

  /// Add a single name without a full re-seed. Call after inserting a wallet.
  static void register(String name) {
    _ensureSeeded();
    _filter.add(name.toLowerCase().trim());
  }

  /// Force full re-seed on next access (call after delete / rename).
  static void invalidate() => _seeded = false;
}
