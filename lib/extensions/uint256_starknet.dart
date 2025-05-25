import 'package:starknet/starknet.dart';

extension ToCalldata on Uint256 {
  List<Felt> toCalldata() => [low, high];
}

extension ListToCalldata on List<Uint256> {
  List<Felt> toCalldata() {
    return [
      Felt.fromInt(length),
      ...expand((u) => u.toCalldata()),
    ];
  }
}

extension ListListToCalldata on List<List<Uint256>> {
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
