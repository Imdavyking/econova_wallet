import 'package:borsh_annotation/borsh_annotation.dart';
part 'dapp_function.g.dart';

class BEnum<T extends Assignable> extends BType<T> {
  final List<List> enumValues;

  const BEnum({
    required this.enumValues,
  });

  @override
  void write(BinaryWriter writer, T value) {
    for (int idx = 0; idx < enumValues.length; ++idx) {
      List items = enumValues[idx];
      String fieldName = items[0];

      if (fieldName == value.properties['enum']) {
        writer.writeU8(idx);
        writer.writeStruct((value as dynamic).toBorsh());
        break;
      }
    }
  }

  @override
  T read(BinaryReader reader) {
    int idx = reader.readU8();
    if (idx < enumValues.length) {
      List items = enumValues[idx];
      String fieldName = items[0];
      BType fieldType = items[1];
      T value = fieldType.read(reader) as T;
      if (fieldName == value.properties['enum']) {
        return value;
      }
    }
    throw Exception('invalid enum value');
  }
}

abstract class Enum {
  int enumValue;

  Enum(Map<String, dynamic> properties) : enumValue = properties['enum'];
}

abstract class Assignable {
  final Map<String, dynamic> properties;

  Assignable(this.properties);

  Map<String, dynamic> toJson() {
    return properties;
  }
}

abstract class IAction extends Assignable {
  IAction(Map<String, dynamic> properties) : super(properties);
  Uint8List toBorsh();
}

@BorshSerializable()
class PublicKey extends Assignable with _$PublicKey {
  factory PublicKey({
    @BU8() required int keyType,
    @BFixedArray(32, BU8()) required List<int> data,
  }) = _PublicKey;

  PublicKey._() : super({});

  factory PublicKey.fromBorsh(Uint8List data) => _$PublicKeyFromBorsh(data);
}

@BorshSerializable()
class AccessKeyPermission extends Enum with _$AccessKeyPermission {
  factory AccessKeyPermission({
    @BEnum<Assignable>(enumValues: [
      ['functionCall', FunctionCallPermission],
      ['fullAccess', FullAccessPermission]
    ])
        required Assignable permission,
    @BU8()
        required int enumValue,
  }) = _AccessKeyPermission;

  AccessKeyPermission._() : super({});

  factory AccessKeyPermission.fromBorsh(Uint8List data) =>
      _$AccessKeyPermissionFromBorsh(data);
}

@BorshSerializable()
class FunctionCallPermission extends Assignable with _$FunctionCallPermission {
  factory FunctionCallPermission({
    @BU64() required BigInt allowance,
    @BString() required String receiverId,
    @BArray(BString()) required List<String> methodNames,
  }) = _FunctionCallPermission;

  FunctionCallPermission._() : super({});

  factory FunctionCallPermission.fromBorsh(Uint8List data) =>
      _$FunctionCallPermissionFromBorsh(data);
}

class FullAccessPermission extends Assignable {
  FullAccessPermission() : super({});

  // Method to serialize the object to binary
  Uint8List toBorsh() {
    final writer = BinaryWriter();
    return writer.toArray();
  }

  // Method to deserialize the object from binary
  factory FullAccessPermission.fromBorsh(Uint8List data) {
    return FullAccessPermission();
  }
}

@BorshSerializable()
class Signature extends Assignable with _$Signature {
  factory Signature({
    @BU8() required int keyType,
    @BFixedArray(64, BU8()) required List<int> data,
  }) = _Signature;

  Signature._() : super({});

  factory Signature.fromBorsh(Uint8List data) => _$SignatureFromBorsh(data);
}

@BorshSerializable()
class AccessKey extends Assignable with _$AccessKey {
  factory AccessKey({
    @BU64() required BigInt nonce,
    @BAccessKeyPermission() required AccessKeyPermission permission,
  }) = _AccessKey;

  AccessKey._() : super({});

  factory AccessKey.fromBorsh(Uint8List data) => _$AccessKeyFromBorsh(data);
}

@BorshSerializable()
class Action extends Enum with _$Action {
  factory Action({
    @BEnum<IAction>(enumValues: [
      ['createAccount', CreateAccount],
      ['deployContract', DeployContract],
      ['functionCall', FunctionCall],
      ['transfer', Transfer],
      ['stake', Stake],
      ['addKey', AddKey],
      ['deleteKey', DeleteKey],
      ['deleteAccount', DeleteAccount]
    ])
        required IAction actionType,
    @BU8()
        required int enumValue,
  }) = _Action;

  Action._() : super({});

  factory Action.fromBorsh(Uint8List data) => _$ActionFromBorsh(data);
}

class CreateAccount extends IAction {
  CreateAccount() : super({});

  // Method to serialize the object to binary
  @override
  Uint8List toBorsh() {
    final writer = BinaryWriter();
    return writer.toArray();
  }

  // Method to deserialize the object from binary
  factory CreateAccount.fromBorsh(Uint8List data) {
    return CreateAccount();
  }
}

@BorshSerializable()
class DeployContract extends IAction with _$DeployContract {
  factory DeployContract({
    @BArray(BU8()) required List<int> code,
  }) = _DeployContract;

  DeployContract._() : super({});

  factory DeployContract.fromBorsh(Uint8List data) =>
      _$DeployContractFromBorsh(data);
}

@BorshSerializable()
class FunctionCall extends IAction with _$FunctionCall {
  factory FunctionCall({
    @BString() required String methodName,
    @BArray(BU8()) required List<int> args,
    @BU64() required BigInt gas,
    @BFixedArray(16, BU8()) required List<int> deposit,
  }) = _FunctionCall;

  FunctionCall._() : super({});

  factory FunctionCall.fromBorsh(Uint8List data) =>
      _$FunctionCallFromBorsh(data);
}

@BorshSerializable()
class Transfer extends IAction with _$Transfer {
  factory Transfer({
    @BFixedArray(16, BU8()) required List<int> deposit,
  }) = _Transfer;

  Transfer._() : super({});

  factory Transfer.fromBorsh(Uint8List data) => _$TransferFromBorsh(data);
}

@BorshSerializable()
class Stake extends IAction with _$Stake {
  factory Stake({
    @BFixedArray(16, BU8()) required List<int> stake,
    @BPublicKey() required PublicKey publicKey,
  }) = _Stake;

  Stake._() : super({});

  factory Stake.fromBorsh(Uint8List data) => _$StakeFromBorsh(data);
}

@BorshSerializable()
class AddKey extends IAction with _$AddKey {
  factory AddKey({
    @BPublicKey() required PublicKey publicKey,
    @BAccessKey() required AccessKey accessKey,
  }) = _AddKey;

  AddKey._() : super({});

  factory AddKey.fromBorsh(Uint8List data) => _$AddKeyFromBorsh(data);
}

@BorshSerializable()
class DeleteKey extends IAction with _$DeleteKey {
  factory DeleteKey({
    @BPublicKey() required PublicKey publicKey,
  }) = _DeleteKey;

  DeleteKey._() : super({});

  factory DeleteKey.fromBorsh(Uint8List data) => _$DeleteKeyFromBorsh(data);
}

@BorshSerializable()
class DeleteAccount extends IAction with _$DeleteAccount {
  factory DeleteAccount({
    @BString() required String beneficiaryId,
  }) = _DeleteAccount;

  DeleteAccount._() : super({});

  factory DeleteAccount.fromBorsh(Uint8List data) =>
      _$DeleteAccountFromBorsh(data);
}

@BorshSerializable()
class Transaction extends Assignable with _$Transaction {
  factory Transaction({
    @BString() required String signerId,
    @BPublicKey() required PublicKey publicKey,
    @BU64() required BigInt nonce,
    @BString() required String receiverId,
    @BFixedArray(32, BU8()) required List<int> blockHash,
    @BArray(BAction()) required List<Action> actions,
  }) = _Transaction;

  Transaction._() : super({});

  @override
  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BString().write(writer, signerId);
    const BPublicKey().write(writer, publicKey);
    const BU64().write(writer, nonce);
    const BString().write(writer, receiverId);
    const BFixedArray(32, BU8()).write(writer, blockHash);

    writer.writeU32(actions.length);
    for (var action in actions) {
      const BU8().write(writer, action.enumValue);
      writer.writeStruct(action.actionType.toBorsh());
    }

    return writer.toArray();
  }

  factory Transaction.fromBorsh(Uint8List data) => _$TransactionFromBorsh(data);
}

@BorshSerializable()
class SignedTransaction extends Assignable with _$SignedTransaction {
  factory SignedTransaction({
    @BTransaction() required Transaction transaction,
    @BSignature() required Signature signature,
  }) = _SignedTransaction;

  SignedTransaction._() : super({});

  factory SignedTransaction.fromBorsh(Uint8List data) =>
      _$SignedTransactionFromBorsh(data);
}
