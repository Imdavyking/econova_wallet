import 'dart:typed_data';
import 'package:agent_dart/principal/principal.dart';
import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_data.dart';

import 'types.dart';

// ---------------------------------------------------------------------------
// ToCBorable – implemented by types that know how to build their own CborValue
// ---------------------------------------------------------------------------
abstract class ToCBorable {
  CborValue toCbor();
}

// ---------------------------------------------------------------------------
// ExtraEncoder – extensible hook for custom types
// ---------------------------------------------------------------------------
abstract class ExtraEncoder<T> {
  String get name;
  bool match(dynamic value);
  CborValue encode(T value);
}

// ---------------------------------------------------------------------------
// Concrete extra encoders
// ---------------------------------------------------------------------------
class PrincipalEncoder extends ExtraEncoder<Principal> {
  @override
  String get name => 'Principal';

  @override
  bool match(dynamic value) => value is Principal;

  @override
  CborValue encode(Principal value) =>
      CborBytes(Uint8List.fromList(value.toUint8Array()));
}

class BufferEncoder extends ExtraEncoder<BinaryBlob> {
  @override
  String get name => 'Buffer';

  @override
  bool match(dynamic value) => value is BinaryBlob;

  @override
  CborValue encode(BinaryBlob value) => CborBytes(Uint8List.fromList(value));
}

class ByteBufferEncoder extends ExtraEncoder<ByteBuffer> {
  @override
  String get name => 'ByteBuffer';

  @override
  bool match(dynamic value) => value is ByteBuffer;

  @override
  CborValue encode(ByteBuffer value) => CborBytes(value.asUint8List());
}

class BigIntEncoder extends ExtraEncoder<BigInt> {
  @override
  String get name => 'BigInt';

  @override
  bool match(dynamic value) => value is BigInt;

  @override
  CborValue encode(BigInt value) => CborBigInt(value);
}

// ---------------------------------------------------------------------------
// CborSerializer – replaces SelfDescribeEncoder
//
// Instead of streaming writes, it builds a CborValue tree and encodes it
// in one shot.  The self-describe tag (0xd9d9f7) is prepended when
// [selfDescribe] is true (the default).
// ---------------------------------------------------------------------------
class CborSerializer {
  final bool selfDescribe;
  final Set<ExtraEncoder> _encoders = {};

  CborSerializer({this.selfDescribe = true});

  void addEncoder(ExtraEncoder encoder) => _encoders.add(encoder);

  void removeEncoder(String encoderName) =>
      _encoders.removeWhere((e) => e.name == encoderName);

  ExtraEncoder? _encoderFor(dynamic value) {
    for (final enc in _encoders) {
      if (enc.match(value)) return enc;
    }
    return null;
  }

  // ── public entry point ───────────────────────────────────────────────────

  Uint8List serialize(dynamic value) {
    final cborValue = _toValue(value);
    final bytes = cbor.encode(cborValue);

    if (!selfDescribe) return Uint8List.fromList(bytes);

    // Prepend the self-describe tag bytes (0xd9, 0xd9, 0xf7)
    final out = Uint8List(3 + bytes.length);
    out[0] = 0xd9;
    out[1] = 0xd9;
    out[2] = 0xf7;
    out.setRange(3, out.length, bytes);
    return out;
  }

  // ── private tree builder ─────────────────────────────────────────────────

  CborValue _toValue(dynamic data) {
    // 1. Extra encoders (Principal, BinaryBlob, ByteBuffer, BigInt, …)
    final extra = _encoderFor(data);
    if (extra != null) return extra.encode(data);

    // 2. Types that know how to serialise themselves
    if (data is ToCBorable) return data.toCbor();

    // 3. Map
    if (data is Map) return _mapValue(data);

    // 4. Typed byte buffers
    if (data is Uint8Buffer) return CborBytes(Uint8List.fromList(data));
    if (data is Uint8List) return CborBytes(data);

    // 5. Generic iterables / lists
    if (data is Iterable) return _listValue(data);

    // 6. Primitives
    if (data is int) return CborSmallInt(data);
    if (data is BigInt) return CborBigInt(data);
    if (data is String) return CborString(data);
    if (data is double) return CborFloat(data);
    if (data is bool) return CborBool(data);
    if (data == null) return const CborNull();

    // 7. Fallback – treat as bytes if it looks like a byte buffer
    if (data is ByteBuffer) return CborBytes(data.asUint8List());

    throw ArgumentError('CborSerializer: unsupported type ${data.runtimeType}');
  }

  CborMap _mapValue(Map map) {
    final entries = <CborValue, CborValue>{};
    for (final entry in map.entries) {
      final key = entry.key is String
          ? CborString(entry.key as String)
          : CborSmallInt(entry.key as int);
      entries[key] = _toValue(entry.value);
    }
    return CborMap(entries);
  }

  CborList _listValue(Iterable data) {
    // If every element is an int, treat as raw bytes
    final list = data.toList();
    if (list.every((e) => e is int)) {
      return CborList([CborBytes(Uint8List.fromList(List<int>.from(list)))]);
    }
    return CborList(list.map(_toValue).toList());
  }
}

// ---------------------------------------------------------------------------
// Factory helpers (mirror the old initCborSerializer / initCborSerializerNoHead)
// ---------------------------------------------------------------------------
CborSerializer initCborSerializer() => CborSerializer(selfDescribe: true)
  ..addEncoder(PrincipalEncoder())
  ..addEncoder(BigIntEncoder())
  ..addEncoder(BufferEncoder())
  ..addEncoder(ByteBufferEncoder());

CborSerializer initCborSerializerNoHead() => CborSerializer(selfDescribe: false)
  ..addEncoder(PrincipalEncoder())
  ..addEncoder(BigIntEncoder())
  ..addEncoder(BufferEncoder())
  ..addEncoder(ByteBufferEncoder());

// ---------------------------------------------------------------------------
// Top-level encode / decode (same signatures as before)
// ---------------------------------------------------------------------------
BinaryBlob cborEncode(dynamic value, {CborSerializer? withSerializer}) {
  final serializer = withSerializer ?? initCborSerializer();
  return serializer.serialize(value);
}

T cborDecode<T>(List<int> value) {
  try {
    // Strip the self-describe tag prefix (0xd9, 0xd9, 0xf7) if present
    var bytes = value is Uint8List ? value : Uint8List.fromList(value);
    if (bytes.length >= 3 &&
        bytes[0] == 0xd9 &&
        bytes[1] == 0xd9 &&
        bytes[2] == 0xf7) {
      bytes = bytes.sublist(3);
    }

    final decoded = cbor.decode(bytes);
    return decoded.toObject() as T;
  } catch (e) {
    throw 'Cannot decode with cbor: $e';
  }
}
