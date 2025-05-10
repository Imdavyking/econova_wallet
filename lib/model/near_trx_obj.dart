import 'dart:typed_data';

import '../utils/is_hex_without_prefix.dart';

abstract class Action {
  int get value;
  factory Action.fromJson(Map<String, dynamic> json) {
    switch (json['enum']) {
      case 'createAccount':
        return CreateAccount();
      case 'deployContract':
        return DeployContract.fromJson(json['deployContract']);
      case 'functionCall':
        return FunctionCall.fromJson(json['functionCall']);
      case 'transfer':
        return Transfer.fromJson(json['transfer']);
      case 'stake':
        return Stake.fromJson(json['stake']);
      case 'addKey':
        return AddKey.fromJson(json['addKey']);
      case 'deleteKey':
        return DeleteKey.fromJson(json['deleteKey']);
      case 'deleteAccount':
        return DeleteAccount.fromJson(json['deleteAccount']);
      case 'signedDelegate':
        return SignedDelegate.fromJson(json['signedDelegate']);
      default:
        throw Exception('Unknown action type');
    }
  }
}

class CreateAccount implements Action {
  @override
  int get value => 0;
}

class DelegateAction {
  String senderId;
  String receiverId;
  List<Action> actions;
  int nonce;
  int maxBlockHeight;
  PublicKey publicKey;

  DelegateAction({
    required this.senderId,
    required this.receiverId,
    required this.actions,
    required this.nonce,
    required this.maxBlockHeight,
    required this.publicKey,
  });

  factory DelegateAction.fromJson(Map<String, dynamic> json) {
    return DelegateAction(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      actions: (json['actions'] as List)
          .map((actionJson) => Action.fromJson(actionJson))
          .toList(),
      nonce: json['nonce'],
      maxBlockHeight: json['maxBlockHeight'],
      publicKey: PublicKey.fromJson(json['publicKey']),
    );
  }
}

class DeployContract implements Action {
  @override
  int get value => 1;
  Uint8List code;

  DeployContract({required this.code});

  factory DeployContract.fromJson(Map<String, dynamic> json) {
    return DeployContract(
      code: Uint8List.fromList(List<int>.from(json['code']['data'])),
    );
  }
}

class FunctionCall implements Action {
  @override
  int get value => 2;
  String methodName;
  Uint8List args;
  BigInt gas;
  BigInt deposit;

  FunctionCall({
    required this.methodName,
    required this.args,
    required this.gas,
    required this.deposit,
  });

  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
      methodName: json['methodName'],
      args: Uint8List.fromList(List<int>.from(json['args']['data'])),
      gas: BigInt.from(json['gas']),
      deposit: BigInt.parse(json['deposit']),
    );
  }
}

class Transfer implements Action {
  @override
  int get value => 3;
  BigInt deposit;

  Transfer({required this.deposit});

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      deposit: BigInt.parse(json['deposit']),
    );
  }
}

class Stake implements Action {
  @override
  int get value => 4;
  BigInt stake;
  Uint8List publicKey;

  Stake({required this.stake, required this.publicKey});

  factory Stake.fromJson(Map<String, dynamic> json) {
    final isBase16 = isHEXStripox(json['stake']);

    return Stake(
      stake: BigInt.parse(json['stake'], radix: isBase16 ? 16 : 10),
      publicKey: PublicKey.fromJson(json['publicKey']).data,
    );
  }
}

class AddKey implements Action {
  Uint8List publicKey;
  AccessKey accessKey;

  AddKey({required this.publicKey, required this.accessKey});

  factory AddKey.fromJson(Map<String, dynamic> json) {
    return AddKey(
      publicKey: PublicKey.fromJson(json['publicKey']).data,
      accessKey: AccessKey.fromJson(json['accessKey']),
    );
  }

  @override
  int get value => 5;
}

class DeleteKey implements Action {
  Uint8List publicKey;

  DeleteKey({required this.publicKey});

  factory DeleteKey.fromJson(Map<String, dynamic> json) {
    return DeleteKey(
      publicKey: PublicKey.fromJson(json['publicKey']).data,
    );
  }

  @override
  int get value => 6;
}

class DeleteAccount implements Action {
  String beneficiaryId;

  DeleteAccount({required this.beneficiaryId});

  factory DeleteAccount.fromJson(Map<String, dynamic> json) {
    return DeleteAccount(
      beneficiaryId: json['beneficiaryId'],
    );
  }

  @override
  int get value => 7;
}

class SignedDelegate implements Action {
  DelegateAction delegateAction;
  Signature signature;

  SignedDelegate({required this.delegateAction, required this.signature});

  factory SignedDelegate.fromJson(Map<String, dynamic> json) {
    return SignedDelegate(
      delegateAction: DelegateAction.fromJson(json['delegateAction']),
      signature: Signature.fromJson(json['signature']),
    );
  }

  @override
  int get value => 8;
}

class Signature {
  int keyType;
  Uint8List data;

  Signature({required this.keyType, required this.data});

  factory Signature.fromJson(Map<String, dynamic> json) {
    return Signature(
      keyType: json['keyType'],
      data: Uint8List.fromList(List<int>.from(json['data']['data'])),
    );
  }
}

class AccessKey {
  AccessKeyPermission permission;

  AccessKey({required this.permission});

  factory AccessKey.fromJson(Map<String, dynamic> json) {
    return AccessKey(
      permission: AccessKeyPermission.fromJson(json['permission']),
    );
  }
}

abstract class AccessKeyPermission {
  factory AccessKeyPermission.fromJson(Map<String, dynamic> json) {
    switch (json['enum']) {
      case 'functionCall':
        return FunctionCallPermission.fromJson(json['functionCall']);
      default:
        throw Exception('Unknown permission type');
    }
  }
}

class FunctionCallPermission implements AccessKeyPermission {
  BigInt allowance;
  String receiverId;
  List<String> methodNames;

  FunctionCallPermission({
    required this.allowance,
    required this.receiverId,
    required this.methodNames,
  });

  factory FunctionCallPermission.fromJson(Map<String, dynamic> json) {
    return FunctionCallPermission(
      allowance: BigInt.parse(json['allowance']),
      receiverId: json['receiverId'],
      methodNames: List<String>.from(json['methodNames']),
    );
  }
}

class PublicKey {
  int keyType;
  Uint8List data;

  PublicKey({
    required this.keyType,
    required this.data,
  });

  factory PublicKey.fromJson(Map<String, dynamic> json) {
    return PublicKey(
      keyType: json['keyType'],
      data: Uint8List.fromList(List<int>.from(json['data']['data'])),
    );
  }
}

class BlockHash {
  List<int> data;

  BlockHash({required this.data});

  factory BlockHash.fromJson(Map<String, dynamic> json) {
    return BlockHash(
      data: List<int>.from(json['data']),
    );
  }
}

class NearDappTrx {
  String signerId;
  PublicKey publicKey;
  int nonce;
  String receiverId;
  List<Action> actions;
  BlockHash blockHash;
  Uint8List? encoded;

  NearDappTrx({
    required this.signerId,
    required this.publicKey,
    required this.nonce,
    required this.receiverId,
    required this.actions,
    required this.blockHash,
    this.encoded,
  });

  factory NearDappTrx.fromJson(Map<String, dynamic> json) {
    return NearDappTrx(
      encoded: Uint8List.fromList(List<int>.from(json['encoded']['data'])),
      signerId: json['signerId'],
      publicKey: PublicKey.fromJson(json['publicKey']),
      nonce: json['nonce'],
      receiverId: json['receiverId'],
      actions: (json['actions'] as List)
          .map((actionJson) => Action.fromJson(actionJson))
          .toList(),
      blockHash: BlockHash.fromJson(json['blockHash']),
    );
  }
}
