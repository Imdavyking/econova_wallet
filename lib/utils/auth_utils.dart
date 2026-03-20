import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../main.dart';
import '../screens/google_fa/fa_details.dart';
import '../screens/google_fa/google_fa_screen_verify.dart';
import '../screens/security.dart';
import '../service/google_fa.dart';
import 'app_config.dart';
import 'rpc_urls.dart' show disEnableScreenShot, enableScreenShot;

Future<bool> authenticateIsAvailable() async {
  final localAuth = LocalAuthentication();
  return await localAuth.canCheckBiometrics &&
      await localAuth.isDeviceSupported();
}

Future<bool> localAuthentication() async {
  if (!pref.get(biometricsKey, defaultValue: true)) return false;
  final localAuth = LocalAuthentication();
  if (await authenticateIsAvailable()) {
    return await localAuth.authenticate(
      localizedReason: 'Your authentication is needed.',
    );
  }
  return false;
}

Future<bool> authenticate(
  BuildContext context, {
  bool? useLocalAuth,
}) async {
  bool? didAuthenticate = false;
  await disEnableScreenShot();

  if (GoogleFA.haveOTPSecret) {
    final faDetails = FADetails(secret: GoogleFA.getOTPSecret()!);
    if (context.mounted) {
      didAuthenticate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => GoogleFAScreenVerify(faDetails: faDetails),
        ),
      );
    }
    return didAuthenticate ??= false;
  }

  if (useLocalAuth ?? true && didAuthenticate == false) {
    didAuthenticate = await localAuthentication();
  }

  if (!didAuthenticate) {
    if (context.mounted) {
      didAuthenticate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Security(
            isEnterPin: true,
            useLocalAuth: useLocalAuth,
          ),
        ),
      );
    }
  }

  await enableScreenShot();
  return didAuthenticate ?? false;
}
