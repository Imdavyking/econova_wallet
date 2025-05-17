import 'package:wallet_app/screens/main_screen.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../main.dart';

class Security extends StatefulWidget {
  final bool? isEnterPin;
  final bool? isChangingPin;
  final bool? useLocalAuth;
  const Security({
    Key? key,
    this.isEnterPin,
    this.isChangingPin,
    this.useLocalAuth,
  }) : super(key: key);

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  final pinController = TextEditingController();
  final pinController2 = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final enterPinController = TextEditingController();

  bool isConfirming = false;
  List allNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    ..shuffle();
  int currentTrial = 0;
  // disallow screenshots
  ScreenshotCallback screenshotCallback = ScreenshotCallback();

  @override
  void initState() {
    super.initState();
    screenshotCallback.addListener(() {
      showDialogWithMessage(
        context: context,
        message: localization.youCantScreenshot,
      );
    });
    disEnableScreenShot();
  }

  @override
  void dispose() {
    pinController.dispose();
    pinController2.dispose();
    enterPinController.dispose();
    if (widget.isEnterPin == null || widget.isEnterPin == false) {
      enableScreenShot();
    }
    super.dispose();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    final trialsRemaining = userPinTrials - currentTrial;
    TextEditingController currentController =
        isConfirming ? pinController2 : pinController;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localization.security),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            child: Container(
              height: MediaQuery.of(context).size.height * .8,
              color: Colors.transparent,
              child: Column(
                children: [
                  widget.isEnterPin != null && widget.isEnterPin == true
                      ? Text(
                          localization.enterYourPasscode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          isConfirming
                              ? localization.confirmYourPin
                              : localization.createYourPin,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Pinput(
                    defaultPinTheme: PinTheme(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appBackgroundblue,
                        ),
                      ),
                    ),
                    obscuringCharacter: ' ',
                    submittedPinTheme: const PinTheme(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appPrimaryColor,
                      ),
                    ),
                    cursor: Container(),
                    useNativeKeyboard: false,
                    onCompleted: (_) async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (widget.isEnterPin != null &&
                          widget.isEnterPin == true) {
                        currentTrial++;
                        bool passcodeCorrect =
                            pref.get(userUnlockPasscodeKey) ==
                                pinController.text.trim();
                        bool userHasTrials = currentTrial < userPinTrials;
                        if (passcodeCorrect) {
                          Navigator.pop(context, true);
                        } else if (userHasTrials) {
                          pinController.clear();
                        } else {
                          Navigator.pop(context, false);
                        }

                        return;
                      }
                      if (isConfirming) {
                        if (pinController.text.trim() ==
                            pinController2.text.trim()) {
                          await pref.put(
                            userUnlockPasscodeKey,
                            pinController2.text.trim(),
                          );

                          if (widget.isChangingPin != null &&
                              widget.isChangingPin == true) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            return;
                          }

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => const MainScreen()),
                              (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                localization.passcodeMismatch,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          pinController.clear();
                          pinController2.clear();
                          setState(() {
                            isConfirming = false;
                          });
                        }
                      } else {
                        setState(() {
                          isConfirming = true;
                        });
                      }
                    },
                    length: pinLength,
                    onChanged: (value) => setState(() {}),
                    autofocus: true,
                    obscureText: true,
                    controller: currentController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (widget.isChangingPin == null &&
                      widget.isChangingPin != true &&
                      trialsRemaining != userPinTrials)
                    Text(
                      localization.youHave(trialsRemaining),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[0],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[0];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[1],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[1];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[2],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[2];
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[3],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[3];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[4],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[4];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[5],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[5];
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[6],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[6];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[7],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[7];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[8],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[8];
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if ((widget.isEnterPin ?? false) &&
                          (widget.useLocalAuth ?? true))
                        InkWell(
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.fingerprint,
                              size: 35,
                            ),
                          ),
                          onTap: () async {
                            bool localAuthConfirmed =
                                await localAuthentication();
                            if (localAuthConfirmed) {
                              Navigator.pop(context, localAuthConfirmed);
                            }
                          },
                        )
                      else
                        const SizedBox(
                          width: 50,
                          height: 50,
                        ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Text(
                              allNumbers[9],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                        onTap: () {
                          currentController.text += allNumbers[9];
                        },
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: Icon(Icons.backspace)),
                        ),
                        onTap: () {
                          if (currentController.text.trim() == '') return;
                          currentController.setText(currentController.text
                              .substring(0, currentController.text.length - 1));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localization.passcodeInfo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(45, 25, 45, 25),
          ),
        ),
      ),
    );
  }
}
