import 'package:flutter/material.dart';

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

class StarknetCallList extends StatelessWidget {
  final List<StarknetCall> dapCalls;

  const StarknetCallList({super.key, required this.dapCalls});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dapCalls.map((call) {
        return ExpansionTile(
          title: Text(
            call.entryPoint,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contract Address: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    call.contractAddress,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Calldata:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                ...call.calldata.map((data) => Text(data)).toList(),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
