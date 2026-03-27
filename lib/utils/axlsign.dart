// axlsign.dart
// Dart port of axlsign.js / axlsign.swift
// Curve25519 signatures with X25519 keys (Waves native signing)
//
// Original: https://github.com/wavesplatform/curve25519-js
// Swift port: https://github.com/miguelsandro/curve25519-swift
// Dart port: derived from Swift port above
//
// Usage:
//   final sig = axlSign(privateKeyBytes, messageBytes);  // returns 64-byte signature

import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

// ─── Field element helpers ───────────────────────────────────────────────────

List<int> _gf([List<int>? ai]) {
  final r = List<int>.filled(16, 0);
  if (ai != null) {
    for (int i = 0; i < ai.length; i++) {
      r[i] = ai[i];
    }
  }
  return r;
}

final _gf0 = _gf();
final _gf1 = _gf([1]);
final _121665 = _gf([0xdb41, 1]);

final _D = _gf([
  0x78a3,
  0x1359,
  0x4dca,
  0x75eb,
  0xd8ab,
  0x4141,
  0x0a4d,
  0x0070,
  0xe898,
  0x7779,
  0x4079,
  0x8cc7,
  0xfe73,
  0x2b6f,
  0x6cee,
  0x5203,
]);

final _D2 = _gf([
  0xf159,
  0x26b2,
  0x9b94,
  0xebd6,
  0xb156,
  0x8283,
  0x149a,
  0x00e0,
  0xd130,
  0xeef3,
  0x80f2,
  0x198e,
  0xfce7,
  0x56df,
  0xd9dc,
  0x2406,
]);

final _X = _gf([
  0xd51a,
  0x8f25,
  0x2d60,
  0xc956,
  0xa7b2,
  0x9525,
  0xc760,
  0x692c,
  0xdc5c,
  0xfdd6,
  0xe231,
  0xc0a4,
  0x53fe,
  0xcd6e,
  0x36d3,
  0x2169,
]);

final _Y = _gf([
  0x6658,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
  0x6666,
]);

final _I = _gf([
  0xa0b0,
  0x4a0e,
  0x1b27,
  0xc4ee,
  0xe478,
  0xad2f,
  0x1806,
  0x2f43,
  0xd7a7,
  0x3dfb,
  0x0099,
  0x2b4d,
  0xdf0b,
  0x4fc1,
  0x2480,
  0x2b83,
]);

final _L = <int>[
  0xed,
  0xd3,
  0xf5,
  0x5c,
  0x1a,
  0x63,
  0x12,
  0x58,
  0xd6,
  0x9c,
  0xf7,
  0xa2,
  0xde,
  0xf9,
  0xde,
  0x14,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0x10,
];

int _shr32(int x, int n) {
  return (x & 0xFFFFFFFF) >> n;
}

void _car25519(List<int> o) {
  int c = 1;
  for (int i = 0; i < 16; i++) {
    int v = o[i] + c + 65535;
    c = v >> 16;
    o[i] = v - c * 65536;
  }
  o[0] += c - 1 + 37 * (c - 1);
}

void _sel25519(List<int> p, List<int> q, int b) {
  final c = ~(b - 1);
  for (int i = 0; i < 16; i++) {
    final t = c & (p[i] ^ q[i]);
    p[i] ^= t;
    q[i] ^= t;
  }
}

void _pack25519(Uint8List o, List<int> n) {
  final m = _gf();
  final t = List<int>.from(n);
  _car25519(t);
  _car25519(t);
  _car25519(t);
  for (int j = 0; j < 2; j++) {
    m[0] = t[0] - 0xffed;
    for (int i = 1; i <= 14; i++) {
      m[i] = t[i] - 0xffff - ((m[i - 1] >> 16) & 1);
      m[i - 1] &= 0xffff;
    }
    m[15] = t[15] - 0x7fff - ((m[14] >> 16) & 1);
    final b = (m[15] >> 16) & 1;
    m[14] &= 0xffff;
    _sel25519(t, m, 1 - b);
  }
  for (int i = 0; i < 16; i++) {
    o[2 * i] = t[i] & 0xff;
    o[2 * i + 1] = (t[i] >> 8) & 0xff;
  }
}

int _par25519(List<int> a) {
  final d = Uint8List(32);
  _pack25519(d, a);
  return d[0] & 1;
}

void _unpack25519(List<int> o, Uint8List n) {
  for (int i = 0; i < 16; i++) {
    o[i] = n[2 * i] + (n[2 * i + 1] << 8);
  }
  o[15] &= 0x7fff;
}

void _fieldAdd(List<int> o, List<int> a, List<int> b) {
  for (int i = 0; i < 16; i++) {
    o[i] = a[i] + b[i];
  }
}

void _fieldSub(List<int> o, List<int> a, List<int> b) {
  for (int i = 0; i < 16; i++) {
    o[i] = a[i] - b[i];
  }
}

void _fieldMul(List<int> o, List<int> a, List<int> b) {
  final at = List<int>.filled(32, 0);
  for (int i = 0; i < 16; i++) {
    final v = a[i];
    for (int j = 0; j < 16; j++) {
      at[j + i] += v * b[j];
    }
  }
  for (int i = 0; i < 15; i++) {
    at[i] += 38 * at[i + 16];
  }
  int c = 1;
  for (int i = 0; i < 16; i++) {
    int v = at[i] + c + 65535;
    c = v >> 16;
    at[i] = v - c * 65536;
  }
  at[0] += c - 1 + 37 * (c - 1);
  c = 1;
  for (int i = 0; i < 16; i++) {
    int v = at[i] + c + 65535;
    c = v >> 16;
    at[i] = v - c * 65536;
  }
  at[0] += c - 1 + 37 * (c - 1);
  for (int i = 0; i < 16; i++) {
    o[i] = at[i];
  }
}

void _fieldSqr(List<int> o, List<int> a) => _fieldMul(o, a, a);

void _inv25519(List<int> o, List<int> inp) {
  final c = List<int>.from(inp);
  for (int i = 253; i >= 0; i--) {
    _fieldSqr(c, c);
    if (i != 2 && i != 4) _fieldMul(c, c, inp);
  }
  for (int i = 0; i < 16; i++) {
    o[i] = c[i];
  }
}

void _set25519(List<int> r, List<int> a) {
  for (int i = 0; i < 16; i++) {
    r[i] = a[i];
  }
}

// ─── Point operations (twisted Edwards) ──────────────────────────────────────

void _pointAdd(List<List<int>> p, List<List<int>> q) {
  final a = _gf(), b = _gf(), c = _gf(), d = _gf();
  final e = _gf(), f = _gf(), g = _gf(), h = _gf(), t = _gf();
  _fieldSub(a, p[1], p[0]);
  _fieldSub(t, q[1], q[0]);
  _fieldMul(a, a, t);
  _fieldAdd(b, p[0], p[1]);
  _fieldAdd(t, q[0], q[1]);
  _fieldMul(b, b, t);
  _fieldMul(c, p[3], q[3]);
  _fieldMul(c, c, _D2);
  _fieldMul(d, p[2], q[2]);
  _fieldAdd(d, d, d);
  _fieldSub(e, b, a);
  _fieldSub(f, d, c);
  _fieldAdd(g, d, c);
  _fieldAdd(h, b, a);
  _fieldMul(p[0], e, f);
  _fieldMul(p[1], h, g);
  _fieldMul(p[2], g, f);
  _fieldMul(p[3], e, h);
}

void _cswap(List<List<int>> p, List<List<int>> q, int b) {
  for (int i = 0; i < 4; i++) {
    _sel25519(p[i], q[i], b);
  }
}

void _pack(Uint8List r, List<List<int>> p) {
  final tx = _gf(), ty = _gf(), zi = _gf();
  _inv25519(zi, p[2]);
  _fieldMul(tx, p[0], zi);
  _fieldMul(ty, p[1], zi);
  _pack25519(r, ty);
  r[31] ^= _par25519(tx) << 7;
}

void _scalarmult(List<List<int>> p, List<List<int>> q, Uint8List s) {
  _set25519(p[0], _gf0);
  _set25519(p[1], _gf1);
  _set25519(p[2], _gf1);
  _set25519(p[3], _gf0);
  for (int i = 255; i >= 0; i--) {
    final b = (_shr32(s[i >> 3], i & 7)) & 1;
    _cswap(p, q, b);
    _pointAdd(q, p);
    _pointAdd(p, p);
    _cswap(p, q, b);
  }
}

void _scalarbase(List<List<int>> p, Uint8List s) {
  final q = [_gf(), _gf(), _gf(), _gf()];
  _set25519(q[0], _X);
  _set25519(q[1], _Y);
  _set25519(q[2], _gf1);
  _fieldMul(q[3], _X, _Y);
  _scalarmult(p, q, s);
}

// ─── Scalar mod L ────────────────────────────────────────────────────────────

void _modL(Uint8List r, List<int> x) {
  int carry;
  for (int i = 63; i >= 32; i--) {
    carry = 0;
    int j = i - 32;
    final k = i - 12;
    while (j < k) {
      x[j] += carry - 16 * x[i] * _L[j - (i - 32)];
      carry = (x[j] + 128) >> 8;
      x[j] -= carry * 256;
      j++;
    }
    x[j] += carry;
    x[i] = 0;
  }
  carry = 0;
  for (int j = 0; j < 32; j++) {
    x[j] += carry - (x[31] >> 4) * _L[j];
    carry = x[j] >> 8;
    x[j] &= 255;
  }
  for (int j = 0; j < 32; j++) {
    x[j] -= carry * _L[j];
  }
  for (int i = 0; i < 32; i++) {
    x[i + 1] += x[i] >> 8;
    r[i] = x[i] & 255;
  }
}

void _reduce(Uint8List r) {
  final x = List<int>.filled(64, 0);
  for (int i = 0; i < 64; i++) {
    x[i] = r[i];
  }
  for (int i = 0; i < 64; i++) {
    r[i] = 0;
  }
  _modL(r, x);
}

// ─── SHA-512 via crypto package ───────────────────────────────────────────────

Uint8List _sha512(List<int> data) =>
    Uint8List.fromList(crypto.sha512.convert(data).bytes);

// ─── curve25519_sign (direct, no random) ─────────────────────────────────────

Uint8List _cryptoSignDirect(Uint8List m, Uint8List sk) {
  // sk = 64 bytes: [0..31] = private scalar, [32..63] = Ed25519 public key
  final n = m.length;
  final sm = Uint8List(n + 64);

  for (int i = 0; i < n; i++) {
    sm[64 + i] = m[i];
  }
  for (int i = 0; i < 32; i++) {
    sm[32 + i] = sk[i];
  }

  // r = SHA512(sk[0..31] || m)
  final rHash = _sha512(sm.sublist(32, n + 64));
  final r = Uint8List.fromList(rHash);
  _reduce(r);

  final p = [_gf(), _gf(), _gf(), _gf()];
  _scalarbase(p, r);
  _pack(sm, p); // sm[0..31] = R

  for (int i = 0; i < 32; i++) {
    sm[32 + i] = sk[32 + i]; // sm[32..63] = edPk
  }

  // h = SHA512(R || edPk || m)
  final hHash = _sha512(sm.sublist(0, n + 64));
  final h = Uint8List.fromList(hHash);
  _reduce(h);

  final x = List<int>.filled(64, 0);
  for (int i = 0; i < 32; i++) {
    x[i] = r[i];
  }
  for (int i = 0; i < 32; i++) {
    for (int j = 0; j < 32; j++) {
      x[i + j] += h[i] * sk[j];
    }
  }

  final sBytes = sm.sublist(32, n + 64);
  _modL(sBytes, x);
  for (int i = 0; i < sBytes.length; i++) {
    sm[32 + i] = sBytes[i];
  }

  return sm;
}

// ─── Public API ──────────────────────────────────────────────────────────────

/// Signs [message] with the native Waves private key [secretKey] (32 bytes).
/// Returns a 64-byte signature.
/// This is the axlsign algorithm used by the Waves TS SDK and Trust Wallet.
Uint8List axlSign(Uint8List secretKey, Uint8List message) {
  // Build Ed25519 secret key from Curve25519 private key
  final edsk = Uint8List(64);
  for (int i = 0; i < 32; i++) {
    edsk[i] = secretKey[i];
  }

  // Clamp
  edsk[0] &= 248;
  edsk[31] &= 127;
  edsk[31] |= 64;

  // Derive Ed25519 public key
  final p = [_gf(), _gf(), _gf(), _gf()];
  _scalarbase(p, edsk);
  final pk = Uint8List(32);
  _pack(pk, p);
  for (int i = 0; i < 32; i++) {
    edsk[32 + i] = pk[i];
  }

  // Remember sign bit
  final signBit = edsk[63] & 128;

  // Sign
  final sm = _cryptoSignDirect(message, edsk);

  // Embed sign bit into signature byte 63
  sm[63] |= signBit;

  // Return just the 64-byte signature
  return sm.sublist(0, 64);
}
