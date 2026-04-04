import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowPrivateKey extends StatelessWidget {
  final String data;
  const ShowPrivateKey({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.showPrivateKey)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _QrCard(data: data),
              const SizedBox(height: 20),
              _WarningBanner(message: loc.neverShareYourPrivateKey),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String data;
  const _QrCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: data));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.copiedToClipboard)),
        );
      },
      child: Card(
        color: const Color(0xffF1F1F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: QrImageView(data: data, version: QrVersions.auto, size: 250),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
