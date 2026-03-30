// dms_background_listener.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/dms_relay_service.dart';

const _kReconnectDelay = Duration(seconds: 10);

class DmsBackgroundListener {
  DmsBackgroundListener._();
  static final DmsBackgroundListener instance = DmsBackgroundListener._();

  bool _running = false;
  String? _pubKeyHex;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;

  // sessionId → { shareIndex → message }
  final _collected = <String, _PendingSession>{};

  Future<void> start(String pubKeyHex) async {
    if (_running && _pubKeyHex == pubKeyHex) return;
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
    _collected.clear();
    await DmsRelayService.disconnect();
    debugPrint('DMS listener: stopped');
  }

  Future<void> _connect() async {
    if (!_running || _pubKeyHex == null) return;
    final roomId = DeadManSwitchService.roomIdFromPubKey(_pubKeyHex!);
    try {
      await DmsRelayService.connect(roomId: roomId, role: 'receiver');

      // Guard: stop() may have been called while we were awaiting connect
      if (!_running) {
        await DmsRelayService.disconnect();
        return;
      }

      debugPrint('DMS listener: connected to room $roomId');
      await _sub?.cancel();
      _sub = DmsRelayService.messages.listen(
        _onMessage,
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint(
          'DMS listener: connect failed ($e), retrying in ${_kReconnectDelay.inSeconds}s');
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic msg) {
    if (msg is DmsWsCancelReceived) {
      _handleCancel(msg.dataHash);
      return;
    }
    if (msg is! DmsWsShareReceived) return;

    final sid = msg.sessionId;

    // If a new sessionId arrives for the same dataHash, evict the old
    // partial session — it will never complete (sender heartbeated).
    _collected.removeWhere((existingSid, pending) {
      if (existingSid == sid) return false;
      if (pending.dataHash == msg.dataHash) {
        debugPrint('DMS listener: evicting stale session $existingSid '
            '(superseded by $sid for dataHash=${msg.dataHash.substring(0, 8)}…)');
        return true;
      }
      return false;
    });

    final session = _collected.putIfAbsent(
      sid,
      () => _PendingSession(
        dataHash: msg.dataHash,
        totalShares: msg.totalShares, // stored once, not re-read per message
      ),
    );

    session.shares[msg.shareIndex] = msg;
    debugPrint(
        'DMS listener [$sid]: ${session.shares.length}/${session.totalShares} shares');

    if (session.shares.length >= session.totalShares) {
      _saveSession(sid, session);
    }
  }

  Future<void> _handleCancel(String dataHash) async {
    // Also evict any in-progress collection for this dataHash
    _collected.removeWhere((_, pending) => pending.dataHash == dataHash);
    await DeadManSwitchService.deleteSessionByDataHash(dataHash);
    debugPrint(
        'DMS listener: 🗑️ cancelled session dataHash=${dataHash.substring(0, 8)}… deleted');
  }

  Future<void> _saveSession(String sid, _PendingSession pending) async {
    final msgs = pending.shares.values.toList();
    final session = DmsSessionData(
      dataHash: pending.dataHash,
      sessionId: sid,
      shares: msgs.map((m) => m.share).toList(),
      threshold: msgs.first.threshold,
      pubKeyHex: msgs.first.pubKeyHex,
      senderAddress: msgs.first.senderAddress,
      milliSeconds: msgs.first.milliSeconds,
    );

    await DeadManSwitchService.saveShares(session);
    _collected.remove(sid);
    debugPrint(
        'DMS listener: ✅ saved session $sid (${session.shares.length} shares)');
  }

  void _onDisconnect() {
    debugPrint('DMS listener: disconnected');
    if (_running) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_kReconnectDelay, _connect);
  }
}

// Holds in-progress share collection for one session.
class _PendingSession {
  final String dataHash;
  final int totalShares;
  final shares = <int, DmsWsShareReceived>{};

  _PendingSession({required this.dataHash, required this.totalShares});
}
