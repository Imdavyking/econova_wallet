import 'dart:convert';
import 'package:crypto/crypto.dart';

class NimiqIdenticon {
  // Counts must match what's actually in your SVG sprite
  static const int FACE_COUNT = 21;
  static const int TOP_COUNT = 21;
  static const int SIDE_COUNT = 21;
  static const int BOTTOM_COUNT = 21;

  static const List<String> COLORS = [
    '#FC7D70',
    '#FE8E51',
    '#FFBE53',
    '#F5CB40',
    '#F5D764',
    '#E8EE6F',
    '#A4D96C',
    '#62C873',
    '#63D0A3',
    '#63C7C7',
    '#64B9E4',
    '#628FE3',
    '#8571E0',
    '#A86FD5',
    '#C569C5',
    '#E36BAC',
    '#F06890',
    '#F5777E',
    '#EEB09A',
    '#D8C9A7',
    '#FFFFFF',
  ];

  static NimiqIconOptions fromAddress(String address) {
    final bytes = utf8.encode(address);
    final digest = sha256.convert(bytes);
    // Use raw bytes as a stream of numbers — no digit-string tricks
    final b = digest.bytes;

    int pick(int byteIndex, int count) => b[byteIndex] % count;

    return NimiqIconOptions(
      face: pick(0, FACE_COUNT),
      top: pick(1, TOP_COUNT),
      side: pick(2, SIDE_COUNT),
      bottom: pick(3, BOTTOM_COUNT),
      bodyColor: COLORS[pick(4, COLORS.length)],
      backgroundColor: COLORS[pick(5, COLORS.length)],
      accentColor: COLORS[pick(6, COLORS.length)],
    );
  }
}

class NimiqIconOptions {
  final int face, top, side, bottom;
  final String bodyColor, backgroundColor, accentColor;

  const NimiqIconOptions({
    required this.face,
    required this.top,
    required this.side,
    required this.bottom,
    required this.bodyColor,
    required this.backgroundColor,
    required this.accentColor,
  });
}
