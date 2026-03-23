// utils/btc_script_utils.dart
//
// Shared Bitcoin output script utilities used by NativeBtcCoin and LegacyUtxoCoin.
//
// Supports all three standard address types so any coin can send to any recipient:
//   P2PKH   — base58check  (1…  / m… / n…)
//   P2WPKH  — bech32  v0   (bc1q… / tb1q…)
//   P2TR    — bech32m v1   (bc1p… / tb1p…)

import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:flutter/foundation.dart';
import 'package:wallet_app/utils/bech32m.dart';
import 'package:wallet_app/utils/segwit_tx.dart';

// ─── Address type ─────────────────────────────────────────────────────────────

enum BtcAddrType { p2pkh, p2wpkh, p2tr, unknown }

/// Detects the script type of [address] for the given network.
/// Try bech32 → bech32m → base58check in order.
BtcAddrType detectBtcAddrType(String address, bool isTestnet) {
  final expectedHrp = isTestnet ? 'tb' : 'bc';

  // bech32  (P2WPKH — witness version 0)
  try {
    final decoded = const Bech32Codec().decode(address);
    if (decoded.hrp == expectedHrp && decoded.data[0] == 0) {
      return BtcAddrType.p2wpkh;
    }
  } catch (_) {}

  // bech32m  (P2TR — witness version 1)
  try {
    final decoded = bech32mDecode(address);
    if (decoded.hrp == expectedHrp && decoded.data[0] == 1) {
      return BtcAddrType.p2tr;
    }
  } catch (_) {}

  // base58check  (P2PKH)
  try {
    final network = isTestnet ? testnet : bitcoin;
    if (Address.validateAddress(address, network)) return BtcAddrType.p2pkh;
  } catch (_) {}

  return BtcAddrType.unknown;
}

// ─── Script builder ───────────────────────────────────────────────────────────

/// Builds the correct scriptPubKey for [address].
///
/// Used by both [NativeBtcCoin] and [LegacyUtxoCoin] so SegWit coins can send
/// to legacy recipients and legacy coins can send to SegWit recipients.
///
/// Throws if [address] is not a recognised format for the given network.
Uint8List buildBtcOutputScript(String address, bool isTestnet) {
  switch (detectBtcAddrType(address, isTestnet)) {
    case BtcAddrType.p2wpkh:
      // OP_0 <20-byte hash>
      return p2wpkhScript(
        Uint8List.fromList(const SegwitCodec().decode(address).program),
      );

    case BtcAddrType.p2tr:
      // OP_1 OP_PUSHBYTES_32 <32-byte tweaked pubkey>
      final words = bech32mDecode(address).data.sublist(1);
      final program = Uint8List.fromList(_convertBits(words, 5, 8, false));
      return Uint8List.fromList([0x51, 0x20, ...program]);

    case BtcAddrType.p2pkh:
      // OP_DUP OP_HASH160 <20-byte pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
      final pubKeyHash = bs58check.decode(address).sublist(1);
      return Uint8List.fromList([
        0x76,
        0xa9,
        0x14,
        ...pubKeyHash,
        0x88,
        0xac,
      ]);

    case BtcAddrType.unknown:
      throw Exception('Unsupported or invalid recipient address: $address');
  }
}

// ─── Internal ─────────────────────────────────────────────────────────────────

List<int> _convertBits(List<int> data, int from, int to, bool pad) {
  int acc = 0, bits = 0;
  final result = <int>[];
  final maxv = (1 << to) - 1;
  for (final value in data) {
    acc = ((acc << from) | value) & 0xfff;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  }
  if (pad && bits > 0) result.add((acc << (to - bits)) & maxv);
  return result;
}// TODO Implement this library.