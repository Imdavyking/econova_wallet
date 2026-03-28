import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/ntcdcrypto.dart';
import 'package:wallet_app/service/drand_service.dart';

// ── Debug flag ─────────────────────────────────────────────────────────────────
// flutter run --dart-define=DMS_TEST=true
const kDmsTestMode = bool.fromEnvironment('DMS_TEST', defaultValue: true);

// ── Pref keys ──────────────────────────────────────────────────────────────────

const _kState = 'dms_state';
const _kConfig = 'dms_config';
const _kShares = 'dms_shares';
const _kLastActivity = 'dms_last_activity';
const _kDrandRound = 'dms_drand_round';

// ── State ──────────────────────────────────────────────────────────────────────

enum DmsState { inactive, active, triggered, cancelled }

// ── Config ─────────────────────────────────────────────────────────────────────

class DmsConfig {
  /// Compressed secp256k1 public key (hex, 66 chars / 33 bytes).
  final String beneficiaryPublicKey;

  /// Timeout in seconds. Use [DmsTimeouts] presets.
  final int timeoutSeconds;

  final int threshold;
  final int totalShares;

  const DmsConfig({
    required this.beneficiaryPublicKey,
    required this.timeoutSeconds,
    required this.threshold,
    required this.totalShares,
  });

  /// Derived from public key — never stored separately.
  String get beneficiaryAddress => publicKeyToAddress(beneficiaryPublicKey);

  /// Human-readable timeout for display.
  String get timeoutLabel {
    if (timeoutSeconds < 3600) {
      final mins = timeoutSeconds ~/ 60;
      return '$mins min${mins == 1 ? '' : 's'}';
    }
    if (timeoutSeconds < 86400) {
      final hrs = timeoutSeconds ~/ 3600;
      return '$hrs hr${hrs == 1 ? '' : 's'}';
    }
    final days = timeoutSeconds ~/ 86400;
    return days >= 365 ? '1 year' : '$days days';
  }

  Map<String, dynamic> toJson() => {
        'beneficiaryPublicKey': beneficiaryPublicKey,
        'timeoutSeconds': timeoutSeconds,
        'threshold': threshold,
        'totalShares': totalShares,
      };

  factory DmsConfig.fromJson(Map<String, dynamic> j) => DmsConfig(
        beneficiaryPublicKey: j['beneficiaryPublicKey'] as String,
        // Legacy: old configs stored timeoutDays
        timeoutSeconds: j.containsKey('timeoutSeconds')
            ? j['timeoutSeconds'] as int
            : (j['timeoutDays'] as int) * 86400,
        threshold: j['threshold'] as int,
        totalShares: j['totalShares'] as int,
      );
}

// ── Timeout presets ────────────────────────────────────────────────────────────

typedef DmsTimeout = ({String label, int seconds});

class DmsTimeouts {
  DmsTimeouts._();

  static const List<DmsTimeout> debug = [
    (label: '30s', seconds: 30),
    (label: '1 min', seconds: 60),
    (label: '2 min', seconds: 120),
    (label: '5 min', seconds: 300),
    (label: '10 min', seconds: 600),
  ];

  static const List<DmsTimeout> production = [
    (label: '7d', seconds: 7 * 86400),
    (label: '14d', seconds: 14 * 86400),
    (label: '30d', seconds: 30 * 86400),
    (label: '90d', seconds: 90 * 86400),
    (label: '180d', seconds: 180 * 86400),
    (label: '1 year', seconds: 365 * 86400),
  ];

  static List<DmsTimeout> get current => kDmsTestMode ? debug : production;

  static int get defaultSeconds => kDmsTestMode ? 120 : 30 * 86400;
}

// ── Encrypted share ────────────────────────────────────────────────────────────

class EncryptedShare {
  final String ciphertext;
  final int drandRound;

  const EncryptedShare({required this.ciphertext, required this.drandRound});

  Map<String, dynamic> toJson() => {
        'ciphertext': ciphertext,
        'drandRound': drandRound,
      };

  factory EncryptedShare.fromJson(Map<String, dynamic> j) => EncryptedShare(
        ciphertext: j['ciphertext'] as String,
        drandRound: j['drandRound'] as int,
      );
}

// ── Result types ───────────────────────────────────────────────────────────────

sealed class DmsResult {}

class DmsOk extends DmsResult {
  final List<EncryptedShare>? encryptedShares;
  DmsOk([this.encryptedShares]);
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

  static List<EncryptedShare>? get encryptedShares {
    final raw = pref.get(_kShares) as String?;
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EncryptedShare.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static int? get drandRound => pref.get(_kDrandRound) as int?;

  static DateTime? get lastActivity {
    final raw = pref.get(_kLastActivity) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Duration? get timeRemaining {
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null || state != DmsState.active) return null;
    final deadline = last.add(Duration(seconds: cfg.timeoutSeconds));
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static DateTime? get deadline {
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null) return null;
    return last.add(Duration(seconds: cfg.timeoutSeconds));
  }

  // ── Activate ──────────────────────────────────────────────────────────────────

  static Future<DmsResult> activate({
    required String mnemonic,
    required DmsConfig cfg,
  }) async {
    if (mnemonic.trim().isEmpty) return DmsErr('Mnemonic is empty');
    if (state == DmsState.active) return DmsErr('Switch is already active');

    try {
      final activatedAt = DateTime.now();
      final deadlineDate =
          activatedAt.add(Duration(seconds: cfg.timeoutSeconds));
      final targetRound = DrandService.roundForTime(deadlineDate);

      debugPrint('DMS${kDmsTestMode ? ' [TEST MODE]' : ''}: '
          'timeout=${cfg.timeoutLabel}  '
          'deadline=$deadlineDate  →  drand round $targetRound '
          '(${DrandService.timeForRound(targetRound).toLocal()})');

      final rawShares = await compute(
        _splitMnemonic,
        _SplitArgs(mnemonic: mnemonic, cfg: cfg),
      );

      final pubKeyBytes =
          _hexToBytes(cfg.beneficiaryPublicKey.replaceFirst('0x', ''));

      final encShares = await compute(
        _encryptAllShares,
        _EncryptArgs(
          shares: rawShares,
          pubKeyBytes: pubKeyBytes,
          drandRound: targetRound,
        ),
      );

      await pref.put(_kConfig, jsonEncode(cfg.toJson()));
      await pref.put(
          _kShares, jsonEncode(encShares.map((e) => e.toJson()).toList()));
      await pref.put(_kDrandRound, targetRound);
      await pref.put(_kLastActivity, activatedAt.toIso8601String());
      await pref.put(_kState, DmsState.active.name);

      return DmsOk(encShares);
    } catch (e, st) {
      debugPrint('DMS activate error: $e\n$st');
      return DmsErr('Activation failed: $e');
    }
  }

  // ── Record activity ───────────────────────────────────────────────────────────

  static Future<void> recordActivity() async {
    if (state != DmsState.active) return;
    await pref.put(_kLastActivity, DateTime.now().toIso8601String());
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────────

  static Future<DmsResult> heartbeat() async {
    if (state != DmsState.active) return DmsErr('Switch is not active');
    final now = DateTime.now();
    await pref.put(_kLastActivity, now.toIso8601String());

    final cfg = config;
    if (cfg != null) {
      final newDeadline = now.add(Duration(seconds: cfg.timeoutSeconds));
      final newRound = DrandService.roundForTime(newDeadline);
      await pref.put(_kDrandRound, newRound);
      debugPrint('DMS heartbeat: new drand round = $newRound');
    }
    return DmsOk();
  }

  // ── Cancel ────────────────────────────────────────────────────────────────────

  static Future<DmsResult> cancel() async {
    if (state != DmsState.active) return DmsErr('Switch is not active');
    await pref.put(_kState, DmsState.cancelled.name);
    await pref.delete(_kShares);
    await pref.delete(_kConfig);
    await pref.delete(_kLastActivity);
    await pref.delete(_kDrandRound);
    return DmsOk();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────

  static Future<void> reset() async {
    await pref.put(_kState, DmsState.inactive.name);
    await pref.delete(_kShares);
    await pref.delete(_kConfig);
    await pref.delete(_kLastActivity);
    await pref.delete(_kDrandRound);
  }

  // ── Check on app open ─────────────────────────────────────────────────────────

  static Future<List<EncryptedShare>?> checkOnAppOpen() async {
    if (state != DmsState.active) return null;
    final cfg = config;
    final last = lastActivity;
    if (cfg == null || last == null) return null;
    final dl = last.add(Duration(seconds: cfg.timeoutSeconds));
    if (DateTime.now().isAfter(dl)) {
      await pref.put(_kState, DmsState.triggered.name);
      debugPrint('DMS triggered after ${cfg.timeoutLabel} of inactivity');
      return encryptedShares;
    }
    return null;
  }

  // ── Decrypt (beneficiary side) ────────────────────────────────────────────────

  static Future<String> decryptAndRecombine({
    required List<EncryptedShare> encryptedShares,
    required String beneficiaryPrivateKeyHex,
    required int threshold,
  }) async {
    if (encryptedShares.length < threshold) {
      throw Exception(
          'Need at least $threshold shares, got ${encryptedShares.length}');
    }

    final round = encryptedShares.first.drandRound;
    final drandRandom = await DrandService.fetchRandomness(round);
    final privKeyBytes =
        _hexToBytes(beneficiaryPrivateKeyHex.replaceFirst('0x', ''));

    final plainShares = await compute(
      _decryptAllShares,
      _DecryptArgs(
        encryptedShares: encryptedShares,
        privKeyBytes: privKeyBytes,
        drandRandomness: drandRandom,
      ),
    );

    final sss = SSS();
    return sss.combine(plainShares.take(threshold).toList(), false);
  }
}

// ── Isolate helpers ────────────────────────────────────────────────────────────

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
    false,
  );
}

class _EncryptArgs {
  final List<String> shares;
  final Uint8List pubKeyBytes;
  final int drandRound;
  const _EncryptArgs({
    required this.shares,
    required this.pubKeyBytes,
    required this.drandRound,
  });
}

List<EncryptedShare> _encryptAllShares(_EncryptArgs args) {
  return args.shares.map((share) {
    final roundBytes = Uint8List(8)
      ..buffer.asByteData().setUint64(0, args.drandRound);
    final timelockKey = _deriveTimelockKey(roundBytes);
    final sharePlain = Uint8List.fromList(utf8.encode(share));
    final aesCipher = aesGcmEncrypt(timelockKey, sharePlain);
    final eciesCipher = eciesEncrypt(args.pubKeyBytes, aesCipher);
    return EncryptedShare(
      ciphertext: base64.encode(eciesCipher),
      drandRound: args.drandRound,
    );
  }).toList();
}

class _DecryptArgs {
  final List<EncryptedShare> encryptedShares;
  final Uint8List privKeyBytes;
  final Uint8List drandRandomness;
  const _DecryptArgs({
    required this.encryptedShares,
    required this.privKeyBytes,
    required this.drandRandomness,
  });
}

List<String> _decryptAllShares(_DecryptArgs args) {
  return args.encryptedShares.map((es) {
    final eciesCipher = base64.decode(es.ciphertext);
    final aesCipher = eciesDecrypt(args.privKeyBytes, eciesCipher);
    final revealKey = _deriveRevealKey(args.drandRandomness);
    final plainBytes = aesGcmDecrypt(revealKey, aesCipher);
    return utf8.decode(plainBytes);
  }).toList();
}

// ── Crypto primitives ──────────────────────────────────────────────────────────

Uint8List _deriveTimelockKey(Uint8List roundBytes) {
  final label = utf8.encode('dms-timelock');
  final digest = SHA256Digest();
  digest.update(Uint8List.fromList(label), 0, label.length);
  digest.update(roundBytes, 0, roundBytes.length);
  final out = Uint8List(32);
  digest.doFinal(out, 0);
  return out;
}

Uint8List _deriveRevealKey(Uint8List drandRandomness) {
  final label = utf8.encode('dms-timelock-reveal');
  final digest = SHA256Digest();
  digest.update(Uint8List.fromList(label), 0, label.length);
  digest.update(drandRandomness, 0, drandRandomness.length);
  final out = Uint8List(32);
  digest.doFinal(out, 0);
  return out;
}

Uint8List aesGcmEncrypt(Uint8List key, Uint8List plaintext) {
  final iv = _randomBytes(12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  final buf = Uint8List(cipher.getOutputSize(plaintext.length));
  var off = 0;
  off += cipher.processBytes(plaintext, 0, plaintext.length, buf, off);
  off += cipher.doFinal(buf, off);
  return Uint8List.fromList([...iv, ...buf.sublist(0, off)]);
}

Uint8List aesGcmDecrypt(Uint8List key, Uint8List data) {
  final iv = data.sublist(0, 12);
  final payload = data.sublist(12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  final buf = Uint8List(cipher.getOutputSize(payload.length));
  var off = 0;
  off += cipher.processBytes(payload, 0, payload.length, buf, off);
  off += cipher.doFinal(buf, off);
  return buf.sublist(0, off);
}

Uint8List eciesEncrypt(Uint8List recipientPubKeyBytes, Uint8List plaintext) {
  final domain = ECDomainParameters('secp256k1');
  final recipientQ = domain.curve.decodePoint(recipientPubKeyBytes)!;
  final rng = FortunaRandom()..seed(KeyParameter(_randomBytes(32)));
  final keyGen = ECKeyGenerator()
    ..init(ParametersWithRandom(ECKeyGeneratorParameters(domain), rng));
  final ephPair = keyGen.generateKeyPair();
  final ephPriv = ephPair.privateKey as ECPrivateKey;
  final ephPub = ephPair.publicKey as ECPublicKey;
  final sharedPoint = recipientQ * ephPriv.d;
  final sharedSecretBytes = _bigIntToBytes32(sharedPoint!.x!.toBigInteger()!);
  final aesKey = _hkdfSha256(sharedSecretBytes, 'ecies-aes256gcm');
  final iv = _randomBytes(12);
  final gcm = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(aesKey), 128, iv, Uint8List(0)));
  final buf = Uint8List(gcm.getOutputSize(plaintext.length));
  var off = 0;
  off += gcm.processBytes(plaintext, 0, plaintext.length, buf, off);
  off += gcm.doFinal(buf, off);
  final ephPubBytes = ephPub.Q!.getEncoded(false);
  return Uint8List.fromList([...ephPubBytes, ...iv, ...buf.sublist(0, off)]);
}

Uint8List eciesDecrypt(Uint8List privKeyBytes, Uint8List data) {
  final domain = ECDomainParameters('secp256k1');
  final ephQ = domain.curve.decodePoint(data.sublist(0, 65))!;
  final privD = _bytesToBigInt(privKeyBytes);
  final sharedPoint = ephQ * privD;
  final sharedSecretBytes = _bigIntToBytes32(sharedPoint!.x!.toBigInteger()!);
  final aesKey = _hkdfSha256(sharedSecretBytes, 'ecies-aes256gcm');
  final iv = data.sublist(65, 77);
  final ciphertext = data.sublist(77);
  final gcm = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(aesKey), 128, iv, Uint8List(0)));
  final buf = Uint8List(gcm.getOutputSize(ciphertext.length));
  var off = 0;
  off += gcm.processBytes(ciphertext, 0, ciphertext.length, buf, off);
  off += gcm.doFinal(buf, off);
  return buf.sublist(0, off);
}

Uint8List _hkdfSha256(Uint8List ikm, String info) {
  final infoBytes = utf8.encode(info);
  final hmacExtract = HMac(SHA256Digest(), 64)
    ..init(KeyParameter(Uint8List(32)));
  hmacExtract.update(ikm, 0, ikm.length);
  final prk = Uint8List(32);
  hmacExtract.doFinal(prk, 0);
  final hmacExpand = HMac(SHA256Digest(), 64)..init(KeyParameter(prk));
  hmacExpand.update(Uint8List.fromList(infoBytes), 0, infoBytes.length);
  hmacExpand.update(Uint8List.fromList([0x01]), 0, 1);
  final okm = Uint8List(32);
  hmacExpand.doFinal(okm, 0);
  return okm;
}

Uint8List _randomBytes(int length) {
  final rng = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
}

Uint8List _hexToBytes(String hex) {
  if (hex.length.isOdd) hex = '0$hex';
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

BigInt _bytesToBigInt(Uint8List bytes) =>
    bytes.fold(BigInt.zero, (acc, byte) => (acc << 8) | BigInt.from(byte));

Uint8List _bigIntToBytes32(BigInt n) {
  final hex = n.toRadixString(16).padLeft(64, '0');
  return _hexToBytes(hex);
}
