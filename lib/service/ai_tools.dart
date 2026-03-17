import "dart:convert";
import 'package:http/http.dart' as http;
import "package:flutter/foundation.dart";
import "package:wallet_app/coins/fungible_tokens/erc_fungible_coin.dart";
import "package:wallet_app/extensions/first_or_null.dart";
import 'package:wallet_app/interface/coin.dart';
import "package:wallet_app/interface/user_quote.dart";
import "package:wallet_app/main.dart";
import "package:wallet_app/service/contact_service.dart";
import "package:wallet_app/service/x402_service.dart";
import "package:wallet_app/utils/ai_agent_utils.dart";
import "package:wallet_app/utils/rpc_urls.dart";
import "package:flutter/material.dart";
import "package:langchain/langchain.dart";
import "package:wallet_app/screens/navigator_service.dart";
import "./ai_confirm_transaction.dart";
import "./ai_agent_service.dart";
import 'package:string_similarity/string_similarity.dart';

class AItools {
  static Coin coin = stackCoins.first;

  AItools();

  Future<String?> confirmTransaction(String message) async {
    final isApproved = await Navigator.push(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => ConfirmTransactionScreen(message: message),
      ),
    );

    if (isApproved == null || isApproved == false) {
      return 'User did not approve $message';
    }

    return null;
  }

  List<Tool> getTools() {
    Constants.user.profileImage = coin.getImage();
    final currentCoin = "${coin.getName().split('(')[0]} (${coin.getSymbol()})";

    // ── QRY_getAddress ──────────────────────────────────────────────────────────

    final addressTool = Tool.fromFunction<_GetAddressInput, String>(
      name: 'QRY_getAddress',
      description: 'Tool for getting current user address.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {},
        'required': [],
      },
      func: (final _GetAddressInput toolInput) async {
        final address = await coin.getAddress();
        try {
          coin.validateAddress(address);
        } catch (e) {
          return 'Invalid $currentCoin address: $address';
        }
        return 'Your $currentCoin address is $address';
      },
      getInputFromJson: _GetAddressInput.fromJson,
    );

    // ── QRY_resolveUserContact ──────────────────────────────────────────────────

    final resolveUserContactTool =
        Tool.fromFunction<_GetContactNameInput, String>(
      name: 'QRY_resolveUsercontact',
      description: 'Tool for resolving user contact to address',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'contactName': {
            'type': 'string',
            'description': 'The contact name to resolve',
          },
        },
        'required': ['contactName'],
      },
      func: (final _GetContactNameInput toolInput) async {
        final contactName = toolInput.contactName;
        final contacts =
            ContactService.getContacts().where((c) => c.coin == coin).toList();

        final exactMatch = contacts.firstWhereOrNull(
          (c) => c.name?.toLowerCase() == contactName.toLowerCase(),
        );

        if (exactMatch != null) {
          final address = exactMatch.address;
          if (address == null || address.isEmpty) {
            return 'Contact "$contactName" has no associated address.';
          }
          try {
            coin.validateAddress(address);
          } catch (e) {
            return 'Invalid address for $coin: $address';
          }
          final hasMemo = exactMatch.memo?.isNotEmpty == true;
          final memoText = hasMemo
              ? ', memo: ${exactMatch.memo!.replaceAll('"', '\\"')}'
              : '';
          return 'The address for "$contactName" on $coin is "$address"$memoText.';
        }

        final contactNames = contacts.map((c) => c.name).toList();
        final bestMatch =
            StringSimilarity.findBestMatch(contactName, contactNames).bestMatch;
        debugPrint('bestMatch: ${bestMatch.target} ${bestMatch.rating}');
        if (bestMatch.rating == null) {
          return 'Contact "$contactName" not found.';
        }
        if (bestMatch.rating! > 0.5) {
          return 'Contact "$contactName" not found. Did you mean "${bestMatch.target}"?';
        } else if (bestMatch.rating! > 0.25) {
          return 'Closest match is "${bestMatch.target}", but similarity is low.';
        } else {
          return 'Contact "$contactName" not found for $coin.';
        }
      },
      getInputFromJson: _GetContactNameInput.fromJson,
    );

    // ── QRY_resolveDomainName ───────────────────────────────────────────────────

    final resolveDomainNameTool =
        Tool.fromFunction<_GetDomainNameInput, String>(
      name: 'QRY_resolveDomainName',
      description: 'Tool for resolving domain name to address',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'domainName': {
            'type': 'string',
            'description': 'The domain name to resolve',
          },
        },
        'required': ['domainName'],
      },
      func: (final _GetDomainNameInput toolInput) async {
        String domainName = toolInput.domainName;
        String? address;
        try {
          address = await coin.resolveAddress(domainName);
          if (address == null) {
            return 'Domain name $domainName not found';
          }
          coin.validateAddress(address);
        } catch (e) {
          return 'Invalid $currentCoin address: $address';
        }
        return 'The address for $domainName is $address';
      },
      getInputFromJson: _GetDomainNameInput.fromJson,
    );

    // ── QRY_getTokenPrice ───────────────────────────────────────────────────────

    final getTokenPriceTool = Tool.fromFunction<_GetTokenPriceInput, String>(
      name: 'QRY_getTokenPrice',
      description: 'Tool for checking $currentCoin price in USD',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'coinGeckoId': {
            'type': 'string',
            'description': 'The coinGeckoId to check price',
          },
        },
        'required': ['coinGeckoId'],
      },
      func: (final _GetTokenPriceInput toolInput) async {
        String coinGeckoId = toolInput.coinGeckoId;
        try {
          debugPrint('coinGeckoId: $coinGeckoId');
          final cryptoPrice = await getCryptoPrice(useCache: true);
          final currPrice = cryptoPrice.getPrice(coinGeckoId);
          if (currPrice == null) return 'Failed to get price for $coinGeckoId';
          return 'the price for $coinGeckoId is $currPrice USD';
        } catch (e) {
          debugPrint('Error getting token price: $e');
          return 'Failed to get price for $coinGeckoId';
        }
      },
      getInputFromJson: _GetTokenPriceInput.fromJson,
    );

    // ── QRY_getBalance ──────────────────────────────────────────────────────────

    final balanceTool = Tool.fromFunction<_GetBalanceInput, String>(
      name: 'QRY_getBalance',
      description: 'Tool for checking $currentCoin balance for any address',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'walletAddress': {
            'type': 'string',
            'description': 'The user wallet address',
          },
          'tokenAddress': {
            'type': 'string',
            'description': 'The token address or symbol',
          },
        },
        'required': ['walletAddress', 'tokenAddress'],
      },
      func: (final _GetBalanceInput toolInput) async {
        final walletAddress = toolInput.walletAddress;
        final tokenAddress = toolInput.tokenAddress;

        // Resolve token silently from current network — no switch needed
        Coin token = coin;
        if (tokenAddress != AIAgentService.defaultCoinTokenAddress) {
          final found = coin.findToken(tokenAddress);
          if (found != null) {
            token = found;
          } else {
            // Not on current network — fall back to searching all chains
            final fallback = supportedChains.firstWhereOrNull((t) =>
                t.tokenAddress() == tokenAddress ||
                t.getSymbol().toLowerCase() == tokenAddress.toLowerCase());
            if (fallback != null) {
              token = fallback;
            } else {
              return 'Token $tokenAddress not found on ${coin.getName()} network.';
            }
          }
        }

        debugPrint("${token.getSymbol()} balance check");

        try {
          coin.validateAddress(walletAddress);
        } catch (e) {
          return 'Invalid $currentCoin address: $walletAddress';
        }

        final coinBal = await token.getUserBalance(address: walletAddress);
        return '$walletAddress has $coinBal ${token.getSymbol()}';
      },
      getInputFromJson: _GetBalanceInput.fromJson,
    );

    // ── CMD_transferBalance ─────────────────────────────────────────────────────

    final transferTool = Tool.fromFunction<_GetTransferInput, String>(
      name: 'CMD_transferBalance',
      description:
          'Transfers tokens to a recipient. Always check the user\'s balance '
          'before transferring. Tokens on the current network (e.g. USDC on '
          'Solana, USDCX on Stacks) are resolved automatically — the user does '
          'not need to switch coins for same-network tokens.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'recipient': {
            'type': 'string',
            'description': 'The recipient address',
          },
          'amount': {
            'type': 'number',
            'description': 'The amount to transfer',
          },
          'memo': {
            'type': 'string',
            'description': 'Optional memo',
          },
          'tokenAddress': {
            'type': 'string',
            'description':
                'The token address or symbol. Use the defaultCoinTokenAddress '
                    'for the native coin.',
          },
        },
        'required': ['recipient', 'amount', 'tokenAddress'],
      },
      func: (final _GetTransferInput toolInput) async {
        final recipient = toolInput.recipient.trim();
        final amount = toolInput.amount;
        final tokenAddress = toolInput.tokenAddress;
        final memo = toolInput.memo;

        if (recipient.isEmpty) return 'Recipient address is empty.';
        if (amount <= 0) return 'Amount must be greater than zero.';

        // ── Resolve token silently from current network ──────────────────────
        // Tokens on the active coin's network are used directly.
        // No network switch is needed for same-network tokens.
        Coin token = coin;
        if (tokenAddress != AIAgentService.defaultCoinTokenAddress) {
          final found = coin.findToken(tokenAddress);
          if (found != null) {
            token = found;
          } else {
            // Not found on current network
            return 'Token $tokenAddress is not available on the ${coin.getName()} network. '
                'Please switch to the correct network first.';
          }
        }

        final networkName = coin.getName().split('(')[0];
        String message =
            'You are about to send $amount ${token.getSymbol()} to $recipient on $networkName.';
        if (memo != null && memo.isNotEmpty && coin.requireMemo()) {
          message += '\n\nMemo: $memo';
        }

        try {
          coin.validateAddress(recipient);
        } catch (e) {
          debugPrint('Address validation failed: $e');
          return 'Invalid recipient address: $recipient';
        }

        final confirmation = await confirmTransaction(message);
        if (confirmation != null) return confirmation;

        try {
          final txHash = await token.transferToken(
            amount.toString(),
            recipient,
            memo: memo,
          );
          if (txHash == null || txHash.isEmpty) {
            return '${token.getSymbol()} Transaction failed: no transaction hash returned.';
          }
          final successMessage =
              'Sent $amount ${token.getSymbol()} to $recipient.\n'
              'Transaction hash: $txHash ${coin.formatTxHash(txHash)}';
          debugPrint(successMessage);
          return successMessage;
        } catch (e) {
          debugPrint('Transfer failed: $e');
          return 'An error occurred during the transfer: $e';
        }
      },
      getInputFromJson: _GetTransferInput.fromJson,
    );

    // ── QRY_getQuote ────────────────────────────────────────────────────────────

    final getQuote = Tool.fromFunction<_GetSwapInput, String>(
      name: 'QRY_getQuote',
      description: 'Tool for getting quote for swapping tokens only',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'tokenIn': {
            'type': 'string',
            'description': 'The address to token to swap from',
          },
          'tokenOut': {
            'type': 'string',
            'description': 'The address to token to swap to',
          },
          'amount': {
            'type': 'string',
            'description': 'The amount to swap',
          },
        },
        'required': ['tokenIn', 'tokenOut', 'amount'],
      },
      func: (final _GetSwapInput toolInput) async {
        String tokenIn = toolInput.tokenIn;
        String tokenOut = toolInput.tokenOut;
        String amount = toolInput.amount;
        try {
          final quote = await coin.getQuote(tokenIn, tokenOut, amount);
          if (quote == null) {
            return 'Failed to get quote for $tokenIn => $tokenOut $amount';
          }
          return 'Quote price for $tokenIn => $tokenOut $amount is ${UserQuote.fromJson(jsonDecode(quote)).quoteAmount}';
        } catch (e) {
          debugPrint('Error getting quote: $e');
          return 'Failed to get quote for $tokenIn => $tokenOut $amount';
        }
      },
      getInputFromJson: _GetSwapInput.fromJson,
    );

    // ── CMD_swapTokens ──────────────────────────────────────────────────────────

    final swapTool = Tool.fromFunction<_GetSwapInput, String>(
      name: 'CMD_swapTokens',
      description: 'Tool for swapping tokens',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'tokenIn': {
            'type': 'string',
            'description': 'The address to token to swap from',
          },
          'tokenOut': {
            'type': 'string',
            'description': 'The address to token to swap to',
          },
          'amount': {
            'type': 'string',
            'description': 'The amount to swap',
          },
        },
        'required': ['tokenIn', 'tokenOut', 'amount'],
      },
      func: (final _GetSwapInput toolInput) async {
        String tokenIn = toolInput.tokenIn;
        String tokenOut = toolInput.tokenOut;
        String amount = toolInput.amount;
        try {
          final quote = await coin.getQuote(tokenIn, tokenOut, amount);
          if (quote == null) {
            return 'Failed to get quote for $tokenIn => $tokenOut $amount';
          }
          final tokenInSymbol =
              tokenIn == AIAgentService.defaultCoinTokenAddress
                  ? coin.getSymbol()
                  : (coin.findToken(tokenIn)?.getSymbol() ?? tokenIn);
          final tokenOutSymbol =
              tokenOut == AIAgentService.defaultCoinTokenAddress
                  ? coin.getSymbol()
                  : (coin.findToken(tokenOut)?.getSymbol() ?? tokenOut);
          final message =
              'You are about to swap $amount $tokenInSymbol for $tokenOutSymbol. '
              'You will get ${UserQuote.fromJson(jsonDecode(quote)).quoteAmount}.';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;

          String? txHash = await coin.swapTokens(tokenIn, tokenOut, amount);
          if (txHash == null) {
            return 'Swapping not available for $tokenIn => $tokenOut $amount';
          }
          return 'Swapped $tokenIn => $tokenOut $amount $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Swapping not available for $tokenIn => $tokenOut $amount';
        }
      },
      getInputFromJson: _GetSwapInput.fromJson,
    );

    // ── CMD_stakeToken ──────────────────────────────────────────────────────────

    final stakeTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_stakeToken',
      description: 'Tool for staking token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {'type': 'string', 'description': 'The amount to stake'},
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;
        try {
          final message = 'You are about to stake $amount $currentCoin';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;
          final txHash = await coin.stakeToken(amount);
          if (txHash == null) return 'Failed to stake $amount $currentCoin';
          return 'Staked $amount $currentCoin $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Staking failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    // ── CMD_unstakeToken ────────────────────────────────────────────────────────

    final unstakeTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_unstakeToken',
      description: 'Tool for unstaking token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {'type': 'string', 'description': 'The amount to unstake'},
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;
        try {
          final message = 'You are about to unstake $amount $currentCoin';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;
          final txHash = await coin.unstakeToken(amount);
          if (txHash == null) return 'Failed to unstake $amount $currentCoin';
          return 'Unstaked $amount $currentCoin $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Unstaking failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    // ── QRY_getStakeRewards ─────────────────────────────────────────────────────

    final stakeRewardsTool = Tool.fromFunction<_GetStakeRewardsInput, String>(
      name: 'QRY_getStakeRewards',
      description: 'Tool for getting current staked rewards',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {},
        'required': [],
      },
      func: (final _GetStakeRewardsInput toolInput) async {
        final errMsg =
            'Failed to get staked rewards for ${await coin.getAddress()}';
        try {
          final stakeRewards = await coin.getTotalStaked();
          if (stakeRewards == null) return errMsg;
          return 'Your staked rewards are $stakeRewards $currentCoin';
        } catch (e) {
          return errMsg;
        }
      },
      getInputFromJson: _GetStakeRewardsInput.fromJson,
    );

    // ── CMD_claimRewards ────────────────────────────────────────────────────────

    final claimRewardsTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_claimRewards',
      description: 'Tool for claiming staked token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'string',
            'description': 'The amount to claim as staking rewards',
          },
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;
        try {
          final message =
              'You are about to claim $amount $currentCoin staking rewards';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;
          final txHash = await coin.claimRewards(amount);
          if (txHash == null)
            return 'Failed to claim $amount $currentCoin rewards';
          return 'Claimed $amount $currentCoin rewards $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Claim rewards failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    // ── CMD_switchCoin ──────────────────────────────────────────────────────────

    final switchCoinTool = Tool.fromFunction<_GetSwitchCoin, String>(
      name: 'CMD_switchCoin',
      description:
          'Switches the active network. Only use this to switch between '
          'different blockchains (e.g. Stacks → Ethereum). Do NOT use this '
          'to switch to a token on the current network — tokens like USDC or '
          'USDCX are resolved automatically on the current network.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name of the network coin to switch to',
          },
          'default': {
            'type': 'string',
            'description': 'The default symbol of the network coin',
          },
        },
        'required': ['name', 'default'],
      },
      func: (final _GetSwitchCoin toolInput) async {
        final name = toolInput.name;
        final default_ = toolInput.default_;
        try {
          final target = supportedChains.firstWhereOrNull(
            (Coin value) =>
                value.getSymbol() == default_ &&
                value.tokenAddress() == null &&
                value.badgeImage == null,
          );

          if (target == null) {
            return 'Network "$name ($default_)" not found. '
                'You can only switch to native network coins.';
          }

          final message = 'You are about to switch to $name ($default_)';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;

          coin = target;
          Constants.user.profileImage = coin.getImage();
          return 'Switched to $name $default_';
        } catch (e) {
          return 'Switching failed for $name $default_: $e';
        }
      },
      getInputFromJson: _GetSwitchCoin.fromJson,
    );

    // ── CMD_deployMeme ──────────────────────────────────────────────────────────

    final deployMeme = Tool.fromFunction<_GetDeployMemeInput, String>(
      name: 'CMD_deployMeme',
      description: 'Tool for deploying a meme token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name of the meme token'
          },
          'symbol': {
            'type': 'string',
            'description': 'The symbol of the meme token'
          },
          'initialSupply': {
            'type': 'string',
            'description': 'The initial supply of the meme token'
          },
        },
        'required': ['name', 'symbol', 'initialSupply'],
      },
      func: (final _GetDeployMemeInput toolInput) async {
        String name = toolInput.name;
        String symbol = toolInput.symbol;
        String initialSupply = toolInput.initialSupply;
        const mininumTotalSupply = 1000000;
        try {
          if (int.parse(initialSupply) < mininumTotalSupply) {
            return 'Initial supply must be greater than $mininumTotalSupply';
          }
          final message =
              'You are about to deploy a meme token with name $name, '
              'symbol $symbol, and initial supply $initialSupply';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;

          final memeData = await coin.deployMemeCoin(
            name: name,
            symbol: symbol,
            initialSupply: initialSupply,
          );

          if (memeData.deployTokenTx == null || memeData.tokenAddress == null) {
            return '❌ Failed to deploy meme token.';
          }

          if (memeData.liquidityTx == null) {
            return '''
⚠️ Liquidity addition failed, but meme token was deployed successfully!

✅ Token Address: ${memeData.tokenAddress}
🔗 Deploy Tx: ${memeData.deployTokenTx!}
🔗 Explorer: ${coin.formatTxHash(memeData.deployTokenTx!)}
''';
          }

          final tokenAddress = memeData.tokenAddress!;
          final dexScreener = coin.getDexScreener(tokenAddress);

          return 'Deployed meme token $name ($symbol) supply $initialSupply. '
              'Token: $tokenAddress. '
              'Liquidity tx: ${memeData.liquidityTx} ${coin.formatTxHash(memeData.liquidityTx!)}. '
              'Deploy tx: ${memeData.deployTokenTx} ${coin.formatTxHash(memeData.deployTokenTx!)}. '
              '${dexScreener ?? ''}';
        } catch (e) {
          if (kDebugMode) print(e);
          return 'Failed to deploy meme token: $e';
        }
      },
      getInputFromJson: _GetDeployMemeInput.fromJson,
    );

    // ── CMD_mintUSDCx ────────────────────────────────────────────────────────────

    final mintUSDCxTool = Tool.fromFunction<_MintUSDCxInput, String>(
      name: 'CMD_mintUSDCx',
      description:
          'Bridges USDC from Ethereum/Sepolia to USDCx on Stacks via xReserve. '
          'Requires the user to be on the Ethereum network with a USDC balance. '
          'Takes ~10-15 minutes after deposit confirmation for USDCx to appear on Stacks. '
          'Always check USDC balance before calling this.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'string',
            'description': 'Amount of USDC to bridge (e.g. "10.00")',
          },
        },
        'required': ['amount'],
      },
      func: (final _MintUSDCxInput input) async {
        final usdcCoin = supportedChains.firstWhereOrNull(
          (c) =>
              c is ERCFungibleCoin &&
              c.getSymbol() == 'USDC' &&
              (c.chainId == 1 || c.chainId == 11155111),
        ) as ERCFungibleCoin?;

        if (usdcCoin == null) {
          return 'USDC not found. Make sure you are on the Ethereum network.';
        }

        final stacksAddress = await stackCoins.first.getAddress();

        final message = 'Bridge ${input.amount} USDC → USDCx on Stacks\n\n'
            'Your Stacks address: $stacksAddress\n'
            'Step 1: Approve USDC spend\n'
            'Step 2: Deposit to xReserve bridge\n\n'
            'USDCx will arrive in ~10-15 minutes.\n\n'
            'Approve?';

        final confirmation = await confirmTransaction(message);
        if (confirmation != null) return confirmation;

        try {
          final (approveTx, depositTx) = await usdcCoin.mintUSDCx(
            stacksRecipient: stacksAddress,
            amount: input.amount,
          );

          print(approveTx);
          print(depositTx);

          return 'Bridge initiated!\n\n'
              '✅ Approve tx: $approveTx\n'
              '✅ Deposit tx: $depositTx\n\n'
              'USDCx will arrive at $stacksAddress in ~10-15 minutes.';
        } catch (e) {
          return 'Bridge failed: $e';
        }
      },
      getInputFromJson: _MintUSDCxInput.fromJson,
    );

    // ── QRY_httpRequest ─────────────────────────────────────────────────────────────

    final httpRequestTool = Tool.fromFunction<_HttpRequestInput, String>(
      name: 'QRY_httpRequest',
      description: 'Make any HTTP request (GET, POST, PUT, DELETE, PATCH). '
          'If the response is 402, use CMD_x402Pay with the same URL.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'url': {'type': 'string'},
          'method': {
            'type': 'string',
            'enum': ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
            'description': 'HTTP method',
          },
          'body': {
            'type': 'string',
            'description': 'Request body as string (optional)',
          },
          'contentType': {
            'type': 'string',
            'description': 'Content-Type header. Defaults to application/json',
          },
          'headers': {
            'type': 'object',
            'description': 'Additional headers as key-value pairs (optional)',
            'additionalProperties': {'type': 'string'},
          },
        },
        'required': ['url', 'method'],
      },
      func: (final _HttpRequestInput input) async {
        try {
          final uri = Uri.parse(input.url);
          final headers = <String, String>{
            'Content-Type': input.contentType ?? 'application/json',
            ...?input.headers,
          };

          final http.Response response;
          switch (input.method.toUpperCase()) {
            case 'GET':
              response = await http.get(uri, headers: headers);
              break;
            case 'POST':
              response =
                  await http.post(uri, headers: headers, body: input.body);
              break;
            case 'PUT':
              response =
                  await http.put(uri, headers: headers, body: input.body);
              break;
            case 'PATCH':
              response =
                  await http.patch(uri, headers: headers, body: input.body);
              break;
            case 'DELETE':
              response =
                  await http.delete(uri, headers: headers, body: input.body);
              break;
            default:
              return 'Unsupported HTTP method: ${input.method}';
          }

          if (response.statusCode == 402) {
            return 'STATUS_402: Payment required. Use CMD_x402Pay with resourceUrl: ${input.url}';
          }
          if (response.statusCode >= 400) {
            return 'HTTP ${response.statusCode}: ${response.body}';
          }

          // Detect content type and return accordingly
          final ct = response.headers['content-type'] ?? '';
          if (ct.contains('application/json')) {
            try {
              // Pretty print JSON so the AI can read it better
              return jsonEncode(jsonDecode(response.body));
            } catch (_) {}
          }
          return response.body;
        } catch (e) {
          return 'Request failed: $e';
        }
      },
      getInputFromJson: _HttpRequestInput.fromJson,
    );

    // ── CMD_x402Pay ─────────────────────────────────────────────────────────────

    final x402PayTool = Tool.fromFunction<_GetX402PayInput, String>(
      name: 'CMD_x402Pay',
      description: 'Pay for a resource using the x402 protocol. '
          'Use when a URL returns 402 Payment Required. '
          'Tokens on the current network are resolved automatically — '
          'the user does not need to switch for same-network tokens. '
          'Only a full network switch (CMD_switchCoin) is needed if the '
          'server requires a completely different blockchain.',
      // ── CMD_x402Pay input schema ─────────────────────────────────────────────────
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'resourceUrl': {
            'type': 'string',
            'description': 'The URL that returned 402',
          },
          'method': {
            'type': 'string',
            'enum': ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
            'description': 'Original HTTP method. Defaults to GET.',
          },
          'body': {
            'type': 'string',
            'description':
                'Original request body to replay after payment (optional)',
          },
        },
        'required': ['resourceUrl'],
      },
      func: (final _GetX402PayInput toolInput) async {
        try {
          final service = X402Service(coin: coin);

          final probeResult = await service.probe(
            toolInput.resourceUrl,
            method: toolInput.method ?? 'GET',
            body: toolInput.body,
          );
          if (probeResult == null) {
            return await service.fetchWithPayment(
              toolInput.resourceUrl,
              method: toolInput.method ?? 'GET',
              body: toolInput.body,
            );
          }

          final message = 'x402 Payment Required\n\n'
              'Resource: ${toolInput.resourceUrl}\n'
              'Amount: ${probeResult.humanReadableAmount}\n'
              'Recipient: ${probeResult.option.payTo}\n'
              'Network: ${probeResult.option.network}\n'
              'Token: ${probeResult.option.asset}\n\n'
              'Approve this payment?';

          final confirmation = await confirmTransaction(message);
          if (confirmation != null) return confirmation;

          return await service.payAndFetch(
            toolInput.resourceUrl,
            probeResult,
            method: toolInput.method ?? 'GET',
            body: toolInput.body,
          );
        } catch (e) {
          return 'x402 payment failed: $e';
        }
      },
      getInputFromJson: _GetX402PayInput.fromJson,
    );

    return [
      mintUSDCxTool,
      httpRequestTool,
      addressTool,
      resolveDomainNameTool,
      balanceTool,
      transferTool,
      getQuote,
      swapTool,
      resolveUserContactTool,
      getTokenPriceTool,
      stakeTool,
      switchCoinTool,
      unstakeTool,
      claimRewardsTool,
      stakeRewardsTool,
      deployMeme,
      x402PayTool,
    ];
  }
}

// ── Input classes ─────────────────────────────────────────────────────────────

class _GetContactNameInput {
  final String contactName;
  _GetContactNameInput({required this.contactName});
  factory _GetContactNameInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getContactNameInput: $json');
    return _GetContactNameInput(contactName: json['contactName'] as String);
  }
}

class _GetDomainNameInput {
  final String domainName;
  _GetDomainNameInput({required this.domainName});
  factory _GetDomainNameInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getDomainNameInput: $json');
    return _GetDomainNameInput(domainName: json['domainName'] as String);
  }
}

class _GetTokenPriceInput {
  final String coinGeckoId;
  _GetTokenPriceInput({required this.coinGeckoId});
  factory _GetTokenPriceInput.fromJson(Map<String, dynamic> json) {
    return _GetTokenPriceInput(coinGeckoId: json['coinGeckoId'] as String);
  }
}

class _GetAddressInput {
  _GetAddressInput();
  factory _GetAddressInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getAddressInput: $json');
    return _GetAddressInput();
  }
}

class _GetBalanceInput {
  final String walletAddress;
  final String tokenAddress;
  _GetBalanceInput({required this.walletAddress, required this.tokenAddress});
  factory _GetBalanceInput.fromJson(Map<String, dynamic> json) {
    return _GetBalanceInput(
      walletAddress: json['walletAddress'] as String,
      tokenAddress: json['tokenAddress'] as String,
    );
  }
}

class _GetSwitchCoin {
  final String name;
  final String default_;
  _GetSwitchCoin({required this.name, required this.default_});
  factory _GetSwitchCoin.fromJson(Map<String, dynamic> json) {
    debugPrint('getSwitchCoin: $json');
    return _GetSwitchCoin(
      name: json['name'] as String,
      default_: json['default'] as String,
    );
  }
}

class _GetStakeRewardsInput {
  _GetStakeRewardsInput();
  factory _GetStakeRewardsInput.fromJson(Map<String, dynamic> json) {
    return _GetStakeRewardsInput();
  }
}

class _GetStakeInput {
  final String amount;
  _GetStakeInput({required this.amount});
  factory _GetStakeInput.fromJson(Map<String, dynamic> json) {
    return _GetStakeInput(amount: json['amount'] as String);
  }
}

class _GetSwapInput {
  final String tokenIn;
  final String tokenOut;
  final String amount;
  _GetSwapInput({
    required this.tokenIn,
    required this.tokenOut,
    required this.amount,
  });
  factory _GetSwapInput.fromJson(Map<String, dynamic> json) {
    return _GetSwapInput(
      tokenIn: json['tokenIn'] as String,
      tokenOut: json['tokenOut'] as String,
      amount: json['amount'] as String,
    );
  }
}

class _GetTransferInput {
  final String recipient;
  final String tokenAddress;
  final String? memo;
  final num amount;
  _GetTransferInput({
    required this.recipient,
    required this.amount,
    required this.memo,
    required this.tokenAddress,
  });
  factory _GetTransferInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getTransferInput: $json');
    return _GetTransferInput(
      recipient: json['recipient'] as String,
      tokenAddress: json['tokenAddress'] as String,
      memo: json['memo'] as String?,
      amount: json['amount'] as num,
    );
  }
}

class _GetDeployMemeInput {
  final String name;
  final String symbol;
  final String initialSupply;
  _GetDeployMemeInput({
    required this.name,
    required this.symbol,
    required this.initialSupply,
  });
  factory _GetDeployMemeInput.fromJson(Map<String, dynamic> json) {
    return _GetDeployMemeInput(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      initialSupply: json['initialSupply'] as String,
    );
  }
}

class _GetX402PayInput {
  final String resourceUrl;
  final String? method;
  final String? body;

  _GetX402PayInput({
    required this.resourceUrl,
    this.method,
    this.body,
  });

  factory _GetX402PayInput.fromJson(Map<String, dynamic> json) {
    return _GetX402PayInput(
      resourceUrl: json['resourceUrl'] as String,
      method: json['method'] as String?,
      body: json['body'] as String?,
    );
  }
}

class _HttpRequestInput {
  final String url;
  final String method;
  final String? body;
  final String? contentType;
  final Map<String, String>? headers;

  _HttpRequestInput({
    required this.url,
    required this.method,
    this.body,
    this.contentType,
    this.headers,
  });

  factory _HttpRequestInput.fromJson(Map<String, dynamic> json) {
    return _HttpRequestInput(
      url: json['url'] as String,
      method: json['method'] as String,
      body: json['body'] as String?,
      contentType: json['contentType'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
    );
  }
}

class _MintUSDCxInput {
  final String amount;
  _MintUSDCxInput({required this.amount});
  factory _MintUSDCxInput.fromJson(Map<String, dynamic> json) {
    return _MintUSDCxInput(
      amount: json['amount'] as String,
    );
  }
}
