import 'package:wallet_app/screens/google_fa/fa_details.dart';
import 'package:wallet_app/service/google_fa.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'google_fa_status.dart';

class GoogleFAScreenVerify extends StatefulWidget {
  final FADetails faDetails;

  const GoogleFAScreenVerify({
    Key? key,
    required this.faDetails,
  }) : super(key: key);

  @override
  State<GoogleFAScreenVerify> createState() => _GoogleFAScreenVerifyState();
}

class _GoogleFAScreenVerifyState extends State<GoogleFAScreenVerify> {
  final pinController = TextEditingController();
  late FADetails faDetails;
  int attempts = 0;
  int maxAttempts = 3;
  List allNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  ScreenshotCallback screenshotCallback = ScreenshotCallback();
  late AppLocalizations localizations;
  ValueNotifier<bool> isComplete = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    faDetails = widget.faDetails;
    screenshotCallback.addListener(() {
      showDialogWithMessage(
        context: context,
        message: AppLocalizations.of(context)!.youCantScreenshot,
      );
    });
    disEnableScreenShot();
  }

  @override
  void dispose() {
    pinController.dispose();

    enableScreenShot();
    super.dispose();
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
            child: Container(
              height: MediaQuery.of(context).size.height * .8,
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    localizations.enterCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Pinput(
                    onClipboardFound: (String value) {
                      value = value.trim();
                      if (value.length != faLength) return;
                      pinController.setText(value);
                    },
                    defaultPinTheme: PinTheme(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: appBackgroundblue,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      isComplete.value = value.length == faLength;
                    },
                    cursor: Container(),
                    length: faLength,
                    autofocus: true,
                    controller: pinController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ValueListenableBuilder(
                    valueListenable: isComplete,
                    builder: (context, value, child) => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => appBackgroundblue
                                .withOpacity(isComplete.value ? 1 : 0.3),
                          ),
                          shape: WidgetStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          textStyle: WidgetStateProperty.resolveWith(
                            (states) => const TextStyle(color: Colors.white),
                          ),
                        ),
                        child: Text(
                          localizations.confirm,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: isComplete.value
                            ? () async {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                attempts++;

                                if (attempts >= maxAttempts) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localizations.tooManyAttempts,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  Navigator.pop(context, false);
                                  return;
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                                final pin = pinController.text.trim();
                                pinController.clear();
                                final otp = GoogleFA.generateOTP(
                                    secret: faDetails.secret);
                                if (otp.totp == pin) {
                                  GoogleFAStatus.faDetails.value = faDetails;
                                  Navigator.pop(context, true);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localizations.invalidCode,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            padding: const EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }
}
