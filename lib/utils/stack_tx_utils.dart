// utils/stacks_tx_utils.dart
// Shared signing & serialization helpers used by both StacksCoin and SIP010Coin.
// All functions are top-level so they are accessible across files without
// worrying about Dart's file-private (_) scoping rules.

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart' as pc;

// ─── Constants ────────────────────────────────────────────────────────────────

const int stacksMicroPerStx = 1000000;

// Auth / wire-format bytes
const int stacksAuthTypeStandard = 0x04;
const int stacksHashModeP2PKH = 0x00;
const int stacksKeyEncodingCompressed = 0x00;
const int stacksAnchorModeAny = 0x03;
const int stacksPostConditionModeAllow = 0x01;

// Payload type bytes
const int stacksPayloadTokenTransfer = 0x00;
const int stacksPayloadContractCall = 0x02;

// Principal type bytes
const int stacksPrincipalTypeStandard = 0x05;

// Memo: 34 raw bytes, zero-padded (no length prefix on the wire)
const int stacksMemoMaxBytes = 34;

// Conservative byte-size estimates used for fee calculation
const int stacksEstimatedStxTxBytes = 180;
const int stacksEstimatedContractCallBytes = 380;

// secp256k1 prime p (for y-coordinate recovery)
final BigInt stacksSecp256k1P = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
  radix: 16,
);

// ─── Hash helpers ─────────────────────────────────────────────────────────────

/// SHA-512/256 — FIPS 180-4 truncated variant (distinct IV from SHA-512).
Uint8List stacksSha512_256(Uint8List data) {
  final d = pc.SHA512tDigest(32)..update(data, 0, data.length);
  final out = Uint8List(32);
  d.doFinal(out, 0);
  return out;
}

/// Plain SHA-256.
Uint8List stacksSha256(Uint8List data) {
  final d = pc.SHA256Digest()..update(data, 0, data.length);
  final out = Uint8List(32);
  d.doFinal(out, 0);
  return out;
}

/// Manual HMAC-SHA256 — avoids pc.HMac entirely (which asserts digestSize*8 < 512).
Uint8List stacksHmacSha256(Uint8List key, Uint8List data) {
  const blockSize = 64;

  Uint8List k = key.length > blockSize ? stacksSha256(key) : key;
  if (k.length < blockSize) {
    final padded = Uint8List(blockSize);
    padded.setRange(0, k.length, k);
    k = padded;
  }

  final ipad = Uint8List(blockSize + data.length);
  final opad = Uint8List(blockSize + 32);
  for (int i = 0; i < blockSize; i++) {
    ipad[i] = k[i] ^ 0x36;
    opad[i] = k[i] ^ 0x5C;
  }
  ipad.setRange(blockSize, blockSize + data.length, data);
  final inner = stacksSha256(ipad);
  opad.setRange(blockSize, blockSize + 32, inner);
  return stacksSha256(opad);
}

/// RIPEMD-160(SHA-256(data)) — the standard hash160 used in P2PKH addresses.
Uint8List stacksHash160(Uint8List pubKey) {
  final shaOut = stacksSha256(pubKey);
  final rmd = pc.RIPEMD160Digest()..update(shaOut, 0, shaOut.length);
  final out = Uint8List(20);
  rmd.doFinal(out, 0);
  return out;
}

// ─── Key helpers ──────────────────────────────────────────────────────────────

/// Compressed SEC-encoded public key derived from raw 32-byte private key.
Uint8List stacksCompressedPubKey(Uint8List privKey) {
  final params = pc.ECDomainParameters('secp256k1');
  final d = BigInt.parse(HEX.encode(privKey), radix: 16);
  return (params.G * d)!.getEncoded(true);
}

// ─── Encoding helpers ─────────────────────────────────────────────────────────

Uint8List stacksU32BE(int value) => Uint8List(4)
  ..[0] = (value >> 24) & 0xFF
  ..[1] = (value >> 16) & 0xFF
  ..[2] = (value >> 8) & 0xFF
  ..[3] = value & 0xFF;

Uint8List stacksU64BE(BigInt value) {
  final buf = Uint8List(8);
  var v = value.toUnsigned(64);
  for (int i = 7; i >= 0; i--) {
    buf[i] = (v & BigInt.from(0xFF)).toInt();
    v >>= 8;
  }
  return buf;
}

Uint8List stacksBigIntTo32Bytes(BigInt v) =>
    Uint8List.fromList(HEX.decode(v.toRadixString(16).padLeft(64, '0')));

/// 34-byte memo field: content at offset 0, zero-padded, no length prefix.
Uint8List stacksMemoBytes(String memo) {
  final src = utf8.encode(memo);
  final buf = Uint8List(stacksMemoMaxBytes);
  final len = src.length.clamp(0, stacksMemoMaxBytes);
  buf.setRange(0, len, src);
  return buf;
}

bool stacksBytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ─── ECDSA helpers ────────────────────────────────────────────────────────────

/// RFC 6979 §2.3 — deterministic k using HMAC-SHA256.
BigInt stacksRfc6979(Uint8List privKey, Uint8List hash, BigInt n) {
  var v = Uint8List(32)..fillRange(0, 32, 0x01);
  var k = Uint8List(32)..fillRange(0, 32, 0x00);

  k = stacksHmacSha256(
      k, Uint8List.fromList([...v, 0x00, ...privKey, ...hash]));
  v = stacksHmacSha256(k, v);
  k = stacksHmacSha256(
      k, Uint8List.fromList([...v, 0x01, ...privKey, ...hash]));
  v = stacksHmacSha256(k, v);

  while (true) {
    v = stacksHmacSha256(k, v);
    final candidate = BigInt.parse(HEX.encode(v), radix: 16);
    if (candidate >= BigInt.one && candidate < n) return candidate;
    k = stacksHmacSha256(k, Uint8List.fromList([...v, 0x00]));
    v = stacksHmacSha256(k, v);
  }
}

/// Truncate hash to the bit-length of the curve order (SEC1).
BigInt stacksHashToInt(Uint8List hash, pc.ECDomainParameters params) {
  final orderBits = params.n.bitLength;
  final orderBytes = (orderBits + 7) ~/ 8;
  final len = hash.length < orderBytes ? hash.length : orderBytes;
  var z = BigInt.parse(HEX.encode(hash.sublist(0, len)), radix: 16);
  final excess = len * 8 - orderBits;
  if (excess > 0) z >>= excess;
  return z;
}

/// Lift x to a curve point on secp256k1 (y² = x³ + 7 mod p).
pc.ECPoint? stacksDecompressPoint(
    BigInt x, bool oddY, pc.ECDomainParameters params) {
  final ySquared =
      (x.modPow(BigInt.from(3), stacksSecp256k1P) + BigInt.from(7)) %
          stacksSecp256k1P;
  final exp = (stacksSecp256k1P + BigInt.one) >> 2;
  var y = ySquared.modPow(exp, stacksSecp256k1P);
  if (y.isOdd != oddY) y = stacksSecp256k1P - y;
  if ((y * y - ySquared) % stacksSecp256k1P != BigInt.zero) return null;
  return params.curve.createPoint(x, y);
}

/// Attempt to recover the public key from a signature + recovery ID.
pc.ECPoint? stacksRecoverPubKey(int recId, pc.ECSignature sig, Uint8List hash,
    pc.ECDomainParameters params) {
  final n = params.n;
  final e = stacksHashToInt(hash, params);
  final x = sig.r + BigInt.from(recId ~/ 2) * n;
  if (x >= stacksSecp256k1P) return null;
  final R = stacksDecompressPoint(x, recId & 1 == 1, params);
  if (R == null) return null;
  final rInv = sig.r.modInverse(n);
  final u1 = ((-e % n) * rInv) % n;
  final u2 = (sig.s * rInv) % n;
  return (params.G * u1)! + (R * u2)!;
}

/// Deterministic secp256k1 ECDSA (RFC 6979) with low-S normalisation.
/// Returns (ECSignature, recoveryId) where recoveryId ∈ {0, 1}.
(pc.ECSignature, int) stacksSecp256k1Sign(Uint8List privKey, Uint8List hash) {
  final params = pc.ECDomainParameters('secp256k1');
  final n = params.n;
  final d = BigInt.parse(HEX.encode(privKey), radix: 16);

  final k = stacksRfc6979(privKey, hash, n);

  final Renc = (params.G * k)!.getEncoded(false); // 04 || x(32) || y(32)
  final r = (BigInt.parse(HEX.encode(Renc.sublist(1, 33)), radix: 16)) % n;
  if (r == BigInt.zero) throw Exception('Invalid r (0)');

  final e = stacksHashToInt(hash, params);
  var s = (k.modInverse(n) * (e + d * r)) % n;
  if (s == BigInt.zero) throw Exception('Invalid s (0)');

  // Low-S normalisation
  if (s > (n >> 1)) s = n - s;

  final sig = pc.ECSignature(r, s);
  final pubKey = (params.G * d)!;
  final expected = pubKey.getEncoded(true);

  for (int id = 0; id <= 1; id++) {
    final candidate = stacksRecoverPubKey(id, sig, hash, params);
    if (candidate == null) continue;
    if (stacksBytesEqual(candidate.getEncoded(true), expected)) {
      return (sig, id);
    }
  }
  throw Exception('Failed to compute secp256k1 recovery ID');
}

// ─── Transaction builder ──────────────────────────────────────────────────────

/// Assembles and signs a standard single-sig Stacks transaction.
///
/// The caller is responsible for building the [payload] bytes (token-transfer
/// or contract-call).  Everything else — the auth envelope, the two-phase hash,
/// and the 65-byte signature — is handled here.
///
/// Two-phase signing (mirrors @stacks/transactions):
///   1. initialHash   = sha512_256( tx with nonce=0, fee=0, sig=0x00…00 )
///   2. presignHash   = sha512_256( initialHash | authType | fee | nonce )
///   3. Sign presignHash with secp256k1 → { recId(1) | r(32) | s(32) }
///   4. Re-serialise with real nonce, fee, and the signature.
Uint8List stacksBuildSignedTx({
  required int txVersion,
  required int chainId,
  required Uint8List privKey,
  required Uint8List senderHash160,
  required BigInt nonce,
  required BigInt fee,
  required Uint8List payload,
}) {
  // Inner helper: wire header + auth envelope + post-conditions + payload
  Uint8List assemble(BigInt n, BigInt f, Uint8List sig) => (BytesBuilder()
        // Header
        ..addByte(txVersion)
        ..add(stacksU32BE(chainId))
        // Auth — standard single-sig P2PKH spending condition
        ..addByte(stacksAuthTypeStandard)
        ..addByte(stacksHashModeP2PKH)
        ..add(senderHash160)
        ..add(stacksU64BE(n))
        ..add(stacksU64BE(f))
        ..addByte(stacksKeyEncodingCompressed)
        ..add(sig)
        // Anchor + post-conditions
        ..addByte(stacksAnchorModeAny)
        ..addByte(stacksPostConditionModeAllow)
        ..add(stacksU32BE(0)) // empty post-condition list
        // Payload (caller-supplied)
        ..add(payload))
      .toBytes();

  // Phase 1: initial hash (zeroed nonce, fee, and signature)
  final unsigned = assemble(BigInt.zero, BigInt.zero, Uint8List(65));
  final initialHash = stacksSha512_256(unsigned);

  // Phase 2: pre-sign hash folds in the real fee and nonce
  final preSignInput = (BytesBuilder()
        ..add(initialHash)
        ..addByte(stacksAuthTypeStandard)
        ..add(stacksU64BE(fee))
        ..add(stacksU64BE(nonce)))
      .toBytes();
  final presignHash = stacksSha512_256(preSignInput);

  // Sign
  final (sig, recoveryId) = stacksSecp256k1Sign(privKey, presignHash);
  final sigBytes = Uint8List(65)
    ..[0] = recoveryId
    ..setRange(1, 33, stacksBigIntTo32Bytes(sig.r))
    ..setRange(33, 65, stacksBigIntTo32Bytes(sig.s));

  // Final: real nonce + fee + real signature
  return assemble(nonce, fee, sigBytes);
}
