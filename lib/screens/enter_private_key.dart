import 'package:bs58check/bs58check.dart';
import 'package:wallet_app/components/wallet_logo.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:pinput/pinput.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:web3dart/crypto.dart';
import '../components/loader.dart';
import '../interface/keystore.dart';
import '../main.dart';
import '../utils/is_hex_without_prefix.dart';
import '../utils/qr_scan_view.dart';

class EnterPrivateKey extends StatefulWidget {
  final Coin coin;
  const EnterPrivateKey({
    super.key,
    required this.coin,
  });
  @override
  State<EnterPrivateKey> createState() => _EnterPrivateKeyState();
}

class _EnterPrivateKeyState extends State<EnterPrivateKey>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final privateKeyCntrl = TextEditingController();
  final keyStoreCntrl = TextEditingController();
  final walletNameController = TextEditingController();
  final passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late TabController importMode;
  ValueNotifier<bool> isPrivateKeyMode = ValueNotifier(true);

  // disallow screenshots
  ScreenshotCallback screenshotCallback = ScreenshotCallback();
  bool invisiblePrivateKey = false;
  bool securitydialogOpen = false;
  late Coin coin;

  late AppLocalizations localization;
  int totalTabs = 1;

  int boolToInt(bool value) {
    return value ? 1 : 0;
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
    coin = widget.coin;
    // convert bool to int

    totalTabs += boolToInt(coin.supportKeystore);

    importMode = TabController(
      length: totalTabs,
      vsync: this,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (invisiblePrivateKey) {
          invisiblePrivateKey = false;
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
            invisiblePrivateKey = true;
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
    privateKeyCntrl.dispose();
    walletNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restore ${coin.getName()}',
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
              final currentContrl =
                  isPrivateKeyMode.value ? privateKeyCntrl : keyStoreCntrl;
              currentContrl.setText(seedPhrase);
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
                        if (totalTabs > 1)
                          DefaultTabController(
                            length: totalTabs,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    color:
                                        const Color.fromRGBO(0, 80, 209, 0.1),
                                  ),
                                  child: TabBar(
                                    onTap: (value) {
                                      isPrivateKeyMode.value =
                                          importMode.index == 0;
                                    },
                                    controller: importMode,
                                    splashBorderRadius:
                                        BorderRadius.circular(22),
                                    labelColor: Colors.black,
                                    unselectedLabelColor: appBackgroundblue,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      color: appBackgroundblue,
                                    ),
                                    tabs: const [
                                      Tab(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "PrivateKey",
                                          ),
                                        ),
                                      ),
                                      Tab(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "KeyStore JSON",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                  child: TabBarView(children: [
                                    Icon(
                                      Icons.apps,
                                      color: Colors.transparent,
                                    ),
                                    Icon(
                                      Icons.movie,
                                      color: Colors.transparent,
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        Stack(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: isPrivateKeyMode,
                              builder: (context, value, child) {
                                final currentContrl = isPrivateKeyMode.value
                                    ? privateKeyCntrl
                                    : keyStoreCntrl;
                                return TextFormField(
                                  maxLines: 3,
                                  controller: currentContrl,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                      top: 100,
                                      left: 12,
                                      right: 12,
                                    ),
                                    hintText: isPrivateKeyMode.value
                                        ? localization.enterPrivateKey
                                        : localization.enterKeystore,
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide.none,
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide.none),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide.none,
                                    ), // you
                                    filled: true,
                                  ),
                                );
                              },
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
                                  final currentContrl = isPrivateKeyMode.value
                                      ? privateKeyCntrl
                                      : keyStoreCntrl;

                                  currentContrl.setText(cdata.text!);
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
                        ValueListenableBuilder(
                          valueListenable: isPrivateKeyMode,
                          builder: (context, value, child) {
                            if (isPrivateKeyMode.value) {
                              return Container();
                            }
                            if (!coin.supportKeystore) return Container();
                            return Column(
                              children: [
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintText: localization.enterPassword,
                                    focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide.none),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide.none),
                                    enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide.none), // you
                                    filled: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            );
                          },
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
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();

                              String privateKey = privateKeyCntrl.text.trim();

                              final String password =
                                  passwordController.text.trim();
                              final String keyStore = keyStoreCntrl.text.trim();

                              String cryptoWallName =
                                  walletNameController.text.trim();

                              final privateKMod = isPrivateKeyMode.value;

                              if (cryptoWallName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      localization.enterName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                                return;
                              } else if (privateKMod && privateKey.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      localization.enterPrivateKey,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                                return;
                              } else if (!privateKMod && keyStore.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      localization.enterKeystore,
                                      style:
                                          const TextStyle(color: Colors.white),
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
                                if (!privateKMod) {
                                  final params = KeyStoreParams(
                                    keystore: keyStore,
                                    password: password,
                                  );
                                  final privateBytes = await compute(
                                    KeyStore.fromKeystore,
                                    params,
                                  );

                                  privateKey = HEX.encode(privateBytes);
                                } else {
                                  privateKey = strip0x(privateKey);

                                  privateKey = privateKey.split(':').last;

                                  Uint8List privKeyBytes;

                                  if (isHEXStripox(privateKey)) {
                                    privKeyBytes =
                                        HEX.decode(privateKey) as Uint8List;
                                  } else {
                                    final privatePubKey =
                                        base58.decode(privateKey);
                                    privKeyBytes = privatePubKey.sublist(0, 32);
                                    privateKey = HEX.encode(privKeyBytes);
                                  }

                                  const byteLength = 32;
                                  if (privKeyBytes.length != byteLength) {
                                    throw Exception(
                                      localization.invalidPrivateKey,
                                    );
                                  }
                                }
                                final privKeyList = WalletService.getActiveKeys(
                                  WalletType.privateKey,
                                );
                                final privatKey = PrivateKeyParams(
                                  data: privateKey,
                                  name: cryptoWallName,
                                  defaultCoin: coin.getDefault(),
                                  coinName: coin.getName(),
                                );

                                for (final privKey in privKeyList) {
                                  if (privKey == privatKey) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          localization.walletAlreadyImported,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                    return;
                                  }
                                }

                                await WalletService.setActiveKey(
                                  WalletType.privateKey,
                                  privatKey,
                                );

                                await coin.importData(privateKey);

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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      e.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );

                                setState(() {
                                  isLoading = false;
                                });
                                return;
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: isLoading
                                  ? const Loader(
                                      color: Colors.black,
                                    )
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
