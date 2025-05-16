class StarknetCall {
  final String contractAddress;
  final String entryPoint;
  final List<String> calldata;

  StarknetCall({
    required this.contractAddress,
    required this.entryPoint,
    required this.calldata,
  });

  factory StarknetCall.fromJson(Map<String, dynamic> json) {
    return StarknetCall(
      contractAddress: json['contract_address'] as String,
      entryPoint: json['entry_point'] as String,
      calldata: List<String>.from(json['calldata'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contract_address': contractAddress,
      'entry_point': entryPoint,
      'calldata': calldata,
    };
  }
}
