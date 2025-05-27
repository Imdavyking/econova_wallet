import 'package:flutter/material.dart';

import '../interface/coin.dart';

class GetTokenImage extends StatelessWidget {
  final Coin currCoin;
  final double? radius;
  const GetTokenImage({
    super.key,
    required this.currCoin,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(currCoin.getImage()),
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
