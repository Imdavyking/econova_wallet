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
  final Coin coin;
  final String name;
  final String address;
  final String? memo;

  const ContactParams({
    required this.id,
    required this.coin,
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
        coin: coin,
        name: name,
        address: address,
        memo: memo,
      );

  /// Returns a copy with updated fields.
  ContactParams copyWith({
    String? name,
    String? address,
    String? memo,
  }) =>
      ContactParams(
        id: id,
        coin: coin,
        name: name ?? this.name,
        address: address ?? this.address,
        memo: memo ?? this.memo,
      );

  // ── Equality — based on coin + address + memo (not id) ────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContactParams) return false;
    return address == other.address &&
        memo == other.memo &&
        coin.getDefault() == other.coin.getDefault() &&
        coin.getName() == other.coin.getName();
  }

  @override
  int get hashCode => Object.hash(
        address,
        memo,
        coin.getDefault(),
        coin.getName(),
      );

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'coin': coin.toJson(),
        'name': name,
        'address': address,
        'memo': memo,
      };

  factory ContactParams.fromJson(Map<String, dynamic> json) {
    final jsonCoin = json['coin'] as Map;
    final coin = supportedChains.firstWhere(
      (e) =>
          e.getName() == jsonCoin['name'] &&
          e.getDefault() == jsonCoin['default'],
    );

    return ContactParams(
      id: json['id'] as String? ?? _generateId(),
      coin: coin,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      memo: json['memo'] as String?,
    );
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
        .where((item) => _resolveCoin(item['coin'] as Map?) != null)
        .map(ContactParams.fromJson)
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Saves a new contact, or updates an existing one matched by [id].
  static Future<List<ContactParams>> saveContact(ContactParams contact) async {
    final list = getContacts();
    final idx = list.indexWhere((c) => c.id == contact.id);

    if (idx >= 0) {
      list[idx] = contact;
    } else {
      // Guard: don't allow duplicate address+coin combos
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

  static Coin? _resolveCoin(Map? jsonCoin) {
    if (jsonCoin == null) return null;
    return supportedChains.firstWhereOrNull(
      (e) =>
          e.getName() == jsonCoin['name'] &&
          e.getDefault() == jsonCoin['default'],
    );
  }
}
