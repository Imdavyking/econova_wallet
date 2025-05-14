import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

T parseBytesFromAccount<T>(Account? account, T Function(Uint8List) convert,
    {int skip = 8}) {
  final accountData = (account?.data as BinaryAccountData).data;
  final data = Uint8List.fromList(accountData);
  return convert(data.sublist(skip));
}

class BPublicKey extends BType<Ed25519HDPublicKey> {
  const BPublicKey();

  @override
  Ed25519HDPublicKey read(BinaryReader reader) {
    final data = reader.readFixedArray(32, () => reader.readU8());

    return Ed25519HDPublicKey(data);
  }

  @override
  void write(BinaryWriter writer, Ed25519HDPublicKey value) {
    final data = value.bytes;
    writer.writeFixedArray<int>(data, writer.writeU8);
  }
}
