class SolanaTransactionLegacy {
  List<dynamic>? signatures;
  String feePayer;
  List<SolanaInstructionData>? instructions;
  String recentBlockhash;

  SolanaTransactionLegacy({
    this.signatures,
    required this.feePayer,
    this.instructions,
    required this.recentBlockhash,
  });

  factory SolanaTransactionLegacy.fromJson(Map<String, dynamic> json) =>
      SolanaTransactionLegacy(
        signatures: json["signatures"] == null
            ? []
            : List<dynamic>.from(json["signatures"].map((x) => x)),
        feePayer: json["feePayer"],
        instructions: json["instructions"] == null
            ? []
            : List<SolanaInstructionData>.from(json["instructions"]
                .map((x) => SolanaInstructionData.fromJson(x))),
        recentBlockhash: json["recentBlockhash"],
      );

  Map<String, dynamic> toJson() => {
        "signatures": signatures == null
            ? []
            : List<dynamic>.from(signatures!.map((x) => x)),
        "feePayer": feePayer,
        "instructions": instructions == null
            ? []
            : List<dynamic>.from(instructions!.map((x) => x.toJson())),
        "recentBlockhash": recentBlockhash,
      };
}

class SolanaInstructionData {
  List<SolanaInstructDataKey>? keys;
  String programId;
  Data? data;

  SolanaInstructionData({
    this.keys,
    required this.programId,
    this.data,
  });

  factory SolanaInstructionData.fromJson(Map<String, dynamic> json) =>
      SolanaInstructionData(
        keys: json["keys"] == null
            ? []
            : List<SolanaInstructDataKey>.from(
                json["keys"].map((x) => SolanaInstructDataKey.fromJson(x))),
        programId: json["programId"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "keys": keys == null
            ? []
            : List<dynamic>.from(keys!.map((x) => x.toJson())),
        "programId": programId,
        "data": data?.toJson(),
      };
}

class Data {
  List<int>? data;

  Data({
    this.data,
  });

  factory Data.fromJson(List<dynamic>? data_) => Data(
        data: data_ == null ? [] : List<int>.from(data_.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<int>.from(data!.map((x) => x)),
      };
}

class SolanaInstructDataKey {
  String pubkey;
  bool isSigner;
  bool isWritable;

  SolanaInstructDataKey({
    required this.pubkey,
    required this.isSigner,
    required this.isWritable,
  });

  factory SolanaInstructDataKey.fromJson(Map<String, dynamic> json) =>
      SolanaInstructDataKey(
        pubkey: json["pubkey"],
        isSigner: json["isSigner"],
        isWritable: json["isWritable"],
      );

  Map<String, dynamic> toJson() => {
        "pubkey": pubkey,
        "isSigner": isSigner,
        "isWritable": isWritable,
      };
}
