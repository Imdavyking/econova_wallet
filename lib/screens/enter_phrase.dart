import 'package:wallet_app/components/wallet_logo.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/import_shamir_secret.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/qr_scan_view.dart';

class EnterPhrase extends StatefulWidget {
  const EnterPhrase({super.key});
  @override
  State<EnterPhrase> createState() => _EnterPhraseState();
}

class _EnterPhraseState extends State<EnterPhrase> with WidgetsBindingObserver {
  final mnemonicController = TextEditingController();
  final walletNameController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  // disallow screenshots
  ScreenshotCallback screenshotCallback = ScreenshotCallback();
  bool invisiblemnemonic = false;
  bool securitydialogOpen = false;

  final _prediction = ValueNotifier<List<String>>([]);

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
    mnemonicController.text = kDebugMode ? testMnemonic : '';
    walletNameController.text = kDebugMode ? 'Test Wallet(DO NOT USE)' : '';
  }

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
  void dispose() {
    enableScreenShot();
    WidgetsBinding.instance.removeObserver(this);
    mnemonicController.dispose();
    walletNameController.dispose();
    super.dispose();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.entermnemonic,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              String? seedPhrase = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const QRScanView(),
                ),
              );
              if (seedPhrase == null) return;
              mnemonicController.setText(seedPhrase);
            },
            icon: const Icon(
              Icons.qr_code_scanner,
            ),
          )
        ],
      ),
      key: _scaffoldKey,
      body: securitydialogOpen
          ? Container()
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const WalletLogo(),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: walletNameController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: localization.name,
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none), // you
                            filled: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            TextFormField(
                              maxLines: 3,
                              controller: mnemonicController,
                              onChanged: (val) {
                                final userWords = val.split(' ');
                                final lastWord =
                                    userWords[userWords.length - 1].trim();

                                if (lastWord == '') {
                                  _prediction.value = [];
                                  return;
                                }
                                final predictions =
                                    phraseAutoComplete.autoComplete(
                                  prefix: lastWord,
                                  limit: 15,
                                );

                                _prediction.value = predictions;
                              },
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  top: 100,
                                  left: 12,
                                  right: 12,
                                ),
                                hintText: localization.entermnemonic,
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide.none,
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide.none),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide.none,
                                ), // you
                                filled: true,
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  ClipboardData? cdata =
                                      await Clipboard.getData(
                                          Clipboard.kTextPlain);
                                  if (cdata == null) return;
                                  if (cdata.text == null) return;
                                  mnemonicController.setText(cdata.text!);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      localization.paste,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => appBackgroundblue,
                              ),
                              shape: WidgetStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              String? mnemonics = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const ImportShamirSecret(),
                                ),
                              );

                              if (mnemonics == null) return;
                              mnemonicController.setText(mnemonics);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                localization.importShamirSecret,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
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
                            onPressed: isLoading
                                ? null
                                : () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();

                                    final String mnemonics = mnemonicController
                                        .text
                                        .trim()
                                        .toLowerCase();

                                    String cryptoWallName =
                                        walletNameController.text.trim();

                                    if (cryptoWallName.isEmpty ||
                                        mnemonics.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            localization.enterName,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (isLoading) return;
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      final mnemonicValid = await compute(
                                        bip39.validateMnemonic,
                                        mnemonics,
                                      );

                                      if (!mnemonicValid) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              localization.invalidmnemonic,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                        return;
                                      }
                                      final mnemonicsList =
                                          WalletService.getActiveKeys(
                                        WalletType.secretPhrase,
                                      );

                                      final phraseData = SeedPhraseParams(
                                        data: mnemonics,
                                        name: cryptoWallName,
                                      );

                                      for (WalletParams? phrases
                                          in mnemonicsList) {
                                        if (phrases == phraseData) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                localization
                                                    .mnemonicAlreadyImported,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        }
                                      }

                                      seedPhraseRoot = await compute(
                                        seedFromMnemonic,
                                        phraseData.data,
                                      );

                                      await WalletService.setActiveKey(
                                        WalletType.secretPhrase,
                                        phraseData,
                                      );

                                      await importAllKeys(phraseData.data);

                                      await pref.put(
                                        currentUserWalletNameKey,
                                        cryptoWallName,
                                      );

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => const Wallet(),
                                        ),
                                        (r) => false,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } catch (e, sk) {
                                      if (kDebugMode) {
                                        print(e);
                                        print(sk);
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            localization.errorTryAgain,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      );

                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: isLoading
                                  ? Text(
                                      localization.loading,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  // const Loader(
                                  //     color: Colors.black,
                                  //   )
                                  : Text(
                                      localization.confirm,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _prediction,
                          builder: (context, List value, child) {
                            if (value.isEmpty) return Container();

                            return Wrap(
                              children: [
                                for (String val in value) ...[
                                  GestureDetector(
                                    onTap: () {
                                      final currentText =
                                          mnemonicController.text;
                                      const space = ' ';
                                      final lastSpaceIndex =
                                          currentText.lastIndexOf(space);

                                      if (lastSpaceIndex == -1) {
                                        mnemonicController
                                            .setText('$val$space');
                                      } else {
                                        mnemonicController.setText(
                                            '${currentText.substring(0, lastSpaceIndex)}$space$val$space');
                                      }
                                      _prediction.value = [];
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          val,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
