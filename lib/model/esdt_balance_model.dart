class EsdtBalanceModel {
  Data? data;
  String? error;
  String? code;

  EsdtBalanceModel({
    this.data,
    this.error,
    this.code,
  });

  factory EsdtBalanceModel.fromJson(Map<String, dynamic> json) =>
      EsdtBalanceModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        error: json["error"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "error": error,
        "code": code,
      };
}

class Data {
  BlockInfo? blockInfo;
  TokenData? tokenData;

  Data({
    this.blockInfo,
    this.tokenData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        blockInfo: json["blockInfo"] == null
            ? null
            : BlockInfo.fromJson(json["blockInfo"]),
        tokenData: json["tokenData"] == null
            ? null
            : TokenData.fromJson(json["tokenData"]),
      );

  Map<String, dynamic> toJson() => {
        "blockInfo": blockInfo?.toJson(),
        "tokenData": tokenData?.toJson(),
      };
}

class BlockInfo {
  String hash;
  int nonce;
  String rootHash;

  BlockInfo({
    required this.hash,
    required this.nonce,
    required this.rootHash,
  });

  factory BlockInfo.fromJson(Map<String, dynamic> json) => BlockInfo(
        hash: json["hash"],
        nonce: json["nonce"],
        rootHash: json["rootHash"],
      );

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "nonce": nonce,
        "rootHash": rootHash,
      };
}

class TokenData {
  String balance;
  String properties;
  String tokenIdentifier;

  TokenData({
    required this.balance,
    required this.properties,
    required this.tokenIdentifier,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) => TokenData(
        balance: json["balance"],
        properties: json["properties"],
        tokenIdentifier: json["tokenIdentifier"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "properties": properties,
        "tokenIdentifier": tokenIdentifier,
      };
}
