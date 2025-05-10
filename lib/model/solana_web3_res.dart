class SolanaWeb3Res {
  List<dynamic>? signatures;
  String feePayer;
  List<Instruction>? instructions;
  String recentBlockhash;

  SolanaWeb3Res({
    this.signatures,
    required this.feePayer,
    this.instructions,
    required this.recentBlockhash,
  });

  factory SolanaWeb3Res.fromJson(Map<String, dynamic> json) => SolanaWeb3Res(
        signatures: json["signatures"] == null
            ? []
            : List<dynamic>.from(json["signatures"].map((x) => x)),
        feePayer: json["feePayer"],
        instructions: json["instructions"] == null
            ? []
            : List<Instruction>.from(
                json["instructions"].map((x) => Instruction.fromJson(x))),
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

class Instruction {
  List<Key>? keys;
  String programId;
  Data? data;

  Instruction({
    this.keys,
    required this.programId,
    this.data,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
        keys: json["keys"] == null
            ? []
            : List<Key>.from(json["keys"].map((x) => Key.fromJson(x))),
        programId: json["programId"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "keys":
            keys == null ? [] : List<dynamic>.from(keys!.map((x) => x.toJson())),
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

class Key {
  String pubkey;
  bool isSigner;
  bool isWritable;

  Key({
    required this.pubkey,
    required this.isSigner,
    required this.isWritable,
  });

  factory Key.fromJson(Map<String, dynamic> json) => Key(
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
