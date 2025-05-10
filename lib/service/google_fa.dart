import 'dart:math';
import 'dart:typed_data';

import 'package:cryptowallet/utils/app_config.dart';
import 'package:otp/otp.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

import '../main.dart';

class _GoogleFACodes {
  final String totp;
  const _GoogleFACodes({required this.totp});
}

class GoogleFA {
  static const String _otpSecretKey = '477a-aea5-700b-9547';

  static String googleSecret() {
    final rand = Random.secure();
    final bytes = <int>[];

    // Generate 20 random bytes for a 32-character base32 string
    for (var i = 0; i < 20; i++) {
      bytes.add(rand.nextInt(256));
    }

    // Base32 encode the byte array
    return Base32.encode(Uint8List.fromList(bytes));
  }

  static String authUrl(String secret) =>
      'otpauth://totp/$walletAbbr:Wallet?secret=$secret&issuer=$walletAbbr';

  static _GoogleFACodes generateOTP({required String secret}) {
    String totp = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      isGoogle: true,
      algorithm: Algorithm.SHA1,
    );
    return _GoogleFACodes(
      totp: totp,
    );
  }

  static bool get haveOTPSecret => GoogleFA.getOTPSecret() != null;

  static Future<void> saveOTPSecret({required String secret}) async {
    await pref.put(_otpSecretKey, secret);
  }

  static String? getOTPSecret() {
    String? secret = pref.get(_otpSecretKey);
    return secret;
  }

  static Future<void> removeOTPSecret() async {
    await pref.delete(_otpSecretKey);
  }
}
