import 'package:cryptowallet/service/google_fa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../utils/app_config.dart';
import '../wallet.dart';
import 'fa_details.dart';
import 'google_fa_screen_verify.dart';

class GoogleFAScreen extends StatefulWidget {
  const GoogleFAScreen({Key? key}) : super(key: key);

  @override
  State<GoogleFAScreen> createState() => _GoogleFAScreenState();
}

class _GoogleFAScreenState extends State<GoogleFAScreen> {
  ValueNotifier<FADetails?> faDetail = ValueNotifier<FADetails?>(null);
  late AppLocalizations localizations;
  @override
  void initState() {
    super.initState();
    String secret = GoogleFA.googleSecret();
    String url = GoogleFA.authUrl(secret);
    faDetail.value = FADetails(secret: secret, url: url);
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.google2FA,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  localizations.scan2FACode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                ValueListenableBuilder<FADetails?>(
                  valueListenable: faDetail,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: Card(
                            color: const Color(0xffF1F1F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Align(
                              alignment: Alignment.center,
                              child: QrImage(
                                padding: const EdgeInsets.all(10),
                                data: value!.url!,
                                version: QrVersions.auto,
                                size: 250,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Or enter the secret key below',
                          style: TextStyle(
                            fontSize: 16,
                            color: grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value.secret,
                              style: const TextStyle(
                                fontSize: 16,
                                color: grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                // copy to clipboard
                                await Clipboard.setData(ClipboardData(
                                  text: value.secret,
                                ));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      localizations.copiedToClipboard,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.copy,
                                size: 20,
                                color: grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => appBackgroundblue),
                              shape: WidgetStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              textStyle: WidgetStateProperty.resolveWith(
                                (states) =>
                                    const TextStyle(color: Colors.white),
                              ),
                            ),
                            child: Text(
                              localizations.continue_,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              bool? verified = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoogleFAScreenVerify(
                                    faDetails: value,
                                  ),
                                ),
                              );

                              if (verified == null) return;

                              if (verified == false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      localizations.invalidCode,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              await GoogleFA.saveOTPSecret(
                                secret: value.secret,
                              );

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const Wallet(),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
