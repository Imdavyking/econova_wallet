// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:wallet_app/components/user_details_placeholder.dart';
import 'package:wallet_app/education/eip4337.edu.dart';
import 'package:wallet_app/screens/contact.dart';
import 'package:wallet_app/screens/language.dart';
import 'package:wallet_app/screens/saved_urls.dart';
import 'package:wallet_app/screens/security.dart';
import 'package:wallet_app/screens/main_screen.dart';
import 'package:wallet_app/screens/recovery_pharse.dart';
import 'package:wallet_app/screens/set_currency.dart';
import 'package:wallet_app/screens/show_private_key.dart';
import 'package:wallet_app/screens/support.dart';
import 'package:wallet_app/screens/unlock_with_biometrics.dart';
import 'package:wallet_app/screens/all_wallets.dart';
import 'package:wallet_app/screens/wallet_connect.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../utils/app_config.dart';
import 'change_identicon.dart';
import '../service/wallet_service.dart';
import 'google_fa/google_fa_status.dart';
import 'launch_url.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  final darkModeKey = 'useDark';
  late AppLocalizations localization;
  bool _isValidUrl(String url) {
    url = url.trim();
    return url.isNotEmpty && Uri.tryParse(url) != null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.settings),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localization.account,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: UserDetailsPlaceHolder(
                      size: .5,
                      textSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localization.wallet,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const SetCurrency(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image(
                                        image: AssetImage(
                                            'assets/currency_new.png'),
                                        width: 25),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.currency,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ChangeIdenticon(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color:
                                            Color.fromARGB(255, 142, 141, 148),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.icons,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.accountIdenticon,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: Color.fromARGB(255, 176, 116, 13),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.key,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    localization.google2FA,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              GoogleFAStatus(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) {
                                return const Language();
                              }),
                            );
                          },
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: Color.fromARGB(255, 255, 95, 82),
                                      ),
                                      child: Icon(
                                        Icons.language,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.language,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) {
                                return const EIP4337Education();
                              }),
                            );
                          },
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: Color.fromARGB(255, 255, 95, 82),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.book,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.education,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) {
                                return Contact();
                              }),
                            );
                          },
                          child: SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color:
                                            Color.fromARGB(255, 50, 117, 186),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.user,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.contact,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (!WalletService.isViewKey()) ...[
                          InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (ctx) {
                                  return const WalletConnect();
                                }),
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 35,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image(
                                          image: AssetImage(
                                              'assets/wallet_connect_new.png'),
                                          width: 25),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Wallet Connect',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => AllWallets(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: Color.fromARGB(255, 50, 185, 55),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.wallet,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.allWallets,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const MainScreen(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color:
                                            Color.fromARGB(255, 233, 68, 123),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.fileImport,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.importWallet,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const Support(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color:
                                            Color.fromARGB(168, 255, 123, 233),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.headset,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.support,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localization.security,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color:
                                            Color.fromARGB(255, 238, 20, 139),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.fingerprint,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      localization.useBiometrics,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                UnlockWithBiometrics(),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (WalletService.isPrivateKey()) ...[
                            InkWell(
                              onTap: () async {
                                final data = WalletService.getActiveKey(
                                  walletImportType,
                                )!
                                    .data;

                                if (await authenticate(context)) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => ShowPrivateKey(
                                        data: data,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        localization.authFailed,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: SizedBox(
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            color: Color.fromARGB(
                                                255, 142, 141, 148),
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.key,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          localization.showPrivateKey,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                          if (WalletService.isPharseKey()) ...[
                            InkWell(
                              onTap: () async {
                                final data = WalletService.getActiveKey(
                                  walletImportType,
                                )!
                                    .data;

                                if (await authenticate(context)) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => RecoveryPhrase(
                                        data: data,
                                        viewOnly: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        localization.authFailed,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: SizedBox(
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            color: Color.fromARGB(
                                                255, 142, 141, 148),
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.key,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          localization.showmnemonic,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                          InkWell(
                            onTap: () async {
                              if (await authenticate(
                                context,
                                useLocalAuth: false,
                              )) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => const Security(
                                      isChangingPin: true,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      localization.authFailed,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 35,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          color:
                                              Color.fromARGB(255, 255, 61, 46),
                                        ),
                                        child: Icon(
                                          FontAwesomeIcons.shieldHalved,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localization.changePin,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localization.web,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              List data = [];
                              if (pref.get(bookMarkKey) != null) {
                                data =
                                    jsonDecode(pref.get(bookMarkKey)) as List;
                              }

                              final bookmarkTitle = localization.bookMark;
                              final bookmarkEmpty = localization.noBookMark;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => SavedUrls(
                                    bookmarkTitle,
                                    bookmarkEmpty,
                                    bookMarkKey,
                                    data: data,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 35,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          color:
                                              Color.fromARGB(255, 28, 119, 255),
                                        ),
                                        child: Icon(
                                          FontAwesomeIcons.bookmark,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localization.bookMark,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localization.joinOurCommunities,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            if (_isValidUrl(telegramLink)) ...[
                              GestureDetector(
                                onTap: () async {
                                  await launchPageUrl(
                                    context: context,
                                    url: telegramLink,
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.telegram,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                            if (_isValidUrl(twitterLink)) ...[
                              GestureDetector(
                                onTap: () async {
                                  await launchPageUrl(
                                    context: context,
                                    url: twitterLink,
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.twitter,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              )
                            ],
                            if (_isValidUrl(mediumLink)) ...[
                              GestureDetector(
                                onTap: () async {
                                  await launchPageUrl(
                                    context: context,
                                    url: mediumLink,
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.medium,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                            if (_isValidUrl(discordLink)) ...[
                              GestureDetector(
                                onTap: () async {
                                  await launchPageUrl(
                                    context: context,
                                    url: discordLink,
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.discord,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                            if (_isValidUrl(instagramLink)) ...[
                              GestureDetector(
                                onTap: () async {
                                  await launchPageUrl(
                                    context: context,
                                    url: instagramLink,
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.instagram,
                                ),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder<Map<String, dynamic>>(future: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();

                  return {
                    'appName': packageInfo.appName,
                    'version': packageInfo.version,
                    'buildNumber': packageInfo.buildNumber
                  };
                }(), builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> data = snapshot.data!;
                    return Align(
                      alignment: Alignment.center,
                      child: Text.rich(
                        TextSpan(
                            text: data['appName'],
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            children: [
                              TextSpan(
                                text:
                                    ' v${data['version']} (${data['buildNumber']})',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              )
                            ]),
                      ),
                    );
                  }
                  return Text('');
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
