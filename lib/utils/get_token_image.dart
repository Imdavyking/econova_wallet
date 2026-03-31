import 'package:flutter/material.dart';
import 'dart:io';
import '../interface/coin.dart';

class GetTokenImage extends StatelessWidget {
  final Coin currCoin;
  final double? radius;
  const GetTokenImage({
    super.key,
    required this.currCoin,
    this.radius,
  });

  ImageProvider _resolveImage() {
    final image = currCoin.getImage();

    // 1️⃣ Absolute path → FileImage
    if (image.startsWith('/')) {
      final file = File(image);
      if (file.existsSync()) return FileImage(file);
      return const AssetImage(
        'assets/ai_icon.jpg',
      ); // file missing — fallback immediately
    }

    // 2️⃣ Any URL (http, https, or protocol-relative)
    if (Uri.tryParse(image)?.host.isNotEmpty == true) {
      return NetworkImage(
        image.startsWith('//') ? 'https:$image' : image,
      );
    }

    // 3️⃣ Asset path
    return AssetImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _resolveImage(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: currCoin.badgeImage == null
          ? null
          : Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                backgroundImage: AssetImage(currCoin.badgeImage!),
                backgroundColor: Theme.of(context).colorScheme.surface,
                radius: 10,
              ),
            ),
    );
  }
}
