import 'dart:convert';

import 'package:wallet_app/extensions/first_or_null.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:hex/hex.dart';

import '../main.dart';

const String _keyList = '52d7a-95cc-b7f0-ad93c-4ab1';

class ContactService {
  static List<ContactParams> getContacts() {
    String jsonList = pref.get(_keyList) ?? '[]';
    List<dynamic> jsonData = json.decode(jsonList);

    return jsonData.map((item) => ContactParams.fromJson(item)).toList();
  }

  static Future<void> _setContacts(List<ContactParams> keysList) async {
    String jsonList = jsonEncode(keysList);
    await pref.put(_keyList, jsonList);
  }

  static Future<void> setContact(ContactParams currentKey) async {
    if (currentKey.id != null) {
      _editContact(currentKey.id!, currentKey);
      return;
    }

    final previousList = getContacts();

    final select = previousList.firstWhereOrNull(
      (element) => element == currentKey,
    );

    if (select == null) {
      previousList.add(currentKey);
    }

    await _setContacts(previousList);
  }

  static Future<void> deleteData(ContactParams anyKey) async {
    final previousList = getContacts();
    previousList.removeWhere((element) => element == anyKey);

    await _setContacts(previousList);
  }

  static Future<void> _editContact(String id, ContactParams newUserName) async {
    final previousList = getContacts();
    for (var key in previousList) {
      if (key.id == id) {
        key.address = newUserName.address;
        key.name = newUserName.name;
        key.memo = newUserName.memo;
        break;
      }
    }
    await _setContacts(previousList);
  }
}

class ContactParams {
  final Coin coin;
  String? address;
  String? memo;
  String? name;
  final String? id;
  ContactParams({
    required this.coin,
    this.address,
    this.memo,
    this.name,
    this.id,
  });
  @override
  int get hashCode => super.hashCode + 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContactParams) return false;
    final otherParm = other;

    return address == otherParm.address &&
        memo == otherParm.memo &&
        coin.getDefault() == otherParm.coin.getDefault() &&
        coin.getName() == otherParm.coin.getName();
  }

  static String genId() {
    return HEX.encode(List.generate(16, (index) => index));
  }

  Map<String, dynamic> toJson() {
    return {
      'coin': coin.toJson(),
      'name': name,
      'address': address,
      'memo': memo,
      'id': id ?? genId(),
    };
  }

  factory ContactParams.fromJson(Map<String, dynamic> json) {
    Map jsonCoin = json['coin'];
    Coin coin = supportedChains.firstWhere((element) {
      final sameName = element.getName() == jsonCoin['name'];
      final sameDefault = element.getDefault() == jsonCoin['default'];
      return sameName && sameDefault;
    });

    return ContactParams(
      coin: coin,
      name: json['name'],
      memo: json['memo'],
      id: json['id'] ?? genId(),
      address: json['address'],
    );
  }
}
