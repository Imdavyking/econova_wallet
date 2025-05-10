import 'package:cryptowallet/utils/get_token_image.dart';
import 'package:flutter/material.dart';

import '../interface/coin.dart';

Widget buildRow(
  Coin coin, {
  bool isSelected = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                GetTokenImage(
                  currCoin: coin,
                ),
                const SizedBox(width: 12),
                Text(coin.getSymbol()),
              ],
            ),
            if (isSelected)
              Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.blue),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  );
}
