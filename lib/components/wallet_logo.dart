import 'package:flutter/material.dart';

class WalletLogo extends StatelessWidget {
  const WalletLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: 100,
    );
  }
}
