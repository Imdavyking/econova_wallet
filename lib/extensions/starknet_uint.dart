// Yes please, for the implementation I think we should have a generic one
import 'package:starknet/starknet.dart';

extension Uint256ListToCalldata on List<Uint256> {
  List<Felt> toCalldata() {
    return [
      Felt.fromInt(length),
      for (final uint in this) ...[uint.low, uint.high],
    ];
  }
}

extension ListUint256ToCalldata on List<List<Uint256>> {
  List<Felt> toCalldata() {
    if (isEmpty) {
      return [Felt.zero];
    }
    final convertedList = map((e) => e.toCalldata()).toList();
    return [
      Felt.fromInt(length),
      ...convertedList.expand((list) => list),
    ];
  }
}
