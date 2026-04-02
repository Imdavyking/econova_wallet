import 'dart:convert';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import '../main.dart';
import '../utils/app_config.dart';
import '../utils/wallet_connect_reown/wc_connector_reown.dart';
import '../utils/wallet_connect_v1/wc_connector_v1.dart';
import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WCService {
  static const _wcSessionKey = '432d-41b3-9296-a7e5c';

  // ── QR / URI routing ────────────────────────────────────────────────────

  static Future<void> _qrScanHandlerReown(String value) async {
    // Reown WalletKit handles wc: v2 URIs (topic@2?...) and link-mode URIs.
    final uri = Uri.parse(value);
    await WCConnectorReown.instance.pair(uri);
  }

  static Future<void> _qrScanHandlerV2(String value) async {
    await WcConnectorV2.signClient.pair(value);
  }

  static Future<void> _qrScanHandlerV1(String value) async {
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

  /// Routes a scanned / pasted WalletConnect URI to the correct connector.
  /// Tries Reown (v2 modern) → legacy v2 → legacy v1.
  static Future<void> qrScanHandler(String? value) async {
    if (value == null) return;
    if (Uri.tryParse(value) == null) return;

    try {
      await WCService._qrScanHandlerReown(value);
      return;
    } catch (_) {}

    try {
      await WCService._qrScanHandlerV2(value);
      return;
    } catch (_) {}

    await WCService._qrScanHandlerV1(value);
  }

  // ── Reown session management ─────────────────────────────────────────────

  /// Returns all active Reown sessions.
  static List<SessionData> getSessionsReown() =>
      WCConnectorReown.instance.getSessions();

  /// Disconnects a Reown session and removes it from the wallet kit store.
  static Future<bool> removeSessionReown(SessionData session) async {
    try {
      await WCConnectorReown.instance.disconnectSession(session.topic);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── V2 session management ────────────────────────────────────────────────

  static Future<bool> removeSessionV2(SessionStruct session) async {
    try {
      await WcConnectorV2.signClient.disconnect(topic: session.topic);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── V1 session management ────────────────────────────────────────────────

  static Future<void> killSessionV1() async {
    try {
      if (isConnectedV1()) await WcConnectorV1.wcClient.killSession();
    } catch (_) {}
  }

  static List<WCSessionAddr> getSessionsV1() {
    final String? wcSessions = pref.get(_wcSessionKey);
    if (wcSessions != null) {
      final List sessions_ = jsonDecode(wcSessions) as List;
      return sessions_
          .map((e) => WCSessionAddr.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<List<WCSessionAddr>> saveSessionV1(
    WCSessionAddr session,
  ) async {
    final List<WCSessionAddr> savedSession = getSessionsV1();
    savedSession.removeWhere(
      (sessionSaved) => sessionSaved == session,
    );
    savedSession.add(session);
    await pref.put(_wcSessionKey, jsonEncode(savedSession));
    return savedSession;
  }

  static Future<void> wcReconnectV1() async {
    final List<WCSessionAddr> savedSession = getSessionsV1();
    for (final WCSessionAddr session in savedSession) {
      try {
        await WcConnectorV1.wcClient
            .connectFromSessionStore(session.sessionStore);
      } catch (_) {}
    }
  }

  static Future<bool> removeCurrentSessionV1() async {
    try {
      if (!isConnectedV1()) return false;
      final List<WCSessionAddr> savedSession = getSessionsV1();
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
      final List<WCSessionAddr> savedSession = getSessionsV1();
      savedSession.removeWhere((sessionSaved) => sessionSaved == session);
      await pref.put(_wcSessionKey, jsonEncode(savedSession));
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isConnectedV1() => WcConnectorV1.wcClient.isConnected;
}

// ── WCSessionAddr (V1 persistence model) ────────────────────────────────────

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
      sessionStore:
          WCSessionStore.fromJson(json['session'] as Map<String, dynamic>),
      address: json['address'] as String,
      date: json['date'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WCSessionAddr && other.sessionStore == sessionStore;
  }

  @override
  int get hashCode => sessionStore.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'session': sessionStore.toJson(),
      'address': address,
      'date': date,
    };
  }
}
