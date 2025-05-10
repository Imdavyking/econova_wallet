// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:cryptowallet/extensions/big_int_ext.dart';
import './blake2bhash.dart';
import 'package:cryptowallet/utils/rpc_urls.dart';

Uint8List _getCID(Uint8List message) {
  final hash = Uint8List.fromList(blake2bHash(message, digestSize: 32));
  return Uint8List.fromList([...CID_PREFIX, ...hash]);
}

Uint8List getDigest(Uint8List message) {
  return Uint8List.fromList(blake2bHash(_getCID(message), digestSize: 32));
}

const CID_PREFIX = [0x01, 0x71, 0xa0, 0xe4, 0x02, 0x20];

Uint8List addressAsBytes(String address) {
  final protocolIndicator = int.parse(address[1], radix: 16);

  switch (protocolIndicator) {
    case ProtocolIndicator.ID:
      final encoded = _lebEncode(int.parse(address.substring(2)));
      return Uint8List.fromList([protocolIndicator] + encoded);
    case ProtocolIndicator.SECP256K1:
    case ProtocolIndicator.ACTOR:
      final decoded = base32.decode(address.substring(2).toUpperCase());
      final payload = decoded.sublist(0, decoded.length - 4);
      final checksum = decoded.sublist(decoded.length - 4);
      if (payload.length != 20) {
        throw Exception('InvalidPayloadLength');
      }
      final bytesAddress = Uint8List.fromList([protocolIndicator] + payload);
      final calculatedChecksum = _getChecksum(bytesAddress);
      if (!seqEqual(calculatedChecksum, checksum)) {
        throw Exception('InvalidChecksumAddress');
      }
      return bytesAddress;
    case ProtocolIndicator.BLS:
      throw Exception('ProtocolNotSupported');
    default:
      throw Exception('UnknownProtocolIndicator');
  }
}

Uint8List serializeBigNum(String gasprice) {
  if (gasprice == "0") {
    return Uint8List(0);
  }
  final gaspriceBigInt = BigInt.parse(gasprice);
  return Uint8List.fromList([0, ...gaspriceBigInt.toUint8List()]);
}

List<int> _lebEncode(int value) {
  final bytes = <int>[];
  do {
    var byte = value & 0x7f;
    value >>= 7;
    if (value != 0) {
      byte |= 0x80;
    }
    bytes.add(byte);
  } while (value != 0);
  return bytes;
}

Uint8List _getChecksum(Uint8List bytes) {
  return Uint8List.fromList([...blake2bHash(bytes, digestSize: 4)]);
}

class ProtocolIndicator {
  static const ID = 0;
  static const SECP256K1 = 1;
  static const ACTOR = 2;
  static const BLS = 3;
}
