import 'dart:math';

class Percent {
  final BigInt numerator;
  final BigInt denominator;

  Percent(this.numerator, this.denominator);

  @override
  String toString() =>
      '${numerator.toDouble() / denominator.toDouble() * 100}%';
}

const int percentageInputPrecision = 4; // or whatever value you're using

Percent convertPercentageStringToPercent(String percentString) {
  final precisionMultiplier = BigInt.from(pow(10, percentageInputPrecision));
  final input = double.tryParse(percentString) ?? 0;
  final numerator = BigInt.from(input * precisionMultiplier.toDouble());
  final denominator = BigInt.from(100) * precisionMultiplier;

  return Percent(numerator, denominator);
}
