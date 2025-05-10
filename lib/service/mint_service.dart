import 'dart:math';

import 'package:cryptowallet/main.dart';
import 'package:flutter/foundation.dart';

import '../coins/fungible_tokens/near_fungible_coin.dart';

class MintService {
  static const mintAmtKey =
      'YefnmA76N0mNCsZGGDL1GngwIEIznmDvBOIHxo+RI6R$kDebugMode';
  static final successMint = pow(10, 9);
  static final failureMint = pow(10, 4);

  static BigInt getMint() {
    if (noMint()) return BigInt.zero;

    return pref.get(mintAmtKey);
  }

  static NearFungibleCoin getMintCoin() {
    final walletNear = walletNearCoin();
    return walletNear[0];
  }

  static double getAmountSuccess({required bool success}) {
    final amount = success ? successMint : failureMint;

    return BigInt.from(amount) / BigInt.from(10).pow(getMintCoin().decimals());
  }

  static Future<void> saveMint({required bool success}) async {
    final currentMint = getMint();
    final amount = success ? successMint : failureMint;
    final tokenMint = BigInt.from(amount) + currentMint;
    await pref.put(mintAmtKey, tokenMint);
  }

  static noMint() {
    return pref.get(mintAmtKey) == null;
  }

  static Future<void> deleteMint() async {
    await pref.delete(mintAmtKey);
  }
}
