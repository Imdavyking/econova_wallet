import 'dart:async';

import 'package:wallet_app/boring_avatar/painter.dart';
import 'package:wallet_app/boring_avatar/widget.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/screens/nano_identicon_generator.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import '../main.dart';
import '../utils/app_config.dart';

// ── Data class — replaces the loose Map ──────────────────────────────────────

class _WalletInfo {
  final String name;

  const _WalletInfo({required this.name});
}

// ── Widget ────────────────────────────────────────────────────────────────────

class UserDetailsPlaceHolder extends StatefulWidget {
  final double? textSize;

  const UserDetailsPlaceHolder({super.key, this.textSize});

  @override
  State<UserDetailsPlaceHolder> createState() => _UserDetailsPlaceHolderState();
}

class _UserDetailsPlaceHolderState extends State<UserDetailsPlaceHolder> {
  _WalletInfo? _info;

  // Removed `size` param — it was declared but never used anywhere in the widget

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(UserDetailsPlaceHolder old) {
    super.didUpdateWidget(old);
    // Only reload if the active key actually changed, not on every rebuild
    if (old.textSize != widget.textSize) _load();
  }

  Future<void> _load() async {
    try {
      // We only need the wallet name here now — no ETH address derivation needed
      // since the identicon was removed. If the address is needed later for
      // something else, pass in the active Coin and call coin.getAddress().
      final name = pref.get(currentUserWalletNameKey) as String?;
      if (mounted) {
        setState(() => _info = _WalletInfo(name: name ?? ''));
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    if (info == null) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Loader(color: appBackgroundblue),
      );
    }

    final name =
        info.name.isEmpty ? AppLocalizations.of(context)!.user : info.name;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NatriconWidget(
          address:
              'nano_33irdhma4h59muwm9zeqhqg6km9j684agbhzyr3o5ggzqgmknk4z1kqm6j7q',
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: ClipOval(
            child: BoringAvatar(
              name: name,
              type: BoringAvatarType.beam,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ellipsify(str: name, maxLength: 34),
          style: TextStyle(fontSize: widget.textSize),
        ),
      ],
    );
  }
}
