import 'package:borsh_annotation/borsh_annotation.dart';

class NearMessageBorsh {
  String message;
  String recipient;
  List<int> nonce;
  String? callbackUrl;
  int tag;
  // The tag's value is a hardcoded value as per
  // defined in the NEP [NEP413](https://github.com/near/NEPs/blob/master/neps/nep-0413.md)
  NearMessageBorsh({
    this.tag = 2147484061,
    required this.message,
    required this.recipient,
    required this.nonce,
    this.callbackUrl,
  });

  Uint8List serialize() {
    BinaryWriter writer = BinaryWriter();
    writer.writeU32(tag);
    writer.writeString(message);

    writer.writeFixedArray(
      Uint8List.fromList(nonce),
      (int e) => writer.writeU8(e),
    );

    writer.writeString(recipient);

    if (callbackUrl != null && callbackUrl!.isNotEmpty) {
      writer.writeU8(1);
      writer.writeString(callbackUrl!);
    } else {
      writer.writeU8(0);
    }

    return writer.toArray();
  }
}
