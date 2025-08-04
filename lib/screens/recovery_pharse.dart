import 'package:wallet_app/screens/confirm_seed_phrase.dart';
import 'package:wallet_app/screens/show_shamir_shares.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:screenshot_callback/screenshot_callback.dart';

import '../utils/rpc_urls.dart';

class RecoveryPhrase extends StatefulWidget {
  final String data;
  final bool viewOnly;

  const RecoveryPhrase({
    super.key,
    required this.data,
    this.viewOnly = true,
  });

  @override
  _RecoveryPhraseState createState() => _RecoveryPhraseState();
}

class _RecoveryPhraseState extends State<RecoveryPhrase>
    with WidgetsBindingObserver {
  // disallow screenshots
  ScreenshotCallback screenshotCallback = ScreenshotCallback();
  bool invisiblemnemonic = false;
  bool securitydialogOpen = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (invisiblemnemonic) {
          invisiblemnemonic = false;
          if (await authenticate(context)) {
            await disEnableScreenShot();
            setState(() {
              securitydialogOpen = false;
            });
          } else {
            SystemNavigator.pop();
          }
        }
        break;
      case AppLifecycleState.paused:
        if (!securitydialogOpen) {
          setState(() {
            invisiblemnemonic = true;
            securitydialogOpen = true;
          });
        }
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    screenshotCallback.addListener(() {
      showDialogWithMessage(
        context: context,
        message: localization.youCantScreenshot,
      );
    });
    WidgetsBinding.instance.addObserver(this);
    disEnableScreenShot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    enableScreenShot();
    super.dispose();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    List mmemonic = widget.data.split(' ');
    int currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.yourSecretPhrase),
      ),
      key: scaffoldKey,
      body: securitydialogOpen
          ? Container()
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(
                        localization.writeDownYourmnemonic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      for (int i = 0; i < mmemonic.length ~/ 3; i++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: '${(currentIndex + 1)}. ',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text: mmemonic[currentIndex++],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: '${(currentIndex + 1)}. ',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text: mmemonic[currentIndex++],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: '${(currentIndex + 1)}. ',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text: mmemonic[currentIndex++],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                      if (!widget.viewOnly)
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: widget.data,
                              ),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localization.copiedToClipboard,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    localization.copy,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Icon(Icons.copy)
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.red[100]),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localization.doNotShareYourmnemonic,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                localization.ifSomeoneHasYourmnemonic,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      if (widget.viewOnly)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => appBackgroundblue),
                              shape: WidgetStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => ShowShamirShares(
                                    data: widget.data,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                localization.exportAsShamirShares,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!widget.viewOnly) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => appBackgroundblue),
                              shape: WidgetStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => Confirmmnemonic(
                                    mmenomic: widget.data.split(' '),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                localization.continue_,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
