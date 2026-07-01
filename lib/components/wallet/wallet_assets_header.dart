import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wallet_app/screens/add_custom_token.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/zkproof.dart';

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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (WalletService.isBip39PhraseOrSeedHexKey())
            GestureDetector(
              onTap: () async {
                final note = await ZkProofBridge.instance.generateNote();

                final info = await ZkProofBridge.instance.generateProof({
                  "nullifier":
                      "0x866d86ccdbbbae15951539aa950076ac135982e49e139e6a8ad45488b7143f",
                  "secret":
                      "0xce2accb4d9c2befb72d19dc9c9497b494cb4cd7c186b8836ffcbc2e3c058ef",
                  "commitment":
                      "6968901238639841340449384697361615858797901214170004573979049867882899542618",
                  "recipient":
                      "GAPO2J457ED6JL2SP7DEUNJ7HRC47RA7ML6OJ4OPQ46HVW2BBZKCLNWC",
                  "commitments": [
                    "6968901238639841340449384697361615858797901214170004573979049867882899542618",
                  ],
                });
                debugPrint("done right now");

                // Navigator.push(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.rightToLeft,
                //     child: const AddCustomToken(),
                //   ),
                // );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appBackgroundblue.withOpacity(0.6),
                    width: 1.5,
                  ),
                  color: appBackgroundblue.withOpacity(0.08),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: appBackgroundblue,
                      ),
                      child:
                          const Icon(Icons.add, size: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localization.addToken,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: appBackgroundblue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
