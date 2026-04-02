// lib/widgets/polkadot_identicon.dart
//
// Correct Polkadot identicon — 19 circles in a hexagonal layout.
// Accepts either an SS58 address string (any Substrate network) OR raw
// 32-byte public key bytes. The identicon matches Subscan, Polkadot.js,
// and all other official explorers.
//
// Algorithm ported from the official JS source:
// https://github.com/paritytech/oo7/blob/master/packages/polkadot-identicon/src/index.jsx
//
// Critical detail: the JS uses blakejs blake2b() which outputs 64 bytes
// (Blake2b-512) by default. The id array is therefore 64 bytes long,
// giving a 64-entry palette. Using Blake2b-256 (32 bytes) produces the
// wrong colors and wrong scheme selection.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pointycastle/digests/blake2b.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SS58 DECODING
// ─────────────────────────────────────────────────────────────────────────────
//
// SS58 layout:
//   single-byte prefix (0–63):   [ 1B prefix | 32B pubkey | 2B checksum ] = 35B
//   two-byte prefix  (64–16383): [ 2B prefix | 32B pubkey | 2B checksum ] = 36B
//
// Checksum = Blake2b-512("SS58PRE" || prefix_bytes || pubkey)[0..1]

const _kBase58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Decodes an SS58 address and returns the 32-byte public key,
/// or null if the address is invalid or the checksum fails.
Uint8List? ss58Decode(String address) {
  // ── Base58 → BigInt → bytes ────────────────────────────────────────────────
  var value = BigInt.zero;
  for (final ch in address.split('')) {
    final digit = _kBase58Alphabet.indexOf(ch);
    if (digit < 0) return null;
    value = value * BigInt.from(58) + BigInt.from(digit);
  }

  final hex = value.toRadixString(16);
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final rawBytes = Uint8List(padded.length ~/ 2);
  for (var i = 0; i < rawBytes.length; i++) {
    rawBytes[i] = int.parse(padded.substring(i * 2, i * 2 + 2), radix: 16);
  }

  // Re-add zero bytes for each leading '1' character (each '1' = 0x00 byte)
  final leadingOnes = address.split('').takeWhile((c) => c == '1').length;
  final decoded = Uint8List(leadingOnes + rawBytes.length);
  decoded.setRange(leadingOnes, decoded.length, rawBytes);

  if (decoded.isEmpty) return null;

  // ── Detect prefix length ───────────────────────────────────────────────────
  // Top 2 bits of byte 0 == 01 → two-byte prefix, else one-byte prefix.
  final prefixLen = (decoded[0] & 0xC0) == 0x40 ? 2 : 1;
  final expectedLen = prefixLen + 32 + 2;
  if (decoded.length != expectedLen) return null;

  // ── Verify checksum ────────────────────────────────────────────────────────
  final ss58Pre = Uint8List.fromList('SS58PRE'.codeUnits);
  final payload = decoded.sublist(0, prefixLen + 32);
  final toHash = Uint8List(ss58Pre.length + payload.length)
    ..setRange(0, ss58Pre.length, ss58Pre)
    ..setRange(ss58Pre.length, ss58Pre.length + payload.length, payload);

  final checksum = _blake2b512(toHash).sublist(0, 2);
  final embeddedChecksum = decoded.sublist(prefixLen + 32, prefixLen + 34);
  if (checksum[0] != embeddedChecksum[0] ||
      checksum[1] != embeddedChecksum[1]) {
    return null;
  }

  return decoded.sublist(prefixLen, prefixLen + 32);
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class PolkadotIdenticon extends StatelessWidget {
  /// SS58 address string (any Substrate network — Polkadot, Kusama, generic, etc.)
  final String? address;

  /// Raw 32-byte public key. Use when you already have the decoded bytes.
  final Uint8List? publicKeyBytes;

  final double size;

  const PolkadotIdenticon({
    super.key,
    this.address,
    this.publicKeyBytes,
    this.size = 48,
  }) : assert(
          address != null || publicKeyBytes != null,
          'Provide either address or publicKeyBytes',
        );

  @override
  Widget build(BuildContext context) {
    final pubkey = _resolvePublicKey();
    if (pubkey == null) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FallbackPainter(size: size)),
      );
    }
    final colors = PolkadotIdenticonColors.derive(pubkey);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PolkadotPainter(colors: colors, size: size),
      ),
    );
  }

  Uint8List? _resolvePublicKey() {
    if (address != null) return ss58Decode(address!);
    if (publicKeyBytes != null && publicKeyBytes!.length == 32) {
      return publicKeyBytes;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLOR DERIVATION
// ─────────────────────────────────────────────────────────────────────────────

class PolkadotIdenticonColors {
  /// Returns exactly 19 [Color]s — one per circle.
  static List<Color> derive(Uint8List publicKeyBytes) {
    // ── Step 1: Blake2b-512(pubkey) XOR Blake2b-512(32×0x00) ─────────────────
    //
    // IMPORTANT: The JS uses blakejs blake2b() which defaults to 64-byte
    // (512-bit) output. This gives a 64-byte id array and a 64-entry palette.
    // Using 32-byte output produces completely different colours.
    final zeroHash = _blake2b512(Uint8List(32)); // hash of 32 zero bytes
    final rawHash = _blake2b512(publicKeyBytes);
    final id = Uint8List(64);
    for (var i = 0; i < 64; i++) {
      id[i] = (rawHash[i] + 256 - zeroHash[i]) % 256;
    }

    // ── Step 2: Saturation from byte 29, range [30, 109] ─────────────────────
    final sat = (id[29] * 70 ~/ 256 + 26) % 80 + 30;

    // ── Step 3: Pick scheme using bytes 30 & 31 (total weight = 357) ─────────
    const schemes = <_Scheme>[
      _Scheme('target', 1,
          [0, 28, 0, 0, 28, 0, 0, 28, 0, 0, 28, 0, 0, 28, 0, 0, 28, 0, 1]),
      _Scheme('cube', 20,
          [0, 1, 3, 2, 4, 3, 0, 1, 3, 2, 4, 3, 0, 1, 3, 2, 4, 3, 5]),
      _Scheme('quazar', 16,
          [1, 2, 3, 1, 2, 4, 5, 5, 4, 1, 2, 3, 1, 2, 4, 5, 5, 4, 0]),
      _Scheme('flower', 32,
          [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 3]),
      _Scheme('cyclic', 32,
          [0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 6]),
      _Scheme('vmirror', 128,
          [0, 1, 2, 3, 4, 5, 3, 4, 2, 0, 1, 6, 7, 8, 9, 7, 8, 6, 10]),
      _Scheme('hmirror', 128,
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 8, 6, 7, 5, 3, 4, 2, 11]),
    ];
    final d = (id[30] + id[31] * 256) % 357;
    final scheme = _pickScheme(schemes, d);

    // ── Step 4: Build 64-entry palette from all 64 id bytes ──────────────────
    //
    //   adjusted = (id[i] + i % 28 * 58) % 256
    //   0   → #444444
    //   255 → transparent
    //   else → HSL(hue, sat%, lightness%)
    //     hue       = (adjusted % 64) * 360 / 64
    //     lightness = [53, 15, 35, 75][adjusted >> 6]
    final palette = List<Color>.generate(64, (i) {
      final b = (id[i] + i % 28 * 58) % 256;
      if (b == 0) return const Color(0xFF444444);
      if (b == 255) return Colors.transparent;
      final h = (b % 64) * 360.0 / 64.0;
      final l = const [53, 15, 35, 75][b >> 6];
      return HSLColor.fromAHSL(1.0, h, sat / 100.0, l / 100.0).toColor();
    });

    // ── Step 5: Apply rotation and map scheme → palette ───────────────────────
    //
    // Byte 28 drives rotation: rot = (id[28] % 6) * 3
    // Outer 18 circles: index into scheme.colors[(i + rot) % 18]
    // Center circle (18): always scheme.colors[18], no rotation
    final rot = (id[28] % 6) * 3;
    return List<Color>.generate(19, (i) {
      final schemeIdx = i < 18 ? (i + rot) % 18 : 18;
      final paletteIdx = scheme.colors[schemeIdx];
      return palette[paletteIdx]; // paletteIdx always < 64
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLAKE2B HELPERS (pointycastle)
// ─────────────────────────────────────────────────────────────────────────────

/// Blake2b-512 — 64-byte output. Used for both identicon hashing AND
/// SS58 checksum verification (the SS58 spec also uses 512-bit Blake2b).
Uint8List _blake2b512(Uint8List input) {
  final d = Blake2bDigest(digestSize: 64); // 512-bit = pointycastle default
  d.update(input, 0, input.length);
  final out = Uint8List(64);
  d.doFinal(out, 0);
  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL TYPES
// ─────────────────────────────────────────────────────────────────────────────

class _Scheme {
  final String name;
  final int freq;
  final List<int> colors; // 19 palette indices
  const _Scheme(this.name, this.freq, this.colors);
}

_Scheme _pickScheme(List<_Scheme> schemes, int d) {
  var cum = 0;
  for (final s in schemes) {
    cum += s.freq;
    if (d < cum) return s;
  }
  return schemes.last;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class _PolkadotPainter extends CustomPainter {
  final List<Color> colors; // exactly 19
  final double size;

  const _PolkadotPainter({required this.colors, required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    final s = size;
    final c = s / 2;

    // r = ring radius (center → outer dot center)
    // z = individual dot radius
    final r = s / 2 / 4 * 3;
    final z = s / 64 * 5;

    final rRoot3o2 = r * math.sqrt(3) / 2;
    final ro2 = r / 2;
    final rRoot3o4 = r * math.sqrt(3) / 4;
    final ro4 = r / 4;
    final r3o4 = r * 3 / 4;

    // Background (#EEEEEE matches the official JS)
    canvas.drawCircle(
      Offset(c, c),
      s / 2,
      Paint()..color = const Color(0xFFEEEEEE),
    );

    // 19 dot positions — exact order from official JS source
    // (0–17 clockwise from top; 18 = center)
    final positions = <Offset>[
      Offset(c, c - r), //  0  top
      Offset(c, c - ro2), //  1
      Offset(c - rRoot3o4, c - r3o4), //  2
      Offset(c - rRoot3o2, c - ro2), //  3
      Offset(c - rRoot3o4, c - ro4), //  4
      Offset(c - rRoot3o2, c), //  5
      Offset(c - rRoot3o2, c + ro2), //  6
      Offset(c - rRoot3o4, c + ro4), //  7
      Offset(c - rRoot3o4, c + r3o4), //  8
      Offset(c, c + r), //  9  bottom
      Offset(c, c + ro2), // 10
      Offset(c + rRoot3o4, c + r3o4), // 11
      Offset(c + rRoot3o2, c + ro2), // 12
      Offset(c + rRoot3o4, c + ro4), // 13
      Offset(c + rRoot3o2, c), // 14
      Offset(c + rRoot3o2, c - ro2), // 15
      Offset(c + rRoot3o4, c - ro4), // 16
      Offset(c + rRoot3o4, c - r3o4), // 17
      Offset(c, c), // 18 center
    ];

    for (var i = 0; i < 19; i++) {
      if (colors[i] == Colors.transparent) continue;
      canvas.drawCircle(positions[i], z, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant _PolkadotPainter old) =>
      old.colors != colors || old.size != size;
}

class _FallbackPainter extends CustomPainter {
  final double size;
  const _FallbackPainter({required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = const Color(0xFFCCCCCC),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
