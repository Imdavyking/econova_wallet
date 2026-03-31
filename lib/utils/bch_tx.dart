// utils/bch_tx.dart
//
// Bitcoin Cash P2PKH transaction signing with SIGHASH_FORKID.
//
// BCH uses a BIP143-style sighash (same structure as SegWit BIP143) but:
//   • Applied to regular P2PKH inputs — not just SegWit
//   • SIGHASH_TYPE = SIGHASH_ALL | SIGHASH_FORKID = 0x01 | 0x40 = 0x41
//   • scriptCode is the full P2PKH scriptPubKey of the input being signed
//   • The value commitment (input amount) prevents replay on BTC chain
//
// Transaction format is standard non-segwit — no marker/flag bytes, no witness.
// Each input's scriptSig = <sig||0x41> <compressed_pubkey>.
//
// References:
//   https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/replay-protected-sighash.md

import 'dart:typed_data';
import 'package:wallet_app/utils/stack_tx_utils.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:bitbox/bitbox.dart' as bitbox;
import 'package:hex/hex.dart';
import 'package:web3dart/crypto.dart' show sign, MsgSignature;

// ─── Constants ────────────────────────────────────────────────────────────────

/// SIGHASH_ALL | SIGHASH_FORKID
const _sighashForkId = 0x41;

/// secp256k1 curve order
final _curveN = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
  radix: 16,
);

// ─── Address helpers ──────────────────────────────────────────────────────────

/// Converts any BCH address format to legacy P2PKH (1XXX…).
/// Accepts CashAddr with prefix, CashAddr without prefix, and legacy.
String bchToLegacy(String address) {
  // Already legacy base58check
  try {
    bs58check.decode(address);
    return address;
  } catch (_) {}

  // CashAddr with prefix (bitcoincash:qXXX…)
  try {
    return bitbox.Address.toLegacyAddress(address);
  } catch (_) {}

  // CashAddr without prefix (qXXX… — stored form in this wallet)
  try {
    return bitbox.Address.toLegacyAddress('bitcoincash:$address');
  } catch (_) {}

  throw Exception('Cannot convert BCH address to legacy: $address');
}

// ─── Script helpers ───────────────────────────────────────────────────────────

/// P2PKH scriptPubKey: OP_DUP OP_HASH160 <20-byte hash> OP_EQUALVERIFY OP_CHECKSIG
Uint8List bchP2pkhScript(Uint8List hash160) => Uint8List.fromList([
      0x76, 0xa9, 0x14, ...hash160, 0x88, 0xac,
    ]);

/// Extracts the 20-byte hash160 from a legacy BCH address.
Uint8List bchAddressHash160(String legacyAddress) =>
    Uint8List.fromList(bs58check.decode(legacyAddress).sublist(1));

// ─── Encoding helpers ─────────────────────────────────────────────────────────

Uint8List _le32(int v) {
  final b = ByteData(4);
  b.setUint32(0, v, Endian.little);
  return b.buffer.asUint8List();
}

Uint8List _le64(int v) {
  final b = ByteData(8);
  b.setUint32(0, v & 0xffffffff, Endian.little);
  b.setUint32(4, (v >> 32) & 0xffffffff, Endian.little);
  return b.buffer.asUint8List();
}


Uint8List dsha256(Uint8List data) {
  final h1 = sha256Bytes(data);
  return sha256Bytes(h1);
}

// ─── BIP143-style shared hashes ───────────────────────────────────────────────

/// dsha256 of all outpoints concatenated — committed by every input's preimage.
Uint8List buildBchHashPrevouts(List<BchUtxo> utxos) {
  final buf = BytesBuilder();
  for (final u in utxos) {
    buf.add(HEX.decode(u.txid).reversed.toList());
    buf.add(_le32(u.vout));
  }
  return dsha256(Uint8List.fromList(buf.toBytes()));
}

/// dsha256 of all sequences (all 0xffffffff for SIGHASH_ALL).
Uint8List buildBchHashSequence(int inputCount) {
  final buf = BytesBuilder();
  for (int i = 0; i < inputCount; i++) {
    buf.add(_le32(0xffffffff));
  }
  return dsha256(Uint8List.fromList(buf.toBytes()));
}

/// dsha256 of all outputs serialized — committed by SIGHASH_ALL preimage.
Uint8List buildBchHashOutputs({
  required int satoshiToSend,
  required Uint8List toScript,
  required int change,
  required Uint8List? changeScript,
}) {
  final buf = BytesBuilder();

  buf.add(_le64(satoshiToSend));
  buf.add(varuint(toScript.length));
  buf.add(toScript);

  if (change > 546 && changeScript != null) {
    buf.add(_le64(change));
    buf.add(varuint(changeScript.length));
    buf.add(changeScript);
  }

  return dsha256(Uint8List.fromList(buf.toBytes()));
}

// ─── Sighash preimage ─────────────────────────────────────────────────────────

/// Builds the BCH SIGHASH_FORKID preimage for a single P2PKH input.
///
/// [txid] must already be reversed (little-endian, as it appears on-wire).
/// [scriptCode] is the P2PKH scriptPubKey of the UTXO being spent.
Uint8List bchSighashPreimage({
  required Uint8List hashPrevouts,
  required Uint8List hashSequence,
  required List<int> txid,
  required int vout,
  required Uint8List scriptCode,
  required int value,
  required Uint8List hashOutputs,
}) {
  final buf = BytesBuilder();
  buf.add(_le32(1));                       // nVersion
  buf.add(hashPrevouts);
  buf.add(hashSequence);
  buf.add(txid);                           // outpoint txid (reversed)
  buf.add(_le32(vout));                    // outpoint vout
  buf.add(varuint(scriptCode.length));
  buf.add(scriptCode);                     // P2PKH scriptPubKey of input
  buf.add(_le64(value));                   // input value (satoshis)
  buf.add(_le32(0xffffffff));              // nSequence
  buf.add(hashOutputs);
  buf.add(_le32(0));                       // nLocktime
  buf.add(_le32(_sighashForkId));          // sighash type (0x41 LE = [41 00 00 00])
  return Uint8List.fromList(buf.toBytes());
}

// ─── Signing ──────────────────────────────────────────────────────────────────

/// Signs [sigHash] with [privBytes] and returns a DER-encoded signature
/// with the 0x41 sighash type byte appended.
///
/// Applies low-S normalization (BIP62) to produce a canonical signature.
Uint8List buildBchSignature({
  required Uint8List privBytes,
  required Uint8List sigHash,
}) {
  final MsgSignature raw = sign(sigHash, privBytes);

  // Low-S normalization — keeps signature in the lower half of the curve
  final halfN = _curveN >> 1;
  final s = raw.s > halfN ? _curveN - raw.s : raw.s;

  final rBytes = _bigIntTo32Bytes(raw.r);
  final sBytes = _bigIntTo32Bytes(s);

  final rDer = _derInt(rBytes);
  final sDer = _derInt(sBytes);

  // DER: 0x30 <total_len> 0x02 <r_len> <r> 0x02 <s_len> <s>
  // Append sighash type 0x41 after the DER body
  return Uint8List.fromList([
    0x30,
    rDer.length + sDer.length + 4,
    0x02, rDer.length, ...rDer,
    0x02, sDer.length, ...sDer,
    _sighashForkId,
  ]);
}

/// Builds the P2PKH scriptSig: <sig||0x41> <compressed_pubkey>
Uint8List buildBchScriptSig(Uint8List sig, Uint8List pubkey) =>
    Uint8List.fromList([
      sig.length, ...sig,
      pubkey.length, ...pubkey,
    ]);

// ─── Transaction serialization ────────────────────────────────────────────────

/// Serializes a complete BCH P2PKH transaction and returns the hex string.
///
/// BCH uses the standard non-segwit wire format — no marker/flag/witness bytes.
String buildBchTxHex({
  required List<BchUtxo> inputs,
  required List<Uint8List> scriptSigs, // one per input, in order
  required int satoshiToSend,
  required Uint8List toScript,
  required int change,
  required Uint8List? changeScript,
}) {
  assert(inputs.length == scriptSigs.length);

  final buf = BytesBuilder();

  // version
  buf.add(_le32(1));

  // inputs
  buf.add(varuint(inputs.length));
  for (int i = 0; i < inputs.length; i++) {
    buf.add(HEX.decode(inputs[i].txid).reversed.toList());
    buf.add(_le32(inputs[i].vout));
    final ss = scriptSigs[i];
    buf.add(varuint(ss.length));
    buf.add(ss);
    buf.add(_le32(0xffffffff)); // sequence
  }

  // outputs
  final outputCount = (change > 546 && changeScript != null) ? 2 : 1;
  buf.add(varuint(outputCount));

  buf.add(_le64(satoshiToSend));
  buf.add(varuint(toScript.length));
  buf.add(toScript);

  if (change > 546 && changeScript != null) {
    buf.add(_le64(change));
    buf.add(varuint(changeScript.length));
    buf.add(changeScript);
  }

  // locktime
  buf.add(_le32(0));

  return HEX.encode(buf.toBytes());
}

// ─── UTXO value object ────────────────────────────────────────────────────────

class BchUtxo {
  final String txid;
  final int vout;
  final int satoshis;

  const BchUtxo({
    required this.txid,
    required this.vout,
    required this.satoshis,
  });
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

Uint8List _bigIntTo32Bytes(BigInt v) =>
    Uint8List.fromList(HEX.decode(v.toRadixString(16).padLeft(64, '0')));

/// DER-encodes a single integer: strips leading zeros,
/// prepends 0x00 if the high bit is set.
Uint8List _derInt(Uint8List bytes) {
  int start = 0;
  while (start < bytes.length - 1 && bytes[start] == 0) {
    start++;
  }
  final stripped = bytes.sublist(start);
  return (stripped[0] & 0x80 != 0)
      ? Uint8List.fromList([0x00, ...stripped])
      : stripped;
}