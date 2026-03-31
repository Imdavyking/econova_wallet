// utils/utxo_script_utils.dart
//
// Shared output script utilities for all UTXO coins.
// Replaces btc_script_utils.dart — now generic across BTC, LTC, DOGE, DASH, etc.
//
// Supports all three standard address types:
//   P2PKH   — base58check        (1… / m… / n… / L… / M… / D… / X…)
//   P2WPKH  — bech32  witness v0 (bc1q… / tb1q… / ltc1q…)
//   P2TR    — bech32m witness v1 (bc1p… / tb1p…)  [BTC only in practice]
//
// Primary API
//   detectAddrType(address, hrp, network)  → UtxoAddrType
//   buildOutputScript(address, hrp, network) → Uint8List (scriptPubKey)
//
// BTC-specific convenience wrappers (for callers that still pass isTestnet bool)
//   detectBtcAddrType(address, isTestnet)  → UtxoAddrType
//   buildBtcOutputScript(address, isTestnet) → Uint8List

import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:flutter/foundation.dart';
import 'package:wallet_app/utils/bech32m.dart';
import 'package:wallet_app/utils/segwit_tx.dart';

// ─── Address type ─────────────────────────────────────────────────────────────

enum UtxoAddrType { p2pkh, p2wpkh, p2tr, unknown }

// Keep old name as alias so existing callers don't need updating immediately.
typedef BtcAddrType = UtxoAddrType;

// ─── Generic detection ────────────────────────────────────────────────────────

/// Detects the script type of [address] for the given [hrp] and [network].
///
/// Detection order: bech32 (P2WPKH) → bech32m (P2TR) → base58check (P2PKH).
///
/// [hrp]     — bech32 human-readable part: 'bc', 'tb', 'ltc', etc.
/// [network] — bitcoin_flutter NetworkType used for base58check validation.
UtxoAddrType detectAddrType(
  String address,
  String hrp,
  NetworkType network,
) {
  // bech32 v0 → P2WPKH
  try {
    final decoded = const Bech32Codec().decode(address);
    if (decoded.hrp == hrp && decoded.data[0] == 0) {
      return UtxoAddrType.p2wpkh;
    }
  } catch (_) {}

  // bech32m v1 → P2TR
  try {
    final decoded = bech32mDecode(address);
    if (decoded.hrp == hrp && decoded.data[0] == 1) {
      return UtxoAddrType.p2tr;
    }
  } catch (_) {}

  // base58check → P2PKH (bitcoin_flutter primary check)
  try {
    if (Address.validateAddress(address, network)) return UtxoAddrType.p2pkh;
  } catch (_) {}

  // base58check → P2PKH (version byte fallback for edge-case networks)
  try {
    final versionByte = bs58check.decode(address)[0];
    if (versionByte == network.pubKeyHash) return UtxoAddrType.p2pkh;
  } catch (_) {}

  return UtxoAddrType.unknown;
}

// ─── Generic script builder ───────────────────────────────────────────────────

/// Builds the correct scriptPubKey for [address].
///
/// Supports P2PKH, P2WPKH, and P2TR recipients.
/// Throws if [address] is not a recognised format for the given [hrp]/[network].
///
/// [hrp]     — bech32 human-readable part: 'bc', 'tb', 'ltc', etc.
/// [network] — bitcoin_flutter NetworkType used for base58check validation.
Uint8List buildOutputScript(
  String address,
  String hrp,
  NetworkType network,
) {
  switch (detectAddrType(address, hrp, network)) {
    case UtxoAddrType.p2wpkh:
      // OP_0 <20-byte witness program>
      return p2wpkhScript(
        Uint8List.fromList(const SegwitCodec().decode(address).program),
      );

    case UtxoAddrType.p2tr:
      // OP_1 OP_PUSHBYTES_32 <32-byte tweaked pubkey>
      final words = bech32mDecode(address).data.sublist(1);
      final program = Uint8List.fromList(convertBits(words, 5, 8, false));
      return Uint8List.fromList([0x51, 0x20, ...program]);

    case UtxoAddrType.p2pkh:
      // OP_DUP OP_HASH160 <20-byte pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
      final pubKeyHash = bs58check.decode(address).sublist(1);
      return Uint8List.fromList([
        0x76, 0xa9, 0x14, ...pubKeyHash, 0x88, 0xac,
      ]);

    case UtxoAddrType.unknown:
      throw Exception('Unsupported or invalid recipient address: $address');
  }
}

// ─── BTC convenience wrappers ─────────────────────────────────────────────────
//
// These preserve the original btc_script_utils.dart call sites so that
// NativeBtcCoin, TaprootBtcCoin, and LegacyUtxoCoin (BTC path) need
// zero changes to their existing code.

/// BTC-specific address type detection.
/// Wraps [detectAddrType] with the correct HRP and NetworkType for BTC.
UtxoAddrType detectBtcAddrType(String address, bool isTestnet) =>
    detectAddrType(
      address,
      isTestnet ? 'tb' : 'bc',
      isTestnet ? testnet : bitcoin,
    );

/// BTC-specific output script builder.
/// Wraps [buildOutputScript] with the correct HRP and NetworkType for BTC.
Uint8List buildBtcOutputScript(String address, bool isTestnet) =>
    buildOutputScript(
      address,
      isTestnet ? 'tb' : 'bc',
      isTestnet ? testnet : bitcoin,
    );

// ─── Bit conversion ───────────────────────────────────────────────────────────
//
// Used internally for bech32m witness program decoding (P2TR).
// Also re-exported so segwit_coin.dart and native_btc_coin.dart
// don't need a separate import.

List<int> convertBits(List<int> data, int from, int to, bool pad) {
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
}