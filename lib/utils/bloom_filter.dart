import 'dart:convert';
import 'dart:typed_data';

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
      MurmurHash3.bloomPositions(item, _hashCount, _size);
  void reset() => _bits.fillRange(0, _bits.length, 0);

  void add(String item) {
    for (final h in _hashes(item)) {
      _setBit(h);
    }
  }

  bool mightContain(String item) => _hashes(item).every(_getBit);
}

class MurmurHash3 {
  MurmurHash3._();

  static const int _c1 = 0xcc9e2d51;
  static const int _c2 = 0x1b873593;

  /// Single 32-bit MurmurHash3 of [input] with optional [seed].
  static int hash(String input, {int seed = 0}) {
    final bytes = utf8.encode(input);
    final length = bytes.length;
    int h1 = seed;
    int i = 0;

    // Process 4-byte blocks
    while (i + 4 <= length) {
      int k1 = (bytes[i] & 0xff) |
          ((bytes[i + 1] & 0xff) << 8) |
          ((bytes[i + 2] & 0xff) << 16) |
          ((bytes[i + 3] & 0xff) << 24);

      k1 = (k1 * _c1) & 0xFFFFFFFF;
      k1 = ((k1 << 15) | (k1 >> 17)) & 0xFFFFFFFF; // rotl32(k1, 15)
      k1 = (k1 * _c2) & 0xFFFFFFFF;

      h1 ^= k1;
      h1 = ((h1 << 13) | (h1 >> 19)) & 0xFFFFFFFF; // rotl32(h1, 13)
      h1 = ((h1 * 5) + 0xe6546b64) & 0xFFFFFFFF;

      i += 4;
    }

    // Remaining bytes (tail)
    int k1 = 0;
    switch (length & 3) {
      case 3:
        k1 ^= (bytes[i + 2] & 0xff) << 16;
      case 2:
        k1 ^= (bytes[i + 1] & 0xff) << 8;
      case 1:
        k1 ^= (bytes[i] & 0xff);
        k1 = (k1 * _c1) & 0xFFFFFFFF;
        k1 = ((k1 << 15) | (k1 >> 17)) & 0xFFFFFFFF;
        k1 = (k1 * _c2) & 0xFFFFFFFF;
        h1 ^= k1;
    }

    // Finalisation mix
    h1 ^= length;
    h1 = _fmix32(h1);
    return h1;
  }

  /// Derive [count] bloom-filter positions from a single pass over [input]
  /// using double hashing: position_i = (h1 + i * h2) % size.
  static List<int> bloomPositions(String input, int count, int size) {
    final h1 = hash(input, seed: 0);
    final h2 = hash(input, seed: h1); // second seed derived from first
    return List.generate(
      count,
      (i) => ((h1 + i * h2) & 0x7FFFFFFF) % size,
    );
  }

  static int _fmix32(int h) {
    h = ((h ^ (h >> 16)) * 0x85ebca6b) & 0xFFFFFFFF;
    h = ((h ^ (h >> 13)) * 0xc2b2ae35) & 0xFFFFFFFF;
    return (h ^ (h >> 16)) & 0xFFFFFFFF;
  }
}
