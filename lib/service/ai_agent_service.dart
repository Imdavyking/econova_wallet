import "dart:convert";
import "package:cryptowallet/extensions/to_real_json_langchain.dart";
import "package:cryptowallet/interface/coin.dart";
import "package:cryptowallet/main.dart";
import "package:cryptowallet/screens/navigator_service.dart";
import "package:cryptowallet/utils/app_config.dart";
import "package:dash_chat_2/dash_chat_2.dart" as dash_chat;
import "package:langchain/langchain.dart" as lang_chain;
import "package:flutter/material.dart";
import "package:langchain/langchain.dart";
import "package:logger/logger.dart";
import "package:langchain_openai/langchain_openai.dart";
import "../utils/ai_agent_utils.dart";
import "../utils/either.dart";
import "./ai_confirm_transaction.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef DashChatMessage = dash_chat.ChatMessage;
typedef DashChatMedia = dash_chat.ChatMedia;

class ChatMessageWithDate {
  final lang_chain.ChatMessage message;
  final DateTime date;

  ChatMessageWithDate(this.message, this.date);
}

class AIAgentService {
  AIAgentService();
  static final memory = ConversationBufferMemory(returnMessages: true);
  static const historyKey = '33221-93d0-8007-8a0f-cd31191';
  static final logger = Logger();

  static lang_chain.ChatMessage jsonToLangchainMessage(
      Map<String, dynamic> json) {
    switch (json['type']) {
      case 'SystemChatMessage':
        return lang_chain.SystemChatMessage(content: json['content']);
      case 'AIChatMessage':
        List<Map<String, dynamic>> toolCalls =
            (json['toolCalls'] as List).cast<Map<String, dynamic>>();

        return lang_chain.AIChatMessage(
          content: json['content'],
          toolCalls: toolCalls.map(
            (tool) {
              return lang_chain.AIChatMessageToolCall(
                arguments: tool['arguments'],
                argumentsRaw: tool['argumentsRaw'],
                id: tool['id'],
                name: tool['name'],
              );
            },
          ).toList(),
        );
      case 'HumanChatMessage':
        return lang_chain.HumanChatMessage(
          content: lang_chain.ChatMessageContent.text(json['content']),
        );
      case 'ToolChatMessage':
        return lang_chain.ToolChatMessage(
          content: json['content'],
          toolCallId: json['toolCallId'],
        );
      case 'CustomChatMessage':
        return lang_chain.CustomChatMessage(
          content: json['content'],
          role: json['role'],
        );
      default:
        throw Exception('can not convert to json');
    }
  }

  static Future<void> saveHistory() async {
    List<lang_chain.ChatMessage> histories =
        await memory.chatHistory.getChatMessages();

    histories = histories.reversed.toList();

    List chatHistoryStore = [];
    if (histories.isNotEmpty) {
      for (final history in histories) {
        chatHistoryStore.add(history.jsonStringify());
      }
      if (chatHistoryStore.isNotEmpty) {
        await pref.put(historyKey, jsonEncode(chatHistoryStore));
      }
    }
  }

  static Future<void> clearSavedMessages() async {
    await pref.delete(historyKey);
    await memory.clear();
  }

  static Future<List<ChatMessageWithDate>> loadSavedMessages() async {
    final historyList = pref.get(historyKey);
    final List<ChatMessageWithDate> messages = [];

    if (historyList != null) {
      final List historyStore = jsonDecode(historyList);

      final convertedMessages = historyStore
          .map(
            (history) => ChatMessageWithDate(
              jsonToLangchainMessage(history),
              DateTime.parse(
                history['date'],
              ),
            ),
          )
          .toList();

      messages.addAll(convertedMessages);

      for (ChatMessageWithDate savedMessages in convertedMessages.reversed) {
        await memory.chatHistory.addChatMessage(savedMessages.message);
      }
    }

    return messages;
  }

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

  Future<Either<String, DashChatMessage>> sendTextMessage(
    DashChatMessage chatMessage,
    Coin coin,
  ) async {
    try {
      final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
      final currentCoin =
          "${coin.getName().split('(')[0]} (${coin.getSymbol()})";
      final llm = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: const ChatOpenAIOptions(
          temperature: 0,
        ),
      );

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

      final balanceTool = Tool.fromFunction<_GetBalanceInput, String>(
        name: 'QRY_getBalance',
        description: 'Tool for checking $currentCoin balance for any address',
        inputJsonSchema: const {
          'type': 'object',
          'properties': {
            'address': {
              'type': 'string',
              'description': 'The address to check balance',
            },
          },
          'required': ['address'],
        },
        func: (final _GetBalanceInput toolInput) async {
          String address = toolInput.address;

          try {
            coin.validateAddress(address);
          } catch (e) {
            return 'Invalid $currentCoin address: $address';
          }
          final result = 'Checking $address balance';
          debugPrint(result);

          final coinBal = await coin.getUserBalance(address: address);

          final balanceString = '$address have $coinBal $currentCoin';
          return balanceString;
        },
        getInputFromJson: _GetBalanceInput.fromJson,
      );
      final transferTool = Tool.fromFunction<_GetTransferInput, String>(
        name: 'CMD_transferBalance',
        description:
            'Tool for transferring user $currentCoin balance,always check for user balance before transfer',
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
          },
          'required': ['recipient', 'amount'],
        },
        func: (final _GetTransferInput toolInput) async {
          final recipient = toolInput.recipient.trim();
          final amount = toolInput.amount;

          if (recipient.isEmpty) {
            return 'Recipient address is empty.';
          }

          if (amount <= 0) {
            return 'Amount must be greater than zero.';
          }

          final message =
              'You are about to send $amount ${coin.getSymbol()} to $recipient on $currentCoin.';

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
                await coin.transferToken(amount.toString(), recipient);

            if (txHash == null || txHash.isEmpty) {
              return '$currentCoin Transaction failed: no transaction hash returned.';
            }

            final successMessage =
                'Sent $amount tokens to $recipient on $currentCoin.\nTransaction hash: $txHash';
            debugPrint(successMessage);
            return successMessage;
          } catch (e) {
            debugPrint('Transfer failed: $e');
            return 'An error occurred during the transfer: $e';
          }
        },
        getInputFromJson: _GetTransferInput.fromJson,
      );
      final tools = [
        addressTool,
        balanceTool,
        transferTool,
        resolveDomainNameTool
      ];
      final otherCoins = getAllBlockchains
          .where((Coin value) =>
              value.getSymbol() == value.getDefault() &&
              value.badgeImage == null &&
              value != coin)
          .toList()
          .map((token) =>
              "${token.getName().split('(')[0]} (${token.getSymbol()})")
          .toList()
          .join(',');

      final prompt = """You are $walletName,
        a smart wallet that allows users to perform transactions,
        and query the blockchain using natural language.
        With your intuitive interface,
        users can seamlessly interact with the blockchain,
        making transactions, checking balances,
        check the current coin is correct or ask the user to switch to the coin needed,
        and querying smart contracts—all through simple, conversational commands.
        current coin is $currentCoin.
        other coins are $otherCoins.
        """;

      debugPrint(prompt);

      final agent = ToolsAgent.fromLLMAndTools(
        llm: llm,
        tools: tools,
        memory: memory,
        systemChatMessage: SystemChatMessagePromptTemplate(
          prompt: PromptTemplate(
            inputVariables: const {},
            template: prompt,
          ),
        ),
      );

      final executor = AgentExecutor(agent: agent);

      final response = await executor.run(chatMessage.text);
      await saveHistory();
      return Right(
        DashChatMessage(
          isMarkdown: true,
          user: Constants.ai,
          createdAt: DateTime.now(),
          text: response,
        ),
      );
    } on Exception catch (error, stackTrace) {
      debugPrint("sendTextMessage error: $error, stackTrace: $stackTrace");

      if (error is OpenAIClientException) {
        return Left(error.message);
      }

      return const Left("Something went wrong. Try again Later.");
    }
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

class _GetAddressInput {
  _GetAddressInput();

  factory _GetAddressInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getBalanceInput: $json');
    return _GetAddressInput();
  }
}

class _GetBalanceInput {
  final String address;

  _GetBalanceInput({required this.address});

  factory _GetBalanceInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getBalanceInput: $json');
    return _GetBalanceInput(
      address: json['address'] as String,
    );
  }
}

// 0x021446826596B924989b7c49Ce5ed8392987cEE8272f73aBc9c016dBB09E3A73
class _GetTransferInput {
  final String recipient;
  final num amount;

  _GetTransferInput({required this.recipient, required this.amount});

  factory _GetTransferInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getTransferInput: $json');
    return _GetTransferInput(
      recipient: json['recipient'] as String,
      amount: json['amount'] as num,
    );
  }
}
