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
    try {
      return AssetImage(image);
    } catch (_) {}

    // 2️⃣ Try FileImage
    try {
      print('file image $image');
      return FileImage(File(image));
    } catch (_) {}

    // 3️⃣ Try NetworkImage
    try {
      return NetworkImage(image);
    } catch (_) {}

    // 4️⃣ Fallback to default asset
    return const AssetImage('assets/default_token.png');
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
