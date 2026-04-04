// nimiq_identicon.dart

import 'package:flutter/material.dart';
import 'package:wallet_app/coins/nimiq_coin.dart';

class NimiqIdenticon {
  // 10 body/accent colors
  static const List<String> COLORS = [
    '#FC8702',
    '#D94432',
    '#E9B213',
    '#1A5493',
    '#0582CA',
    '#5961A8',
    '#21BCA5',
    '#FA7268',
    '#88B04B',
    '#795548',
  ];

  // 10 background colors (slightly different from body colors)
  static const List<String> BACKGROUND_COLORS = [
    '#FC8702',
    '#D94432',
    '#E9B213',
    '#1F2348',
    '#0582CA',
    '#5F4B8B',
    '#21BCA5',
    '#FA7268',
    '#88B04B',
    '#795548',
  ];

  static double _chaosHash(double x) {
    double r = 1.0 / x;
    for (int i = 0; i < 100; i++) {
      r = (1 - r) * r * 3.569956786876;
    }
    return r;
  }

  /// Replicates Nimiq's `makeHash(address)` JS function exactly.
  static String makeHash(String address) {
    // Step 1: logistic map over char codes
    double value = address.split('').map((c) => c.codeUnitAt(0) + 3.0).fold(
          0.5,
          (acc, charVal) => acc * (1 - acc) * _chaosHash(charVal),
        );

    // Step 2: reverse the decimal string
    String reversed = value.toString().split('').reversed.join('');

    // Step 3: replace the dot (index 5 of reversed) then substr(4,17), padEnd to 13
    if (reversed.length <= 5) {
      reversed = reversed.padRight(6, '0');
    }
    String dotReplaced = reversed.replaceFirst('.', reversed[5]);
    String result = dotReplaced.length >= 21
        ? dotReplaced.substring(4, 21)
        : dotReplaced.substring(4);

    // padEnd to 13 with repeated char
    String padChar = reversed[5];
    while (result.length < 13) {
      result += padChar;
    }
    return result.substring(0, result.length > 13 ? 13 : result.length);
  }

  static NimiqIconOptions fromAddress(String address) {
    final hash =
        makeHash(NimiqCoin.formatAddressGroups(address.split(' ').join('')));
    debugPrint('nimiq hash for "$address": $hash'); // ← add this

    int bodyIdx = int.parse(hash[0]);
    int bgIdx = int.parse(hash[2]);
    int accentIdx = int.parse(hash[11]);

    // Ensure no color collisions (mirrors JS hashToIndices)
    if (bodyIdx == bgIdx) {
      bodyIdx = (bodyIdx + 1) % 10;
    }
    while (accentIdx == bodyIdx || accentIdx == bgIdx) {
      accentIdx = (accentIdx + 1) % 10;
    }

    // Face = hash[3..4], Top = hash[5..6], Side = hash[7..8], Bottom = hash[9..10]
    int face = int.parse(hash.substring(3, 5)) % 21;
    int top = int.parse(hash.substring(5, 7)) % 21;
    int side = int.parse(hash.substring(7, 9)) % 21;
    int bottom = int.parse(hash.substring(9, 11)) % 21;

    return NimiqIconOptions(
      face: face,
      top: top,
      side: side,
      bottom: bottom,
      bodyColor: COLORS[bodyIdx],
      backgroundColor: BACKGROUND_COLORS[bgIdx],
      accentColor: COLORS[accentIdx],
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
