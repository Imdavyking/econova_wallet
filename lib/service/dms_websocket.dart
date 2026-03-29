import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';

final rooms = <String, Set<WebSocket>>{};

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  debugPrint('🚀 WebSocket server running on ws://localhost:8080');

  await for (final req in server) {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final ws = await WebSocketTransformer.upgrade(req);
      handleConnection(ws);
    } else {
      req.response.statusCode = HttpStatus.notImplemented;
      await req.response.close();
    }
  }
}

void handleConnection(WebSocket ws) {
  String? room;

  ws.listen(
    (data) {
      final msg = jsonDecode(data as String) as Map<String, dynamic>;

      if (msg['type'] == 'join') {
        room = msg['room'] as String;
        rooms.putIfAbsent(room!, () => {}).add(ws);
        final peers = rooms[room]!.length;
        ws.add(jsonEncode({'type': 'joined', 'room': room, 'peers': peers}));
        broadcast(room!, ws, {'type': 'peers', 'count': peers});
      } else if (msg['type'] == 'ping') {
        ws.add(jsonEncode({'type': 'pong'}));
      } else if (room != null) {
        broadcast(room!, ws, msg);
      }
    },
    onDone: () {
      if (room != null) rooms[room]?.remove(ws);
    },
  );
}

void broadcast(String room, WebSocket sender, Map<String, dynamic> msg) {
  final raw = jsonEncode(msg);
  rooms[room]?.forEach((c) {
    if (c != sender && c.closeCode == null) c.add(raw);
  });
}
