import 'dart:typed_data';

extension BigIntExt on String {
  /// Converts a string amount with decimals to a BigInt scaled according to the provided decimals

  BigInt toBigIntDec(int decimals) {
    String amount = this;
    final base = BigInt.from(10);
    bool isNegative = amount.startsWith('-');
    if (isNegative) {
      amount = amount.substring(1); // Remove the negative sign for processing
    }

    // Split the amount into whole and fractional parts
    final amountParts = amount.split('.');
    final wholePart = BigInt.parse(amountParts[0]);
    final fractionalPart =
        amountParts.length > 1 ? BigInt.parse(amountParts[1]) : BigInt.zero;

    // Calculate the scaling factor for the fractional part
    final fractionalScalingFactor = base
        .pow(decimals - (amountParts.length > 1 ? amountParts[1].length : 0));
    BigInt result = (wholePart * base.pow(decimals)) +
        (fractionalPart * fractionalScalingFactor);

    return isNegative ? -result : result;
  }
}

extension BigIntExtension on BigInt {
  Uint8List toUint8List() {
    final byteMask = BigInt.from(0xff);
    var number = this;
    var size = (number.bitLength + 7) >> 3;
    var result = Uint8List(size);
    for (var i = 0; i < size; i++) {
      result[size - i - 1] = (number & byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }
}
