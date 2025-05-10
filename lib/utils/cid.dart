// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:bs58check/bs58check.dart';
import 'package:crypto/crypto.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

_length(value) {
  var N1 = pow(2, 7);
  var N2 = pow(2, 14);
  var N3 = pow(2, 21);
  var N4 = pow(2, 28);
  var N5 = pow(2, 35);
  var N6 = pow(2, 42);
  var N7 = pow(2, 49);
  var N8 = pow(2, 56);
  var N9 = pow(2, 63);
  return (value < N1
      ? 1
      : value < N2
          ? 2
          : value < N3
              ? 3
              : value < N4
                  ? 4
                  : value < N5
                      ? 5
                      : value < N6
                          ? 6
                          : value < N7
                              ? 7
                              : value < N8
                                  ? 8
                                  : value < N9
                                      ? 9
                                      : 10);
}

class Varint {
  static encodingLength(nuber) {
    return _length(nuber);
  }
}

class CIDCodes {
  static const int jsonCode = 512;
  static const int dagPBCode = 112;
  static const int rawCode = 85;
}

String genCid(
  String msg, [
  int code = CIDCodes.jsonCode,
  version = 1,
]) {
  if (version == 0 && code != CIDCodes.dagPBCode) {
    throw Exception(
        'Version 0 CID must use dag-pb (code: ${CIDCodes.dagPBCode}) block encoding');
  }
  final bytes = utf8.encode(msg);
  final digest = sha256.convert(bytes);
  final fullBytes = Uint8List.fromList([18, 32, ...digest.bytes]);

  if (version == 1) {
    final bytesCode = encodeCid(version, code, fullBytes);
    return 'b${Base32.encode(bytesCode).toLowerCase()}';
  } else {
    return base58.encode(fullBytes);
  }
}

fromV0ToV1(String v1) {
  if (v1[0] != 'Q') {
    throw Exception('only v1 to v2 supported');
  }
  final fullBytes = base58.decode(v1);
  final bytesCode = encodeCid(1, CIDCodes.dagPBCode, fullBytes);
  return 'b${Base32.encode(bytesCode).toLowerCase()}';
}

Uint8List encodeTo(number, Uint8List? target, [int offset = 0]) {
  target ??= Uint8List(10);
  const MSB = 0x80;
  const REST = 0x7F;
  const MSBALL = ~REST;
  const INT = 1 << 31;

  while (number >= INT) {
    target[offset++] = (number & 0xFF) | MSB;
    number /= 128;
  }

  while ((number & MSBALL) != 0) {
    target[offset++] = (number & 0xFF) | MSB;
    number >>= 7;
  }

  target[offset] = number | 0;
  return target;
}

Uint8List encodeCid(version, code, Uint8List fullBytes) {
  final codeOffset = Varint.encodingLength(version);

  final hashOffset = codeOffset + Varint.encodingLength(code);

  var bytes = Uint8List(hashOffset + fullBytes.length);
  bytes = encodeTo(version, bytes, 0);
  bytes = encodeTo(code, bytes, codeOffset);
  bytes.setAll(hashOffset, fullBytes);
  return bytes;
}
