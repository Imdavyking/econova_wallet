import 'package:flutter/material.dart';
import 'package:wallet_app/interface/coin.dart';
import 'wallet_coin_list_item.dart';

class WalletCoinList extends StatelessWidget {
  final List<Coin> coins;
  const WalletCoinList({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, coin) in coins.indexed) ...[
            WalletCoinListItem(
              key: ValueKey(
                '${i}_${coin.getName()}${DateTime.now().millisecond}',
              ),
              coin: coin,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
