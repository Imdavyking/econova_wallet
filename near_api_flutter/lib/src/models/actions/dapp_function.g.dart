// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dapp_function.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$PublicKey {
  int get keyType => throw UnimplementedError();
  List<int> get data => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU8().write(writer, keyType);
    const BFixedArray(32, BU8()).write(writer, data);

    return writer.toArray();
  }
}

class _PublicKey extends PublicKey {
  _PublicKey({
    required this.keyType,
    required this.data,
  }) : super._();

  final int keyType;
  final List<int> data;
}

class BPublicKey implements BType<PublicKey> {
  const BPublicKey();

  @override
  void write(BinaryWriter writer, PublicKey value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  PublicKey read(BinaryReader reader) {
    return PublicKey(
      keyType: const BU8().read(reader),
      data: const BFixedArray(32, BU8()).read(reader),
    );
  }
}

PublicKey _$PublicKeyFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BPublicKey().read(reader);
}

mixin _$AccessKeyPermission {
  Assignable get permission => throw UnimplementedError();
  int get enumValue => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BEnum<Assignable>(enumValues: [
      ['functionCall', FunctionCallPermission],
      ['fullAccess', FullAccessPermission]
    ]).write(writer, permission);
    const BU8().write(writer, enumValue);

    return writer.toArray();
  }
}

class _AccessKeyPermission extends AccessKeyPermission {
  _AccessKeyPermission({
    required this.permission,
    required this.enumValue,
  }) : super._();

  final Assignable permission;
  final int enumValue;
}

class BAccessKeyPermission implements BType<AccessKeyPermission> {
  const BAccessKeyPermission();

  @override
  void write(BinaryWriter writer, AccessKeyPermission value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  AccessKeyPermission read(BinaryReader reader) {
    return AccessKeyPermission(
      permission: const BEnum<Assignable>(enumValues: [
        ['functionCall', FunctionCallPermission],
        ['fullAccess', FullAccessPermission]
      ]).read(reader),
      enumValue: const BU8().read(reader),
    );
  }
}

AccessKeyPermission _$AccessKeyPermissionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BAccessKeyPermission().read(reader);
}

mixin _$FunctionCallPermission {
  BigInt get allowance => throw UnimplementedError();
  String get receiverId => throw UnimplementedError();
  List<String> get methodNames => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, allowance);
    const BString().write(writer, receiverId);
    const BArray(BString()).write(writer, methodNames);

    return writer.toArray();
  }
}

class _FunctionCallPermission extends FunctionCallPermission {
  _FunctionCallPermission({
    required this.allowance,
    required this.receiverId,
    required this.methodNames,
  }) : super._();

  final BigInt allowance;
  final String receiverId;
  final List<String> methodNames;
}

class BFunctionCallPermission implements BType<FunctionCallPermission> {
  const BFunctionCallPermission();

  @override
  void write(BinaryWriter writer, FunctionCallPermission value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  FunctionCallPermission read(BinaryReader reader) {
    return FunctionCallPermission(
      allowance: const BU64().read(reader),
      receiverId: const BString().read(reader),
      methodNames: const BArray(BString()).read(reader),
    );
  }
}

FunctionCallPermission _$FunctionCallPermissionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BFunctionCallPermission().read(reader);
}

mixin _$Signature {
  int get keyType => throw UnimplementedError();
  List<int> get data => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU8().write(writer, keyType);
    const BFixedArray(64, BU8()).write(writer, data);

    return writer.toArray();
  }
}

class _Signature extends Signature {
  _Signature({
    required this.keyType,
    required this.data,
  }) : super._();

  final int keyType;
  final List<int> data;
}

class BSignature implements BType<Signature> {
  const BSignature();

  @override
  void write(BinaryWriter writer, Signature value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Signature read(BinaryReader reader) {
    return Signature(
      keyType: const BU8().read(reader),
      data: const BFixedArray(64, BU8()).read(reader),
    );
  }
}

Signature _$SignatureFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BSignature().read(reader);
}

mixin _$AccessKey {
  BigInt get nonce => throw UnimplementedError();
  AccessKeyPermission get permission => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, nonce);
    const BAccessKeyPermission().write(writer, permission);

    return writer.toArray();
  }
}

class _AccessKey extends AccessKey {
  _AccessKey({
    required this.nonce,
    required this.permission,
  }) : super._();

  final BigInt nonce;
  final AccessKeyPermission permission;
}

class BAccessKey implements BType<AccessKey> {
  const BAccessKey();

  @override
  void write(BinaryWriter writer, AccessKey value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  AccessKey read(BinaryReader reader) {
    return AccessKey(
      nonce: const BU64().read(reader),
      permission: const BAccessKeyPermission().read(reader),
    );
  }
}

AccessKey _$AccessKeyFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BAccessKey().read(reader);
}

mixin _$Action {
  IAction get actionType => throw UnimplementedError();
  int get enumValue => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BEnum<IAction>(enumValues: [
      ['createAccount', CreateAccount],
      ['deployContract', DeployContract],
      ['functionCall', FunctionCall],
      ['transfer', Transfer],
      ['stake', Stake],
      ['addKey', AddKey],
      ['deleteKey', DeleteKey],
      ['deleteAccount', DeleteAccount]
    ]).write(writer, actionType);
    const BU8().write(writer, enumValue);

    return writer.toArray();
  }
}

class _Action extends Action {
  _Action({
    required this.actionType,
    required this.enumValue,
  }) : super._();

  final IAction actionType;
  final int enumValue;
}

class BAction implements BType<Action> {
  const BAction();

  @override
  void write(BinaryWriter writer, Action value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Action read(BinaryReader reader) {
    return Action(
      actionType: const BEnum<IAction>(enumValues: [
        ['createAccount', CreateAccount],
        ['deployContract', DeployContract],
        ['functionCall', FunctionCall],
        ['transfer', Transfer],
        ['stake', Stake],
        ['addKey', AddKey],
        ['deleteKey', DeleteKey],
        ['deleteAccount', DeleteAccount]
      ]).read(reader),
      enumValue: const BU8().read(reader),
    );
  }
}

Action _$ActionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BAction().read(reader);
}

mixin _$DeployContract {
  List<int> get code => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BArray(BU8()).write(writer, code);

    return writer.toArray();
  }
}

class _DeployContract extends DeployContract {
  _DeployContract({
    required this.code,
  }) : super._();

  final List<int> code;
}

class BDeployContract implements BType<DeployContract> {
  const BDeployContract();

  @override
  void write(BinaryWriter writer, DeployContract value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  DeployContract read(BinaryReader reader) {
    return DeployContract(
      code: const BArray(BU8()).read(reader),
    );
  }
}

DeployContract _$DeployContractFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BDeployContract().read(reader);
}

mixin _$FunctionCall {
  String get methodName => throw UnimplementedError();
  List<int> get args => throw UnimplementedError();
  BigInt get gas => throw UnimplementedError();
  List<int> get deposit => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BString().write(writer, methodName);
    const BArray(BU8()).write(writer, args);
    const BU64().write(writer, gas);
    const BFixedArray(16, BU8()).write(writer, deposit);

    return writer.toArray();
  }
}

class _FunctionCall extends FunctionCall {
  _FunctionCall({
    required this.methodName,
    required this.args,
    required this.gas,
    required this.deposit,
  }) : super._();

  final String methodName;
  final List<int> args;
  final BigInt gas;
  final List<int> deposit;
}

class BFunctionCall implements BType<FunctionCall> {
  const BFunctionCall();

  @override
  void write(BinaryWriter writer, FunctionCall value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  FunctionCall read(BinaryReader reader) {
    return FunctionCall(
      methodName: const BString().read(reader),
      args: const BArray(BU8()).read(reader),
      gas: const BU64().read(reader),
      deposit: const BFixedArray(16, BU8()).read(reader),
    );
  }
}

FunctionCall _$FunctionCallFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BFunctionCall().read(reader);
}

mixin _$Transfer {
  List<int> get deposit => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BFixedArray(16, BU8()).write(writer, deposit);

    return writer.toArray();
  }
}

class _Transfer extends Transfer {
  _Transfer({
    required this.deposit,
  }) : super._();

  final List<int> deposit;
}

class BTransfer implements BType<Transfer> {
  const BTransfer();

  @override
  void write(BinaryWriter writer, Transfer value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Transfer read(BinaryReader reader) {
    return Transfer(
      deposit: const BFixedArray(16, BU8()).read(reader),
    );
  }
}

Transfer _$TransferFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BTransfer().read(reader);
}

mixin _$Stake {
  List<int> get stake => throw UnimplementedError();
  PublicKey get publicKey => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BFixedArray(16, BU8()).write(writer, stake);
    const BPublicKey().write(writer, publicKey);

    return writer.toArray();
  }
}

class _Stake extends Stake {
  _Stake({
    required this.stake,
    required this.publicKey,
  }) : super._();

  final List<int> stake;
  final PublicKey publicKey;
}

class BStake implements BType<Stake> {
  const BStake();

  @override
  void write(BinaryWriter writer, Stake value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Stake read(BinaryReader reader) {
    return Stake(
      stake: const BFixedArray(16, BU8()).read(reader),
      publicKey: const BPublicKey().read(reader),
    );
  }
}

Stake _$StakeFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BStake().read(reader);
}

mixin _$AddKey {
  PublicKey get publicKey => throw UnimplementedError();
  AccessKey get accessKey => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, publicKey);
    const BAccessKey().write(writer, accessKey);

    return writer.toArray();
  }
}

class _AddKey extends AddKey {
  _AddKey({
    required this.publicKey,
    required this.accessKey,
  }) : super._();

  final PublicKey publicKey;
  final AccessKey accessKey;
}

class BAddKey implements BType<AddKey> {
  const BAddKey();

  @override
  void write(BinaryWriter writer, AddKey value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  AddKey read(BinaryReader reader) {
    return AddKey(
      publicKey: const BPublicKey().read(reader),
      accessKey: const BAccessKey().read(reader),
    );
  }
}

AddKey _$AddKeyFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BAddKey().read(reader);
}

mixin _$DeleteKey {
  PublicKey get publicKey => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BPublicKey().write(writer, publicKey);

    return writer.toArray();
  }
}

class _DeleteKey extends DeleteKey {
  _DeleteKey({
    required this.publicKey,
  }) : super._();

  final PublicKey publicKey;
}

class BDeleteKey implements BType<DeleteKey> {
  const BDeleteKey();

  @override
  void write(BinaryWriter writer, DeleteKey value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  DeleteKey read(BinaryReader reader) {
    return DeleteKey(
      publicKey: const BPublicKey().read(reader),
    );
  }
}

DeleteKey _$DeleteKeyFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BDeleteKey().read(reader);
}

mixin _$DeleteAccount {
  String get beneficiaryId => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BString().write(writer, beneficiaryId);

    return writer.toArray();
  }
}

class _DeleteAccount extends DeleteAccount {
  _DeleteAccount({
    required this.beneficiaryId,
  }) : super._();

  final String beneficiaryId;
}

class BDeleteAccount implements BType<DeleteAccount> {
  const BDeleteAccount();

  @override
  void write(BinaryWriter writer, DeleteAccount value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  DeleteAccount read(BinaryReader reader) {
    return DeleteAccount(
      beneficiaryId: const BString().read(reader),
    );
  }
}

DeleteAccount _$DeleteAccountFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BDeleteAccount().read(reader);
}

mixin _$Transaction {
  String get signerId => throw UnimplementedError();
  PublicKey get publicKey => throw UnimplementedError();
  BigInt get nonce => throw UnimplementedError();
  String get receiverId => throw UnimplementedError();
  List<int> get blockHash => throw UnimplementedError();
  List<Action> get actions => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BString().write(writer, signerId);
    const BPublicKey().write(writer, publicKey);
    const BU64().write(writer, nonce);
    const BString().write(writer, receiverId);
    const BFixedArray(32, BU8()).write(writer, blockHash);
    const BArray(BAction()).write(writer, actions);

    return writer.toArray();
  }
}

class _Transaction extends Transaction {
  _Transaction({
    required this.signerId,
    required this.publicKey,
    required this.nonce,
    required this.receiverId,
    required this.blockHash,
    required this.actions,
  }) : super._();

  final String signerId;
  final PublicKey publicKey;
  final BigInt nonce;
  final String receiverId;
  final List<int> blockHash;
  final List<Action> actions;
}

class BTransaction implements BType<Transaction> {
  const BTransaction();

  @override
  void write(BinaryWriter writer, Transaction value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      signerId: const BString().read(reader),
      publicKey: const BPublicKey().read(reader),
      nonce: const BU64().read(reader),
      receiverId: const BString().read(reader),
      blockHash: const BFixedArray(32, BU8()).read(reader),
      actions: const BArray(BAction()).read(reader),
    );
  }
}

Transaction _$TransactionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BTransaction().read(reader);
}

mixin _$SignedTransaction {
  Transaction get transaction => throw UnimplementedError();
  Signature get signature => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BTransaction().write(writer, transaction);
    const BSignature().write(writer, signature);

    return writer.toArray();
  }
}

class _SignedTransaction extends SignedTransaction {
  _SignedTransaction({
    required this.transaction,
    required this.signature,
  }) : super._();

  final Transaction transaction;
  final Signature signature;
}

class BSignedTransaction implements BType<SignedTransaction> {
  const BSignedTransaction();

  @override
  void write(BinaryWriter writer, SignedTransaction value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  SignedTransaction read(BinaryReader reader) {
    return SignedTransaction(
      transaction: const BTransaction().read(reader),
      signature: const BSignature().read(reader),
    );
  }
}

SignedTransaction _$SignedTransactionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BSignedTransaction().read(reader);
}
