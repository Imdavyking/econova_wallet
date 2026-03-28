import 'package:flutter/material.dart';
import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/components/user_details_placeholder.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TestnetBanner(),
        Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserDetailsPlaceHolder(size: .5),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
