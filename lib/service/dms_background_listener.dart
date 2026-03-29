import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/dms_relay_service.dart';

class DmsBackgroundListener {
  DmsBackgroundListener._();
  static final DmsBackgroundListener instance = DmsBackgroundListener._();

  bool _running = false;
  String? _pubKeyHex;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;

  final _collected = <String, Map<int, DmsWsShareReceived>>{};

  Future<void> start(String pubKeyHex) async {
    // Already listening for this key — nothing to do
    if (_running && _pubKeyHex == pubKeyHex) return;

    // Different key (wallet switched) — restart
    if (_running) await stop();

    _pubKeyHex = pubKeyHex;
    _running = true;
    debugPrint(
        'DMS listener: starting for pubKey ${pubKeyHex.substring(0, 8)}…');
    await _connect();
  }

  Future<void> stop() async {
    _running = false;
    _pubKeyHex = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _sub?.cancel();
    _sub = null;
    await DmsRelayService.disconnect();
    debugPrint('DMS listener: stopped');
  }

  Future<void> _connect() async {
    if (!_running || _pubKeyHex == null) return;

    final roomId = DeadManSwitchService.roomIdFromPubKey(_pubKeyHex!);

    try {
      await DmsRelayService.connect(roomId: roomId, role: 'receiver');
      debugPrint('DMS listener: connected to room $roomId');

      await _sub?.cancel();
      _sub = DmsRelayService.messages.listen(
        _onMessage,
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('DMS listener: connect failed ($e), retrying in 10s');
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic msg) {
    if (msg is! DmsWsShareReceived) return;

    final sid = msg.sessionId;
    _collected.putIfAbsent(sid, () => {});
    _collected[sid]![msg.shareIndex] = msg;

    debugPrint('DMS listener [$sid]: '
        '${_collected[sid]!.length}/${msg.totalShares} shares');

    if (_collected[sid]!.length >= msg.totalShares) {
      _saveSession(sid);
    }
  }

  Future<void> _saveSession(String sid) async {
    final msgs = _collected[sid]!.values.toList();
    final session = DmsSessionData(
      dataHash: msgs.first.dataHash,
      sessionId: sid,
      shares: msgs.map((m) => m.share).toList(),
      threshold: msgs.first.threshold,
      pubKeyHex: msgs.first.pubKeyHex,
      senderAddress: msgs.first.senderAddress,
      milliSeconds: msgs.first.milliSeconds,
    );

    await DeadManSwitchService.saveShares(session);
    _collected.remove(sid);
    debugPrint('DMS listener: ✅ saved session $sid '
        '(${session.shares.length} shares)');
  }

  void _onDisconnect() {
    debugPrint('DMS listener: disconnected');
    if (_running) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), _connect);
  }
}
