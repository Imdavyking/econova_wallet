import 'package:starknet/starknet.dart';

extension CallDataExt on List<Felt> {
  List<Felt> toCalldata() {
    return [
      Felt.fromInt(length),
      ...this,
    ];
  }
}

extension CallDataListExt on List<List<Felt>> {
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
