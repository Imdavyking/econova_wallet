// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dtos.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$FavoriteDomain {
  int get tag => throw UnimplementedError();
  Ed25519HDPublicKey get nameAccount => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU8().write(writer, tag);
    const BPublicKey().write(writer, nameAccount);

    return writer.toArray();
  }
}

class _FavoriteDomain extends FavoriteDomain {
  _FavoriteDomain({
    required this.tag,
    required this.nameAccount,
  }) : super._();

  final int tag;
  final Ed25519HDPublicKey nameAccount;
}

class BFavoriteDomain implements BType<FavoriteDomain> {
  const BFavoriteDomain();

  @override
  void write(BinaryWriter writer, FavoriteDomain value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  FavoriteDomain read(BinaryReader reader) {
    return FavoriteDomain(
      tag: const BU8().read(reader),
      nameAccount: const BPublicKey().read(reader),
    );
  }
}

FavoriteDomain _$FavoriteDomainFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BFavoriteDomain().read(reader);
}

mixin _$NameRegistryState {
  Ed25519HDPublicKey get parentName => throw UnimplementedError();
  Ed25519HDPublicKey get owner => throw UnimplementedError();
  Ed25519HDPublicKey get stateClass => throw UnimplementedError();
  String get name => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, parentName);
    const BPublicKey().write(writer, owner);
    const BPublicKey().write(writer, stateClass);
    const BString().write(writer, name);

    return writer.toArray();
  }
}

class _NameRegistryState extends NameRegistryState {
  _NameRegistryState({
    required this.parentName,
    required this.owner,
    required this.stateClass,
    required this.name,
  }) : super._();

  final Ed25519HDPublicKey parentName;
  final Ed25519HDPublicKey owner;
  final Ed25519HDPublicKey stateClass;
  final String name;
}

class BNameRegistryState implements BType<NameRegistryState> {
  const BNameRegistryState();

  @override
  void write(BinaryWriter writer, NameRegistryState value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  NameRegistryState read(BinaryReader reader) {
    return NameRegistryState(
      parentName: const BPublicKey().read(reader),
      owner: const BPublicKey().read(reader),
      stateClass: const BPublicKey().read(reader),
      name: const BString().read(reader),
    );
  }
}

NameRegistryState _$NameRegistryStateFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BNameRegistryState().read(reader);
}
