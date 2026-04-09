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
      k1 = ((k1 << 15) | (k1 >> 17)) & 0xFFFFFFFF;
      k1 = (k1 * _c2) & 0xFFFFFFFF;

      h1 ^= k1;
      h1 = ((h1 << 13) | (h1 >> 19)) & 0xFFFFFFFF;
      h1 = ((h1 * 5) + 0xe6546b64) & 0xFFFFFFFF;

      i += 4;
    }

    // Remaining bytes (tail) — fixed: Dart 3 switch has no fall-through
    int k1 = 0;
    final tail = length & 3;
    if (tail >= 3) k1 ^= (bytes[i + 2] & 0xff) << 16;
    if (tail >= 2) k1 ^= (bytes[i + 1] & 0xff) << 8;
    if (tail >= 1) {
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

  static List<int> bloomPositions(String input, int count, int size) {
    final h1 = hash(input, seed: 0);
    final h2 = hash(input, seed: h1);
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

class MurmurHash {
  /// MurmurHash v3
  ///
  /// Ported from: https://github.com/garycourt/murmurhash-js
  static int v3(String key, int seed) {
    int remainder = key.length & 3;
    int bytes = key.length - remainder;
    int h1 = seed;
    int c1 = 0xcc9e2d51;
    int c2 = 0x1b873593;
    int i = 0;
    int k1, h1b;
    while (i < bytes) {
      k1 = ((key.codeUnitAt(i) & 0xff)) |
          ((key.codeUnitAt(++i) & 0xff) << 8) |
          ((key.codeUnitAt(++i) & 0xff) << 16) |
          ((key.codeUnitAt(++i) & 0xff) << 24);
      ++i;
      k1 = ((((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16))) &
          0xffffffff;
      k1 = (k1 << 15) | (k1 >>> 17);
      k1 = ((((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16))) &
          0xffffffff;

      h1 ^= k1;
      h1 = (h1 << 13) | (h1 >>> 19);
      h1b = ((((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16))) &
          0xffffffff;
      h1 = (((h1b & 0xffff) + 0x6b64) +
          ((((h1b >>> 16) + 0xe654) & 0xffff) << 16));
    }
    k1 = 0;

    switch (remainder) {
      case 3:
        k1 ^= (key.codeUnitAt(i + 2) & 0xff) << 16;
        continue case2;
      case2:
      case 2:
        k1 ^= (key.codeUnitAt(i + 1) & 0xff) << 8;
        continue case1;
      case1:
      case 1:
        k1 ^= (key.codeUnitAt(i) & 0xff);

        k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) &
            0xffffffff;
        k1 = (k1 << 15) | (k1 >>> 17);
        k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) &
            0xffffffff;
        h1 ^= k1;
    }
    h1 ^= key.length;

    h1 ^= h1 >>> 16;
    h1 = (((h1 & 0xffff) * 0x85ebca6b) +
            ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) &
        0xffffffff;
    h1 ^= h1 >>> 13;
    h1 = ((((h1 & 0xffff) * 0xc2b2ae35) +
            ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16))) &
        0xffffffff;
    h1 ^= h1 >>> 16;

    return h1 >>> 0;
  }
}
