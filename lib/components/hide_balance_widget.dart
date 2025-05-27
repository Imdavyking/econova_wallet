import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HideBalanceWidget extends StatelessWidget {
  final double? iconSize;
  final Color? iconColor;
  final Widget? iconDivider;
  final Widget? iconSuffix;
  const HideBalanceWidget({
    super.key,
    this.iconSize,
    this.iconColor,
    this.iconDivider,
    this.iconSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FontAwesomeIcons.asterisk,
          size: iconSize ?? 10,
          color: iconColor ?? Colors.grey,
        ),
        iconDivider ?? Container(),
        Icon(
          FontAwesomeIcons.asterisk,
          size: iconSize ?? 10,
          color: iconColor ?? Colors.grey,
        ),
        iconDivider ?? Container(),
        Icon(
          FontAwesomeIcons.asterisk,
          size: iconSize ?? 10,
          color: iconColor ?? Colors.grey,
        ),
        iconDivider ?? Container(),
        Icon(
          FontAwesomeIcons.asterisk,
          size: iconSize ?? 10,
          color: iconColor ?? Colors.grey,
        ),
        iconDivider ?? Container(),
        iconSuffix ?? Container(),
      ],
    );
  }
}
