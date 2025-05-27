import 'package:wallet_app/components/loader.dart';
import 'package:flutter/material.dart';

class EmptyLoadingScreen extends StatelessWidget {
  const EmptyLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Loader(),
      ),
    );
  }
}
