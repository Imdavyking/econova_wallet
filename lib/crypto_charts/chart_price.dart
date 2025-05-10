import 'package:flutter/material.dart';

class ChartPriceParam {
  final String? price;
  const ChartPriceParam({this.price});
}

class ChartPrice extends StatelessWidget {
  final ChartPriceParam chartPriceData;
  const ChartPrice({
    Key? key,
    required this.chartPriceData,
  }) : super(key: key);

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
