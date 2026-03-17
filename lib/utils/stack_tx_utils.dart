// utils/stacks_tx_utils.dart
// Shared signing & serialization helpers used by both StacksCoin and SIP010Coin.
// All functions are top-level so they are accessible across files without
// worrying about Dart's file-private (_) scoping rules.

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:wallet_app/utils/c32check.dart';

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

/// Signs [message] (as a UTF-8 string) with [privKey] using the same
/// algorithm as Stacks.js `signMessageHashRsv`:
///
///   1. Prefix the message.
///   2. SHA-256 hash the prefixed bytes.
///   3. secp256k1 sign the hash (deterministic, RFC 6979).
///   4. Normalise s to low-s (BIP-62).
///   5. Return 65 bytes: [ recId (1) | r (32) | s (32) ].
///
/// The hex of the returned bytes is the `rsv` signature string that
/// Stacks dApps verify with `verifyMessageSignatureRsv`.
// In stack_tx_utils.dart

const String _stacksPrefixCurrent = "\x17Stacks Signed Message:\n";
const String _stacksPrefixLegacy = "\x18Stacks Message Signing:\n";

/// Signs a message using the Stacks personal-sign format.
///
/// [isLegacy] = false (default) → current prefix '\x17Stacks Signed Message:\n'
///              (Stacks.js >=5.x, Xverse, Leather)
/// [isLegacy] = true            → legacy prefix '\x18Stacks Message Signing:\n'
///              (Stacks.js <=4.x, old blockstack.js dApps)
///
/// verifyMessageSignatureRsv() on the JS side handles both automatically.
Uint8List stacksSignMessage(Uint8List privKey, String message,
    {bool isLegacy = false}) {
  final prefix = isLegacy ? _stacksPrefixLegacy : _stacksPrefixCurrent;

  final msgBytes = utf8.encode(message);

  final hash = stacksSha256(Uint8List.fromList([
    ...utf8.encode(prefix),
    ..._varuint(msgBytes.length),
    ...msgBytes,
  ]));

  

  return _secp256k1SignRecoverable(privKey, hash);
}

Uint8List _varuint(int value) {
  if (value < 0xfd) {
    return Uint8List.fromList([value]);
  } else if (value <= 0xffff) {
    return Uint8List.fromList([0xfd, value & 0xff, (value >> 8) & 0xff]);
  } else {
    return Uint8List.fromList([
      0xfe,
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ]);
  }
}

/// secp256k1 deterministic signing (RFC 6979) with low-s normalisation.
/// Returns [ recId (1) | r (32) | s (32) ].
///
/// This reuses the same secp256k1 domain params / signer that
/// stacksBuildSignedTx uses.  Pull the ECDomainParameters instance and
/// ECDSASigner construction out of stacksBuildSignedTx (or duplicate the
/// two lines below) so they match your existing imports exactly.
Uint8List _secp256k1SignRecoverable(Uint8List privKey, Uint8List hash) {
  final domainParams = pc.ECDomainParameters('secp256k1');
  final privScalar = BigInt.parse(HEX.encode(privKey), radix: 16);
  final ecPrivKey = pc.ECPrivateKey(privScalar, domainParams);

  final signer = pc.ECDSASigner(null, pc.HMac(pc.SHA256Digest(), 32));
  signer.init(true, pc.PrivateKeyParameter<pc.ECPrivateKey>(ecPrivKey));

  // Low-s normalisation (BIP-62): if s > n/2, replace with n - s.
  pc.ECSignature sig = signer.generateSignature(hash) as pc.ECSignature;
  final halfN = domainParams.n >> 1;
  if (sig.s > halfN) {
    sig = pc.ECSignature(sig.r, domainParams.n - sig.s);
  }

  // Derive recovery id (0 or 1) by trying both and checking the recovered
  // public key against the expected compressed public key.
  final expectedPub = HEX.encode(stacksCompressedPubKey(privKey));
  int recId = 0;
  for (int candidate = 0; candidate < 2; candidate++) {
    final recovered = _recoverPublicKey(hash, sig, candidate, domainParams);
    if (recovered != null && HEX.encode(recovered) == expectedPub) {
      recId = candidate;
      break;
    }
  }

  final r = _bigIntTo32Bytes(sig.r);
  final s = _bigIntTo32Bytes(sig.s);
  return Uint8List.fromList([recId, ...r, ...s]);
}

/// Attempts to recover the compressed public key for [sig] using [recId].
/// Returns null if the recovery point is at infinity or off the curve.
Uint8List? _recoverPublicKey(
  Uint8List hash,
  pc.ECSignature sig,
  int recId,
  pc.ECDomainParameters params,
) {
  try {
    final n = params.n;
    final x = sig.r + BigInt.from(recId ~/ 2) * n;
    if (x >= BigInt.from(params.curve.fieldSize)) return null;

    final R = params.curve.decompressPoint(recId & 1, x);

    final e = BigInt.parse(HEX.encode(hash), radix: 16);
    final rInv = sig.r.modInverse(n);
    final eNeg = (-e) % n;

    // Q = rInv·s·R + rInv·(-e)·G  — ECPoint.operator* expects BigInt
    final sScalar = rInv * sig.s % n;
    final eScalar = rInv * eNeg % n;
    final Q = (R * sScalar)! + (params.G * eScalar)!;
    if (Q == null || Q.isInfinity) return null;

    // Return compressed public key (33 bytes)
    return Q.getEncoded(true);
  } catch (_) {
    return null;
  }
}

Uint8List _bigIntTo32Bytes(BigInt v) {
  final hex = v.toRadixString(16).padLeft(64, '0');
  return Uint8List.fromList(HEX.decode(hex));
}

// ─── ADD TO stack_tx_utils.dart ───────────────────────────────────────────────
//
// Paste this block anywhere after the existing imports in stack_tx_utils.dart.
// It requires no new imports beyond what the file already has:
//   dart:typed_data, package:hex/hex.dart, and the secp256k1 signer that
//   stacksBuildSignedTx already uses internally.
//
// The only extra dependency is SHA-256, which is available via the
// `blockchain_utils` package already imported elsewhere in the project
// (look for sha256 / SHA256Digest usage in rpc_urls.dart / other utils).
// If your stack_tx_utils.dart already imports a SHA-256 helper, use that.
// Otherwise add:  import 'package:crypto/crypto.dart';
// and replace stacksSha256(data) → sha256.convert(data).bytes.
// ─────────────────────────────────────────────────────────────────────────────

/// Signs an already-computed [hash] directly with secp256k1 — no message
/// prefix applied. Used for SIP-018 structured messages where the caller
/// builds the hash manually.
///
/// Returns 65 bytes: [ recId (1) | r (32) | s (32) ]
Uint8List stacksSignRaw(Uint8List privKey, Uint8List hash) =>
    _secp256k1SignRecoverable(privKey, hash);

/// Re-signs a pre-serialised Stacks transaction [rawTx] with [privKey].
///
/// The Stacks transaction wire format places a 65-byte presig at a fixed
/// offset inside the spending condition. This function:
///   1. Locates the presig field.
///   2. Computes the sighash (SHA-512/256 of the tx with presig zeroed).
///   3. Replaces the presig with the real recoverable signature.
///
/// Layout assumed: standard single-sig spending condition (P2PKH).
///
///   offset  size  field
///   ──────  ────  ──────────────────────────────────────────
///   0       1     tx version
///   1       4     chain id
///   5       1     auth type  (0x04 = standard)
///   6       1     hash mode  (0x00 = P2PKH compressed)
///   7       20    signer hash160
///   27      8     nonce (big-endian uint64)
///   35      8     fee  (big-endian uint64)
///   43      1     key encoding (0x00 = compressed)
///   44      65    signature  ← this is what we replace
///   109     …     payload
///
/// If the tx uses a different spending-condition layout this will throw;
/// callers should catch and surface the error to the user.
Uint8List stacksResignTx(Uint8List rawTx, Uint8List privKey) {
  // The presig occupies bytes 44–108 (0-indexed).
  const sigOffset = 44;
  const sigLength = 65;

  if (rawTx.length < sigOffset + sigLength) {
    throw Exception('stacksResignTx: tx too short to contain a signature');
  }

  // 1. Zero out the presig field to get the signing bytes.
  final forSigning = Uint8List.fromList(rawTx);
  for (int i = sigOffset; i < sigOffset + sigLength; i++) {
    forSigning[i] = 0x00;
  }

  // 2. Compute the Stacks sighash: SHA-512/256 of the zeroed tx.
  //    Stacks uses SHA-512/256 (truncated SHA-512), not SHA-256.
  //    Replace the call below with your project's SHA-512/256 helper.
  //    If you use blockchain_utils:  SHA512256Digest().process(forSigning)
  //    If you use pointycastle:      SHA512tDigest(256).process(forSigning)
  final sigHash = stacksSha512_256(forSigning); // ← replace with actual helper

  // 3. Sign the sighash and write back into the tx.
  final sig = _secp256k1SignRecoverable(privKey, sigHash);
  final signed = Uint8List.fromList(rawTx);
  signed.setRange(sigOffset, sigOffset + sigLength, sig);
  return signed;
}

// ─── ADD TO stack_tx_utils.dart ───────────────────────────────────────────────
// Paste this block into stack_tx_utils.dart.
// Once added, delete the private duplicates from SIP010Coin and StacksNFTCoin
// and replace their calls with these public versions.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Hiro API base URL ────────────────────────────────────────────────────────

String stacksApiUrl(bool isTestnet) =>
    isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';

// ─── Chain constants ──────────────────────────────────────────────────────────

int stacksTxVersion(bool isTestnet) => isTestnet ? 0x80 : 0x00;
int stacksChainId(bool isTestnet) => isTestnet ? 0x80000000 : 0x00000001;

// ─── Fee / nonce ──────────────────────────────────────────────────────────────

Future<int> stacksFetchFeeRate(bool isTestnet) async {
  try {
    final res = await http
        .get(Uri.parse('${stacksApiUrl(isTestnet)}/v2/fees/transfer'));
    if (res.statusCode ~/ 100 == 2) {
      return int.parse(jsonDecode(res.body).toString());
    }
  } catch (_) {}
  return 10; // fallback: 10 µSTX / byte
}

Future<int> stacksFetchNonce(bool isTestnet, String address) async {
  final res = await http.get(
    Uri.parse('${stacksApiUrl(isTestnet)}/v2/accounts/$address?proof=0'),
  );
  if (res.statusCode ~/ 100 != 2) throw Exception('STX nonce fetch failed');
  return jsonDecode(res.body)['nonce'] as int;
}

// ─── Clarity value encoders ───────────────────────────────────────────────────

/// Clarity UInt: type byte 0x01 | 16-byte big-endian unsigned integer.
Uint8List clarityUInt(BigInt value) {
  final buf = Uint8List(17)..[0] = 0x01;
  var v = value.toUnsigned(128);
  for (int i = 16; i >= 1; i--) {
    buf[i] = (v & BigInt.from(0xFF)).toInt();
    v >>= 8;
  }
  return buf;
}

/// Returns the 17-byte Clarity uint as a hex string (no 0x prefix).
/// Used when passing arguments to read-only contract calls via the API.
String clarityUIntHex(BigInt value) => HEX.encode(clarityUInt(value));

/// Clarity standard principal: type 0x05 | version (1 byte) | hash160 (20 bytes).
Uint8List clarityStandardPrincipal(int version, Uint8List hash160) =>
    (BytesBuilder()
          ..addByte(0x05)
          ..addByte(version)
          ..add(hash160))
        .toBytes();

/// Clarity (optional (buff N)):
///   - None  → 0x09
///   - Some  → 0x0a | 0x02 | 4-byte big-endian length | bytes (capped at [stacksMemoMaxBytes])
Uint8List clarityOptionalMemo(String? memo) {
  final text = (memo ?? '').trim();
  if (text.isEmpty) return Uint8List(1)..[0] = 0x09;
  final content = utf8.encode(text);
  final len = content.length.clamp(0, stacksMemoMaxBytes);
  return (BytesBuilder()
        ..addByte(0x0a)
        ..addByte(0x02)
        ..add(stacksU32BE(len))
        ..add(content.sublist(0, len)))
      .toBytes();
}

// ─── Contract-call payload builder ───────────────────────────────────────────

/// Serialises a Clarity contract-call payload (payload type 0x02).
///
/// Wire layout:
///   [1]     payload type  (stacksPayloadContractCall = 0x02)
///   [1]     contract address version
///   [20]    contract address hash160
///   [1+N]   contract name  (1-byte length prefix + UTF-8 bytes)
///   [1+N]   function name  (1-byte length prefix + UTF-8 bytes)
///   [4]     argument count (big-endian uint32)
///   [N×]    Clarity-encoded arguments
///
/// Used by SIP010Coin, StacksNFTCoin, and _callContract in StacksHandler.
Uint8List stacksBuildContractCallPayload({
  required int contractVersion,
  required Uint8List contractHash160,
  required String contractName,
  required String functionName,
  required List<Uint8List> args,
}) {
  final nameBytes = utf8.encode(contractName);
  final fnBytes = utf8.encode(functionName);

  final bb = BytesBuilder()
    ..addByte(stacksPayloadContractCall)
    ..addByte(contractVersion)
    ..add(contractHash160)
    ..addByte(nameBytes.length)
    ..add(nameBytes)
    ..addByte(fnBytes.length)
    ..add(fnBytes)
    ..add(stacksU32BE(args.length));

  for (final arg in args) {
    bb.add(arg);
  }
  return bb.toBytes();
}

// ─── Clarity response parsers ─────────────────────────────────────────────────

/// Extracts a Stacks address from a hex-encoded Clarity
/// `(ok (some (principal …)))` read-only call response.
/// Returns null if parsing fails.
String? clarityParsePrincipal(String hex) {
  try {
    final h = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = HEX.decode(h);
    // Scan for 0x05 (standard principal marker): version (1) + hash160 (20)
    for (int i = 0; i < bytes.length - 21; i++) {
      if (bytes[i] == 0x05) {
        final version = bytes[i + 1];
        final hash160 = bytes.sublist(i + 2, i + 22);
        return 'S${c32checkEncode(version, HEX.encode(hash160))}';
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Extracts a UTF-8 string from a hex-encoded Clarity
/// `(ok (some (string-ascii|string-utf8 …)))` read-only call response.
/// Returns null if parsing fails.
String? clarityParseString(String hex) {
  try {
    final h = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = HEX.decode(h);
    for (int i = 0; i < bytes.length - 5; i++) {
      // 0x0d = string-ascii, 0x0e = string-utf8
      if (bytes[i] == 0x0d || bytes[i] == 0x0e) {
        final len = ByteData.sublistView(
                Uint8List.fromList(bytes.sublist(i + 1, i + 5)))
            .getUint32(0, Endian.big);
        if (i + 5 + len <= bytes.length) {
          return utf8.decode(bytes.sublist(i + 5, i + 5 + len));
        }
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}
