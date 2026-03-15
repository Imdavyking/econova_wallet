import 'package:flutter/material.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:wallet_app/screens/token.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class WalletSearchBar extends StatelessWidget {
  const WalletSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () async {
          final Coin? coin = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => SelectBlockchain(filterFn: (coin) => true),
            ),
          );
          if (coin == null) return;
          if (context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => Token(coin: coin)),
            );
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      localization.searchCoin,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}