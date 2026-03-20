import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

String formatMoney(num? money, [bool isTwoDPlace = false]) {
  if (money == null) return '0';

  double actualMoney = money.toDouble();

  // Get current locale
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final languageCode = locale.languageCode;
  final countryCode = locale.countryCode ?? '';

  // Use German locale for Germany
  final localeString =
      (languageCode == 'de' && countryCode == 'DE') ? 'de_DE' : 'en_US';

  if (actualMoney >= 1e6) {
    return intl.NumberFormat.compact(locale: localeString).format(actualMoney);
  }

  if (actualMoney.abs() < 0.00000001) {
    return '0';
  }

  if (isTwoDPlace && actualMoney.abs() > 0.001) {
    return intl.NumberFormat.decimalPattern(localeString).format(actualMoney);
  }

  if (actualMoney.abs() < 1 && actualMoney.abs() > 0.000001) {
    return intl.NumberFormat('0.00000', localeString).format(actualMoney);
  }

  if (actualMoney.abs() < 1 && actualMoney.abs() != 0) {
    return money.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  return intl.NumberFormat.decimalPattern(localeString).format(actualMoney);
}
