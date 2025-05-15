import "dart:convert";

import "package:cryptowallet/coins/starknet_coin.dart";
import 'package:cryptowallet/interface/coin.dart';
import "package:cryptowallet/main.dart";
import "package:cryptowallet/utils/rpc_urls.dart";
import "package:flutter/material.dart";
import "package:langchain/langchain.dart";
import "package:cryptowallet/screens/navigator_service.dart";
import "./ai_confirm_transaction.dart";
import "./ai_agent_service.dart";

class AItools {
  static Coin coin = starkNetCoins.first;
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
    final currentCoin = "${coin.getName().split('(')[0]} (${coin.getSymbol()})";
    final addressTool = Tool.fromFunction<_GetAddressInput, String>(
      name: 'QRY_getAddress',
      description: 'Tool for getting current user address,',
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
        final result = 'The address for $domainName is $address';
        return result;
      },
      getInputFromJson: _GetDomainNameInput.fromJson,
    );

    final getTokenPriceTool = Tool.fromFunction<_GetTokenPriceInput, String>(
      name: 'QRY_getTokenPrice',
      description: 'Tool for checking $currentCoin price',
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
          Map allCryptoPrice = jsonDecode(
            await getCryptoPrice(skipNetworkRequest: true),
          ) as Map;

          final Map cryptoMarket = allCryptoPrice[coinGeckoId];

          final currPrice = cryptoMarket['usd'] as num;
          return 'the price for $coinGeckoId is $currPrice';
        } catch (e) {
          debugPrint('Error getting token price: $e');
          return 'Failed to get price for $coinGeckoId';
        }
      },
      getInputFromJson: _GetTokenPriceInput.fromJson,
    );

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
            'description': 'The token address',
          },
        },
        'required': ['address', 'tokenAddress'],
      },
      func: (final _GetBalanceInput toolInput) async {
        String walletAddress = toolInput.walletAddress;
        String tokenAddress = toolInput.tokenAddress;
        Coin token = coin;

        if (AIAgentService.defaultCoinTokenAddress != tokenAddress) {
          token = getAllBlockchains.firstWhere((token) =>
              token.getExplorer() == coin.getExplorer() &&
              token.tokenAddress() == tokenAddress);
        }

        debugPrint("${token.getSymbol()} balance check");

        try {
          coin.validateAddress(walletAddress);
        } catch (e) {
          return 'Invalid $currentCoin address: $walletAddress';
        }
        final result = 'Checking $walletAddress $tokenAddress balance';
        debugPrint(result);

        final coinBal = await token.getUserBalance(address: walletAddress);

        final balanceString =
            '$walletAddress have $coinBal ${token.getSymbol()}';
        return balanceString;
      },
      getInputFromJson: _GetBalanceInput.fromJson,
    );
    final transferTool = Tool.fromFunction<_GetTransferInput, String>(
      name: 'CMD_transferBalance',
      description:
          'Transfers $currentCoin to a recipient. Always check the user’s balance before transferring.',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'recipient': {
            'type': 'string',
            'description': 'The recipient to send token to',
          },
          'amount': {
            'type': 'number',
            'description': 'The amount to transfer',
          },
          'tokenAddress': {
            'type': 'string',
            'description': 'The token address',
          },
        },
        'required': ['recipient', 'amount', 'tokenAddress'],
      },
      func: (final _GetTransferInput toolInput) async {
        final recipient = toolInput.recipient.trim();
        final amount = toolInput.amount;
        final tokenAddress = toolInput.tokenAddress;

        if (recipient.isEmpty) {
          return 'Recipient address is empty.';
        }

        if (amount <= 0) {
          return 'Amount must be greater than zero.';
        }

        Coin token = coin;

        if (AIAgentService.defaultCoinTokenAddress != tokenAddress) {
          token = getAllBlockchains.firstWhere((token) =>
              token.getExplorer() == coin.getExplorer() &&
              token.tokenAddress() == tokenAddress);
        }

        final message =
            'You are about to send $amount ${token.getSymbol()} to $recipient on $currentCoin.';

        try {
          coin.validateAddress(recipient);
        } catch (e) {
          debugPrint('Address validation failed: $e');
          return 'Invalid recipient address: $recipient';
        }

        final confirmation = await confirmTransaction(message);
        if (confirmation != null) {
          return confirmation; // User cancelled or rejected confirmation
        }

        try {
          final txHash =
              await token.transferToken(amount.toString(), recipient);

          if (txHash == null || txHash.isEmpty) {
            return '${token.getSymbol()} Transaction failed: no transaction hash returned.';
          }

          final successMessage =
              'Sent $amount tokens to $recipient on ${token.getSymbol()}.\nTransaction hash: $txHash ${coin.formatTxHash(txHash)}';
          debugPrint(successMessage);
          return successMessage;
        } catch (e) {
          debugPrint('Transfer failed: $e');
          return 'An error occurred during the transfer: $e';
        }
      },
      getInputFromJson: _GetTransferInput.fromJson,
    );

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
          return 'Quote price for $tokenIn => $tokenOut $amount is ${Quote.fromJson(jsonDecode(quote)).quoteAmount}';
        } catch (e) {
          return 'Failed to get quote for $tokenIn => $tokenOut $amount';
        }
      },
      getInputFromJson: _GetSwapInput.fromJson,
    );

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
                  : tokenIn;
          final tokenOutSymbol =
              tokenOut == AIAgentService.defaultCoinTokenAddress
                  ? coin.getSymbol()
                  : tokenOut;

          final message =
              'You are about to swap $amount $tokenInSymbol for $tokenOutSymbol. You will get ${jsonDecode(quote)['buyAmount']}';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) {
            return confirmation;
          }

          String? txHash = await coin.swapTokens(tokenIn, tokenOut, amount);
          if (txHash == null) {
            return 'Swapping not available for this now $tokenIn => $tokenOut $amount';
          }
          return 'Swapped $tokenIn => $tokenOut $amount $txHash';
        } catch (e, stackTrace) {
          print('Error: $e');
          print('StackTrace: $stackTrace');
          return 'Swapping not available for this now $tokenIn => $tokenOut $amount';
        }
      },
      getInputFromJson: _GetSwapInput.fromJson,
    );

    final stakeTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_stakeToken',
      description: 'Tool for staking token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'string',
            'description': 'The amount to stake',
          },
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;

        try {
          final message = 'You are about to stake $amount $currentCoin';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) {
            return confirmation;
          }
          final txHash = await coin.stakeToken(amount);
          if (txHash == null) {
            return 'Failed to get stake $amount $currentCoin';
          }

          return 'Staked $amount $currentCoin $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Staking failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    final unstakeTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_stakeToken',
      description: 'Tool for unstaking token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'string',
            'description': 'The amount to unstake',
          },
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;

        try {
          final message = 'You are about to unStake $amount $currentCoin';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) {
            return confirmation;
          }
          final txHash = await coin.unstakeToken(amount);
          if (txHash == null) {
            return 'Failed to get unstake $amount $currentCoin';
          }

          return 'Unstaked $amount $currentCoin $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'UnStaking failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    final stakeRewardsTool = Tool.fromFunction<_GetStakeRewardsInput, String>(
      name: 'QRY_getStakeRewards',
      description:
          'Tool for getting the users current staked rewards they can claim',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {},
        'required': [],
      },
      func: (final _GetStakeRewardsInput toolInput) async {
        final errMsg =
            'Failed to get staked rewards for ${await coin.getAddress()}';
        try {
          final stakeRewards = await coin.getStakedRewards();
          if (stakeRewards == null) {
            return errMsg;
          }

          return 'Your staked rewards are $stakeRewards $currentCoin';
        } catch (e) {
          return errMsg;
        }
      },
      getInputFromJson: _GetStakeRewardsInput.fromJson,
    );

    final claimRewardsTool = Tool.fromFunction<_GetStakeInput, String>(
      name: 'CMD_claimRewards',
      description: 'Tool for claiming staked token',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'amount': {
            'type': 'string',
            'description': 'The amount to claims as staking rewards',
          },
        },
        'required': ['amount'],
      },
      func: (final _GetStakeInput toolInput) async {
        String amount = toolInput.amount;

        try {
          final message =
              'You are about to claim $amount $currentCoin rewards for staking';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) {
            return confirmation;
          }
          final txHash = await coin.claimRewards(amount);
          if (txHash == null) {
            return 'Failed to get claim $amount $currentCoin token rewards';
          }

          return 'Claimed staked rewards $amount $currentCoin $txHash ${coin.formatTxHash(txHash)}';
        } catch (e) {
          return 'Claim rewards failed for $currentCoin $amount $e';
        }
      },
      getInputFromJson: _GetStakeInput.fromJson,
    );

    final switchCoinTool = Tool.fromFunction<_GetSwitchCoin, String>(
      name: 'CMD_switchCoin',
      description: 'Tool for switching to another coin',
      inputJsonSchema: const {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name of the coin to switch to',
          },
          'default': {
            'type': 'string',
            'description': 'The default symbol of the coin to switch to',
          },
        },
        'required': ['name', 'default'],
      },
      func: (final _GetSwitchCoin toolInput) async {
        String name = toolInput.name;
        String default_ = toolInput.default_;

        try {
          final message = 'You are about to switch to $name ($default_)';
          final confirmation = await confirmTransaction(message);
          if (confirmation != null) {
            return confirmation;
          }
          coin = getAllBlockchains
              .firstWhere((Coin value) => value.getSymbol() == default_);

          return 'Switched to $name $default_';
        } catch (e) {
          return 'Switching failed for $currentCoin $name $default_ $e';
        }
      },
      getInputFromJson: _GetSwitchCoin.fromJson,
    );

    return [
      addressTool,
      resolveDomainNameTool,
      balanceTool,
      transferTool,
      getQuote,
      swapTool,
      getTokenPriceTool,
      stakeTool,
      switchCoinTool,
      unstakeTool,
      claimRewardsTool,
      stakeRewardsTool,
    ];
  }
}

class _GetDomainNameInput {
  final String domainName;

  _GetDomainNameInput({required this.domainName});

  factory _GetDomainNameInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getDomainNameInput: $json');
    return _GetDomainNameInput(
      domainName: json['domainName'] as String,
    );
  }
}

class _GetTokenPriceInput {
  final String coinGeckoId;

  _GetTokenPriceInput({required this.coinGeckoId});

  factory _GetTokenPriceInput.fromJson(Map<String, dynamic> json) {
    return _GetTokenPriceInput(
      coinGeckoId: json['coinGeckoId'] as String,
    );
  }
}

class _GetAddressInput {
  _GetAddressInput();

  factory _GetAddressInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getBalanceInput: $json');
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

  _GetStakeInput({
    required this.amount,
  });

  factory _GetStakeInput.fromJson(Map<String, dynamic> json) {
    return _GetStakeInput(
      amount: json['amount'] as String,
    );
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
  final num amount;

  _GetTransferInput({
    required this.recipient,
    required this.amount,
    required this.tokenAddress,
  });

  factory _GetTransferInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getTransferInput: $json');
    return _GetTransferInput(
      recipient: json['recipient'] as String,
      tokenAddress: json['tokenAddress'] as String,
      amount: json['amount'] as num,
    );
  }
}
