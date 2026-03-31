import 'package:wallet_app/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_config.dart';
import '../utils/format_money.dart';
import 'hide_balance_widget.dart';

class UserBalance extends StatelessWidget {
  final double balance;
  final double? iconSize;
  final String symbol;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Widget? iconDivider;
  final bool reversed;
  final Widget? iconSuffix;
  final bool haveValue;
  final Widget? mustIcon;
  final bool seperate;
  final String? rawBalance; // raw chain string for precision-safe formatting

  const UserBalance({
    super.key,
    required this.symbol,
    required this.balance,
    this.rawBalance,
    this.haveValue = true,
    this.seperate = true,
    this.textStyle,
    this.iconSize,
    this.iconColor,
    this.iconSuffix,
    this.iconDivider,
    this.reversed = false,
    this.mustIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: pref.listenable(keys: [hideBalanceKey]),
      builder: (context, box, _) {
        if (box.get(hideBalanceKey, defaultValue: false)) {
          return HideBalanceWidget(
            iconSize: iconSize,
            iconColor: iconColor,
            iconDivider: iconDivider,
            iconSuffix: mustIcon ?? iconSuffix,
          );
        }

        if (!haveValue) {
          return _BalanceRow(
            balanceWidget: Text('- $symbol', style: textStyle ?? _defaultStyle),
            mustIcon: mustIcon,
          );
        }

        final style = textStyle ?? _defaultStyle;

        // Build the amount widget — uses formatMoneyWidget so ERC-8117
        // compressed values (0.0(5)1) render with a readable badge instead
        // of tiny Unicode subscripts.
        final amountWidget = formatMoneyWidget(
          balance,
          rawValue: rawBalance,
          style: style,
        );

        final symbolWidget = Text(
          symbol,
          style: style,
          overflow: TextOverflow.fade,
        );

        final children = reversed
            ? [
                symbolWidget,
                if (seperate) const SizedBox(width: 4),
                amountWidget
              ]
            : [
                amountWidget,
                if (seperate) const SizedBox(width: 4),
                symbolWidget
              ];

        return _BalanceRow(
          balanceWidget: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
          mustIcon: mustIcon,
        );
      },
    );
  }

  static const _defaultStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    overflow: TextOverflow.fade,
  );
}

class _BalanceRow extends StatelessWidget {
  final Widget balanceWidget;
  final Widget? mustIcon;

  const _BalanceRow({required this.balanceWidget, this.mustIcon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        balanceWidget,
        if (mustIcon != null) ...[const SizedBox(width: 5), mustIcon!],
      ],
    );
  }
}
