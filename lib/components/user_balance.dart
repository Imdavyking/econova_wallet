import 'package:wallet_app/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_config.dart';
import '../utils/format_money.dart';
import 'hide_balance_widget.dart';

class UserBalance extends StatefulWidget {
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
  const UserBalance({
    Key? key,
    required this.symbol,
    required this.balance,
    this.haveValue = true,
    this.seperate = true,
    this.textStyle,
    this.iconSize,
    this.iconColor,
    this.iconSuffix,
    this.iconDivider,
    this.reversed = false,
    this.mustIcon,
  }) : super(key: key);

  @override
  State<UserBalance> createState() => _UserBalanceState();
}

class _UserBalanceState extends State<UserBalance> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: pref.listenable(keys: [hideBalanceKey]),
      builder: (context, box, _) {
        if (box.get(hideBalanceKey, defaultValue: false)) {
          return SizedBox(
            child: HideBalanceWidget(
              iconSize: widget.iconSize,
              iconColor: widget.iconColor,
              iconDivider: widget.iconDivider,
              iconSuffix: widget.mustIcon ?? widget.iconSuffix,
            ),
          );
        }

        String toDisplay = '${formatMoney(widget.balance)} ${widget.symbol}';
        if (!widget.haveValue) {
          toDisplay = '- ${widget.symbol}';
        }
        if (widget.reversed == true) {
          toDisplay = toDisplay
              .split(' ')
              .reversed
              .toList()
              .join(widget.seperate ? ' ' : '');
        }

        return SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                toDisplay,
                style: widget.textStyle ??
                    const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      overflow: TextOverflow.fade,
                    ),
              ),
              if (widget.mustIcon != null) ...[
                const SizedBox(width: 5),
                widget.mustIcon!
              ],
            ],
          ),
        );
      },
    );
  }
}
