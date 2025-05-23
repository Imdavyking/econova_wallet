import 'package:starknet/starknet.dart';

extension CallData on Uint256 {
  List<Felt> toCalldata() {
    return [low, high];
  }
}

abstract class StarknetSerializable {
  List<Felt> toCalldata();
}

extension SerializableListToCalldata<T> on List<T> {
  List<Felt> toCalldata() {
    if (isEmpty) return [Felt.zero];
    // final dynamic first = this.first;
    // if (first is! StarknetSerializable) {
    //   throw Exception(
    //       'Element of type ${first.runtimeType} does not implement StarknetSerializable');
    // }

    return [
      Felt.fromInt(length),
      ...map((element) {
        final serializable = element as StarknetSerializable;
        return serializable.toCalldata();
      }).expand((x) => x),
    ];
  }
}


  // @override
  // List<Felt> toCalldata() {
  //   return [this.low, this.high];
  // } // uint256