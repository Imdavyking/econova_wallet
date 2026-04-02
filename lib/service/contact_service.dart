import 'dart:convert';
import 'dart:math';
import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import '../main.dart';

// ── Storage key ───────────────────────────────────────────────────────────────

const _kContactList = '52d7a-95cc-b7f0-ad93c-4ab1';

// ── ContactParams — immutable value object ────────────────────────────────────

class ContactParams {
  final String id;

  /// CAIP-2 chain ID — e.g. "eip155:1", "stacks:1", "solana:5eykt4..."
  final String caip2ChainId;

  final String name;
  final String address;
  final String? memo;

  const ContactParams({
    required this.id,
    required this.caip2ChainId,
    required this.name,
    required this.address,
    this.memo,
  });

  /// Creates a new contact (generates a random ID).
  factory ContactParams.create({
    required Coin coin,
    required String name,
    required String address,
    String? memo,
  }) =>
      ContactParams(
        id: _generateId(),
        caip2ChainId: coin.caip2ChainId,
        name: name,
        address: address,
        memo: memo,
      );

  /// Full CAIP-10 account identifier — e.g. "eip155:1:0xabc123..."
  String get caip10AccountId => '$caip2ChainId:$address';

  /// Returns true if this contact belongs to [coin]'s network.
  bool matchesCoin(Coin coin) => caip2ChainId == coin.caip2ChainId;

  /// Returns a copy with updated fields.
  ContactParams copyWith({
    String? name,
    String? address,
    String? memo,
  }) =>
      ContactParams(
        id: id,
        caip2ChainId: caip2ChainId,
        name: name ?? this.name,
        address: address ?? this.address,
        memo: memo ?? this.memo,
      );

  // ── Equality — based on caip10AccountId + memo ────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContactParams) return false;
    return caip10AccountId == other.caip10AccountId && memo == other.memo;
  }

  @override
  int get hashCode => Object.hash(caip10AccountId, memo);

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'caip2ChainId': caip2ChainId,
        'name': name,
        'address': address,
        'memo': memo,
      };

  factory ContactParams.fromJson(Map<String, dynamic> json) {
    // ── Forward-compatible: prefer caip2ChainId, fall back to legacy coin obj
    final caip2ChainId = json['caip2ChainId'] as String? ??
        _caip2FromLegacyCoin(json['coin'] as Map?);

    if (caip2ChainId == null) {
      throw const FormatException('Contact missing caip2ChainId and coin');
    }

    return ContactParams(
      id: json['id'] as String? ?? _generateId(),
      caip2ChainId: caip2ChainId,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      memo: json['memo'] as String?,
    );
  }

  /// Converts a legacy `coin` JSON object to a CAIP-2 chain ID by matching
  /// against [supportedChains].
  static String? _caip2FromLegacyCoin(Map? jsonCoin) {
    if (jsonCoin == null) return null;
    final coin = supportedChains.firstWhereOrNull(
      (e) =>
          e.getName() == jsonCoin['name'] &&
          e.getDefault() == jsonCoin['default'],
    );
    return coin?.caip2ChainId;
  }

  // ── ID generation — cryptographically random ──────────────────────────────

  static String _generateId() {
    final rng = Random.secure();
    final bytes = List.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

// ── ContactService ────────────────────────────────────────────────────────────

class ContactService {
  ContactService._();

  // ── Read ──────────────────────────────────────────────────────────────────

  static List<ContactParams> getContacts() {
    final raw = pref.get(_kContactList) as String? ?? '[]';
    final list = json.decode(raw) as List;

    return list
        .whereType<Map<String, dynamic>>()
        .where((item) => _resolveCaip2(item) != null)
        .map((item) {
          try {
            return ContactParams.fromJson(item);
          } catch (_) {
            return null;
          }
        })
        .whereType<ContactParams>()
        .toList();
  }

  /// Returns contacts filtered to [coin]'s network via CAIP-2 matching.
  static List<ContactParams> getContactsForCoin(Coin coin) =>
      getContacts().where((c) => c.matchesCoin(coin)).toList();

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Saves a new contact, or updates an existing one matched by [id].
  static Future<List<ContactParams>> saveContact(ContactParams contact) async {
    final list = getContacts();
    final idx = list.indexWhere((c) => c.id == contact.id);

    if (idx >= 0) {
      list[idx] = contact;
    } else {
      // Guard: don't allow duplicate caip10AccountId + memo combos
      final duplicate = list.firstWhereOrNull((c) => c == contact);
      if (duplicate == null) list.add(contact);
    }

    await _persist(list);
    return list;
  }

  /// Deletes a contact by [id].
  static Future<List<ContactParams>> deleteContact(String id) async {
    final list = getContacts()..removeWhere((c) => c.id == id);
    await _persist(list);
    return list;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Future<void> _persist(List<ContactParams> contacts) async {
    await pref.put(_kContactList, json.encode(contacts));
  }

  /// Returns the CAIP-2 chain ID from either the new or legacy format,
  /// or null if the entry cannot be resolved to a supported chain.
  static String? _resolveCaip2(Map<String, dynamic> item) {
    // New format
    final caip2 = item['caip2ChainId'] as String?;
    if (caip2 != null) {
      final supported = supportedChains.any((c) => c.caip2ChainId == caip2);
      return supported ? caip2 : null;
    }

    // Legacy format
    return ContactParams._caip2FromLegacyCoin(item['coin'] as Map?);
  }
}
