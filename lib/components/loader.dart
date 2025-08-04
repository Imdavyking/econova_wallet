import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double? size;
  const Loader({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 25,
      height: size ?? 25,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2,
      ),
    );
  }
}
