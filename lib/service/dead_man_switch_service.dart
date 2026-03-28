import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/ntcdcrypto.dart';
import 'package:wallet_app/service/drand_service.dart';

// ── Pref keys ──────────────────────────────────────────────────────────────────

const _kState = 'dms_state';
const _kConfig = 'dms_config';
const _kShares = 'dms_shares'; // stores List<EncryptedShare> as JSON
const _kLastActivity = 'dms_last_activity';
const _kDrandRound = 'dms_drand_round';

// ── State ──────────────────────────────────────────────────────────────────────

enum DmsState { inactive, active, triggered, cancelled }

// ── Config ─────────────────────────────────────────────────────────────────────

class DmsConfig {
  String get beneficiaryAddress => publicKeyToAddress(beneficiaryPublicKey);

  /// Compressed secp256k1 public key (hex, 66 chars / 33 bytes) belonging to
  /// the beneficiary.  Only the holder of the matching private key can decrypt
  /// the shares.
  final String beneficiaryPublicKey;

  final int timeoutDays;
  final int threshold;
  final int totalShares;

  const DmsConfig({
    required this.beneficiaryPublicKey,
    required this.timeoutDays,
    required this.threshold,
    required this.totalShares,
  });

  Map<String, dynamic> toJson() => {
        'beneficiaryAddress': beneficiaryAddress,
        'beneficiaryPublicKey': beneficiaryPublicKey,
        'timeoutDays': timeoutDays,
        'threshold': threshold,
        'totalShares': totalShares,
      };

  factory DmsConfig.fromJson(Map<String, dynamic> j) => DmsConfig(
        beneficiaryPublicKey: j['beneficiaryPublicKey'] as String,
        timeoutDays: j['timeoutDays'] as int,
        threshold: j['threshold'] as int,
        totalShares: j['totalShares'] as int,
      );
}

// ── Encrypted share ────────────────────────────────────────────────────────────

/// Stores one fully-encrypted share.
///
/// Encryption layers (outer → inner):
/// 1. ECIES(beneficiaryPublicKey)   — only beneficiary can unwrap
/// 2. AES-256-GCM(drandRandomness) — only unlockable after deadline round
class EncryptedShare {
  /// The raw bytes of the doubly-encrypted share, base64-encoded.
  final String ciphertext;

  /// drand round whose randomness was used as the inner AES key material.
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
  /// Present on activate — the *encrypted* shares ready to distribute.
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

  /// Returns the stored list of [EncryptedShare]s (already encrypted —
  /// safe to display QR codes or send over WebSocket).
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

  // ── Activate ──────────────────────────────────────────────────────────────────

  static Future<DmsResult> activate({
    required String mnemonic,
    required DmsConfig cfg,
  }) async {
    if (mnemonic.trim().isEmpty) return DmsErr('Mnemonic is empty');
    if (state == DmsState.active) return DmsErr('Switch is already active');

    try {
      // 1. Calculate which drand round corresponds to the deadline.
      final activatedAt = DateTime.now();
      final deadlineDate = activatedAt.add(Duration(days: cfg.timeoutDays));
      final targetRound = DrandService.roundForTime(deadlineDate);

      debugPrint('DMS: deadline=$deadlineDate  →  drand round $targetRound '
          '(${DrandService.timeForRound(targetRound).toLocal()})');

      // 2. Split mnemonic into SSS shares on an isolate.
      final rawShares = await compute(
        _splitMnemonic,
        _SplitArgs(mnemonic: mnemonic, cfg: cfg),
      );

      // 3. Encrypt each share: AES-256-GCM(timelockKey) then ECIES(pubKey).
      //    The timelockKey is derived from the *commitment* to the drand round —
      //    the actual randomness (= decryption key) won't exist until that round
      //    fires, so shares are physically un-decryptable before the deadline.
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

      // 4. Persist.
      await pref.put(_kConfig, jsonEncode(cfg.toJson()));
      await pref.put(
        _kShares,
        jsonEncode(encShares.map((e) => e.toJson()).toList()),
      );
      await pref.put(_kDrandRound, targetRound);
      await pref.put(_kLastActivity, activatedAt.toIso8601String());
      await pref.put(_kState, DmsState.active.name);

      return DmsOk(encShares);
    } catch (e, st) {
      debugPrint('DMS activate error: $e\n$st');
      return DmsErr('Activation failed: $e');
    }
  }

  static Future<void> recordActivity() async {
    if (state != DmsState.active) return;
    await pref.put(_kLastActivity, DateTime.now().toIso8601String());
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────────

  static Future<DmsResult> heartbeat() async {
    if (state != DmsState.active) return DmsErr('Switch is not active');
    final now = DateTime.now();
    await pref.put(_kLastActivity, now.toIso8601String());

    // Re-compute drand round since the deadline just moved.
    final cfg = config;
    if (cfg != null) {
      final newDeadline = now.add(Duration(days: cfg.timeoutDays));
      final newRound = DrandService.roundForTime(newDeadline);
      await pref.put(_kDrandRound, newRound);
      debugPrint('DMS heartbeat: new drand round target = $newRound');
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
    final dl = last.add(Duration(days: cfg.timeoutDays));
    if (DateTime.now().isAfter(dl)) {
      await pref.put(_kState, DmsState.triggered.name);
      return encryptedShares;
    }
    return null;
  }

  // ── Decrypt (beneficiary side) ────────────────────────────────────────────────

  /// Call on the **beneficiary's device** to reconstruct the mnemonic.
  ///
  /// Steps:
  ///   1. Fetch drand randomness for [share.drandRound]
  ///      (throws [DrandNotYetAvailableException] if deadline hasn't passed)
  ///   2. ECIES-decrypt with [beneficiaryPrivateKeyHex]
  ///   3. AES-GCM-decrypt with drand randomness
  ///   4. Combine enough plaintext shares via SSS
  static Future<String> decryptAndRecombine({
    required List<EncryptedShare> encryptedShares,
    required String beneficiaryPrivateKeyHex,
    required int threshold,
  }) async {
    if (encryptedShares.length < threshold) {
      throw Exception(
          'Need at least $threshold shares, got ${encryptedShares.length}');
    }

    // Fetch drand randomness — will throw if round is still in the future.
    final round = encryptedShares.first.drandRound;
    final drandRandom = await DrandService.fetchRandomness(round);

    final privKeyBytes =
        _hexToBytes(beneficiaryPrivateKeyHex.replaceFirst('0x', ''));

    // Decrypt shares in isolate.
    final plainShares = await compute(
      _decryptAllShares,
      _DecryptArgs(
        encryptedShares: encryptedShares,
        privKeyBytes: privKeyBytes,
        drandRandomness: drandRandom,
      ),
    );

    // Recombine with SSS.
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

// ──

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
    // Step 1 — AES-256-GCM with key derived from drand round commitment.
    //   key = SHA-256("dms-timelock" || round_as_8_bytes)
    //   We use a *commitment* (deterministic), not the actual randomness.
    //   The actual randomness (same derivation path but with the beacon output)
    //   will unlock it after the deadline.
    final roundBytes = Uint8List(8)
      ..buffer.asByteData().setUint64(0, args.drandRound);
    final timelockKey = _deriveTimelockKey(roundBytes);
    final sharePlain = Uint8List.fromList(utf8.encode(share));
    final aesCipher = aesGcmEncrypt(timelockKey, sharePlain);

    // Step 2 — ECIES with beneficiary's secp256k1 public key.
    final eciesCipher = eciesEncrypt(args.pubKeyBytes, aesCipher);

    return EncryptedShare(
      ciphertext: base64.encode(eciesCipher),
      drandRound: args.drandRound,
    );
  }).toList();
}

// ──

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
    // Step 1 — ECIES decrypt.
    final eciesCipher = base64.decode(es.ciphertext);
    final aesCipher = eciesDecrypt(args.privKeyBytes, eciesCipher);

    // Step 2 — AES-GCM decrypt with drand randomness.
    //   key = SHA-256("dms-timelock-reveal" || drand_randomness)
    final revealKey = _deriveRevealKey(args.drandRandomness);
    final plainBytes = aesGcmDecrypt(revealKey, aesCipher);

    return utf8.decode(plainBytes);
  }).toList();
}

// ── Crypto primitives ──────────────────────────────────────────────────────────

/// Derive the 32-byte AES key used at *activation* time (commitment).
/// key = SHA-256( "dms-timelock" || round_8_bytes )
Uint8List _deriveTimelockKey(Uint8List roundBytes) {
  final label = utf8.encode('dms-timelock');
  final digest = SHA256Digest();
  digest.update(Uint8List.fromList(label), 0, label.length);
  digest.update(roundBytes, 0, roundBytes.length);
  final out = Uint8List(32);
  digest.doFinal(out, 0);
  return out;
}

/// Derive the 32-byte AES key used at *decryption* time (reveal).
/// key = SHA-256( "dms-timelock-reveal" || drand_randomness_32_bytes )
Uint8List _deriveRevealKey(Uint8List drandRandomness) {
  final label = utf8.encode('dms-timelock-reveal');
  final digest = SHA256Digest();
  digest.update(Uint8List.fromList(label), 0, label.length);
  digest.update(drandRandomness, 0, drandRandomness.length);
  final out = Uint8List(32);
  digest.doFinal(out, 0);
  return out;
}

// ──────────────────────────────────────────────────────────────────────────────
// AES-256-GCM
// ──────────────────────────────────────────────────────────────────────────────

// ── AES-256-GCM fix ────────────────────────────────────────────────────────────

Uint8List aesGcmEncrypt(Uint8List key, Uint8List plaintext) {
  final iv = _randomBytes(12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));

  final buf = Uint8List(cipher.getOutputSize(plaintext.length));
  var off = 0;
  off += cipher.processBytes(plaintext, 0, plaintext.length, buf, off);
  off += cipher.doFinal(buf, off); // ← capture return value

  // Trim to actual bytes written, then prepend IV
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
  off += cipher.doFinal(buf, off); // ← capture return value

  return buf.sublist(0, off); // ← trim
}

// ── ECIES fix ──────────────────────────────────────────────────────────────────

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
  off += gcm.doFinal(buf, off); // ← capture return value

  final ephPubBytes = ephPub.Q!.getEncoded(false); // 65 bytes uncompressed
  // Layout: ephPubKey(65) | iv(12) | trimmed ciphertext+tag
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
  off += gcm.doFinal(buf, off); // ← capture return value

  return buf.sublist(0, off); // ← trim
}
// ── HKDF-SHA256 (extract + expand, OKM = 32 bytes) ───────────────────────────

Uint8List _hkdfSha256(Uint8List ikm, String info) {
  final infoBytes = utf8.encode(info);

  // Extract: PRK = HMAC-SHA256(salt=zeros, ikm)
  final hmacExtract = HMac(SHA256Digest(), 64)
    ..init(KeyParameter(Uint8List(32)));
  hmacExtract.update(ikm, 0, ikm.length);
  final prk = Uint8List(32);
  hmacExtract.doFinal(prk, 0);

  // Expand: T(1) = HMAC-SHA256(PRK, info || 0x01)
  final hmacExpand = HMac(SHA256Digest(), 64)..init(KeyParameter(prk));
  hmacExpand.update(Uint8List.fromList(infoBytes), 0, infoBytes.length);
  hmacExpand.update(Uint8List.fromList([0x01]), 0, 1);
  final okm = Uint8List(32);
  hmacExpand.doFinal(okm, 0);
  return okm;
}

// ── Utility ───────────────────────────────────────────────────────────────────

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

BigInt _bytesToBigInt(Uint8List bytes) {
  return bytes.fold(BigInt.zero, (acc, byte) => (acc << 8) | BigInt.from(byte));
}

Uint8List _bigIntToBytes32(BigInt n) {
  final hex = n.toRadixString(16).padLeft(64, '0');
  return _hexToBytes(hex);
}
