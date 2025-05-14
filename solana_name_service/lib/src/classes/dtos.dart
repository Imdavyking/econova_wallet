import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:solana/solana.dart';

part 'dtos.g.dart';

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

@BorshSerializable()
class FavoriteDomain with _$FavoriteDomain {
  factory FavoriteDomain({
    @BU8() required int tag,
    @BPublicKey() required Ed25519HDPublicKey nameAccount,
  }) = _FavoriteDomain;

  @override
  factory FavoriteDomain.fromBorsh(Uint8List data) =>
      _$FavoriteDomainFromBorsh(data);

  FavoriteDomain._();
}

@BorshSerializable()
class NameRegistryState with _$NameRegistryState {
  factory NameRegistryState(
      {@BPublicKey() required Ed25519HDPublicKey parentName,
      @BPublicKey() required Ed25519HDPublicKey owner,
      @BPublicKey() required Ed25519HDPublicKey stateClass,
      @BString() required String name}) = _NameRegistryState;

  @override
  factory NameRegistryState.fromBorsh(Uint8List data) =>
      _$NameRegistryStateFromBorsh(data);

  NameRegistryState._();
}
