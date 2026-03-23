// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:hex/hex.dart';
import 'package:solana/dto.dart' hide AccountData;
import 'package:wallet_app/coins/fungible_tokens/spl_token_coin.dart';
import 'package:wallet_app/interface/user_quote.dart';
import 'package:wallet_app/model/solana_transaction_versioned.dart'
    hide Message;
import 'package:wallet_app/model/token_approvals.dart';
import 'package:wallet_app/service/ai_agent_service.dart';
import 'package:wallet_app/utils/solana_meme.coin.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:solana_name_service/solana_name_service.dart';
import '../extensions/resign_solana.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import 'package:solana/solana.dart' as solana;
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import "package:http/http.dart" as http;

const solDecimals = 9;

class SolanaCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String rpc;
  String ws;
  String geckoID;
  String rampID;
  String payScheme;

  @override
  bool requireMemo() => true;

  @override
  bool get supportPrivateKey => true;

  @override
  String? getSwapDappUrl() => 'https://jup.ag';

  @override
  String? getStakeDappUrl() => 'https://marinade.finance';

  @override
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

  SolanaCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.rpc,
    required this.ws,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  factory SolanaCoin.fromJson(Map<String, dynamic> json) {
    return SolanaCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      rpc: json['rpc'],
      ws: json['ws'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['rpc'] = rpc;
    data['image'] = image;
    data['ws'] = ws;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  @override
  List<Coin> get networkTokens => getSplTokens();

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'solanaDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final privateKeyBytes = HEX.decode(privateKey);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final keys = AccountData(
      address: keyPair.address,
      privateKey: privateKey,
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'solanaCoinDetail${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = SolanaArgs(
      seedRoot: seedPhraseRoot,
    );
    final keys = await compute(calculateSolanaKey, args);

    mnemonicMap[mnemonic] = keys;

    await pref.put(saveKey, jsonEncode(mnemonicMap));

    return AccountData.fromJson(keys);
  }

  List<String> dappTrxVersionedResult(SolanaTransactionVersioned simulation) {
    final instructions = simulation.message.compiledInstructions;
    final staticKeys = simulation.message.staticAccountKeys;

    List<String> trxResults = [];

    for (final ix in instructions) {
      final programIdIndex = ix.programIdIndex;
      final programId = staticKeys[programIdIndex];
      final data = ix.data.data; // Byte array
      if (data == null) return trxResults;
      if (programId == SystemProgram.programId) {
        final instructionType = data[0];
        if (instructionType == 2 && data.length >= 12) {
          // Transfer
          final fromAddress = staticKeys[ix.accountKeyIndexes[0]];
          final toAddress = staticKeys[ix.accountKeyIndexes[1]];
          final amountLamports = extractLamportsFromSystemTransfer(data);
          trxResults.add(
            "SOL Transfer: from $fromAddress to $toAddress amount: ${amountLamports / 1e9} SOL",
          );
        } else if (instructionType == 0) {
          // Create Account
          final fromAddress = staticKeys[ix.accountKeyIndexes[0]];
          final newAccountAddress = staticKeys[ix.accountKeyIndexes[1]];
          trxResults.add(
              "Create Account: from $fromAddress new account $newAccountAddress");
        }
      } else if (programId == TokenProgram.programId && data[0] == 3) {
        final instructionType = data[0];
        if (instructionType == 3) {
          // Transfer SPL Token
          final source = staticKeys[ix.accountKeyIndexes[0]];
          final destination = staticKeys[ix.accountKeyIndexes[1]];
          final amount = extractAmountFromSplTransfer(data);
          trxResults.add(
              "SPL Token Transfer: from $source to $destination amount: $amount tokens");
        } else if (instructionType == 4) {
          // Approve SPL Token
          final delegate = staticKeys[ix.accountKeyIndexes[1]];
          final owner = staticKeys[ix.accountKeyIndexes[2]];
          final amount = extractAmountFromSplTransfer(data);
          trxResults.add(
              "SPL Token Approve: owner $owner delegate $delegate amount: $amount tokens");
        } else if (instructionType == 6) {
          // Revoke SPL Token
          final owner = staticKeys[ix.accountKeyIndexes[1]];
          trxResults.add("SPL Token Revoke: owner $owner");
        } else if (instructionType == 7) {
          // Set Authority
          final account = staticKeys[ix.accountKeyIndexes[0]];
          trxResults.add("SPL Token Set Authority for $account");
        }
      }
    }
    return trxResults;
  }

  int extractLamportsFromSystemTransfer(List<int> data) {
    if (data.length < 12 || data[0] != 2) return 0;
    final amountBytes = Uint8List.fromList(data.sublist(4, 12));
    final byteData = ByteData.sublistView(amountBytes);
    return byteData.getUint64(0, Endian.little);
  }

  int extractAmountFromSplTransfer(List<int> data) {
    if (data.length < 9 || data[0] != 3) return 0;
    final amountBytes = Uint8List.fromList(data.sublist(1, 9));
    final byteData = ByteData.sublistView(amountBytes);
    return byteData.getUint64(0, Endian.little);
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final lamports = await getProxy().rpcClient.getBalance(address);

    final base = BigInt.from(10);

    return BigInt.from(lamports.value) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'solanaAddressBalance$address$rpc';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double balanceInSol = await getUserBalance(address: address);
      await pref.put(key, balanceInSol);

      return balanceInSol;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  Future<String?> testCreateApproval() async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final response = await importData(data);
      final privateKeyBytes = HEX.decode(response.privateKey!);
      final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes,
      );

      const testMint = 'USDCoctVLVnvTXBEuP9s8hntucdJokbo17RwHuNXemT';
      const testSpender = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';

      final accounts = await getProxy().rpcClient.getTokenAccountsByOwner(
            await getAddress(),
            const TokenAccountsFilter.byMint(testMint),
            encoding: Encoding.jsonParsed,
          );

      if (accounts.value.isEmpty) return 'No USDC token account found';

      final tokenAccount = Ed25519HDPublicKey.fromBase58(
        accounts.value.first.pubkey,
      );

      final bh = await getProxy().rpcClient.getLatestBlockhash(
            commitment: Commitment.finalized,
          );

      final approveIx = TokenInstruction.approve(
        source: tokenAccount,
        delegate: Ed25519HDPublicKey.fromBase58(testSpender),
        sourceOwner: keyPair.publicKey,
        amount: 1000000,
      );

      final signed = await keyPair.signMessage(
        message: Message(instructions: [approveIx]),
        recentBlockhash: bh.value.blockhash,
      );

      return await getProxy().rpcClient.sendTransaction(
            base64Encode(signed.toByteArray().toList()),
          );
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<int>> signVersionTx(Uint8List txBytes) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );
    final bh = await getProxy()
        .rpcClient
        .getLatestBlockhash(commitment: Commitment.finalized);
    SignedTx newCompiledMessage = await SignedTx.fromBytes(txBytes).resign(
      wallet: keyPair,
      blockhash: bh.value.blockhash,
    );

    return newCompiledMessage.toByteArray().toList();
  }

  @override
  Future<List<TokenApproval>>? getApprovals(String address) async {
    if (address.isEmpty) return null; // ← stops the RPC call

    final cacheKey = 'solana_approvals_$address$rpc';
    final cachedTime = pref.get('${cacheKey}_time');
    final cached = pref.get(cacheKey);

    // Return cache if fresh (< 10 minutes)
    if (cached != null && cachedTime != null) {
      final age = DateTime.now().difference(DateTime.parse(cachedTime));
      if (age.inMinutes < 10) {
        try {
          final list = jsonDecode(cached) as List;
          return list.map((e) => TokenApproval.fromJson(e)).toList();
        } catch (_) {}
      }
    }

    try {
      final client = getProxy().rpcClient;
      print("Heeeeeee");
      print("Address being used: '$address'");
      print("Address length: ${address.length}");
      // Get all token accounts owned by this wallet
      final accounts = await client.getTokenAccountsByOwner(
        address,
        const TokenAccountsFilter.byProgramId(
          TokenProgram.programId,
        ),
        commitment: Commitment.finalized,
      );
      print("we good");

      print(accounts);

      final approvals = <TokenApproval>[];

      for (final account in accounts.value) {
        final parsed = account.account.data;
        if (parsed is! ParsedSplTokenProgramAccountData) continue;

        final info = parsed.parsed;
        if (info is! TokenAccountData) continue;

        // Only include accounts with an active delegate
        final delegate = info.info.delegate;
        final delegatedAmount = info.info.delegateAmount;

        if (delegate == null || delegatedAmount == null) continue;
        if (delegatedAmount.amount == '0') continue;

        final mintAddress = info.info.mint;

        // Try to find token symbol from your SPL tokens list
        final splToken = getSplTokens().cast<Coin?>().firstWhere(
              (t) =>
                  t?.tokenAddress()?.toLowerCase() == mintAddress.toLowerCase(),
              orElse: () => null,
            );

        approvals.add(TokenApproval(
          tokenAddress: mintAddress,
          tokenSymbol: splToken?.getSymbol() ?? _shortAddr(mintAddress),
          tokenName: splToken?.getName() ?? mintAddress,
          spenderAddress: delegate,
          spenderName: _resolveSpenderName(delegate),
          allowance: BigInt.parse(delegatedAmount.amount),
          lastUpdated: null, // Solana doesn't return this from token accounts
        ));
      }

      // Cache result
      await pref.put(
          cacheKey, jsonEncode(approvals.map((a) => a.toJson()).toList()));
      await pref.put('${cacheKey}_time', DateTime.now().toIso8601String());

      return approvals;
    } catch (e) {
      debugPrint('SolanaCoin.getApprovals error: $e');

      // Return stale cache on error
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List;
          return list.map((e) => TokenApproval.fromJson(e)).toList();
        } catch (_) {}
      }
      return [];
    }
  }

// ── Revoke delegate ────────────────────────────────────────────────────────

  @override
  Future<bool>? revokeApproval(TokenApproval approval) async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final response = await importData(data);
      final privateKeyBytes = HEX.decode(response.privateKey!);
      final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes,
      );

      // Find the token account for this mint
      final accounts = await getProxy().rpcClient.getTokenAccountsByOwner(
            await getAddress(),
            TokenAccountsFilter.byMint(approval.tokenAddress),
            encoding: Encoding.jsonParsed,
          );

      if (accounts.value.isEmpty) {
        throw Exception('Token account not found for ${approval.tokenSymbol}');
      }

      final tokenAccountAddress = accounts.value.first.pubkey;

      // Get latest blockhash
      final bh = await getProxy().rpcClient.getLatestBlockhash(
            commitment: Commitment.finalized,
          );

      // Build revoke instruction with correct parameter names
      final revokeIx = TokenInstruction.revoke(
        source: Ed25519HDPublicKey.fromBase58(
          tokenAccountAddress,
        ), // ← source not accountToChange
        sourceOwner: keyPair.publicKey, // ← sourceOwner not accountOwner
      );

      final message = Message(instructions: [revokeIx]);

      // signMessage takes Message + recentBlockhash, not compiled bytes
      final signed = await keyPair.signMessage(
        message: message, // ← Message not compiled.toByteArray()
        recentBlockhash: bh.value.blockhash, // ← required param
      );

      await getProxy().rpcClient.sendTransaction(
            base64Encode(signed.toByteArray().toList()),
          );

      // Clear cache
      final address = await getAddress();
      await pref.delete('solana_approvals_$address$rpc');
      await pref.delete('solana_approvals_$address${rpc}_time');
      return true;
    } catch (e) {
      return false;
    }
  }
// ── Helpers ────────────────────────────────────────────────────────────────

  static const _knownSolanaSpenders = <String, String>{
    'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4': 'Jupiter V6',
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc': 'Orca Whirlpool',
    '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP': 'Orca V2',
    'RVKd61ztZW9GUwhRbbLoYVRE5Xf1B2tVscKqwZqXgEr': 'Raydium V4',
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8': 'Raydium AMM',
  };

  String _resolveSpenderName(String address) {
    return _knownSolanaSpenders[address] ?? _shortAddr(address);
  }

  String _shortAddr(String addr) =>
      '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';

  @override
  Future<DeployMeme> deployMemeCoin({
    required String name,
    required String symbol,
    required String initialSupply,
  }) async {
    const imageUrl =
        "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg";
    const description = "A meme token created with Pump.fun";

    final cryptoPrice = await getCryptoPrice(useCache: true);
    final currPrice = cryptoPrice.getPrice(geckoID) ?? 0.0;

    const dollarLiqInSol = 0.3;

    final options = PumpfunTokenOptions(
      initialLiquiditySol: dollarLiqInSol / currPrice,
      slippageBps: 500,
      priorityFee: 0,
    );

    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final result = await PumpfunTokenManager.launchPumpfunToken(
      solanaClient: getProxy().rpcClient,
      wallet: keyPair,
      tokenName: name,
      tokenTicker: symbol,
      description: description,
      imageUrl: imageUrl,
      options: options,
    );

    return DeployMeme(
      liquidityTx: result.transactionHash,
      tokenAddress: result.mintAddress,
      deployTokenTx: result.transactionHash,
    );
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final lamportToSend = amount.toBigIntDec(solDecimals);
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );

    final txHash = await getProxy().transferLamports(
      source: keyPair,
      destination: solana.Ed25519HDPublicKey.fromBase58(to),
      lamports: lamportToSend.toInt(),
      memo: memo,
    );
    return (
      txHash: txHash,
      txRaw: null,
    );
  }

  @override
  validateAddress(String address) {
    solana.Ed25519HDPublicKey.fromBase58(address);
  }

  @override
  int decimals() {
    return solDecimals;
  }

  String SWAP_HOST() => enableTestNet
      ? 'https://transaction-v1-devnet.raydium.io'
      : 'https://transaction-v1.raydium.io';

  String BASE_HOST() => enableTestNet
      ? 'https://api-v3-devnet.raydium.io'
      : 'https://api-v3.raydium.io';
  String NATIVE_SOL_ADDRESS = 'So11111111111111111111111111111111111111112';

  Future<int> getTokenDecimals(String tokenAddress) async {
    if (tokenAddress == NATIVE_SOL_ADDRESS) {
      return solDecimals;
    }
    final mint = await getProxy().getMint(
      address: Ed25519HDPublicKey.fromBase58(tokenAddress),
    );
    return mint.decimals;
  }

  Future<ProgramAccount> findOrCreateTokenAccount({
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mintKey,
    required Ed25519HDKeyPair funder,
  }) async {
    final account = await getProxy().getAssociatedTokenAccount(
      owner: owner,
      mint: mintKey,
      commitment: solana.Commitment.finalized,
    );

    if (account != null) return account;

    await getProxy().createAssociatedTokenAccount(
      mint: mintKey,
      funder: funder,
      owner: owner,
      commitment: solana.Commitment.finalized,
    );

    final createdAccount = await getProxy().getAssociatedTokenAccount(
      owner: owner,
      mint: mintKey,
      commitment: solana.Commitment.finalized,
    );

    if (createdAccount == null) {
      throw Exception("Failed to create associated token account.");
    }

    return createdAccount;
  }

  Future<SwapQuote> _getSwapResponse(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async {
    if (tokenIn == AIAgentService.defaultCoinTokenAddress) {
      tokenIn = NATIVE_SOL_ADDRESS;
    } else if (tokenOut == AIAgentService.defaultCoinTokenAddress) {
      tokenOut = NATIVE_SOL_ADDRESS;
    }

    final amountDecimals = amount.toBigIntDec(await getTokenDecimals(tokenIn));

    const slippage = 0.05;
    final url = Uri.parse(
      '${SWAP_HOST()}/compute/swap-base-in?inputMint=$tokenIn&outputMint=$tokenOut&amount=$amountDecimals&slippageBps=${(slippage * 100).toInt()}&txVersion=V0',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch quote: ${response.body}');
    }

    return SwapQuote.fromJson(jsonDecode(response.body));
  }

  @override
  Future<String?> getQuote(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async {
    if (tokenIn == AIAgentService.defaultCoinTokenAddress) {
      tokenIn = NATIVE_SOL_ADDRESS;
    } else if (tokenOut == AIAgentService.defaultCoinTokenAddress) {
      tokenOut = NATIVE_SOL_ADDRESS;
    }

    debugPrint(
      'Getting quote for $tokenIn => $tokenOut $amount',
    );

    final tokenOutDecimals = await getTokenDecimals(tokenOut);

    final responseData = await _getSwapResponse(
      tokenIn,
      tokenOut,
      amount,
    );

    final unit = pow(10, tokenOutDecimals);

    final quoteAmount = num.parse(responseData.data.outputAmount) / unit;

    final quote = UserQuote(quoteAmount);
    return jsonEncode(quote.toJson());
  }

  Future<PriorityFeeResponse> _priorityFee() async {
    final url = '${BASE_HOST()}/main/auto-fee';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch priority fee: ${response.body}');
    }
    final data = PriorityFeeResponse.fromJson(jsonDecode(response.body));
    return data;
  }

  Future<int> getFeeForMessage(String base64Message) async {
    try {
      final client = getProxy().rpcClient;

      final fee = await client.getFeeForMessage(base64Message);
      if (fee == null) {
        return 0;
      }
      return fee;
    } catch (e) {
      debugPrint('Error getting fee for message: $e');
      return 0; // Return 0 if there's an error
    }
  }

  Future<TransactionStatusResult?> simulateTransaction(
      String base64Message) async {
    try {
      final client = getProxy().rpcClient;

      final result = await client.simulateTransaction(base64Message);

      return result;
    } catch (e) {
      debugPrint('Error getting fee for message: $e');
      return null; // Return 0 if there's an error
    }
  }

  @override
  Future<String?> swapTokens(
    String tokenIn,
    String tokenOut,
    String amount,
  ) async {
    if (tokenIn == AIAgentService.defaultCoinTokenAddress) {
      tokenIn = NATIVE_SOL_ADDRESS;
    } else if (tokenOut == AIAgentService.defaultCoinTokenAddress) {
      tokenOut = NATIVE_SOL_ADDRESS;
    }
    final responseData = await _getSwapResponse(
      tokenIn,
      tokenOut,
      amount,
    );

    debugPrint(
      'Swapping $amount of $tokenIn to $tokenOut',
    );
    final swapData = responseData.data;
    final inputMint = swapData.inputMint;
    final outputMint = swapData.outputMint;
    final isInputSol = inputMint == NATIVE_SOL_ADDRESS;
    final isOutputSol = outputMint == NATIVE_SOL_ADDRESS;
    final address = await getAddress();

    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final privateKeyBytes = HEX.decode(response.privateKey!);

    final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKeyBytes,
    );
    solana.Ed25519HDKeyPair solanaKeyPair = keyPair;

    final inputTokenAcc = isInputSol
        ? null
        : await findOrCreateTokenAccount(
            funder: solanaKeyPair,
            owner: Ed25519HDPublicKey.fromBase58(address),
            mintKey: Ed25519HDPublicKey.fromBase58(
              inputMint,
            ),
          );

    final outputTokenAcc = isOutputSol
        ? null
        : await findOrCreateTokenAccount(
            funder: solanaKeyPair,
            owner: Ed25519HDPublicKey.fromBase58(address),
            mintKey: Ed25519HDPublicKey.fromBase58(
              outputMint,
            ),
          );

    final url = Uri.parse('${SWAP_HOST()}/transaction/swap-base-in');

    debugPrint('Swapping tokens with URL: $url');

    final priorityFee = await _priorityFee();

    final body = {
      'txVersion': 'V0',
      'computeUnitPriceMicroLamports':
          priorityFee.data.priorityFee.h.toString(),
      'wallet': address,
      'wrapSol': isInputSol,
      'unwrapSol': isOutputSol,
      'swapResponse': responseData.toJson(),
    };

    if (inputTokenAcc != null) {
      body['inputAccount'] = inputTokenAcc.pubkey;
    }

    if (outputTokenAcc != null) {
      body['outputAccount'] = outputTokenAcc.pubkey;
    }

    final rpcCall = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (rpcCall.statusCode >= 400) {
      throw Exception('Failed to swap tokens: ${rpcCall.body}');
    }

    final swapResponse = SwapResponse.fromJson(jsonDecode(rpcCall.body));
    if (!swapResponse.success) {
      throw Exception('Swap failed: ${swapResponse.msg}');
    }

    final transactions = swapResponse.data;
    if (transactions.isEmpty) {
      throw Exception('No transactions returned from swap response');
    }

    String? lastTxSig;
    int idx = 0;
    final solanaClient = getProxy().rpcClient;

    for (final tx in transactions) {
      final txBytes = base64Decode(tx.transaction);
      final bh = await solanaClient.getLatestBlockhash(
        commitment: Commitment.finalized,
      );
      SignedTx newCompiledMessage = await SignedTx.fromBytes(txBytes).resign(
        wallet: solanaKeyPair,
        blockhash: bh.value.blockhash,
      );

      // Send and confirm transaction
      final transactionHash = await solanaClient.sendTransaction(
        base64.encode(newCompiledMessage.toByteArray().toList()),
      );
      lastTxSig = transactionHash;

      debugPrint('Transaction ${++idx} sent and confirmed: $transactionHash');
    }

    return lastTxSig;
  }

  @override
  Future<String?> resolveAddress(String address) async {
    if (address.endsWith('.sol')) {
      address = address.substring(0, address.length - 4);
    }
    final publicKey = await findAccountByName(
      address,
      environment: SolanaEnvironment.mainnet,
    );

    if (publicKey == null) {
      return null;
    }

    return publicKey.toBase58();
  }

  solana.SolanaClient getProxy() {
    return solana.SolanaClient(
      rpcUrl: Uri.parse(rpc),
      websocketUrl: Uri.parse(ws),
    );
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0.000005; // TODO: Implement this method
    // final fees = await getProxy().rpcClient.getFeeForMessage(message);
    // return fees.feeCalculator.lamportsPerSignature / pow(10, solDecimals);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

List<SolanaCoin> getSolanaBlockChains() {
  List<SolanaCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.add(
      SolanaCoin(
        name: 'Solana(Devnet)',
        symbol: 'SOL',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder?cluster=devnet',
        image: 'assets/solana.webp',
        rpc: 'https://api.devnet.solana.com',
        ws: 'wss://api.devnet.solana.com',
        geckoID: 'solana',
        rampID: "SOLANA_SOL",
        payScheme: 'solana',
      ),
    );
  } else {
    blockChains.addAll([
      SolanaCoin(
        name: 'Solana',
        symbol: 'SOL',
        default_: 'SOL',
        blockExplorer:
            'https://explorer.solana.com/tx/$blockExplorerPlaceholder',
        image: 'assets/solana.webp',
        rpc: 'https://api.mainnet-beta.solana.com',
        ws: 'wss://api.mainnet-beta.solana.com',
        geckoID: 'solana',
        rampID: "SOLANA_SOL",
        payScheme: 'solana',
      ),
    ]);
  }
  return blockChains;
}

class SolanaArgs {
  final SeedPhraseRoot seedRoot;

  const SolanaArgs({
    required this.seedRoot,
  });
}

Future calculateSolanaKey(SolanaArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;

  final solana.Ed25519HDKeyPair keyPair =
      await solana.Ed25519HDKeyPair.fromSeedWithHdPath(
    seed: seedRoot_.seed,
    hdPath: "m/44'/501'/0'",
  );

  final keyPairData = await keyPair.extract();

  return {
    'address': keyPair.address,
    'privateKey': HEX.encode(keyPairData.bytes),
  };
}

class SwapQuote {
  final String id;
  final bool success;
  final String version;
  final SwapData data;

  SwapQuote({
    required this.id,
    required this.success,
    required this.version,
    required this.data,
  });

  factory SwapQuote.fromJson(Map<String, dynamic> json) {
    return SwapQuote(
      id: json['id'],
      success: json['success'],
      version: json['version'],
      data: SwapData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'success': success,
      'version': version,
      'data': data.toJson()
    };
  }
}

class SwapData {
  final String swapType;
  final String inputMint;
  final String inputAmount;
  final String outputMint;
  final String outputAmount;
  final String otherAmountThreshold;
  final int slippageBps;
  final double priceImpactPct;
  final String referrerAmount;
  final List<RoutePlan> routePlan;

  SwapData({
    required this.swapType,
    required this.inputMint,
    required this.inputAmount,
    required this.outputMint,
    required this.outputAmount,
    required this.otherAmountThreshold,
    required this.slippageBps,
    required this.priceImpactPct,
    required this.referrerAmount,
    required this.routePlan,
  });

  factory SwapData.fromJson(Map<String, dynamic> json) {
    return SwapData(
      swapType: json['swapType'],
      inputMint: json['inputMint'],
      inputAmount: json['inputAmount'],
      outputMint: json['outputMint'],
      outputAmount: json['outputAmount'],
      otherAmountThreshold: json['otherAmountThreshold'],
      slippageBps: json['slippageBps'],
      priceImpactPct: (json['priceImpactPct'] as num).toDouble(),
      referrerAmount: json['referrerAmount'],
      routePlan: (json['routePlan'] as List<dynamic>)
          .map((e) => RoutePlan.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swapType': swapType,
      'inputMint': inputMint,
      'inputAmount': inputAmount,
      'outputMint': outputMint,
      'outputAmount': outputAmount,
      'otherAmountThreshold': otherAmountThreshold,
      'slippageBps': slippageBps,
      'priceImpactPct': priceImpactPct,
      'referrerAmount': referrerAmount,
      'routePlan': routePlan.map((e) => e.toJson()).toList(),
    };
  }
}

class RoutePlan {
  final String poolId;
  final String inputMint;
  final String outputMint;
  final String feeMint;
  final int feeRate;
  final String feeAmount;
  final List<String> remainingAccounts;
  final String? lastPoolPriceX64;

  RoutePlan({
    required this.poolId,
    required this.inputMint,
    required this.outputMint,
    required this.feeMint,
    required this.feeRate,
    required this.feeAmount,
    required this.remainingAccounts,
    required this.lastPoolPriceX64,
  });

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    return RoutePlan(
      poolId: json['poolId'],
      inputMint: json['inputMint'],
      outputMint: json['outputMint'],
      feeMint: json['feeMint'],
      feeRate: json['feeRate'],
      feeAmount: json['feeAmount'],
      remainingAccounts:
          List<String>.from(json['remainingAccounts'] as List<dynamic>),
      lastPoolPriceX64: json['lastPoolPriceX64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'poolId': poolId,
      'inputMint': inputMint,
      'outputMint': outputMint,
      'feeMint': feeMint,
      'feeRate': feeRate,
      'feeAmount': feeAmount,
      'remainingAccounts': remainingAccounts,
      'lastPoolPriceX64': lastPoolPriceX64,
    };
  }
}

class PriorityFeeResponse {
  final String id;
  final bool success;
  final PriorityFeeData data;

  PriorityFeeResponse({
    required this.id,
    required this.success,
    required this.data,
  });

  factory PriorityFeeResponse.fromJson(Map<String, dynamic> json) {
    return PriorityFeeResponse(
      id: json['id'],
      success: json['success'],
      data: PriorityFeeData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PriorityFeeData {
  final PriorityFee priorityFee;

  PriorityFeeData({required this.priorityFee});

  factory PriorityFeeData.fromJson(Map<String, dynamic> json) {
    return PriorityFeeData(
      priorityFee: PriorityFee.fromJson(json['default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default': priorityFee.toJson(),
    };
  }
}

class PriorityFee {
  final int vh;
  final int h;
  final int m;

  PriorityFee({
    required this.vh,
    required this.h,
    required this.m,
  });

  factory PriorityFee.fromJson(Map<String, dynamic> json) {
    return PriorityFee(
      vh: json['vh'],
      h: json['h'],
      m: json['m'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vh': vh,
      'h': h,
      'm': m,
    };
  }
}

class SwapResponse {
  final String id;
  final bool success;
  final String version;
  final String? msg;
  final List<SwapTransaction> data;

  SwapResponse({
    required this.id,
    required this.success,
    required this.version,
    this.msg,
    required this.data,
  });

  factory SwapResponse.fromJson(Map<String, dynamic> json) {
    return SwapResponse(
      id: json['id'],
      success: json['success'],
      version: json['version'],
      msg: json['msg'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => SwapTransaction.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'success': success,
      'version': version,
      'msg': msg,
      'data': data.map((tx) => tx.toJson()).toList(),
    };
  }
}

class SwapTransaction {
  final String transaction;

  SwapTransaction({required this.transaction});

  factory SwapTransaction.fromJson(Map<String, dynamic> json) {
    return SwapTransaction(
      transaction: json['transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction,
    };
  }
}
