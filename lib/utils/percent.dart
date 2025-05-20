import 'dart:math';

import 'package:fraction/fraction.dart';

class Percent {
  final BigInt numerator;
  final BigInt denominator;

  Percent(this.numerator, this.denominator);

  double toDouble() {
    if (denominator == BigInt.zero) {
      throw Exception('Division by zero');
    }
    return numerator.toDouble() / denominator.toDouble();
  }

  Fraction multiply(Fraction other) {
    final percentFraction = Fraction.fromDouble(toDouble());
    return percentFraction * other;
  }

  @override
  String toString() {
    final value = toDouble() * 100;
    return '${value.toStringAsFixed(2)}%';
  }
}

const int percentageInputPrecision = 4; // or whatever value you're using

Percent convertPercentageStringToPercent(String percentString) {
  final precisionMultiplier = BigInt.from(pow(10, percentageInputPrecision));
  final input = double.tryParse(percentString) ?? 0;
  final numerator = BigInt.from(input * precisionMultiplier.toDouble());
  final denominator = BigInt.from(100) * precisionMultiplier;

  return Percent(numerator, denominator);
}
