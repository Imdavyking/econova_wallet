// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:bip39/bip39.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/components/user_details_placeholder.dart';
import 'package:wallet_app/education/eip4337.edu.dart';
import 'package:wallet_app/screens/contact.dart';
import 'package:wallet_app/screens/dead_man_switch_screen.dart';
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
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
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
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  late AppLocalizations localization;

  // ── Cached futures — computed once per lifecycle ──────────────────────────
  late final Future<bool> _deadSwitchFuture;
  late final Future<bool> _dmsUserFuture;
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _deadSwitchFuture = _checkDeadSwitch();
    _dmsUserFuture = _checkDmsUser();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<bool> _checkDeadSwitch() async {
    final mnemonic = WalletService.getActiveKey(walletImportType)!.data;
    return compute(validateMnemonic, mnemonic);
  }

  Future<bool> _checkDmsUser() async {
    final ethCoin = getChains<EthereumCoin>().first;
    final mnemonic = WalletService.getActiveKey(walletImportType)!.data;
    final response = await ethCoin.importData(mnemonic);
    final config = DeadManSwitchService.config;
    return config?.senderAddress == response.address;
  }

  bool _isValidUrl(String url) {
    url = url.trim();
    return url.isNotEmpty && Uri.tryParse(url) != null;
  }

  // ── Testnet toggle ────────────────────────────────────────────────────────
  void _onTestNetToggle(bool value) {
    enableTestNet = value;
    debugPrint('enableTestNet changed → $enableTestNet');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            enableTestNet ? 'Switched to Testnet' : 'Switched to Mainnet',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.settings),
      ),
      body: Column(
        children: [
          const TestnetBanner(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      // ── Account ───────────────────────────────────────────
                      _SectionHeader(label: localization.account),
                      const SizedBox(height: 10),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: UserDetailsPlaceHolder(size: .5, textSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Wallet ────────────────────────────────────────────
                      _SectionHeader(label: localization.wallet),
                      const SizedBox(height: 10),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SettingsRow(
                                icon: Image(
                                  image: AssetImage('assets/currency_new.png'),
                                  width: 25,
                                ),
                                label: localization.currency,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SetCurrency()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 142, 141, 148),
                                  icon: FontAwesomeIcons.icons,
                                ),
                                label: localization.accountIdenticon,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ChangeIdenticon()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 176, 116, 13),
                                  icon: FontAwesomeIcons.key,
                                ),
                                label: localization.google2FA,
                                trailing: GoogleFAStatus(),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 255, 95, 82),
                                  icon: Icons.language,
                                  iconSize: 22,
                                ),
                                label: localization.language,
                                onTap: () async => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Language()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 255, 95, 82),
                                  icon: FontAwesomeIcons.book,
                                  iconSize: 22,
                                ),
                                label: localization.education,
                                onTap: () async => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const EIP4337Education()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 50, 117, 186),
                                  icon: FontAwesomeIcons.user,
                                ),
                                label: localization.contact,
                                onTap: () async => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Contact()),
                                ),
                              ),
                              if (!WalletService.isViewKey())
                                _SettingsRow(
                                  icon: Image(
                                    image: AssetImage(
                                        'assets/wallet_connect_new.png'),
                                    width: 25,
                                  ),
                                  label: 'Wallet Connect',
                                  // FIX: removed the broken WcConnectorV2.signClient
                                  // check — WalletConnect screen handles V2 being
                                  // unavailable gracefully on its own.
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const WalletConnect()),
                                  ),
                                ),
                              if (WalletService.isBip39PhraseOrSeedHexKey())
                                FutureBuilder<bool>(
                                  future: _deadSwitchFuture,
                                  builder: (context, data) {
                                    if (!data.hasData || data.data == false) {
                                      return const SizedBox.shrink();
                                    }
                                    return _SettingsRow(
                                      icon: _CircleIcon(
                                        color: Color.fromARGB(255, 180, 30, 30),
                                        icon: FontAwesomeIcons.heartPulse,
                                        iconSize: 14,
                                      ),
                                      label: 'Dead Man\'s Switch',
                                      trailing: _DmsStatusBadge(
                                        future: _dmsUserFuture,
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DeadManSwitchScreen(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 50, 185, 55),
                                  icon: FontAwesomeIcons.wallet,
                                ),
                                label: localization.allWallets,
                                onTap: () async => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AllWallets()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 233, 68, 123),
                                  icon: FontAwesomeIcons.fileImport,
                                ),
                                label: localization.importWallet,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MainScreen()),
                                ),
                              ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(168, 255, 123, 233),
                                  icon: FontAwesomeIcons.headset,
                                ),
                                label: localization.support,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Support()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Security ──────────────────────────────────────────
                      _SectionHeader(label: localization.security),
                      const SizedBox(height: 10),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 238, 20, 139),
                                  icon: FontAwesomeIcons.fingerprint,
                                ),
                                label: localization.useBiometrics,
                                trailing: UnlockWithBiometrics(),
                              ),
                              if (WalletService.isPrivateKey())
                                _SettingsRow(
                                  icon: _CircleIcon(
                                    color: Color.fromARGB(255, 142, 141, 148),
                                    icon: FontAwesomeIcons.key,
                                  ),
                                  label: localization.showPrivateKey,
                                  onTap: () async {
                                    final data = WalletService.getActiveKey(
                                      walletImportType,
                                    )!
                                        .data;
                                    if (await authenticate(context)) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ShowPrivateKey(data: data),
                                        ),
                                      );
                                    } else {
                                      if (!context.mounted) return;
                                      _showAuthFailed();
                                    }
                                  },
                                ),
                              if (WalletService.isBip39PhraseOrSeedHexKey())
                                _SettingsRow(
                                  icon: _CircleIcon(
                                    color: Color.fromARGB(255, 142, 141, 148),
                                    icon: FontAwesomeIcons.key,
                                  ),
                                  label: localization.showmnemonic,
                                  onTap: () async {
                                    final data = WalletService.getActiveKey(
                                      walletImportType,
                                    )!
                                        .data;
                                    if (await authenticate(context)) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecoveryPhrase(
                                            data: data,
                                            viewOnly: true,
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (!context.mounted) return;
                                      _showAuthFailed();
                                    }
                                  },
                                ),
                              _SettingsRow(
                                icon: _CircleIcon(
                                  color: Color.fromARGB(255, 255, 61, 46),
                                  icon: FontAwesomeIcons.lock,
                                ),
                                label: localization.changePin,
                                onTap: () async {
                                  if (await authenticate(context,
                                      useLocalAuth: false)) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const Security(isChangingPin: true),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    _showAuthFailed();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Network ───────────────────────────────────────────
                      _SectionHeader(label: 'Network'),
                      const SizedBox(height: 10),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: testNetNotifier,
                            builder: (_, isTestNet, __) {
                              debugPrint('enableTestNet = $enableTestNet');
                              return _SettingsRow(
                                icon: _CircleIcon(
                                  color: isTestNet
                                      ? Color.fromARGB(255, 255, 149, 0)
                                      : Color.fromARGB(255, 50, 185, 55),
                                  icon: FontAwesomeIcons.networkWired,
                                ),
                                label: isTestNet ? 'Testnet' : 'Mainnet',
                                trailing: Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: isTestNet,
                                    activeColor: appBackgroundblue,
                                    onChanged: _onTestNetToggle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Web ───────────────────────────────────────────────
                      _SectionHeader(label: localization.web),
                      const SizedBox(height: 10),
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: _SettingsRow(
                            icon: _CircleIcon(
                              color: Color.fromARGB(255, 28, 119, 255),
                              icon: FontAwesomeIcons.bookmark,
                            ),
                            label: localization.bookMark,
                            onTap: () async {
                              List data = [];
                              if (pref.get(bookMarkKey) != null) {
                                data =
                                    jsonDecode(pref.get(bookMarkKey)) as List;
                              }
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SavedUrls(
                                    localization.bookMark,
                                    localization.noBookMark,
                                    bookMarkKey,
                                    data: data,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Community ─────────────────────────────────────────
                      Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.joinOurCommunities,
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (_isValidUrl(telegramLink)) ...[
                                    _SocialIcon(
                                      icon: FontAwesomeIcons.telegram,
                                      url: telegramLink,
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (_isValidUrl(twitterLink)) ...[
                                    _SocialIcon(
                                      icon: FontAwesomeIcons.twitter,
                                      url: twitterLink,
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (_isValidUrl(mediumLink)) ...[
                                    _SocialIcon(
                                      icon: FontAwesomeIcons.medium,
                                      url: mediumLink,
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (_isValidUrl(discordLink)) ...[
                                    _SocialIcon(
                                      icon: FontAwesomeIcons.discord,
                                      url: discordLink,
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (_isValidUrl(instagramLink))
                                    _SocialIcon(
                                      icon: FontAwesomeIcons.instagram,
                                      url: instagramLink,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── App version ───────────────────────────────────────
                      FutureBuilder<PackageInfo>(
                        future: _packageInfoFuture,
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final info = snapshot.data!;
                          return Text(
                            '${info.appName} v${info.version} (${info.buildNumber})',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthFailed() {
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

  @override
  bool get wantKeepAlive => true;
}

// ── Components ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(fontSize: 18)),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double iconSize;

  const _CircleIcon({
    required this.color,
    required this.icon,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchPageUrl(context: context, url: url),
      child: Icon(icon),
    );
  }
}

class _DmsStatusBadge extends StatelessWidget {
  final Future<bool> future;
  const _DmsStatusBadge({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, data) {
        var (color, label) = (Colors.grey, 'Off');
        if (!data.hasError && data.hasData && data.data == true) {
          (color, label) = switch (DeadManSwitchService.state) {
            DmsState.active => (Colors.green, 'Armed'),
            DmsState.triggered => (Colors.red, 'Triggered'),
            DmsState.cancelled => (Colors.orange, 'Off'),
            DmsState.inactive => (Colors.grey, 'Off'),
          };
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(label, style: TextStyle(fontSize: 11, color: color)),
        );
      },
    );
  }
}
