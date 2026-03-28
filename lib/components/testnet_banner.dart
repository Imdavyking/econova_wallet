import 'package:flutter/material.dart';
import 'package:wallet_app/utils/app_config.dart';

class TestnetBanner extends StatelessWidget {
  const TestnetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: testNetNotifier,
      builder: (_, isTestNet, __) {
        if (!isTestNet) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: Colors.orange.withOpacity(0.25),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'TESTNET MODE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
