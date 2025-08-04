import 'package:flutter/material.dart';

class ChartPriceParam {
  final String? price;
  const ChartPriceParam({this.price});
}

class ChartPrice extends StatelessWidget {
  final ChartPriceParam chartPriceData;
  const ChartPrice({
    super.key,
    required this.chartPriceData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          chartPriceData.price ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
