import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wallet_app/screens/add_custom_token.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class WalletAssetsHeader extends StatelessWidget {
  const WalletAssetsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localization.assets,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (WalletService.isPharseKey())
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const AddCustomToken(),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          localization.addToken,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.add, size: 20),
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
}