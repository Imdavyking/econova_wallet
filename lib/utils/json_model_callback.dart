// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:hex/hex.dart';

class JsCallbackModel {
  int? id;
  String? name;
  String url;
  Map<String, dynamic>? object;
  String? network;

  JsCallbackModel({
    this.id,
    required this.name,
    required this.url,
    required this.object,
    required this.network,
  });

  factory JsCallbackModel.fromJson(Map<String, dynamic> json) {
    return JsCallbackModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      object: json['object'],
      network: json['network'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['url'] = url;
    data['object'] = object;
    data['network'] = network;
    return data;
  }
}

class JsDataModel {
  String data;

  JsDataModel({required this.data});

  factory JsDataModel.fromJson(Map<String, dynamic> json) {
    return JsDataModel(data: json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    return data;
  }
}

class JsSolanaMessageObject {
  String data;

  JsSolanaMessageObject({
    required this.data,
  });

  factory JsSolanaMessageObject.fromJson(Map<String, dynamic> json) {
    return JsSolanaMessageObject(
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['data'] = data;

    return data;
  }
}

class JsSolanaTransactionObject {
  String data;
  String raw;
  String version;
  String? rawMessage;

  JsSolanaTransactionObject({
    required this.data,
    required this.raw,
    required this.version,
    this.rawMessage,
  });

  factory JsSolanaTransactionObject.fromJson(Map<String, dynamic> json) {
    return JsSolanaTransactionObject(
      data: json['data'],
      raw: json['raw'],
      rawMessage: json['rawMessage'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['data'] = data;
    data['raw'] = raw;
    data['rawMessage'] = rawMessage;
    data['version'] = version;
    return data;
  }
}

class NearNonce {
  String type;
  List<int> data;

  NearNonce({required this.type, required this.data});

  factory NearNonce.fromJson(Map<String, dynamic> json) {
    return NearNonce(
      type: json['type'] as String,
      data: List<int>.from(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}

class JsNearMessageObject {
  String message;
  String recipient;
  NearNonce nonce;
  String? callbackUrl;
  String? state;

  JsNearMessageObject({
    required this.message,
    required this.recipient,
    required this.nonce,
    this.callbackUrl,
    required this.state,
  });

  factory JsNearMessageObject.fromJson(Map<String, dynamic> json) {
    return JsNearMessageObject(
      message: json['message'],
      recipient: json['recipient'],
      callbackUrl: json['callbackUrl'],
      state: json['state'],
      nonce: NearNonce.fromJson(json['nonce']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'recipient': recipient,
      'nonce': nonce.toJson(),
      'callbackUrl': callbackUrl,
      'state': state,
    };
  }
}

class JsTransactionObject {
  String? gas;
  String? value;
  String from;
  String? to;
  String? data;
  String? nonce;
  String? gasPrice;

  JsTransactionObject({
    required this.gas,
    required this.value,
    required this.from,
    required this.to,
    required this.data,
    required this.nonce,
    required this.gasPrice,
  });

  factory JsTransactionObject.fromJson(Map<String, dynamic> json) {
    return JsTransactionObject(
      gas: json['gas'],
      value: json['value'],
      from: json['from'],
      to: json['to'],
      data: json['data'],
      nonce: json['nonce'],
      gasPrice: json['gasPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gas'] = gas;
    data['value'] = value;
    data['from'] = from;
    data['to'] = to;
    data['data'] = data;
    data['nonce'] = nonce;
    data['gasPrice'] = gasPrice;
    return data;
  }
}

class JsEcRecoverObject {
  String signature;
  String message;

  JsEcRecoverObject({required this.signature, required this.message});

  factory JsEcRecoverObject.fromJson(Map<String, dynamic> json) {
    return JsEcRecoverObject(
      signature: json['signature'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['signature'] = signature;
    data['message'] = message;
    return data;
  }
}

class SignTypedDomain {
  int chainId;

  SignTypedDomain({
    required this.chainId,
  });

  factory SignTypedDomain.fromJson(Map<String, dynamic> json) {
    return SignTypedDomain(
      chainId: BigInt.parse(json['domain']['chainId']).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['chainId'] = chainId;

    return data;
  }
}

class JsEthSignTypedData {
  String raw;
  SignTypedDomain domain;

  JsEthSignTypedData({
    required this.raw,
    required this.domain,
  });

  factory JsEthSignTypedData.fromJson(Map<String, dynamic> json) {
    return JsEthSignTypedData(
      raw: json['raw'],
      domain: SignTypedDomain.fromJson(
        jsonDecode(json['raw']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['raw'] = raw;
    data['domain'] = domain;
    return data;
  }
}

class JsWatchAsset {
  String type;
  String contract;
  String? symbol;
  int? decimals;

  JsWatchAsset({
    required this.type,
    required this.contract,
    required this.symbol,
    required this.decimals,
  });

  factory JsWatchAsset.fromJson(Map<String, dynamic> json) {
    return JsWatchAsset(
      type: json['type'],
      contract: json['contract'],
      symbol: json['symbol'],
      decimals: json['decimals'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['contract'] = contract;
    data['symbol'] = symbol;
    data['decimals'] = decimals;
    return data;
  }
}

class JsSwitchEthereumChain {
  String chainId;

  JsSwitchEthereumChain({
    required this.chainId,
  });

  factory JsSwitchEthereumChain.fromJson(Map<String, dynamic> json) {
    return JsSwitchEthereumChain(
      chainId: json['chainId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;

    return data;
  }
}

class JsAddEthereumChain {
  String chainId;
  String chainName;
  List rpcUrls;
  List blockExplorerUrls;
  String? symbol;
  String? name;

  JsAddEthereumChain({
    required this.chainId,
    required this.chainName,
    required this.blockExplorerUrls,
    required this.rpcUrls,
    this.name,
    this.symbol,
  });

  factory JsAddEthereumChain.fromJson(Map<String, dynamic> json) {
    String? name;
    String? symbol;
    if (json['nativeCurrency'] != null) {
      symbol = json['nativeCurrency']['symbol'];
      name = json['nativeCurrency']['name'];
    }
    return JsAddEthereumChain(
      chainId: json['chainId'],
      chainName: json['chainName'],
      blockExplorerUrls: json['blockExplorerUrls'],
      rpcUrls: json['rpcUrls'],
      name: name,
      symbol: symbol,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;
    data['chainName'] = chainName;
    data['rpcUrls'] = rpcUrls;
    data['blockExplorerUrls'] = blockExplorerUrls;
    data['symbol'] = symbol;
    data['name'] = name;
    return data;
  }
}

class IncomingAccountsModel {
  int chainId;
  String rpcUrl;
  String address;

  IncomingAccountsModel({
    required this.chainId,
    required this.rpcUrl,
    required this.address,
  });

  factory IncomingAccountsModel.fromJson(Map<String, dynamic> json) {
    return IncomingAccountsModel(
      chainId: json['chainId'],
      rpcUrl: json['rpcUrl'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;
    data['rpcUrl'] = rpcUrl;
    data['address'] = address;

    return data;
  }
}

class CosmosDirectSignDoc {
  String body_bytes;
  String auth_info_bytes;

  CosmosDirectSignDoc({
    required this.auth_info_bytes,
    required this.body_bytes,
  });

  factory CosmosDirectSignDoc.fromJson(Map<String, dynamic> json) {
    String? _body_bytes;
    String? _auth_info_bytes;
    if (json['bodyBytes'] is Map) {
      Map bodyBytes = json['bodyBytes'];
      _body_bytes = HEX.encode(List<int>.from(bodyBytes.values));
    } else {
      _body_bytes = json['body_bytes'];
    }
    if (json['authInfoBytes'] is Map) {
      Map authInfoBytes = json['authInfoBytes'];

      _auth_info_bytes = HEX.encode(List<int>.from(authInfoBytes.values));
    } else {
      _auth_info_bytes = json['auth_info_bytes'];
    }

    return CosmosDirectSignDoc(
      body_bytes: _body_bytes!,
      auth_info_bytes: _auth_info_bytes!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['body_bytes'] = body_bytes;
    data['auth_info_bytes'] = auth_info_bytes;

    return data;
  }
}

class CosmosRequestObject {
  String chainId;

  String? data;

  String? raw;
  String? mode;

  CosmosDirectSignDoc? signDoc;

  CosmosRequestObject({
    required this.chainId,
    required this.data,
    required this.raw,
    required this.mode,
    this.signDoc,
  });

  factory CosmosRequestObject.fromJson(Map<String, dynamic> json) {
    CosmosDirectSignDoc? _signDoc;
    if (json['sign_doc'] != null) {
      _signDoc = CosmosDirectSignDoc.fromJson(json['sign_doc']);
    }
    return CosmosRequestObject(
      chainId: json['chainId'],
      data: json['data'],
      raw: json['raw'],
      mode: json['mode'],
      signDoc: _signDoc,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['chainId'] = chainId;
    data['data'] = data;
    data['signDoc'] = signDoc;
    data['raw'] = raw;
    data['mode'] = mode;

    return data;
  }
}
