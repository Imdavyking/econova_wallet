import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

// ── Contract addresses (BSC mainnet) ──────────────────────────────────────────
// TokenManager2 confirmed: bsc-mcp, bitquery, multiple independent agents
const _tokenManager2Address = '0x5c952063c7fc8610FFDB798152D69F0B9550762b';
// TokenManagerHelper3 (for getTokenInfo / tryBuy / trySell)
const _tokenManagerHelper3Address =
    '0xF251F83e40a78868FcfA3FA4599Dad6494E46034';
const _baseUrl = 'https://four.meme/meme-api';

// ── TokenManager2 full ABI (0x5c952063c7fc8610FFDB798152D69F0B9550762b) ───────
// Sources: official four.meme gitbook docs, Bitquery trading bot guide,
//          Quicknode copytrading guide, 0xfnzero/four-trading-sdk,
//          slightlyuseless/fourMemeLauncher docs.
//
// Functions confirmed:
//   createToken(bytes,bytes)                                   payable
//   buyTokenAMAP(address,address,uint256,uint256)              payable  ← Bitquery
//   buyTokenAMAP(uint256,address,uint256,uint256)              payable  ← Quicknode (origin overload)
//   sellToken(address,uint256)                                 nonpayable
//
// Events confirmed:
//   TokenCreate  – creator(indexed), token(indexed), requestId, name, symbol, totalSupply, launchTime
//   TokenPurchase – buyer(indexed), token(indexed), amount, cost, fee
//   TokenSale    – seller(indexed), token(indexed), amount, cost, fee
//   LiquidityAdded – token(indexed), pair(indexed), liquidity
const _tokenManager2Abi = '''[
  {
    "inputs": [
      {"internalType": "bytes", "name": "createArg", "type": "bytes"},
      {"internalType": "bytes", "name": "sign",      "type": "bytes"}
    ],
    "name": "createToken",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "token",     "type": "address"},
      {"internalType": "address", "name": "to",        "type": "address"},
      {"internalType": "uint256", "name": "funds",     "type": "uint256"},
      {"internalType": "uint256", "name": "minAmount", "type": "uint256"}
    ],
    "name": "buyTokenAMAP",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "uint256", "name": "origin",    "type": "uint256"},
      {"internalType": "address", "name": "token",     "type": "address"},
      {"internalType": "uint256", "name": "funds",     "type": "uint256"},
      {"internalType": "uint256", "name": "minAmount", "type": "uint256"}
    ],
    "name": "buyTokenAMAP",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "token",    "type": "address"},
      {"internalType": "uint256", "name": "amount",   "type": "uint256"}
    ],
    "name": "sellToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "token",    "type": "address"},
      {"internalType": "uint256", "name": "amount",   "type": "uint256"},
      {"internalType": "uint256", "name": "minFunds", "type": "uint256"}
    ],
    "name": "sellToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true,  "name": "creator",     "type": "address"},
      {"indexed": true,  "name": "token",       "type": "address"},
      {"indexed": false, "name": "requestId",   "type": "uint256"},
      {"indexed": false, "name": "name",        "type": "string"},
      {"indexed": false, "name": "symbol",      "type": "string"},
      {"indexed": false, "name": "totalSupply", "type": "uint256"},
      {"indexed": false, "name": "launchTime",  "type": "uint256"}
    ],
    "name": "TokenCreate",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true,  "name": "buyer",  "type": "address"},
      {"indexed": true,  "name": "token",  "type": "address"},
      {"indexed": false, "name": "amount", "type": "uint256"},
      {"indexed": false, "name": "cost",   "type": "uint256"},
      {"indexed": false, "name": "fee",    "type": "uint256"}
    ],
    "name": "TokenPurchase",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true,  "name": "seller", "type": "address"},
      {"indexed": true,  "name": "token",  "type": "address"},
      {"indexed": false, "name": "amount", "type": "uint256"},
      {"indexed": false, "name": "cost",   "type": "uint256"},
      {"indexed": false, "name": "fee",    "type": "uint256"}
    ],
    "name": "TokenSale",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true,  "name": "token",     "type": "address"},
      {"indexed": true,  "name": "pair",      "type": "address"},
      {"indexed": false, "name": "liquidity", "type": "uint256"}
    ],
    "name": "LiquidityAdded",
    "type": "event"
  }
]''';

// ── TokenManagerHelper3 ABI (0xF251F83e40a78868FcfA3FA4599Dad6494E46034) ─────
// Source: official four.meme gitbook docs, emlahieu.blog API reference
const _tokenManagerHelper3Abi = '''[
  {
    "inputs": [{"internalType": "address", "name": "token", "type": "address"}],
    "name": "getTokenInfo",
    "outputs": [
      {"name": "version",        "type": "uint256"},
      {"name": "tokenManager",   "type": "address"},
      {"name": "quote",          "type": "address"},
      {"name": "lastPrice",      "type": "uint256"},
      {"name": "tradingFeeRate", "type": "uint256"},
      {"name": "minTradingFee",  "type": "uint256"},
      {"name": "launchTime",     "type": "uint256"},
      {"name": "offers",         "type": "uint256"},
      {"name": "maxOffers",      "type": "uint256"},
      {"name": "funds",          "type": "uint256"},
      {"name": "maxFunds",       "type": "uint256"},
      {"name": "liquidityAdded", "type": "bool"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"name": "token",  "type": "address"},
      {"name": "amount", "type": "uint256"},
      {"name": "funds",  "type": "uint256"}
    ],
    "name": "tryBuy",
    "outputs": [
      {"name": "tokenManager",    "type": "address"},
      {"name": "quote",           "type": "address"},
      {"name": "estimatedAmount", "type": "uint256"},
      {"name": "estimatedCost",   "type": "uint256"},
      {"name": "estimatedFee",    "type": "uint256"},
      {"name": "fundRequirement", "type": "uint256"},
      {"name": "fundAsParameter", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {"name": "token",  "type": "address"},
      {"name": "amount", "type": "uint256"}
    ],
    "name": "trySell",
    "outputs": [
      {"name": "tokenManager", "type": "address"},
      {"name": "quote",        "type": "address"},
      {"name": "funds",        "type": "uint256"},
      {"name": "fee",          "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
]''';

// ── Data classes ──────────────────────────────────────────────────────────────

class FourMemeConceptInput {
  final String name;
  final String shortName; // ticker, ≤6 chars
  final String description;
  final String label; // AI | Meme | Defi | Games | Infra | Others ...
  final String? webUrl;
  final String? twitterUrl;
  final String? telegramUrl;
  final String? imageUrl; // already uploaded to four.meme CDN
  final Uint8List? imageBytes; // raw bytes to upload if imageUrl is null
  final String imageContentType; // e.g. image/png
  final double preSaleBnb; // 0 = no presale
  final bool antiSniperFee; // feePlan

  const FourMemeConceptInput({
    required this.name,
    required this.shortName,
    required this.description,
    required this.label,
    this.webUrl,
    this.twitterUrl,
    this.telegramUrl,
    this.imageUrl,
    this.imageBytes,
    this.imageContentType = 'image/png',
    this.preSaleBnb = 0.0,
    this.antiSniperFee = false,
  });
}

class FourMemeCreateResult {
  final String tokenAddress; // parsed from TokenCreate event
  final String txHash;
  final String tokenName;
  final String tokenSymbol;
  final String? imageUrl;

  const FourMemeCreateResult({
    required this.tokenAddress,
    required this.txHash,
    required this.tokenName,
    required this.tokenSymbol,
    this.imageUrl,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class FourMemeService {
  final String rpc;
  final String privateKey; // hex, with or without 0x

  late final Web3Client _web3;
  late final EthPrivateKey _credentials;
  late final EthereumAddress _address;

  String? _accessToken;

  FourMemeService({required this.rpc, required this.privateKey}) {
    _web3 = Web3Client(rpc, http.Client());
    final key = privateKey.startsWith('0x') ? privateKey : '0x$privateKey';
    _credentials = EthPrivateKey.fromHex(key);
    _address = _credentials.address;
  }

  void dispose() => _web3.dispose();

  // ── Authentication ──────────────────────────────────────────────────────────

  Future<String> _ensureToken() async {
    if (_accessToken != null) return _accessToken!;

    // Nonce
    final nonceRes = await http.post(
      Uri.parse('$_baseUrl/v1/private/user/nonce/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accountAddress': _address.hexEip55,
        'verifyType': 'LOGIN',
        'networkCode': 'BSC',
      }),
    );
    _assertOk(nonceRes, 'nonce/generate');
    final nonce = jsonDecode(nonceRes.body)['data'] as String;

    // Sign + Login
    final message = 'You are sign in Meme $nonce';
    final signature = _personalSign(message);

    final loginRes = await http.post(
      Uri.parse('$_baseUrl/v1/private/user/login/dex'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'region': 'WEB',
        'langType': 'EN',
        'loginIp': '',
        'inviteCode': '',
        'verifyInfo': {
          'address': _address.hexEip55,
          'networkCode': 'BSC',
          'signature': signature,
          'verifyType': 'LOGIN',
        },
        'walletName': 'MetaMask',
      }),
    );
    _assertOk(loginRes, 'login');
    _accessToken = jsonDecode(loginRes.body)['data'] as String;
    return _accessToken!;
  }
  // ── Image upload ────────────────────────────────────────────────────────────

  Future<String> uploadImage({
    required Uint8List bytes,
    required String contentType, // e.g. image/png
    required String filename,
  }) async {
    try {
      debugPrint(
          'FourMemeService: uploading image ($filename, $contentType, ${bytes.length} bytes)');
      final token = await _ensureToken();

      final request = http.MultipartRequest(
        'POST',
        // live agents use /private/tool/upload; gitbook shows /private/token/upload
        Uri.parse('$_baseUrl/v1/private/token/upload'),
      )
        ..headers['meme-web-access'] = token
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}_$filename',
          contentType: MediaType.parse(contentType), // add mime pkg if needed
        ));

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      _assertOk(res, 'tool/upload');
      final url = jsonDecode(res.body)['data'] as String;
      return url;
    } catch (e) {
      debugPrint('FourMemeService: image upload failed: $e');
      return '';
    }
  }

  // ── Token creation ──────────────────────────────────────────────────────────

  /// Full flow: auth → (optional) upload image → create API → on-chain tx.
  Future<FourMemeCreateResult> createToken(FourMemeConceptInput input) async {
    final token = await _ensureToken();

    // 1. Resolve image URL
    String imgUrl = input.imageUrl ?? '';
    if (imgUrl.isEmpty && input.imageBytes != null) {
      imgUrl = await uploadImage(
        bytes: input.imageBytes!,
        contentType: input.imageContentType,
        filename: '${input.shortName.toLowerCase()}.png',
      );
    }
    if (imgUrl.isEmpty) {
      // Fallback: use a generic four.meme placeholder accepted by the API
      imgUrl =
          'https://static.four.meme/market/68b871b6-96f7-408c-b8d0-388d804b34275092658264263839640.png';
    }

    // 2. Fetch platform raisedToken config (BNB) — uses public config endpoint
    final raisedToken = await _fetchRaisedTokenConfig();

    // 3. Call create API
    final createRes = await http.post(
      Uri.parse('$_baseUrl/v1/private/token/create'),
      headers: {
        'Content-Type': 'application/json',
        'meme-web-access': token,
      },
      body: jsonEncode({
        'name': input.name,
        'shortName': input.shortName,
        'desc': input.description,
        'imgUrl': imgUrl,
        'launchTime': DateTime.now().millisecondsSinceEpoch,
        'label': _sanitizeLabel(input.label),
        'lpTradingFee': 0.0025,
        if (input.webUrl?.isNotEmpty == true) 'webUrl': input.webUrl,
        if (input.twitterUrl?.isNotEmpty == true)
          'twitterUrl': input.twitterUrl,
        if (input.telegramUrl?.isNotEmpty == true)
          'telegramUrl': input.telegramUrl,
        'preSale': input.preSaleBnb.toStringAsFixed(4),
        'onlyMPC': false,
        'feePlan': input.antiSniperFee,
        'raisedToken': raisedToken,
      }),
    );
    _assertOk(createRes, 'token/create');

    final createData =
        jsonDecode(createRes.body)['data'] as Map<String, dynamic>;
    final createArgHex = createData['createArg'] as String;
    final signatureHex = createData['signature'] as String;

    // 4. Submit on-chain
    final txHash = await _submitOnChain(
      createArgHex: createArgHex,
      signatureHex: signatureHex,
      preSaleBnb: input.preSaleBnb,
    );

    // 5. Parse token address from receipt logs
    final tokenAddress = await _extractTokenAddress(txHash);

    return FourMemeCreateResult(
      tokenAddress: tokenAddress,
      txHash: txHash,
      tokenName: input.name,
      tokenSymbol: input.shortName,
      imageUrl: imgUrl,
    );
  }

  // ── On-chain submission ─────────────────────────────────────────────────────

  Future<String> _submitOnChain({
    required String createArgHex,
    required String signatureHex,
    required double preSaleBnb,
  }) async {
    final createArgBytes = hexToBytes(_strip0x(createArgHex));
    final signBytes = hexToBytes(_strip0x(signatureHex));

    // Minimum creation fee: 0.01 BNB + presale
    final launchFeeBnb = 0.01 + preSaleBnb;
    final valueWei = BigInt.from((launchFeeBnb * 1e18).round());

    final gasPrice = await _web3.getGasPrice();

    // Build calldata manually:
    // createToken(bytes,bytes) selector = keccak256("createToken(bytes,bytes)")[0:4]
    final selector = keccak256(
      Uint8List.fromList(utf8.encode('createToken(bytes,bytes)')),
    ).sublist(0, 4);

    // ABI encode: two dynamic bytes args
    // offset1 = 64, offset2 = 64 + 32 + roundUp(len1)
    final arg1Padded = _abiEncodeBytes(createArgBytes);
    final arg2Padded = _abiEncodeBytes(signBytes);

    final offset1 = BigInt.from(64);
    final offset2 = BigInt.from(64 + 32 + arg1Padded.length);

    final calldata = Uint8List.fromList([
      ...selector,
      ..._uint256Bytes(offset1),
      ..._uint256Bytes(offset2),
      ...arg1Padded,
      ...arg2Padded,
    ]);

    final tx = Transaction(
      from: _address,
      to: EthereumAddress.fromHex(_tokenManager2Address),
      value: EtherAmount.inWei(valueWei),
      data: calldata,
      gasPrice: gasPrice,
    );

    final signed = await _web3.signTransaction(
      _credentials,
      tx,
      chainId: 56, // BSC mainnet
    );

    return await _web3.sendRawTransaction(signed);
  }

  Future<String> _extractTokenAddress(String txHash) async {
    // TokenCreate event selector:
    // keccak256("TokenCreate(address,address,uint256,string,string,uint256,uint256)")
    // Layout: topics[0]=selector, topics[1]=creator(indexed), topics[2]=token(indexed)
    // → token address is in topics[2], NOT topics[1]
    final tokenCreateSelector = bytesToHex(
      keccak256(Uint8List.fromList(
        utf8.encode(
            'TokenCreate(address,address,uint256,string,string,uint256,uint256)'),
      )),
      include0x: true,
    );

    // Poll for receipt (up to 60 s, 2 s interval)
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final receipt = await _web3.getTransactionReceipt(txHash);
        if (receipt == null) continue;

        // 1. Find the TokenCreate log by matching topics[0] = event selector
        for (final log in receipt.logs) {
          final topics = log.topics;
          if (topics == null || topics.length < 3) continue;

          final topic0 = topics[0].toString().toLowerCase();
          if (topic0 != tokenCreateSelector.toLowerCase()) continue;

          // topics[2] = token address (second indexed param)
          final raw2 = topics[2].toString();
          // Padded as 0x000...000<20-byte-address> (64 hex chars after 0x)
          final addr = _topicToAddress(raw2);
          if (addr != null) return addr;
        }

        // 2. Fallback: any log from TokenManager2 with ≥ 3 topics
        //    and a valid address in topics[2]
        for (final log in receipt.logs) {
          final logAddr = log.address?.hexEip55.toLowerCase();
          if (logAddr != _tokenManager2Address.toLowerCase()) continue;
          final topics = log.topics;
          if (topics != null && topics.length >= 3) {
            final addr = _topicToAddress(topics[2].toString());
            if (addr != null) return addr;
          }
        }

        // 3. Last resort: first log's address (the newly deployed token contract)
        if (receipt.logs.isNotEmpty) {
          return receipt.logs.first.address?.hexEip55 ?? txHash;
        }
        return txHash;
      } catch (e) {
        debugPrint('FourMemeService: receipt poll error: $e');
      }
    }
    return txHash; // timed out — return tx hash as fallback
  }

  /// Converts a 32-byte topic hex string to a checksummed address, or null.
  String? _topicToAddress(String topic) {
    // topic is "0x" + 64 hex chars; address occupies the last 40 chars
    final hex = topic.startsWith('0x') ? topic.substring(2) : topic;
    if (hex.length < 40) return null;
    final addrHex = '0x${hex.substring(hex.length - 40)}';
    if (!_isValidAddress(addrHex)) return null;
    try {
      return EthereumAddress.fromHex(addrHex).hexEip55;
    } catch (_) {
      return null;
    }
  }

  // ── Config fetch ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _fetchRaisedTokenConfig() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/v1/public/config'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if (data is Map && data['raisedTokenList'] is List) {
          final list = data['raisedTokenList'] as List;
          final bnb = list.firstWhere(
            (e) => e['symbol'] == 'BNB' && e['status'] == 'PUBLISH',
            orElse: () => null,
          );
          if (bnb != null) return Map<String, dynamic>.from(bnb);
        }
      }
    } catch (e) {
      debugPrint('FourMemeService: config fetch failed: $e');
    }
    // Hardcoded BNB config as fallback (from API docs)
    return {
      'symbol': 'BNB',
      'nativeSymbol': 'BNB',
      'symbolAddress': '0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c',
      'deployCost': '0',
      'buyFee': '0.01',
      'sellFee': '0.01',
      'minTradeFee': '0',
      'b0Amount': '8',
      'totalBAmount': '24',
      'totalAmount': '1000000000',
      'tradeLevel': ['0.1', '0.5', '1'],
      'status': 'PUBLISH',
      'buyTokenLink': 'https://pancakeswap.finance/swap',
      'reservedNumber': 10,
      'saleRate': '0.8',
      'networkCode': 'BSC',
      'platform': 'MEME',
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _personalSign(String message) {
    final msgBytes = utf8.encode(message);
    final prefixed = '\x19Ethereum Signed Message:\n${msgBytes.length}$message';
    final digest = keccak256(Uint8List.fromList(utf8.encode(prefixed)));
    final sig = sign(digest, _credentials.privateKey);
    final v = (sig.v + 27).toRadixString(16).padLeft(2, '0');
    final r = sig.r.toRadixString(16).padLeft(64, '0');
    final s = sig.s.toRadixString(16).padLeft(64, '0');
    return '0x$r$s$v';
  }

  Uint8List _abiEncodeBytes(Uint8List data) {
    final lenPadded = _uint256Bytes(BigInt.from(data.length));
    final paddedLen = ((data.length + 31) ~/ 32) * 32;
    final dataPadded = Uint8List(paddedLen)..setAll(0, data);
    return Uint8List.fromList([...lenPadded, ...dataPadded]);
  }

  Uint8List _uint256Bytes(BigInt value) =>
      hexToBytes(value.toRadixString(16).padLeft(64, '0'));

  String _strip0x(String s) => s.startsWith('0x') ? s.substring(2) : s;

  bool _isValidAddress(String addr) {
    return addr.length == 42 && addr.startsWith('0x');
  }

  String _sanitizeLabel(String label) {
    const valid = [
      'Meme',
      'AI',
      'Defi',
      'Games',
      'Infra',
      'De-Sci',
      'Social',
      'Depin',
      'Charity',
      'Others'
    ];
    final match = valid.firstWhere(
      (v) => v.toLowerCase() == label.toLowerCase(),
      orElse: () => 'Meme',
    );
    return match;
  }

  void _assertOk(http.Response res, String endpoint) {
    if (res.statusCode >= 400) {
      throw Exception(
          'FourMeme $endpoint failed (${res.statusCode}): ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body['code'] != '0' && body['code'] != 0) {
      throw Exception('FourMeme $endpoint error: ${body['msg'] ?? body}');
    }
  }
}
