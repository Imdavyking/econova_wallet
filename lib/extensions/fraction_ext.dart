import 'dart:math';

import 'package:fraction/fraction.dart';

extension FractionExtensions on Fraction {
  int get quotient => numerator ~/ denominator;

  /// Returns the fraction as a double formatted with fixed decimal places.
  int toFixed(int digits) {
    final value = numerator / denominator;
    final factor = pow(10, digits);
    return (value * factor).round();
  }

  /// Returns a new Fraction which is this fraction divided by [other].
  Fraction divide(Fraction other) {
    // a/b ÷ c/d = (a/b) * (d/c) = (a*d)/(b*c)
    return Fraction(
        numerator * other.denominator, denominator * other.numerator);
  }

  /// Returns a new Fraction which is this fraction multiplied by [other].
  Fraction multiply(Fraction other) {
    // a/b * c/d = (a*c)/(b*d)
    return Fraction(
        numerator * other.numerator, denominator * other.denominator);
  }

  Fraction add(int value) {
    // sum = a/b + value/1 = (a + value * b) / b
    final newNumerator = numerator + value * denominator;
    return Fraction(newNumerator, denominator);
  }
}
