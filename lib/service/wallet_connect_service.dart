import 'dart:convert';

import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';

import '../main.dart';
import '../utils/app_config.dart';
import '../utils/wallet_connect_v1/wc_connector_v1.dart';
import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WCService {
  static const _wcSessionKey = '432d-41b3-9296-a7e5c';
  static _qrScanHandlerV1(String value) async {
    final session = WCSession.from(value);
    if (session == WCSession.empty()) return;
    final peerMeta = WCPeerMeta(
      name: walletName,
      url: walletURL,
      description: walletAbbr,
      icons: [walletIconURL],
    );

    await WcConnectorV1.wcClient.connectNewSession(
      session: session,
      peerMeta: peerMeta,
    );
  }

  static _qrScanHandlerV2(String value) async {
    await WcConnectorV2.signClient.pair(value);
  }

  static Future<void> qrScanHandler(String? value) async {
    if (value == null) return;

    if (Uri.tryParse(value) == null) return;
    try {
      await WCService._qrScanHandlerV2(value);
    } catch (_) {
      await WCService._qrScanHandlerV1(value);
    }
  }

  static Future killSessionV1() async {
    try {
      if (isConnectedV1()) await WcConnectorV1.wcClient.killSession();
    } catch (_) {}
  }

  static List<WCSessionAddr> getSessionsV1() {
    String? wcSessions = pref.get(_wcSessionKey);
    if (wcSessions != null) {
      List sessions_ = jsonDecode(wcSessions);
      return sessions_.map((e) => WCSessionAddr.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<WCSessionAddr>> saveSessionV1(
    WCSessionAddr session,
  ) async {
    List<WCSessionAddr> savedSession = getSessionsV1();
    savedSession.removeWhere(
      (sessionSaved) => sessionSaved == session,
    );

    savedSession.add(session);
    await pref.put(_wcSessionKey, jsonEncode(savedSession));
    return savedSession;
  }

  static Future<void> wcReconnectV1() async {
    List<WCSessionAddr> savedSession = getSessionsV1();

    for (WCSessionAddr session in savedSession) {
      try {
        await WcConnectorV1.wcClient.connectFromSessionStore(
          session.sessionStore,
        );
      } catch (_) {}
    }
  }

  static Future<bool> removeCurrentSessionV1() async {
    try {
      if (!isConnectedV1()) return false;
      List<WCSessionAddr> savedSession = getSessionsV1();
      savedSession.removeWhere(
        (sessionSaved) =>
            sessionSaved.sessionStore == WcConnectorV1.wcClient.sessionStore,
      );
      await pref.put(_wcSessionKey, jsonEncode(savedSession));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeSessionV1(WCSessionAddr session) async {
    try {
      if (isConnectedV1() &&
          session.sessionStore == WcConnectorV1.wcClient.sessionStore) {
        await WcConnectorV1.wcClient.killSession();
      }
      List<WCSessionAddr> savedSession = getSessionsV1();
      savedSession.removeWhere((sessionSaved) => sessionSaved == session);
      await pref.put(_wcSessionKey, jsonEncode(savedSession));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeSessionV2(SessionStruct session) async {
    try {
      await WcConnectorV2.signClient.disconnect(topic: session.topic);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isConnectedV1() {
    return WcConnectorV1.wcClient.isConnected;
  }
}

class WCSessionAddr {
  final WCSessionStore sessionStore;
  final String address;
  final int date;
  const WCSessionAddr({
    required this.sessionStore,
    required this.address,
    required this.date,
  });

  factory WCSessionAddr.fromJson(Map<String, dynamic> json) {
    return WCSessionAddr(
      sessionStore: WCSessionStore.fromJson(json['session']),
      address: json['address'],
      date: json['date'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WCSessionAddr && other.sessionStore == sessionStore;
  }

  @override
  int get hashCode => super.hashCode + 0;

  Map<String, dynamic> toJson() {
    return {
      'session': sessionStore.toJson(),
      'address': address,
      'date': date,
    };
  }
}
