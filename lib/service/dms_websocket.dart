// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

final rooms = <String, Set<WebSocket>>{};

// roomStore[roomId][dataHash] = {
//   'type': 'shares', 'sessionId': ..., 'dataHash': ..., 'shares': { shareIndex: msg }
// } | {
//   'type': 'cancel', 'dataHash': ...
// }
final roomStore = <String, Map<String, Map<String, dynamic>>>{};

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

        // ── Replay all stored state to newly joined peer ──────────────────
        final stored = roomStore[room];
        if (stored != null && stored.isNotEmpty) {
          print(
              '📬 [#$id] Replaying ${stored.length} entry(ies) to new peer in room "$room"');
          for (final entry in stored.values) {
            if (entry['type'] == 'cancel') {
              print(
                  '📬 [#$id]   → cancel for dataHash=${_short(entry['dataHash'] as String?)}');
              ws.add(jsonEncode({
                'type': 'cancel',
                'dataHash': entry['dataHash'],
              }));
            } else if (entry['type'] == 'shares') {
              final shares = entry['shares'] as Map<String, dynamic>;
              print(
                  '📬 [#$id]   → ${shares.length} share(s) for dataHash=${_short(entry['dataHash'] as String?)}');
              for (final shareMsg in shares.values) {
                ws.add(jsonEncode(shareMsg));
              }
            }
          }
        } else {
          print('📭 [#$id] No stored state for room "$room"');
        }
      } else if (type == 'ping') {
        print('🏓 [#$id] Ping → Pong');
        ws.add(jsonEncode({'type': 'pong'}));
      } else if (type == 'share') {
        final shareIndex = msg['shareIndex'];
        final totalShares = msg['totalShares'];
        final sessionId = msg['sessionId'] as String?;
        final senderAddress = msg['senderAddress'];
        final dataHash = msg['dataHash'] as String?;
        final drandRound =
            (msg['share'] as Map<String, dynamic>?)?['drandRound'] ??
                msg['drandRound'];
        final shortHash = _short(dataHash);

        print('📦 [#$id] Share $shareIndex/$totalShares '
            'session=$sessionId '
            'sender=$senderAddress '
            'drandRound=$drandRound '
            'dataHash=$shortHash '
            '→ storing & broadcasting to room "$room"');

        if (room != null) {
          final dataHashKey = dataHash ?? 'unknown';

          roomStore.putIfAbsent(room!, () => {});

          // If new sessionId for this dataHash (heartbeat), replace old shares
          final existing = roomStore[room!]![dataHashKey];
          if (existing == null ||
              existing['type'] == 'cancel' ||
              existing['sessionId'] != sessionId) {
            print(
                '🔄 [#$id] New session $sessionId for dataHash=$shortHash — replacing old store');
            roomStore[room!]![dataHashKey] = {
              'type': 'shares',
              'sessionId': sessionId,
              'dataHash': dataHash,
              'shares': <String, dynamic>{},
            };
          }

          // Store individual share message by index
          (roomStore[room!]![dataHashKey]!['shares']
              as Map<String, dynamic>)['$shareIndex'] = msg;
          final collected = (roomStore[room!]![dataHashKey]!['shares']
                  as Map<String, dynamic>)
              .length;
          print(
              '💾 [#$id] Stored share $shareIndex — $collected/$totalShares for dataHash=$shortHash in room "$room"');

          broadcast(room!, ws, msg, id);
        }
      } else if (type == 'cancel') {
        final dataHash = msg['dataHash'] as String?;
        final shortHash = _short(dataHash);
        print(
            '🗑️  [#$id] Cancel for dataHash=$shortHash — storing & broadcasting to room "$room"');

        if (room != null) {
          final dataHashKey = dataHash ?? 'unknown';
          roomStore.putIfAbsent(room!, () => {});
          // Replace this sender's shares with a cancel marker
          roomStore[room!]![dataHashKey] = {
            'type': 'cancel',
            'dataHash': dataHash,
          };
          broadcast(room!, ws, msg, id);
        }
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
          print(
              '🗑️  Room "$room" is now empty — removed (store kept for offline replay)');
          // NOTE: roomStore is intentionally NOT cleared —
          // beneficiary may connect later and needs the replay
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

String _short(String? s) {
  if (s == null) return 'none';
  if (s.length < 16) return s;
  return '${s.substring(0, 8)}…${s.substring(s.length - 8)}';
}

///NOTE: DO NOT DELETE THIS COMMENT. This file is used as a reference implementation for the DMS relay server.
// const { WebSocketServer } = require("ws");

// const wss = new WebSocketServer({ port: 8080 });
// const rooms = {}; // roomId → Set<ws>

// // roomStore[roomId][dataHash] = {
// //   type: 'shares', sessionId, dataHash, shares: { shareIndex: msg }
// // } | {
// //   type: 'cancel', dataHash
// // }
// const roomStore = {};

// let connectionCount = 0;

// console.log("🚀 WebSocket server running on ws://0.0.0.0:8080");

// wss.on("connection", (ws, req) => {
//   const id = ++connectionCount;
//   const ip = req.socket.remoteAddress;
//   console.log(`🔌 [#${id}] New connection from ${ip}`);

//   let room = null;

//   ws.on("message", (data) => {
//     let msg;
//     try {
//       msg = JSON.parse(data);
//     } catch (e) {
//       console.log(`❌ [#${id}] Failed to parse message: ${e.message}`);
//       return;
//     }

//     const type = msg.type;
//     console.log(`📨 [#${id}] Received type="${type}" room="${room}"`);

//     if (type === "join") {
//       room = msg.room;
//       rooms[room] = rooms[room] || new Set();
//       rooms[room].add(ws);
//       const peers = rooms[room].size;
//       console.log(`🚪 [#${id}] Joined room "${room}" — ${peers} peer(s)`);
//       ws.send(JSON.stringify({ type: "joined", room, peers }));
//       broadcast(room, ws, { type: "peers", count: peers }, id);

//       // ── Replay all stored state to newly joined peer ────────────────────
//       const stored = roomStore[room];
//       if (stored && Object.keys(stored).length > 0) {
//         console.log(`📬 [#${id}] Replaying ${Object.keys(stored).length} entry(ies) to new peer in room "${room}"`);
//         for (const entry of Object.values(stored)) {
//           if (entry.type === "cancel") {
//             console.log(`📬 [#${id}]   → cancel for dataHash=${short(entry.dataHash)}`);
//             ws.send(JSON.stringify({ type: "cancel", dataHash: entry.dataHash }));
//           } else if (entry.type === "shares") {
//             const shares = Object.values(entry.shares);
//             console.log(`📬 [#${id}]   → ${shares.length} share(s) for dataHash=${short(entry.dataHash)}`);
//             for (const shareMsg of shares) {
//               ws.send(JSON.stringify(shareMsg));
//             }
//           }
//         }
//       } else {
//         console.log(`📭 [#${id}] No stored state for room "${room}"`);
//       }

//     } else if (type === "ping") {
//       console.log(`🏓 [#${id}] Ping → Pong`);
//       ws.send(JSON.stringify({ type: "pong" }));

//     } else if (type === "share") {
//       const { shareIndex, totalShares, sessionId, senderAddress, dataHash } = msg;
//       const drandRound = msg.share?.drandRound ?? msg.drandRound;
//       const shortHash = short(dataHash);

//       console.log(
//         `📦 [#${id}] Share ${shareIndex}/${totalShares} ` +
//         `session=${sessionId} sender=${senderAddress} ` +
//         `drandRound=${drandRound} dataHash=${shortHash} ` +
//         `→ storing & broadcasting to room "${room}"`
//       );

//       if (room) {
//         const dataHashKey = dataHash ?? "unknown";
//         roomStore[room] = roomStore[room] || {};

//         // If new sessionId for this dataHash (heartbeat), replace old shares
//         const existing = roomStore[room][dataHashKey];
//         if (!existing || existing.type === "cancel" || existing.sessionId !== sessionId) {
//           console.log(`🔄 [#${id}] New session ${sessionId} for dataHash=${shortHash} — replacing old store`);
//           roomStore[room][dataHashKey] = {
//             type: "shares",
//             sessionId,
//             dataHash,
//             shares: {},
//           };
//         }

//         // Store individual share by index
//         roomStore[room][dataHashKey].shares[shareIndex] = msg;
//         const collected = Object.keys(roomStore[room][dataHashKey].shares).length;
//         console.log(`💾 [#${id}] Stored share ${shareIndex} — ${collected}/${totalShares} for dataHash=${shortHash} in room "${room}"`);

//         broadcast(room, ws, msg, id);
//       }

//     } else if (type === "cancel") {
//       const { dataHash } = msg;
//       const shortHash = short(dataHash);
//       console.log(`🗑️  [#${id}] Cancel for dataHash=${shortHash} — storing & broadcasting to room "${room}"`);

//       if (room) {
//         const dataHashKey = dataHash ?? "unknown";
//         roomStore[room] = roomStore[room] || {};
//         // Replace this sender's shares with a cancel marker
//         roomStore[room][dataHashKey] = { type: "cancel", dataHash };
//         broadcast(room, ws, msg, id);
//       }

//     } else if (room) {
//       console.log(`📡 [#${id}] Relaying type="${type}" to room "${room}"`);
//       broadcast(room, ws, msg, id);

//     } else {
//       console.log(`⚠️  [#${id}] Message type="${type}" received but not in any room — ignored`);
//     }
//   });

//   ws.on("close", () => {
//     if (room) {
//       rooms[room]?.delete(ws);
//       const remaining = rooms[room]?.size ?? 0;
//       console.log(`👋 [#${id}] Disconnected from room "${room}" — ${remaining} peer(s) remaining`);
//       if (remaining === 0) {
//         delete rooms[room];
//         console.log(`🗑️  Room "${room}" is now empty — removed (store kept for offline replay)`);
//         // NOTE: roomStore[room] intentionally NOT cleared —
//         // beneficiary may connect later and needs the replay
//       }
//     } else {
//       console.log(`👋 [#${id}] Disconnected (was not in any room)`);
//     }
//   });

//   ws.on("error", (e) => {
//     console.log(`❌ [#${id}] Error in room "${room}": ${e.message}`);
//     if (room) rooms[room]?.delete(ws);
//   });
// });

// function broadcast(room, sender, msg, senderId) {
//   const targets = [...(rooms[room] ?? [])].filter(
//     (c) => c !== sender && c.readyState === 1
//   );
//   console.log(`📢 [#${senderId}] Broadcasting type="${msg.type}" to ${targets.length} peer(s) in room "${room}"`);
//   const raw = JSON.stringify(msg);
//   targets.forEach((c) => c.send(raw));
// }

// function short(s) {
//   if (!s) return "none";
//   if (s.length < 16) return s;
//   return `${s.substring(0, 8)}…${s.substring(s.length - 8)}`;
// }