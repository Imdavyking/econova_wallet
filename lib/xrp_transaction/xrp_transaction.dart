// ignore_for_file: constant_identifier_names, non_constant_identifier_names, prefer_const_declarations

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:web3dart/crypto.dart';

import '../coins/xrp_coin.dart';
import 'xrp_definitions.dart';
import 'xrp_ordinal.dart';

// ── Public API ────────────────────────────────────────────────────────────────

/// Encodes [txJson] to the canonical XRP binary format.
///
/// Pass [forSigning] = true (default) to exclude non-signing fields
/// (e.g. TxnSignature) so the output can be hashed for signing.
/// Pass [forSigning] = false when encoding the final signed transaction
/// for submission.
String encodeXrpJson(Map txJson, {bool forSigning = true}) {
  // Work on a copy so the caller's map is never mutated.
  final sampleXrpJson = Map.of(txJson);

  // Resolve X-Addresses before encoding.
  if (sampleXrpJson.containsKey('Destination') &&
      isXrp_X_Address(sampleXrpJson['Destination'] as String)) {
    final d =
        xaddress_to_classic_address(sampleXrpJson['Destination'] as String);
    sampleXrpJson['Destination'] = d.classicAddress;
    if (d.tag != null) sampleXrpJson['DestinationTag'] = d.tag;
  }

  if (sampleXrpJson.containsKey('Account') &&
      isXrp_X_Address(sampleXrpJson['Account'] as String)) {
    final s = xaddress_to_classic_address(sampleXrpJson['Account'] as String);
    sampleXrpJson['Account'] = s.classicAddress;
    if (s.tag != null) sampleXrpJson['SourceTag'] = s.tag;
  }

  // Build field metadata from FIELDS definition.
  final fields = rippleDefinitions['FIELDS'] as List;
  final Map<String, Map> fieldMeta = {};
  for (final field in fields) {
    final key = field[0] as String;
    fieldMeta[key] = Map.from(field[1] as Map);
  }

  // Collect only fields that are present in the tx AND are serializable.
  final List<Map> toSerialize = [];
  for (final key in sampleXrpJson.keys) {
    final ordinalEntry = xrpOrdinal[key as String];
    if (ordinalEntry == null) continue; // unknown field — skip

    final meta = fieldMeta[key];
    if (meta == null) continue;

    final isSerialized = meta['isSerialized'] as bool? ?? false;
    final isSigningField = meta['isSigningField'] as bool? ?? false;

    if (!isSerialized) continue;
    if (forSigning && !isSigningField) continue; // exclude TxnSignature etc.

    toSerialize.add({
      'name': key,
      'ordinal': ordinalEntry['ordinal'] as int,
      'nth': ordinalEntry['nth'] as int,
      'type': meta['type'] as String,
      'isVLEncoded': meta['isVLEncoded'] as bool? ?? false,
    });
  }

  // Sort by canonical ordinal order.
  toSerialize.sort((a, b) => (a['ordinal'] as int) - (b['ordinal'] as int));

  // Serialize.
  final List<int> serializer = [];
  const xrpTransactionPrefix = [83, 84, 88, 0];

  for (final field in toSerialize) {
    final name = field['name'] as String;
    final typeCode = rippleDefinitions['TYPES'][field['type']] as int;
    final fieldCode = field['nth'] as int;
    final isVLEncoded = field['isVLEncoded'] as bool;

    // Field header
    final List<int> header = _buildHeader(typeCode, fieldCode);
    serializer.addAll(header);

    // Field value
    final Uint8List value = _encodeFieldValue(
      name: name,
      type: field['type'] as String,
      rawValue: sampleXrpJson[name],
    );

    if (isVLEncoded) {
      serializer.addAll(_encodeVariableLengthPrefix(value.length));
    }
    serializer.addAll(value);
  }

  serializer.insertAll(0, xrpTransactionPrefix);
  return HEX.encode(serializer).toUpperCase();
}

/// Signs [xrpTransactionJson] with [privateKeyHex] and returns the map
/// with 'TxnSignature' populated.
Map signXrpTransaction(String privateKeyHex, Map xrpTransactionJson) {
  final signingHex = encodeXrpJson(xrpTransactionJson, forSigning: true);

  // XRP signs SHA-512Half of the prefixed serialized tx.
  final full = sha512.convert(HEX.decode(signingHex)).bytes;
  final half = Uint8List.fromList(full.sublist(0, 32));

  final sig = sign(half, Uint8List.fromList(HEX.decode(privateKeyHex)));
  final derSig = _encodeDer(sig);

  final signed = Map.of(xrpTransactionJson);
  signed['TxnSignature'] = derSig;
  return signed;
}

/// Throws a user-friendly [Exception] if [balanceDrops] minus [sendDrops]
/// would fall below the XRP base reserve (1 XRP = 1_000_000 drops).
///
/// Call this before building the transaction in your XRP coin's transferToken.
void assertXrpReserve({
  required BigInt balanceDrops,
  required BigInt sendDrops,
  required BigInt feeDrops,
  int reserveDrops = 1000000,
}) {
  final remaining = balanceDrops - sendDrops - feeDrops;
  if (remaining < BigInt.from(reserveDrops)) {
    final reserveXrp = (reserveDrops / 1e6).toStringAsFixed(1);
    throw Exception(
      'Insufficient balance — XRP requires a minimum reserve of $reserveXrp XRP '
      'to remain in the account at all times.',
    );
  }
}

// ── Address helpers ───────────────────────────────────────────────────────────

Uint8List decodeClassicAddress(String classicAddress) =>
    _decode(classicAddress, _CLASSIC_ADDRESS_PREFIX);

Uint8List _decode(String address, List<int> prefix) {
  final decoded = xrpBaseCodec.decode(address);
  return decoded.sublist(prefix.length, decoded.length - 4);
}

bool isXrp_X_Address(String address) {
  try {
    xaddress_to_classic_address(address);
    return true;
  } catch (_) {
    return false;
  }
}

// ── Internal encoding helpers ─────────────────────────────────────────────────

List<int> _buildHeader(int typeCode, int fieldCode) {
  if (typeCode < 16 && fieldCode < 16) return [typeCode << 4 | fieldCode];
  if (typeCode < 16) return [typeCode << 4, fieldCode];
  if (fieldCode < 16) return [0, typeCode, fieldCode];
  return [0, typeCode, fieldCode];
}

Uint8List _encodeFieldValue({
  required String name,
  required String type,
  required dynamic rawValue,
}) {
  switch (type) {
    case 'UInt16':
      if (name == 'TransactionType') {
        final code = rippleDefinitions['TRANSACTION_TYPES'][rawValue] as int;
        return _toUint16(code);
      }
      return _toUint16(rawValue as int);

    case 'UInt32':
      return _toUint32(rawValue as int);

    case 'Amount':
      // XRP amounts are passed as strings (drops) to avoid int overflow.
      final drops = BigInt.parse(rawValue.toString());
      return _toAmount(drops);

    case 'AccountID':
      return decodeClassicAddress(rawValue as String);

    case 'Blob':
      return Uint8List.fromList(HEX.decode(rawValue as String));

    default:
      // Unhandled types (Hash256, STObject, etc.) — return empty for now.
      // Extend as needed when supporting escrows, offers, etc.
      return Uint8List(0);
  }
}

Uint8List _toUint16(int value) {
  final buf = ByteData(2);
  buf.setUint16(0, value);
  return buf.buffer.asUint8List();
}

Uint8List _toUint32(int value) {
  final buf = ByteData(4);
  buf.setUint32(0, value);
  return buf.buffer.asUint8List();
}

/// Encodes an XRP Amount field.
/// XRP native amounts set bit 62 (positive sign bit); bits 63 and 0–61 are value.
/// Using BigInt throughout avoids int64 overflow for large drop values.
Uint8List _toAmount(BigInt drops) {
  const posBit = 0x4000000000000000;
  final withBit = drops | BigInt.from(posBit);
  final buf = ByteData(8);
  // Write as two 32-bit halves to avoid Dart's int truncation on web.
  final hi = (withBit >> 32).toInt();
  final lo = (withBit & BigInt.from(0xFFFFFFFF)).toInt();
  buf.setUint32(0, hi);
  buf.setUint32(4, lo);
  return buf.buffer.asUint8List();
}

String _encodeDer(MsgSignature sig) {
  List<int> r = sig.r.toUint8List();
  List<int> s = sig.s.toUint8List();

  // Pad with leading zero if high bit is set (DER positive integer encoding).
  if (r[0] & 0x80 != 0) r = [0, ...r];
  if (s[0] & 0x80 != 0) s = [0, ...s];

  final rLen = r.length;
  final sLen = s.length;
  final totalLen = rLen + sLen + 4; // 2 type+length bytes each for r and s

  return HEX.encode([
    0x30,
    totalLen,
    0x02,
    rLen,
    ...r,
    0x02,
    sLen,
    ...s,
  ]).toUpperCase();
}

// ── Variable length prefix ────────────────────────────────────────────────────

const int _MAX_SINGLE_BYTE_LENGTH = 192;
const int _MAX_DOUBLE_BYTE_LENGTH = 12481;
const int _MAX_LENGTH_VALUE = 918744;
const int _MAX_SECOND_BYTE_VALUE = 240;

Uint8List _encodeVariableLengthPrefix(int length) {
  if (length <= _MAX_SINGLE_BYTE_LENGTH) {
    return Uint8List.fromList([length]);
  } else if (length < _MAX_DOUBLE_BYTE_LENGTH) {
    final adjusted = length - (_MAX_SINGLE_BYTE_LENGTH + 1);
    return Uint8List.fromList([
      (_MAX_SINGLE_BYTE_LENGTH + 1 + (adjusted >> 8)) & 0xFF,
      adjusted & 0xFF,
    ]);
  } else if (length <= _MAX_LENGTH_VALUE) {
    final adjusted = length - _MAX_DOUBLE_BYTE_LENGTH;
    return Uint8List.fromList([
      (_MAX_SECOND_BYTE_VALUE + 1 + (adjusted >> 16)) & 0xFF,
      (adjusted >> 8) & 0xFF,
      adjusted & 0xFF,
    ]);
  }
  throw Exception('VL field exceeds max length of $_MAX_LENGTH_VALUE bytes');
}

// ── X-Address helpers ─────────────────────────────────────────────────────────

final _PREFIX_BYTES_MAIN = Uint8List.fromList([0x05, 0x44]);
final _PREFIX_BYTES_TEST = Uint8List.fromList([0x04, 0x93]);
final _CLASSIC_ADDRESS_PREFIX = [0x0];
const _CLASSIC_ADDRESS_LENGTH = 20;

ClassicAddressWithTag xaddress_to_classic_address(String xAddress) {
  Uint8List decoded = xrpBaseCodec.decode(xAddress);
  decoded = decoded.sublist(0, decoded.length - 4);

  final isTest = _isTestXAddress(decoded.sublist(0, 2));
  final addressBytes = decoded.sublist(2, 22);
  final tag = _getTag(decoded.sublist(22));
  final classic = _encodeClassicAddress(addressBytes);

  return ClassicAddressWithTag(
    classicAddress: classic,
    tag: tag,
    isXTestNet: isTest,
  );
}

String _encodeClassicAddress(Uint8List bytes) {
  if (bytes.length != _CLASSIC_ADDRESS_LENGTH) {
    throw Exception('Invalid address payload length: ${bytes.length}');
  }
  final payload = [..._CLASSIC_ADDRESS_PREFIX, ...bytes];
  final checksum =
      sha256.convert(sha256.convert([0, ...bytes]).bytes).bytes.sublist(0, 4);
  return xrpBaseCodec.encode(Uint8List.fromList([...payload, ...checksum]));
}

int? _getTag(Uint8List buf) {
  final flag = buf[0];
  if (flag >= 2) throw Exception('Unsupported X-Address');
  if (flag == 1) {
    return buf[1] + buf[2] * 0x100 + buf[3] * 0x10000 + buf[4] * 0x1000000;
  }
  if (!seqEqual(List.filled(8, 0), buf.sublist(1, 9))) {
    throw Exception('Remaining bytes must be zero for no-tag X-Address');
  }
  return null;
}

bool _isTestXAddress(Uint8List prefix) {
  if (seqEqual(_PREFIX_BYTES_MAIN, prefix)) return false;
  if (seqEqual(_PREFIX_BYTES_TEST, prefix)) return true;
  throw Exception('Invalid X-Address: unrecognized prefix');
}

// ── ClassicAddressWithTag ─────────────────────────────────────────────────────

class ClassicAddressWithTag {
  final String classicAddress;
  final int? tag;
  final bool isXTestNet;

  const ClassicAddressWithTag({
    required this.classicAddress,
    required this.tag,
    required this.isXTestNet,
  });

  Map<String, dynamic> toJson() => {
        'classicAddress': classicAddress,
        'tag': tag,
        'isXTestNet': isXTestNet,
      };

  factory ClassicAddressWithTag.fromJson(Map<dynamic, dynamic> json) =>
      ClassicAddressWithTag(
        classicAddress: json['classicAddress'] as String,
        tag: json['tag'] as int?,
        isXTestNet: json['isXTestNet'] as bool,
      );
}
