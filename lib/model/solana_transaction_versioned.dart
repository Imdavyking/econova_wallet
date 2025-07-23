class SolanaTransactionVersioned {
  final List<List<int>> signatures;
  final Message message;

  SolanaTransactionVersioned({
    required this.signatures,
    required this.message,
  });

  factory SolanaTransactionVersioned.fromJson(Map<String, dynamic> json) {
    return SolanaTransactionVersioned(
      signatures: (json['signatures'] as List)
          .map((sig) => List<int>.from((sig as Map<String, dynamic>).values))
          .toList(),
      message: Message.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() => {
        'signatures': signatures
            .map((sig) =>
                {for (int i = 0; i < sig.length; i++) i.toString(): sig[i]})
            .toList(),
        'message': message.toJson(),
      };
}

class Message {
  final Header header;
  final List<String> staticAccountKeys;
  final String recentBlockhash;
  final List<CompiledInstruction> compiledInstructions;
  final List<dynamic> addressTableLookups;

  Message({
    required this.header,
    required this.staticAccountKeys,
    required this.recentBlockhash,
    required this.compiledInstructions,
    required this.addressTableLookups,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      header: Header.fromJson(json['header']),
      staticAccountKeys:
          List<String>.from(json['staticAccountKeys'] as List<dynamic>),
      recentBlockhash: json['recentBlockhash'],
      compiledInstructions: (json['compiledInstructions'] as List)
          .map((e) => CompiledInstruction.fromJson(e))
          .toList(),
      addressTableLookups: List<dynamic>.from(json['addressTableLookups']),
    );
  }

  Map<String, dynamic> toJson() => {
        'header': header.toJson(),
        'staticAccountKeys': staticAccountKeys,
        'recentBlockhash': recentBlockhash,
        'compiledInstructions':
            compiledInstructions.map((e) => e.toJson()).toList(),
        'addressTableLookups': addressTableLookups,
      };
}

class Header {
  final int numRequiredSignatures;
  final int numReadonlySignedAccounts;
  final int numReadonlyUnsignedAccounts;

  Header({
    required this.numRequiredSignatures,
    required this.numReadonlySignedAccounts,
    required this.numReadonlyUnsignedAccounts,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        numRequiredSignatures: json['numRequiredSignatures'],
        numReadonlySignedAccounts: json['numReadonlySignedAccounts'],
        numReadonlyUnsignedAccounts: json['numReadonlyUnsignedAccounts'],
      );

  Map<String, dynamic> toJson() => {
        'numRequiredSignatures': numRequiredSignatures,
        'numReadonlySignedAccounts': numReadonlySignedAccounts,
        'numReadonlyUnsignedAccounts': numReadonlyUnsignedAccounts,
      };
}

class CompiledInstruction {
  final int programIdIndex;
  final List<int> accountKeyIndexes;
  final BufferData data;

  CompiledInstruction({
    required this.programIdIndex,
    required this.accountKeyIndexes,
    required this.data,
  });

  factory CompiledInstruction.fromJson(Map<String, dynamic> json) =>
      CompiledInstruction(
        programIdIndex: json['programIdIndex'],
        accountKeyIndexes:
            List<int>.from(json['accountKeyIndexes'] as List<dynamic>),
        data: BufferData.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
        'programIdIndex': programIdIndex,
        'accountKeyIndexes': accountKeyIndexes,
        'data': data.toJson(),
      };
}

class BufferData {
  final String type;
  final List<int> data;

  BufferData({
    required this.type,
    required this.data,
  });

  factory BufferData.fromJson(Map<String, dynamic> json) => BufferData(
        type: json['type'],
        data: List<int>.from(json['data']),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };
}
