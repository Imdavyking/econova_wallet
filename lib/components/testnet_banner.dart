import 'package:flutter/material.dart';
import 'package:wallet_app/utils/app_config.dart';

class TestnetBanner extends StatelessWidget {
  const TestnetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!enableTestNet) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.orange.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 14, color: Colors.orange),
          SizedBox(width: 6),
          Text('Testnet', style: TextStyle(fontSize: 12, color: Colors.orange)),
        ],
      ),
    );
  }
}
