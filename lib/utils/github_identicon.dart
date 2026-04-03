import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class GitHubIdenticon extends StatelessWidget {
  final int userId;
  final double size;

  const GitHubIdenticon({
    super.key,
    required this.userId,
    this.size = 100,
  });

  List<int> _md5Hash(String input) {
    return md5.convert(utf8.encode(input)).bytes; // NO toLowerCase!
  }

  Color _getColor(List<int> hash) {
    // Last 7 nibbles: HHHSSLL
    // Extract nibbles from bytes 14 and 15
    final nibbles = <int>[];
    for (final byte in hash) {
      nibbles.add((byte >> 4) & 0xF);
      nibbles.add(byte & 0xF);
    }

    // HHH = nibbles 25,26,27 → hue 0..360
    final hRaw = (nibbles[25] << 8) | (nibbles[26] << 4) | nibbles[27];
    final h = (hRaw / 4095.0) * 360.0;

    // SS → saturation: remapped to 0..20, subtracted from 65%
    final sRaw = (nibbles[28] << 4) | nibbles[29];
    final s = (65.0 - (sRaw / 255.0) * 20.0) / 100.0;

    // LL → lightness: remapped to 0..20, subtracted from 75%
    final lRaw = (nibbles[30] << 4) | nibbles[31];
    final l = (75.0 - (lRaw / 255.0) * 20.0) / 100.0;

    return HSLColor.fromAHSL(1.0, h, s, l).toColor();
  }

  List<List<bool>> _getGrid(List<int> hash) {
    // Extract nibbles
    final nibbles = <int>[];
    for (final byte in hash) {
      nibbles.add((byte >> 4) & 0xF);
      nibbles.add(byte & 0xF);
    }

    // First 15 nibbles → 5x3 grid (mirrored to 5x5)
    // Order: middle col first, then outward
    // Column order: 2, 1, 0 (col 3 = mirror of 1, col 4 = mirror of 0)
    final grid = List.generate(5, (_) => List.filled(5, false));

    int nibbleIndex = 0;
    for (int col = 2; col >= 0; col--) {
      for (int row = 0; row < 5; row++) {
        final filled = nibbles[nibbleIndex] % 2 == 0;
        grid[row][col] = filled;
        if (col != 2) {
          grid[row][4 - col] = filled; // mirror
        }
        nibbleIndex++;
      }
    }

    return grid;
  }

  @override
  Widget build(BuildContext context) {
    final hash = _md5Hash(userId.toString());
    final color = _getColor(hash);
    final grid = _getGrid(hash);
    final cellSize = size / 5;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IdenticonPainter(
          grid: grid,
          color: color,
          cellSize: cellSize,
        ),
      ),
    );
  }
}

class _IdenticonPainter extends CustomPainter {
  final List<List<bool>> grid;
  final Color color;
  final double cellSize;

  _IdenticonPainter({
    required this.grid,
    required this.color,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0F0F0);
    final fgPaint = Paint()..color = color;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (grid[row][col]) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            fgPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_IdenticonPainter old) =>
      old.color != color || old.grid != grid;
}
