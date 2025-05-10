import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchNFTs(String accountId) async {
  const String query = """
    query GetUserNFTs(\$accountId: String!) {
      nfts(where: { owner: \$accountId }) {
        id
        tokenId
        contractAddress
        metadata {
          title
          description
          media
        }
      }
    }
  """;

  String endpoint = "";

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'query': query,
      'variables': {
        'accountId': accountId,
      },
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['nfts'];
  } else {
    throw Exception('Failed to load NFTs');
  }
}
