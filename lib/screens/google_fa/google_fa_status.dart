import 'package:cryptowallet/screens/google_fa/fa_details.dart';
import 'package:cryptowallet/service/google_fa.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../utils/rpc_urls.dart';
import 'google_fa_screen.dart';

class GoogleFAStatus extends StatefulWidget {
  static ValueNotifier<FADetails?> faDetails = ValueNotifier(null);
  const GoogleFAStatus({Key? key}) : super(key: key);

  @override
  State<GoogleFAStatus> createState() => _GoogleFAStatusState();
}

class _GoogleFAStatusState extends State<GoogleFAStatus> {
  bool faEnabled = true;
  late AppLocalizations localizations;
  @override
  void initState() {
    super.initState();
    faEnabled = GoogleFA.haveOTPSecret;
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context)!;
    return Transform.scale(
      scale: 0.9,
      child: CupertinoSwitch(
        value: faEnabled,
        activeColor: appBackgroundblue,
        onChanged: (bool enable) async {
          if (!await authenticate(context)) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  localizations.authFailed,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
            return;
          }

          if (enable) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => const GoogleFAScreen(),
              ),
            );
          } else {
            await GoogleFA.removeOTPSecret();
            GoogleFAStatus.faDetails.value = null;
            faEnabled = false;
            setState(() {});
          }
        },
      ),
    );
  }
}
