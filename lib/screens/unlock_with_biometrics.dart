import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../utils/rpc_urls.dart';

class UnlockWithBiometrics extends StatefulWidget {
  const UnlockWithBiometrics({super.key});

  @override
  State<UnlockWithBiometrics> createState() => _UnlockWithBiometricsState();
}

class _UnlockWithBiometricsState extends State<UnlockWithBiometrics> {
  bool allowedBiometrics = true;
  @override
  void initState() {
    super.initState();
    allowedBiometrics = pref.get(biometricsKey, defaultValue: true);
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Transform.scale(
      scale: 0.9,
      child: CupertinoSwitch(
        value: allowedBiometrics,
        activeColor: appBackgroundblue,
        onChanged: (bool value) async {
          if (await authenticate(context)) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            allowedBiometrics = !allowedBiometrics;
            setState(() {});
            await pref.put(biometricsKey, allowedBiometrics);
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  localization.authFailed,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
