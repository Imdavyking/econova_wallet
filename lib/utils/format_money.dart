import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wallet_app/utils/rpc_urls.dart';

/// Returns a formatted money string.
///
/// [rawValue] — pass the original string from the chain (e.g. "0.000000000000000016")
/// so that small decimals are formatted without IEEE-754 precision loss.
String formatMoney(num? money, [bool isTwoDPlace = false, String? rawValue]) {
  if (money == null) return '0';

  final double actualMoney = money.toDouble();

  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final localeString =
      (locale.languageCode == 'de' && (locale.countryCode ?? '') == 'DE')
          ? 'de_DE'
          : 'en_US';

  if (actualMoney >= 1e6) {
    return intl.NumberFormat.compact(locale: localeString).format(actualMoney);
  }

  if (actualMoney == 0) return '0';

  if (actualMoney.abs() < 1) {
    final priceStr = (rawValue != null && rawValue.isNotEmpty)
        ? rawValue.trim()
        : actualMoney.toStringAsFixed(20).replaceAll(RegExp(r'0+$'), '');

    final result = Erc8117.fromTokenPrice(priceStr);

    if (result.ascii != null) {
      final ascii = result.ascii!;
      final parenClose = ascii.indexOf(')');
      if (parenClose != -1 && parenClose < ascii.length - 1) {
        final significant = ascii.substring(parenClose + 1);
        final capped =
            significant.length > 4 ? significant.substring(0, 4) : significant;
        return '${ascii.substring(0, parenClose + 1)}$capped';
      }
      return ascii;
    }

    if (actualMoney.abs() > 1e-6) {
      return intl.NumberFormat('0.00000#', localeString).format(actualMoney);
    }

    if (rawValue != null && rawValue.isNotEmpty) return rawValue.trim();

    return actualMoney
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }

  if (isTwoDPlace) {
    return intl.NumberFormat.decimalPattern(localeString).format(actualMoney);
  }

  return intl.NumberFormat.decimalPattern(localeString).format(actualMoney);
}

/// Renders a formatted money value inline.
///
/// For ERC-8117 values like "0.0(5)1" the zero count is shown as a small
/// badge so it stays readable at any font size. All other values fall through
/// to a plain [Text].
Widget formatMoneyWidget(
  num? money, {
  bool isTwoDPlace = false,
  String? rawValue,
  TextStyle? style,
}) {
  final formatted = formatMoney(money, isTwoDPlace, rawValue);

  final match = RegExp(r'^(0\.0)\((\d+)\)(.*)$').firstMatch(formatted);

  if (match == null) {
    return Text(formatted, style: style);
  }

  final prefix = match.group(1)!;
  final count = match.group(2)!;
  final significant = match.group(3)!;
  final baseStyle = style ?? const TextStyle();
  final badgeFontSize = (baseStyle.fontSize ?? 14) * 0.68;

  return RichText(
    text: TextSpan(
      style: baseStyle,
      children: [
        TextSpan(text: prefix),
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: (baseStyle.color ?? Colors.black).withOpacity(0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                count,
                style: baseStyle.copyWith(fontSize: badgeFontSize),
              ),
            ),
          ),
        ),
        TextSpan(text: significant),
      ],
    ),
  );
}
