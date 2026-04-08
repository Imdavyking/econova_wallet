import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class BloomFilter {
  final Uint8List _bits;
  final int _hashCount;
  final int _size;

  BloomFilter({int size = 1 << 16, int hashCount = 4})
      : _size = size,
        _hashCount = hashCount,
        _bits = Uint8List((size + 7) ~/ 8);

  void _setBit(int i) => _bits[i >> 3] |= 1 << (i & 7);
  bool _getBit(int i) => (_bits[i >> 3] >> (i & 7) & 1) == 1;

  List<int> _hashes(String item) =>
      FNV1a.bloomPositions(item, _hashCount, _size);

  void reset() => _bits.fillRange(0, _bits.length, 0);

  void add(String item) {
    for (final h in _hashes(item)) {
      _setBit(h);
    }
  }

  bool mightContain(String item) => _hashes(item).every(_getBit);
}

class FNV1a {
  FNV1a._();

  static const int _offset32 = 0x811c9dc5;
  static const int _prime32 = 0x01000193;

  /// Single 32-bit FNV-1a hash of [input].
  static int hash(String input) {
    int h = _offset32;
    for (final byte in utf8.encode(input)) {
      h = ((h ^ byte) * _prime32) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Derive [count] bloom-filter positions from a single pass over [input]
  /// using double hashing: position_i = (h1 + i * h2) % size.
  static List<int> bloomPositions(String input, int count, int size) {
    int h1 = _offset32;
    int h2 = 0;
    for (final byte in utf8.encode(input)) {
      h1 = ((h1 ^ byte) * _prime32) & 0xFFFFFFFF;
      h2 = ((h2 + byte) * 0x9e3779b9) & 0xFFFFFFFF;
    }
    return List.generate(
      count,
      (i) => ((h1 + i * h2) & 0x7FFFFFFF) % size,
    );
  }
}
