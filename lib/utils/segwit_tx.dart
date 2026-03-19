// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';
import 'package:hex/hex.dart';

import './stack_tx_utils.dart'; // stacksSha256, stacksSecp256k1Sign, stacksCompressedPubKey, hash160

// ─── Primitive helpers ────────────────────────────────────────────────────────

Uint8List le32(int v) => Uint8List(4)
  ..[0] = v & 0xff
  ..[1] = (v >> 8) & 0xff
  ..[2] = (v >> 16) & 0xff
  ..[3] = (v >> 24) & 0xff;

Uint8List le64(int v) {
  final b = Uint8List(8);
  for (int i = 0; i < 8; i++) {
    b[i] = (v >> (8 * i)) & 0xff;
  }
  return b;
}

Uint8List dsha256(Uint8List d) => sha256Bytes(sha256Bytes(d));

/// Encodes a varint (compact size uint) as used in Bitcoin serialization.
Uint8List varuint(int v) {
  if (v < 0xfd) return Uint8List(1)..[0] = v;
  if (v <= 0xffff) {
    return Uint8List(3)
      ..[0] = 0xfd
      ..[1] = v & 0xff
      ..[2] = (v >> 8) & 0xff;
  }
  if (v <= 0xffffffff) {
    return Uint8List(5)
      ..[0] = 0xfe
      ..[1] = v & 0xff
      ..[2] = (v >> 8) & 0xff
      ..[3] = (v >> 16) & 0xff
      ..[4] = (v >> 24) & 0xff;
  }
  throw ArgumentError('varuint value too large: $v');
}

// ─── Script helpers ───────────────────────────────────────────────────────────

/// P2WPKH scriptPubKey: OP_0 <20-byte-witness-program>
/// [witnessProgram] must already be the 20-byte hash160 — do NOT hash it again.
Uint8List p2wpkhScript(Uint8List witnessProgram) =>
    Uint8List.fromList([0x00, 0x14, ...witnessProgram]);

/// P2WPKH scriptCode for BIP143 sighash preimage:
///   OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
/// Includes the leading length byte (0x19) as required by BIP143.
Uint8List p2wpkhScriptCode(Uint8List pubKeyHash) =>
    Uint8List.fromList([0x19, 0x76, 0xa9, 0x14, ...pubKeyHash, 0x88, 0xac]);

/// DER-encode a positive big-integer (r or s component of an ECDSA signature).
Uint8List derInt(BigInt v) {
  final bytes = HEX.decode(v.toRadixString(16).padLeft(64, '0'));
  int start = 0;
  while (start < bytes.length - 1 && bytes[start] == 0) {
    start++;
  }
  final stripped = bytes.sublist(start);
  // Prepend 0x00 if high bit set (would be interpreted as negative otherwise)
  return Uint8List.fromList(
    stripped[0] & 0x80 != 0 ? [0x00, ...stripped] : stripped,
  );
}

// ─── BIP143 sighash ───────────────────────────────────────────────────────────

/// Builds hashPrevouts: dSHA256 of all outpoints concatenated.
Uint8List buildHashPrevouts(List<Map<String, dynamic>> inputs) {
  final bb = BytesBuilder();
  for (final utxo in inputs) {
    bb.add(HEX.decode(utxo['txid'] as String).reversed.toList());
    bb.add(le32(utxo['vout'] as int));
  }
  return dsha256(bb.toBytes());
}

/// Builds hashSequence: dSHA256 of all sequences (all 0xffffffff here).
Uint8List buildHashSequence(int inputCount) {
  final bb = BytesBuilder();
  for (int i = 0; i < inputCount; i++) {
    bb.add(le32(0xffffffff));
  }
  return dsha256(bb.toBytes());
}

/// Builds hashOutputs: dSHA256 of all outputs serialized.
Uint8List buildHashOutputs({
  required int satoshiToSend,
  required Uint8List toScript,
  required int change,
  required Uint8List? changeScript,
}) {
  final bb = BytesBuilder();
  bb.add(le64(satoshiToSend));
  bb.add(varuint(toScript.length));
  bb.add(toScript);
  if (changeScript != null) {
    bb.add(le64(change));
    bb.add(varuint(changeScript.length));
    bb.add(changeScript);
  }
  return dsha256(bb.toBytes());
}

/// Builds the BIP143 sighash preimage for a single P2WPKH input.
Uint8List bip143Preimage({
  required Uint8List hashPrevouts,
  required Uint8List hashSequence,
  required List<int> txid, // already reversed (little-endian)
  required int vout,
  required Uint8List scriptCode, // from p2wpkhScriptCode()
  required int value, // input value in satoshis
  required Uint8List hashOutputs,
  int version = 2,
  int sequence = 0xffffffff,
  int locktime = 0,
  int sighashType = 0x01,
}) =>
    (BytesBuilder()
          ..add(le32(version))
          ..add(hashPrevouts)
          ..add(hashSequence)
          ..add(txid)
          ..add(le32(vout))
          ..add(scriptCode)
          ..add(le64(value))
          ..add(le32(sequence))
          ..add(hashOutputs)
          ..add(le32(locktime))
          ..add(le32(sighashType)))
        .toBytes();

// ─── Witness builder ──────────────────────────────────────────────────────────

/// Signs [sigHash] with [privBytes] and returns the P2WPKH witness stack:
/// [[der_signature_with_sighash_type], [compressed_pubkey]]
List<Uint8List> buildInputWitness({
  required Uint8List privBytes,
  required Uint8List sigHash,
  int sighashType = 0x01,
}) {
  final (ecSig, _) = secp256k1Sign(privBytes, sigHash);
  final rDer = derInt(ecSig.r);
  final sDer = derInt(ecSig.s);
  final der = Uint8List.fromList([
    0x30,
    rDer.length + sDer.length + 4,
    0x02,
    rDer.length,
    ...rDer,
    0x02,
    sDer.length,
    ...sDer,
    sighashType,
  ]);
  return [der, compressedPubKey(privBytes)];
}

// ─── Transaction serializer ───────────────────────────────────────────────────

/// Serializes a complete segwit (BIP141) transaction and returns the hex string.
///
/// [inputs]     — list of UTXO maps with 'txid' (String) and 'vout' (int)
/// [witnesses]  — one witness stack per input, in the same order as [inputs]
/// [toScript]   — scriptPubKey for the recipient output
/// [changeScript] — scriptPubKey for the change output, or null if none
String buildSegwitTxHex({
  required List<Map<String, dynamic>> inputs,
  required int satoshiToSend,
  required Uint8List toScript,
  required int change,
  required Uint8List? changeScript,
  required List<List<Uint8List>> witnesses,
  int version = 2,
  int locktime = 0,
}) {
  final rawTx = BytesBuilder();

  // Header
  rawTx.add(le32(version));
  rawTx.addByte(0x00); // segwit marker
  rawTx.addByte(0x01); // segwit flag

  // Inputs
  rawTx.add(varuint(inputs.length));
  for (final utxo in inputs) {
    rawTx.add(HEX.decode(utxo['txid'] as String).reversed.toList());
    rawTx.add(le32(utxo['vout'] as int));
    rawTx.addByte(0x00); // empty scriptSig (P2WPKH)
    rawTx.add(le32(0xffffffff)); // sequence
  }

  // Outputs
  final outCount = changeScript != null ? 2 : 1;
  rawTx.add(varuint(outCount));
  rawTx.add(le64(satoshiToSend));
  rawTx.add(varuint(toScript.length));
  rawTx.add(toScript);
  if (changeScript != null) {
    rawTx.add(le64(change));
    rawTx.add(varuint(changeScript.length));
    rawTx.add(changeScript);
  }

  // Witness data (one stack per input)
  for (final w in witnesses) {
    rawTx.add(varuint(w.length));
    for (final item in w) {
      rawTx.add(varuint(item.length));
      rawTx.add(item);
    }
  }

  // Locktime
  rawTx.add(le32(locktime));

  return HEX.encode(rawTx.toBytes());
}
