// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

final rooms = <String, Set<WebSocket>>{};
int _connectionCount = 0;

void main() async {
  final server = await HttpServer.bind('0.0.0.0', 8080);
  print('🚀 WebSocket server running on ws://0.0.0.0:8080');

  await for (final req in server) {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final ws = await WebSocketTransformer.upgrade(req);
      _connectionCount++;
      print(
          '🔌 [#$_connectionCount] New connection from ${req.connectionInfo?.remoteAddress.address}');
      handleConnection(ws, _connectionCount);
    } else {
      print('⚠️  Non-WebSocket request: ${req.method} ${req.uri}');
      req.response.statusCode = HttpStatus.notImplemented;
      await req.response.close();
    }
  }
}

void handleConnection(WebSocket ws, int id) {
  String? room;

  ws.listen(
    (data) {
      final msg = jsonDecode(data as String) as Map<String, dynamic>;
      final type = msg['type'] as String?;
      print('📨 [#$id] Received type="$type" room="$room"');

      if (type == 'join') {
        room = msg['room'] as String;
        rooms.putIfAbsent(room!, () => {}).add(ws);
        final peers = rooms[room]!.length;
        print('🚪 [#$id] Joined room "$room" — $peers peer(s) now in room');
        ws.add(jsonEncode({'type': 'joined', 'room': room, 'peers': peers}));
        broadcast(room!, ws, {'type': 'peers', 'count': peers}, id);
      } else if (type == 'ping') {
        print('🏓 [#$id] Ping → Pong');
        ws.add(jsonEncode({'type': 'pong'}));
      } else if (type == 'share') {
        final shareIndex = msg['shareIndex'];
        final totalShares = msg['totalShares'];
        final sessionId = msg['sessionId'];
        final senderAddress = msg['senderAddress'];
        final dataHash = msg['dataHash'] as String?;
        final drandRound = msg['share']?['drandRound'] ?? msg['drandRound'];
        print('📦 [#$id] Share $shareIndex/$totalShares '
            'session=$sessionId '
            'sender=$senderAddress '
            'drandRound=$drandRound '
            'dataHash=$dataHash '
            '→ broadcasting to room "$room"');
        if (room != null) broadcast(room!, ws, msg, id);
      } else if (room != null) {
        print('📡 [#$id] Relaying type="$type" to room "$room"');
        broadcast(room!, ws, msg, id);
      } else {
        print(
            '⚠️  [#$id] Message received but not in any room — ignored. type="$type"');
      }
    },
    onDone: () {
      if (room != null) {
        rooms[room]?.remove(ws);
        final remaining = rooms[room]?.length ?? 0;
        print(
            '👋 [#$id] Disconnected from room "$room" — $remaining peer(s) remaining');
        if (remaining == 0) {
          rooms.remove(room);
          print('🗑️  Room "$room" is now empty — removed');
        }
      } else {
        print('👋 [#$id] Disconnected (was not in any room)');
      }
    },
    onError: (e) {
      print('❌ [#$id] Error in room "$room": $e');
      if (room != null) rooms[room]?.remove(ws);
    },
  );
}

void broadcast(
    String room, WebSocket sender, Map<String, dynamic> msg, int senderId) {
  final targets =
      rooms[room]?.where((c) => c != sender && c.closeCode == null).toList() ??
          [];
  print(
      '📢 [#$senderId] Broadcasting type="${msg['type']}" to ${targets.length} peer(s) in room "$room"');
  final raw = jsonEncode(msg);
  for (final c in targets) {
    c.add(raw);
  }
}
