import 'package:flutter/material.dart';

import '../interface/coin.dart';

class GetTokenImage extends StatelessWidget {
  final Coin currCoin;
  final double? radius;
  const GetTokenImage({
    Key? key,
    required this.currCoin,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(currCoin.getImage()),
      backgroundColor: Theme.of(context).colorScheme.background,
      child: currCoin.badgeImage == null
          ? null
          : Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                backgroundImage: AssetImage(currCoin.badgeImage!),
                backgroundColor: Theme.of(context).colorScheme.background,
                radius: 10,
              ),
            ),
    );
  }
}
