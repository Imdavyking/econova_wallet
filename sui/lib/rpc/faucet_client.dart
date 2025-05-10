import 'dart:convert';

import 'package:sui/types/faucet.dart';
import 'package:http/http.dart' as http;

class FaucetClient {
  final String endpoint;
  FaucetClient(this.endpoint);

  Future<FaucetResponse> requestSui(String recipient) async {
    final data = {
      "FixedAmountRequest": {"recipient": recipient}
    };

    final resp = await http.post(
      Uri.parse(endpoint),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    print(resp.body);
    return FaucetResponse.fromJson(jsonDecode(resp.body));
  }
}
