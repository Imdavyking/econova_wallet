// utils/neo_ont_utils.dart
//
// Shared low-level helpers for NEO N3 and Ontology coin implementations.
// Both chains use:
//   - NIST P-256 (secp256r1 / prime256v1) key derivation
//   - Base58Check address encoding (Bitcoin alphabet)
//   - SHA-256 / RIPEMD-160 / double-SHA-256 address hashing
//   - VarInt / VarBytes / little-endian integer serialisation
//   - ECDSA P-256 signing with low-S normalisation
//   - Identical JSON-RPC 2.0 call structure
//
// What is NOT shared (stays in each coin file):
//   - Address version byte and script hash endianness
//   - Transaction binary serialisation
//   - NeoVM / OntVM script building
//   - RPC method names and response shapes

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/ecc/curves/prime256v1.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:blockchain_utils/blockchain_utils.dart';

Uint8List slip10Nist256p1Derive(Uint8List seed, String path) {
  var node = Bip32Slip10Nist256p1.fromSeed(seed);

  return Uint8List.fromList(node.derivePath(path).privateKey.raw);
}

// ─── Hash helpers ──────────────────────────────────────────────────────────

Uint8List neoOntSha256(Uint8List data) =>
    Uint8List.fromList(crypto.sha256.convert(data).bytes);

Uint8List neoOntRipemd160(Uint8List data) =>
    (pc.RIPEMD160Digest()..update(data, 0, data.length)).let((d) {
      final out = Uint8List(20);
      d.doFinal(out, 0);
      return out;
    });

/// RIPEMD-160(SHA-256(data)) — standard hash160 for P2PKH-style scripts.
Uint8List neoOntHash160(Uint8List data) => neoOntRipemd160(neoOntSha256(data));

/// SHA-256(SHA-256(data)) — used for checksums and tx signing.
Uint8List neoOntDsha256(Uint8List data) => neoOntSha256(neoOntSha256(data));

// ─── Base58Check ───────────────────────────────────────────────────────────

const neoOntB58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

String neoOntB58Encode(Uint8List bytes) {
  BigInt value = BigInt.parse(HEX.encode(bytes), radix: 16);
  var result = '';
  while (value > BigInt.zero) {
    final mod = value % BigInt.from(58);
    result = neoOntB58Alphabet[mod.toInt()] + result;
    value ~/= BigInt.from(58);
  }
  for (final b in bytes) {
    if (b != 0) break;
    result = '1$result';
  }
  return result;
}

Uint8List neoOntB58Decode(String input) {
  BigInt value = BigInt.zero;
  for (final c in input.split('')) {
    final idx = neoOntB58Alphabet.indexOf(c);
    if (idx < 0) throw Exception('Invalid base58 char: $c');
    value = value * BigInt.from(58) + BigInt.from(idx);
  }
  final hex = value.toRadixString(16).padLeft(2, '0');
  final padded = hex.length.isOdd ? '0$hex' : hex;
  final bytes = Uint8List.fromList(HEX.decode(padded));
  final leading = input.split('').takeWhile((c) => c == '1').length;
  return Uint8List.fromList([...List.filled(leading, 0), ...bytes]);
}

/// Encodes [version] byte + [payload] with a 4-byte double-SHA-256 checksum.
String neoOntB58CheckEncode(int version, Uint8List payload) {
  final versioned = Uint8List(1 + payload.length)
    ..[0] = version
    ..setRange(1, 1 + payload.length, payload);
  final checksum = neoOntDsha256(versioned).sublist(0, 4);
  return neoOntB58Encode(
    Uint8List.fromList([...versioned, ...checksum]),
  );
}

/// Validates and decodes a Base58Check address.
/// Returns the 25-byte decoded buffer (version + payload + checksum)
/// or throws if the checksum is invalid.
Uint8List neoOntB58CheckDecode(String address) {
  final decoded = neoOntB58Decode(address);
  if (decoded.length < 5) throw Exception('Address too short');
  final payload = decoded.sublist(0, decoded.length - 4);
  final checksum = decoded.sublist(decoded.length - 4);
  final expected = neoOntDsha256(payload).sublist(0, 4);
  if (!neoOntBytesEqual(checksum, expected)) {
    throw Exception('Bad checksum');
  }
  return decoded;
}

// ─── Binary serialisation helpers ─────────────────────────────────────────

/// Variable-length integer (NEO / ONT / Bitcoin varint encoding).
Uint8List neoOntVarInt(int value) {
  if (value < 0xfd) return Uint8List.fromList([value]);
  if (value <= 0xffff) {
    return Uint8List.fromList([0xfd, value & 0xff, (value >> 8) & 0xff]);
  }
  return Uint8List.fromList([
    0xfe,
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff,
  ]);
}

/// VarInt-length-prefixed byte string.
Uint8List neoOntVarBytes(Uint8List bytes) =>
    Uint8List.fromList([...neoOntVarInt(bytes.length), ...bytes]);

Uint8List neoOntLeUInt16(int v) =>
    (ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List();

Uint8List neoOntLeUInt32(int v) =>
    (ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List();

/// Signed little-endian Int64.
Uint8List neoOntLeInt64(int v) =>
    (ByteData(8)..setInt64(0, v, Endian.little)).buffer.asUint8List();

/// Unsigned little-endian UInt64.
Uint8List neoOntLeUInt64(int v) =>
    (ByteData(8)..setUint64(0, v, Endian.little)).buffer.asUint8List();

// ─── ECDSA P-256 signing ───────────────────────────────────────────────────

/// Signs [input] with the NIST P-256 private key [privKeyBytes].
///
/// Returns the 64-byte (r ‖ s) signature with s normalised to low-S form.
///
/// [innerDigest] controls how [input] is pre-processed inside the signer:
///   - `null`  → [input] is treated as an already-hashed 32-byte digest
///               (ONT behaviour: signs dsha256(txBody) directly)
///   - `SHA256Digest()` → the signer hashes [input] again before signing
///               (NEO behaviour: signs SHA256(dsha256(txBody)))
///
/// Pass the correct digest to match the chain's expected signing scheme.
Uint8List neoOntP256Sign(
  Uint8List privKeyBytes,
  Uint8List input, {
  pc.Digest? innerDigest,
}) {
  final curve = ECCurve_prime256v1();
  final privKey = pc.ECPrivateKey(
    BigInt.parse(HEX.encode(privKeyBytes), radix: 16),
    pc.ECDomainParameters('prime256v1'),
  );

  final signer = pc.ECDSASigner(innerDigest)
    ..init(
      true,
      pc.ParametersWithRandom(
        pc.PrivateKeyParameter<pc.ECPrivateKey>(privKey),
        pc.SecureRandom('Fortuna')
          ..seed(pc.KeyParameter(Uint8List.fromList(
            List.generate(32, (i) => privKeyBytes[i % 32]),
          ))),
      ),
    );

  final sig = signer.generateSignature(input) as pc.ECSignature;
  final n = curve.n;
  BigInt s = sig.s;
  if (s > (n >> 1)) s = n - s; // low-S normalisation

  Uint8List to32(BigInt v) =>
      Uint8List.fromList(HEX.decode(v.toRadixString(16).padLeft(64, '0')));

  return Uint8List.fromList([...to32(sig.r), ...to32(s)]);
}

// ─── JSON-RPC 2.0 helpers ──────────────────────────────────────────────────

/// Posts a JSON-RPC call to [rpcUrl] and returns the `result` as a
/// `Map<String, dynamic>`.  Throws on HTTP error or `error` in the response.
Future<Map<String, dynamic>> neoOntRpc(
  String rpcUrl,
  String method,
  List params,
) async {
  final res = await http.post(
    Uri.parse(rpcUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
        {'jsonrpc': '2.0', 'method': method, 'params': params, 'id': 1}),
  );
  if (res.statusCode > 399) {
    throw Exception('RPC HTTP error ${res.statusCode} ($rpcUrl)');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (data['error'] != null) throw Exception('RPC error: ${data['error']}');
  return data['result'] as Map<String, dynamic>;
}

/// Same as [neoOntRpc] but returns `result` as raw [dynamic] — useful for
/// methods that return a scalar (e.g. `getblockcount` → int).
Future<dynamic> neoOntRpcRaw(
  String rpcUrl,
  String method,
  List params,
) async {
  final res = await http.post(
    Uri.parse(rpcUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
        {'jsonrpc': '2.0', 'method': method, 'params': params, 'id': 1}),
  );
  if (res.statusCode ~/ 100 != 2) {
    throw Exception('RPC HTTP error ${res.statusCode} ($rpcUrl)');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (data['error'] != null) throw Exception('RPC error: ${data['error']}');
  return data['result'];
}

// ─── Misc ──────────────────────────────────────────────────────────────────

bool neoOntBytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
  return true;
}

// ─── Extension trick to avoid a local variable for the digest ─────────────
extension _LetExt<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
