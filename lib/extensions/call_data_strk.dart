import 'package:starknet/starknet.dart';

extension on List<Felt> {
  List<Felt> toCalldata() {
    return [
      Felt.fromInt(length),
      ...this,
    ];
  }
}

extension on List<List<Felt>> {
  List<Felt> toCalldata() {
    if (isEmpty) {
      return [Felt.zero];
    }

    final a = map((e) => e.toCalldata()).toList();
    return [
      Felt.fromInt(length),
      ...a.expand((list) => list),
    ];
  }
}
