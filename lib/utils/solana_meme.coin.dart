import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:on_chain/on_chain.dart';
import 'package:solana/solana.dart';

class PumpfunTokenOptions {
  final double initialLiquiditySol;
  final int slippageBps;
  final int priorityFee;
  final String? twitter;
  final String? telegram;
  final String? website;

  PumpfunTokenOptions({
    required this.initialLiquiditySol,
    required this.slippageBps,
    required this.priorityFee,
    this.twitter,
    this.telegram,
    this.website,
  });
}

class TokenLaunchResult {
  final String transactionHash;
  final String mintAddress;
  final String metadataUri;

  TokenLaunchResult({
    required this.transactionHash,
    required this.mintAddress,
    required this.metadataUri,
  });
}

class PumpfunTokenManager {
  static Future<Map<String, dynamic>> _uploadMetadata({
    required http.Client client,
    required String tokenName,
    required String tokenTicker,
    required String description,
    required String imageUrl,
    PumpfunTokenOptions? options,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('https://pump.fun/api/ipfs'));

    request.fields['name'] = tokenName;
    request.fields['symbol'] = tokenTicker;
    request.fields['description'] = description;
    request.fields['showName'] = 'true';

    if (options != null) {
      if (options.twitter != null) request.fields['twitter'] = options.twitter!;
      if (options.telegram != null) {
        request.fields['telegram'] = options.telegram!;
      }
      if (options.website != null) request.fields['website'] = options.website!;
    }

    final imageResponse = await client.get(Uri.parse(imageUrl));
    if (imageResponse.statusCode != 200) {
      throw Exception('Failed to download image from $imageUrl');
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageResponse.bodyBytes,
      filename: 'token_image.png',
      contentType: MediaType('image', 'png'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('Metadata upload failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  static Future<Uint8List> _createTokenTransaction({
    required http.Client client,
    required Ed25519HDKeyPair wallet,
    required Ed25519HDKeyPair mintKeypair,
    required Map<String, dynamic> metadataResponse,
    required PumpfunTokenOptions options,
  }) async {
    final payload = {
      "publicKey": wallet.address,
      "action": "create",
      "tokenMetadata": {
        "name": metadataResponse["metadata"]["name"],
        "symbol": metadataResponse["metadata"]["symbol"],
        "uri": metadataResponse["metadataUri"],
      },
      "mint": mintKeypair.address,
      "denominatedInSol": "true",
      "amount": options.initialLiquiditySol,
      "slippage": options.slippageBps,
      "priorityFee": options.priorityFee,
      "pool": "pump",
    };

    final response = await client.post(
      Uri.parse('https://pumpportal.fun/api/trade-local'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Transaction creation failed: ${response.body}');
    }

    return Uint8List.fromList(response.bodyBytes);
  }

  static Future<TokenLaunchResult> launchPumpfunToken({
    required RpcClient solanaClient,
    required Ed25519HDKeyPair wallet,
    required String tokenName,
    required String tokenTicker,
    required String description,
    required String imageUrl,
    required PumpfunTokenOptions options,
  }) async {
    final mintKeypair = await Ed25519HDKeyPair.random();

    final client = http.Client();
    try {
      final metadata = await _uploadMetadata(
        client: client,
        tokenName: tokenName,
        tokenTicker: tokenTicker,
        description: description,
        imageUrl: imageUrl,
        options: options,
      );

      final txBytes = await _createTokenTransaction(
        client: client,
        wallet: wallet,
        mintKeypair: mintKeypair,
        metadataResponse: metadata,
        options: options,
      );
      final signature = await wallet.sign(txBytes);
      final transactionHash =
          await solanaClient.sendTransaction(base64Encode(signature.bytes));
      signature.bytes;

      VersionedMessage vMesssage = VersionedMessage.fromBuffer(txBytes);
      print(vMesssage.compiledInstructions);
      // print("Message: $message");
      // print(message.compiledInstructions);

      // final tx = await signTransaction(
      //   message.recentBlockhash,
      //   message,
      //   signers,
      // );

      // final signature = '';
      // final signature = await solanaClient.sendTransaction(txBytes, [wallet]);

      return TokenLaunchResult(
        transactionHash: transactionHash,
        mintAddress: mintKeypair.address,
        metadataUri: metadata["metadataUri"],
      );
    } finally {
      client.close();
    }
  }
}
