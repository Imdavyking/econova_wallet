import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DMS WebSocket Relay Service
//
// NO browser needed. Both devices run the EcoNova Flutter app and connect to
// the same lightweight relay server (e.g. your own Node.js WS server, or a
// free tier on Fly.io / Railway).
//
// Protocol (JSON frames over WS):
//
//   → join         { type:"join",  room:"<roomId>", role:"sender"|"receiver" }
//   ← joined       { type:"joined", room:"<roomId>", peers: int }
//   → share        { type:"share",  shareIndex: int, data: "<base64>",
//                    drandRound: int, totalShares: int, threshold: int }
//   ← share        (same, relayed from sender)
//   ← error        { type:"error", message: "..." }
//   → ping         { type:"ping" }
//   ← pong         { type:"pong" }
//
// A room ID is any short string both parties agree on — e.g. show a QR code
// on the sender device and scan on the receiver device.
// ──────────────────────────────────────────────────────────────────────────────

// Default relay.  Replace with your own server.
const _kDefaultRelayUrl = 'ws://localhost:8080';

// ── Incoming message types ─────────────────────────────────────────────────────

sealed class DmsWsMessage {}

class DmsWsJoined extends DmsWsMessage {
  final String roomId;
  final int peers;
  DmsWsJoined(this.roomId, this.peers);
}

class DmsWsShareReceived extends DmsWsMessage {
  final String sessionId;

  final EncryptedShare share;
  final int shareIndex;
  final int totalShares;
  final int threshold;
  DmsWsShareReceived({
    required this.share,
    required this.shareIndex,
    required this.totalShares,
    required this.threshold,
    required this.sessionId,
  });
}

class DmsWsError extends DmsWsMessage {
  final String message;
  DmsWsError(this.message);
}

class DmsWsPeerCount extends DmsWsMessage {
  final int peers;
  DmsWsPeerCount(this.peers);
}

// ── Service ────────────────────────────────────────────────────────────────────

class DmsRelayService {
  DmsRelayService._();

  static WebSocketChannel? _channel;
  static final _controller = StreamController<DmsWsMessage>.broadcast();

  static Stream<DmsWsMessage> get messages => _controller.stream;

  static bool get isConnected => _channel != null;

  // ── Connect ──────────────────────────────────────────────────────────────────

  /// Connect to the relay and join [roomId].
  ///
  /// [role] is 'sender' on the device that owns the wallet, 'receiver' on the
  /// beneficiary device.
  static Future<void> connect({
    required String roomId,
    required String role, // 'sender' | 'receiver'
    String relayUrl = _kDefaultRelayUrl,
  }) async {
    await disconnect(); // clean up any previous connection

    debugPrint('DmsRelay: connecting to $relayUrl');
    _channel = IOWebSocketChannel.connect(
      Uri.parse(relayUrl),
      pingInterval: const Duration(seconds: 20),
    );

    // Listen for messages.
    _channel!.stream.listen(
      (raw) {
        debugPrint('RAW WS: $raw');
        _handleRaw(raw as String);
      },
      onError: (e) {
        debugPrint('DmsRelay error: $e');
        _controller.add(DmsWsError('Connection error: $e'));
      },
      onDone: () {
        debugPrint('DmsRelay: connection closed');
        _channel = null;
      },
      cancelOnError: false,
    );

    // Join the room.
    _send({'type': 'join', 'room': roomId, 'role': role});
    debugPrint('DmsRelay: joined room "$roomId" as $role');
  }

  // ── Disconnect ───────────────────────────────────────────────────────────────

  static Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  // ── Send shares (sender side) ────────────────────────────────────────────────

  /// Broadcast all [shares] over the relay channel.
  ///
  /// The receiver only needs [threshold] shares to reconstruct — distribute
  /// different shares to different trusted parties for best security.
  static void sendShares({
    required List<EncryptedShare> shares,
    required int threshold,
  }) {
    if (_channel == null) throw StateError('Not connected to relay');
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    for (var i = 0; i < shares.length; i++) {
      _send({
        'type': 'share',
        'sessionId': sessionId,
        'shareIndex': i,
        'totalShares': shares.length,
        'threshold': threshold,
        'data': shares[i].ciphertext,
        'drandRound': shares[i].drandRound,
      });
      debugPrint('DmsRelay: sent share ${i + 1}/${shares.length}');
    }
  }

  /// Convenience: send only a single share by index (e.g. to one specific
  /// trusted contact in their own room).
  static void sendSingleShare({
    required EncryptedShare share,
    required int shareIndex,
    required int totalShares,
    required int threshold,
  }) {
    if (_channel == null) throw StateError('Not connected to relay');
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _send({
      'type': 'share',
      'sessionId': sessionId,
      'shareIndex': shareIndex,
      'totalShares': totalShares,
      'threshold': threshold,
      'data': share.ciphertext,
      'drandRound': share.drandRound,
    });
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  static void _send(Map<String, dynamic> msg) {
    _channel?.sink.add(jsonEncode(msg));
  }

  static void _handleRaw(String raw) {
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      final type = msg['type'] as String?;

      switch (type) {
        case 'joined':
          _controller.add(DmsWsJoined(
            msg['room'] as String,
            (msg['peers'] as num).toInt(),
          ));

        case 'peers':
          _controller.add(DmsWsPeerCount((msg['count'] as num).toInt()));

        case 'share':
          _controller.add(DmsWsShareReceived(
            sessionId: msg['sessionId'] as String,
            shareIndex: (msg['shareIndex'] as num).toInt(),
            totalShares: (msg['totalShares'] as num).toInt(),
            threshold: (msg['threshold'] as num).toInt(),
            share: EncryptedShare(
              ciphertext: msg['data'] as String,
              drandRound: (msg['drandRound'] as num).toInt(),
            ),
          ));

        case 'error':
          _controller.add(DmsWsError(msg['message'] as String? ?? 'Unknown'));

        case 'pong':
          break; // keepalive, ignore

        default:
          debugPrint('DmsRelay: unknown message type: $type');
      }
    } catch (e) {
      debugPrint('DmsRelay: parse error: $e  raw=$raw');
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Receiver-side accumulator
//
// Use this on the beneficiary's device to collect incoming shares until
// threshold is met, then reconstruct.
// ──────────────────────────────────────────────────────────────────────────────

class DmsShareAccumulator {
  final int threshold;
  final void Function(List<EncryptedShare> shares) onThresholdMet;

  final _collected = <int, EncryptedShare>{};
  late final StreamSubscription _sub;

  DmsShareAccumulator({
    required this.threshold,
    required this.onThresholdMet,
  }) {
    _sub = DmsRelayService.messages.listen((msg) {
      if (msg is DmsWsShareReceived) {
        _collected[msg.shareIndex] = msg.share;
        debugPrint(
            'DmsAccumulator: ${_collected.length}/$threshold shares received');
        if (_collected.length >= threshold) {
          onThresholdMet(_collected.values.toList());
        }
      }
    });
  }

  void dispose() => _sub.cancel();

  int get receivedCount => _collected.length;
  List<EncryptedShare> get collected => _collected.values.toList();
}

// ──────────────────────────────────────────────────────────────────────────────
// Minimal Node.js relay server (paste into server.js and run with node)
// ──────────────────────────────────────────────────────────────────────────────
//
// const { WebSocketServer } = require('ws');
// const wss = new WebSocketServer({ port: 8080 });
// const rooms = {}; // roomId → Set<ws>
//
// wss.on('connection', (ws) => {
//   let room = null;
//   ws.on('message', (data) => {
//     const msg = JSON.parse(data);
//     if (msg.type === 'join') {
//       room = msg.room;
//       rooms[room] = rooms[room] || new Set();
//       rooms[room].add(ws);
//       ws.send(JSON.stringify({ type:'joined', room, peers: rooms[room].size }));
//       broadcast(room, ws, { type:'peers', count: rooms[room].size });
//     } else if (msg.type === 'ping') {
//       ws.send(JSON.stringify({ type:'pong' }));
//     } else if (room) {
//       broadcast(room, ws, msg); // relay to everyone else in room
//     }
//   });
//   ws.on('close', () => { if (room) rooms[room]?.delete(ws); });
// });
//
// function broadcast(room, sender, msg) {
//   const raw = JSON.stringify(msg);
//   rooms[room]?.forEach(c => { if (c !== sender && c.readyState === 1) c.send(raw); });
// }