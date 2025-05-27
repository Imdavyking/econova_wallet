import 'package:wallet_app/utils/blockie_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jazzicon/jazzicon.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

class Identicon extends StatefulWidget {
  final String address;
  const Identicon({super.key, required this.address});

  @override
  State<Identicon> createState() => _IdenticonState();
}

class _IdenticonState extends State<Identicon> {
  late Widget jazzicon, blockie;
  @override
  void initState() {
    super.initState();
    jazzicon = Jazzicon.getIconWidget(
      Jazzicon.getJazziconData(40, address: widget.address),
    );
    blockie = Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(75)),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: BlockieWidget(
          size: .6,
          data: widget.address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: pref.listenable(keys: [useBlockiesKey]),
      builder: (context, box, _) {
        if (walletImportType != WalletType.secretPhrase) blockie;
        return box.get(useBlockiesKey, defaultValue: true) ? blockie : jazzicon;
      },
    );
  }
}
