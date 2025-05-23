import 'package:starknet/starknet.dart';

// Interface for objects that can be serialized to calldata
abstract class ToCalldata {
  List<Felt> toCalldata();
}

// Extension for lists of objects that implement ToCalldata
extension ListToCalldata<T extends ToCalldata> on List<T> {
  List<Felt> toCalldata() {
    if (isEmpty) {
      return [Felt.zero];
    }
    return [
      Felt.fromInt(length), // Length prefix
      ...expand((item) => item.toCalldata()), // Flatten serialized items
    ];
  }
}

// Extension for Felt to support ToCalldata
extension FeltToCalldata on Felt {
  List<Felt> toCalldata() => [this];
}

// Extension for Uint256 to support ToCalldata
extension Uint256ToCalldata on Uint256 {
  List<Felt> toCalldata() => [low, high];
}

// Extension for List<Felt> to support ToCalldata
extension FeltListToCalldata on List<Felt> {
  List<Felt> toCalldata() => [
        Felt.fromInt(length),
        ...this,
      ];
}

// Extension for nested lists of ToCalldata types
extension NestedListToCalldata<T extends ToCalldata> on List<List<T>> {
  List<Felt> toCalldata() {
    if (isEmpty) {
      return [Felt.zero];
    }
    return [
      Felt.fromInt(length), // Length prefix for outer list
      ...map((innerList) => innerList.toCalldata())
          .expand((list) => list), // Flatten inner lists
    ];
  }
}
