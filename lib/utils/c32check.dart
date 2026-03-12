// c32check.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:sui/utils/sha.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:bech32/bech32.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:bitbox/bitbox.dart' as bitbox;

import 'package:http/http.dart';
import 'package:wallet_app/utils/pos_networks.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:http/http.dart' as http;

const String _c32Alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
const String _hexAlphabet = '0123456789abcdef';

// ─── Core encode/decode ───────────────────────────────────────────────────────

String c32encode(String inputHex, {int? minLength}) {
  if (!RegExp(r'^[0-9a-fA-F]*$').hasMatch(inputHex)) {
    throw ArgumentError('Not a hex-encoded string');
  }

  if (inputHex.length % 2 != 0) inputHex = '0$inputHex';
  inputHex = inputHex.toLowerCase();

  List<String> res = [];
  int carry = 0;

  for (int i = inputHex.length - 1; i >= 0; i--) {
    if (carry < 4) {
      final currentCode = _hexAlphabet.indexOf(inputHex[i]) >> carry;
      int nextCode = 0;
      if (i != 0) nextCode = _hexAlphabet.indexOf(inputHex[i - 1]);

      final nextBits = 1 + carry;
      final nextLowBits = (nextCode % (1 << nextBits)) << (5 - nextBits);
      final curC32Digit = _c32Alphabet[currentCode + nextLowBits];
      carry = nextBits;
      res.insert(0, curC32Digit);
    } else {
      carry = 0;
    }
  }

  // Strip leading '0' chars from result
  int c32LeadingZeros = 0;
  for (int i = 0; i < res.length; i++) {
    if (res[i] != '0') break;
    c32LeadingZeros++;
  }
  res = res.sublist(c32LeadingZeros);

  // Count leading zero bytes in the original hex
  final bytes = HEX.decode(inputHex);
  int numLeadingZeroBytes = 0;
  for (final b in bytes) {
    if (b != 0) break;
    numLeadingZeroBytes++;
  }

  for (int i = 0; i < numLeadingZeroBytes; i++) {
    res.insert(0, _c32Alphabet[0]);
  }

  if (minLength != null) {
    final count = minLength - res.length;
    for (int i = 0; i < count; i++) {
      res.insert(0, _c32Alphabet[0]);
    }
  }

  return res.join('');
}

String c32normalize(String input) {
  return input
      .toUpperCase()
      .replaceAll('O', '0')
      .replaceAll(RegExp(r'[LI]'), '1');
}

String c32decode(String c32input, {int? minLength}) {
  c32input = c32normalize(c32input);

  if (!RegExp('^[${RegExp.escape(_c32Alphabet)}]*\$').hasMatch(c32input)) {
    throw ArgumentError('Not a c32-encoded string');
  }

  final zeroMatch =
      RegExp('^${RegExp.escape(_c32Alphabet[0])}*').firstMatch(c32input);
  final numLeadingZeroBytes =
      zeroMatch != null ? zeroMatch.group(0)!.length : 0;

  List<String> res = [];
  int carry = 0;
  int carryBits = 0;

  for (int i = c32input.length - 1; i >= 0; i--) {
    if (carryBits == 4) {
      res.insert(0, _hexAlphabet[carry]);
      carryBits = 0;
      carry = 0;
    }
    final currentCode = _c32Alphabet.indexOf(c32input[i]) << carryBits;
    final currentValue = currentCode + carry;
    final currentHexDigit = _hexAlphabet[currentValue % 16];
    carryBits += 1;
    carry = currentValue >> 4;
    res.insert(0, currentHexDigit);
  }

  res.insert(0, _hexAlphabet[carry]);

  if (res.length % 2 == 1) res.insert(0, '0');

  int hexLeadingZeros = 0;
  for (int i = 0; i < res.length; i++) {
    if (res[i] != '0') break;
    hexLeadingZeros++;
  }
  res = res.sublist(hexLeadingZeros - (hexLeadingZeros % 2));

  String hexStr = res.join('');
  for (int i = 0; i < numLeadingZeroBytes; i++) {
    hexStr = '00$hexStr';
  }

  if (minLength != null) {
    int count = minLength * 2 - hexStr.length;
    for (int i = 0; i < count; i += 2) {
      hexStr = '00$hexStr';
    }
  }

  return hexStr;
}

// ─── Checksum & public API ────────────────────────────────────────────────────

String _c32checksum(String dataHex) {
  final bytes = HEX.decode(dataHex);

  final firstHash = sha256(bytes);
  final secondHash = sha256(firstHash);
  return HEX.encode(secondHash.sublist(0, 4));
}

String c32checkEncode(int version, String data) {
  if (version < 0 || version >= 32) {
    throw ArgumentError('Invalid version (must be between 0 and 31)');
  }
  if (!RegExp(r'^[0-9a-fA-F]*$').hasMatch(data)) {
    throw ArgumentError('Invalid data (not a hex string)');
  }

  data = data.toLowerCase();
  if (data.length % 2 != 0) data = '0$data';

  String versionHex = version.toRadixString(16);
  if (versionHex.length == 1) versionHex = '0$versionHex';

  final checksumHex = _c32checksum('$versionHex$data');
  final c32str = c32encode('$data$checksumHex');

  return '${_c32Alphabet[version]}$c32str';
}

List<dynamic> c32checkDecode(String c32data) {
  c32data = c32normalize(c32data);
  final dataHex = c32decode(c32data.substring(1));
  final versionChar = c32data[0];
  final version = _c32Alphabet.indexOf(versionChar);
  final checksum = dataHex.substring(dataHex.length - 8);

  String versionHex = version.toRadixString(16);
  if (versionHex.length == 1) versionHex = '0$versionHex';

  final payload = dataHex.substring(0, dataHex.length - 8);
  if (_c32checksum('$versionHex$payload') != checksum) {
    throw Exception('Invalid c32check string: checksum mismatch');
  }

  return [version, payload];
}
