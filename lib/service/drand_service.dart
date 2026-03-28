import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// drand Quicknet chain — 3-second rounds, BLS unchained.
/// Chain hash: 52db9ba7...
class DrandService {
  DrandService._();

  // ── Chain constants (drand Quicknet) ────────────────────────────────────────

  static const _baseUrl =
      'https://api.drand.sh/52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971';

  /// Unix timestamp (seconds) of round 1 on the Quicknet chain.
  static const int _genesisTime = 1692803367;

  /// Seconds between rounds.
  static const int _periodSeconds = 3;

  // ── Round ↔ time helpers ────────────────────────────────────────────────────

  /// Returns the drand round number that will be published **at or after** [t].
  ///
  /// Use this to lock a share until your deadline: the randomness for this
  /// round won't exist until that moment in real time.
  static int roundForTime(DateTime t) {
    final ts = t.millisecondsSinceEpoch ~/ 1000;
    if (ts <= _genesisTime) return 1;
    return ((ts - _genesisTime) / _periodSeconds).ceil();
  }

  /// Inverse: what wall-clock time does [round] correspond to?
  static DateTime timeForRound(int round) {
    return DateTime.fromMillisecondsSinceEpoch(
        (_genesisTime + (round - 1) * _periodSeconds) * 1000,
        isUtc: true);
  }

  // ── Fetch randomness ────────────────────────────────────────────────────────

  /// Fetches the 32-byte randomness for [round].
  ///
  /// Throws [DrandNotYetAvailableException] if the round is in the future
  /// (HTTP 404) — the beacon hasn't fired yet, shares are still locked.
  ///
  /// Throws [DrandFetchException] on any other error.
  static Future<Uint8List> fetchRandomness(int round) async {
    final uri = Uri.parse('$_baseUrl/public/$round');
    debugPrint('DrandService: fetching round $round → $uri');

    late http.Response resp;
    try {
      resp = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw DrandFetchException('Network error: $e');
    }

    if (resp.statusCode == 404) {
      throw DrandNotYetAvailableException(
          'Round $round is in the future — shares are still time-locked.');
    }
    if (resp.statusCode != 200) {
      throw DrandFetchException('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final hex = json['randomness'] as String;
    return _hexToBytes(hex);
  }

  /// Returns true if [round] has already been published (i.e. it is in the
  /// past), false if it's still in the future.
  static bool isRoundPast(int round) {
    return DateTime.now().isAfter(timeForRound(round));
  }

  // ── Latest round ────────────────────────────────────────────────────────────

  static Future<int> latestRound() async {
    final uri = Uri.parse('$_baseUrl/public/latest');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) throw DrandFetchException(resp.body);
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return json['round'] as int;
  }

  // ── Hex helper ──────────────────────────────────────────────────────────────

  static Uint8List _hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '').replaceAll('\n', '');
    if (hex.length.isOdd) hex = '0$hex';
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

// ── Exceptions ─────────────────────────────────────────────────────────────────

class DrandNotYetAvailableException implements Exception {
  final String message;
  const DrandNotYetAvailableException(this.message);
  @override
  String toString() => 'DrandNotYetAvailableException: $message';
}

class DrandFetchException implements Exception {
  final String message;
  const DrandFetchException(this.message);
  @override
  String toString() => 'DrandFetchException: $message';
}
