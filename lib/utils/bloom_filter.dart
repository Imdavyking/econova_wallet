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

  List<int> _hashes(String item) {
    final bytes = utf8.encode(item);
    return List.generate(_hashCount, (seed) {
      final h = sha256.convert([...bytes, seed]);
      final b = Uint8List.fromList(h.bytes);
      final val = b.buffer.asByteData().getUint32(0);
      return val % _size;
    });
  }

  void reset() => _bits.fillRange(0, _bits.length, 0);

  void add(String item) {
    for (final h in _hashes(item)) {
      _setBit(h);
    }
  }

  bool mightContain(String item) => _hashes(item).every(_getBit);
}
