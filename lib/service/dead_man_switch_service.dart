import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/ntcdcrypto.dart';

// ── Pref keys ──────────────────────────────────────────────────────────────────

const _kState = 'dms_state';
const _kConfig = 'dms_config';
const _kShares = 'dms_shares';
const _kLastActivity = 'dms_last_activity';

// ── State ──────────────────────────────────────────────────────────────────────

enum DmsState { inactive, active, triggered, cancelled }

// ── Config ─────────────────────────────────────────────────────────────────────

class DmsConfig {
  final String beneficiaryAddress;
  final int timeoutDays;
  final int threshold;
  final int totalShares;

  const DmsConfig({
    required this.beneficiaryAddress,
    required this.timeoutDays,
    required this.threshold,
    required this.totalShares,
  });

  Map<String, dynamic> toJson() => {
        'beneficiaryAddress': beneficiaryAddress,
        'timeoutDays': timeoutDays,
        'threshold': threshold,
        'totalShares': totalShares,
      };

  factory DmsConfig.fromJson(Map<String, dynamic> j) => DmsConfig(
        beneficiaryAddress: j['beneficiaryAddress'] as String,
        timeoutDays: j['timeoutDays'] as int,
        threshold: j['threshold'] as int,
        totalShares: j['totalShares'] as int,
      );
}

// ── Result types ───────────────────────────────────────────────────────────────

sealed class DmsResult {}

class DmsOk extends DmsResult {
  final List<String>? shares;
  DmsOk([this.shares]);
}

class DmsErr extends DmsResult {
  final String message;
  DmsErr(this.message);
}

// ── Service ────────────────────────────────────────────────────────────────────

class DeadManSwitchService {
  DeadManSwitchService._();

  // ── Getters ──────────────────────────────────────────────────────────────────

  static DmsState get state {
    final s = pref.get(_kState) as String?;
    return DmsState.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DmsState.inactive,
    );
  }

  static DmsConfig? get config {
    final raw = pref.get(_kConfig) as String?;
    if (raw == null) return null;
    try {
      return DmsConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static List<String>? get shares {
    final raw = pref.get(_kShares) as String?;
    if (raw == null) return null;
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return null;
    }
  }

  static DateTime? get lastActivity {
    final raw = pref.get(_kLastActivity) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Duration? get timeRemaining {
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null || state != DmsState.active) return null;
    final deadline = last.add(Duration(days: cfg.timeoutDays));
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static DateTime? get deadline {
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null) return null;
    return last.add(Duration(days: cfg.timeoutDays));
  }

  // ── Activity tracking (call from WalletCoinListItem) ─────────────────────────

  static Future<void> recordActivity() async {
    if (state != DmsState.active) return;
    await pref.put(_kLastActivity, DateTime.now().toIso8601String());
  }

  // ── Check on app open ─────────────────────────────────────────────────────────

  /// Call this on every app open. Returns triggered shares if switch fired.
  static Future<List<String>?> checkOnAppOpen() async {
    if (state != DmsState.active) return null;
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null) return null;

    final dl = last.add(Duration(days: cfg.timeoutDays));
    if (DateTime.now().isAfter(dl)) {
      await pref.put(_kState, DmsState.triggered.name);
      debugPrint(
          'DeadManSwitch: triggered after ${cfg.timeoutDays}d inactivity');
      return shares;
    }
    return null;
  }

  // ── Activate ──────────────────────────────────────────────────────────────────

  /// Split [mnemonic] using SSS and persist state.
  static Future<DmsResult> activate({
    required String mnemonic,
    required DmsConfig cfg,
  }) async {
    if (mnemonic.trim().isEmpty) return DmsErr('Mnemonic is empty');
    if (state == DmsState.active) return DmsErr('Switch is already active');

    try {
      final generatedShares = await compute(
        _splitMnemonic,
        _SplitArgs(mnemonic: mnemonic, cfg: cfg),
      );

      await pref.put(_kConfig, jsonEncode(cfg.toJson()));
      await pref.put(_kShares, jsonEncode(generatedShares));
      await pref.put(_kLastActivity, DateTime.now().toIso8601String());
      await pref.put(_kState, DmsState.active.name);

      return DmsOk(generatedShares);
    } catch (e, st) {
      debugPrint('DeadManSwitch activate error: $e\n$st');
      return DmsErr('Failed to split secret: $e');
    }
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────────

  static Future<DmsResult> heartbeat() async {
    if (state != DmsState.active) return DmsErr('Switch is not active');
    await pref.put(_kLastActivity, DateTime.now().toIso8601String());
    return DmsOk();
  }

  // ── Cancel ────────────────────────────────────────────────────────────────────

  static Future<DmsResult> cancel() async {
    if (state != DmsState.active) return DmsErr('Switch is not active');
    await pref.put(_kState, DmsState.cancelled.name);
    await pref.delete(_kShares);
    await pref.delete(_kConfig);
    await pref.delete(_kLastActivity);
    return DmsOk();
  }

  // ── Reset (from cancelled) ────────────────────────────────────────────────────

  static Future<void> reset() async {
    await pref.put(_kState, DmsState.inactive.name);
    await pref.delete(_kShares);
    await pref.delete(_kConfig);
    await pref.delete(_kLastActivity);
  }

  // ── Reconstruct (beneficiary side) ───────────────────────────────────────────

  static String reconstructMnemonic(List<String> providedShares) {
    final sss = SSS();
    return sss.combine(providedShares, false);
  }
}

// ── Compute helpers ────────────────────────────────────────────────────────────

class _SplitArgs {
  final String mnemonic;
  final DmsConfig cfg;
  const _SplitArgs({required this.mnemonic, required this.cfg});
}

List<String> _splitMnemonic(_SplitArgs args) {
  final sss = SSS();
  return sss.create(
    args.cfg.threshold,
    args.cfg.totalShares,
    args.mnemonic,
    false, // hex encoding
  );
}
