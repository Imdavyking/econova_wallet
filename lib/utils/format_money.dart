import 'package:intl/intl.dart' as intl;

String formatMoney(num? money, [bool isTwoDPlace = false]) {
  if (money == null) return '0';

  double actualMoney = money.toDouble();

  if (actualMoney >= 1e6) {
    return intl.NumberFormat.compact().format(actualMoney);
  }

  if (actualMoney.abs() < 0.00000001) {
    return '0';
  }

  if (isTwoDPlace && actualMoney.abs() > 0.001) {
    return intl.NumberFormat.decimalPattern('en_US').format(actualMoney);
  }

  if (actualMoney.abs() < 1 && actualMoney.abs() > 0.000001) {
    return intl.NumberFormat('0.00000').format(actualMoney);
  }

  if (actualMoney.abs() < 1 && actualMoney.abs() != 0) {
    return money.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  return intl.NumberFormat.decimalPattern().format(actualMoney);
}
