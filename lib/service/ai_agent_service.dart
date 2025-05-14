import "dart:convert";

import "package:awesome_dialog/awesome_dialog.dart";
import "package:cryptowallet/coins/starknet_coin.dart";
import "package:cryptowallet/extensions/to_real_json_langchain.dart";
import "package:cryptowallet/main.dart";
import "package:cryptowallet/screens/navigator_service.dart";
import "package:cryptowallet/utils/app_config.dart";
import "package:cryptowallet/utils/rpc_urls.dart";
import "package:dash_chat_2/dash_chat_2.dart" as dash_chat;
import "package:langchain/langchain.dart" as lang_chain;
import "package:flutter/material.dart";
import "package:langchain/langchain.dart";
import "package:langchain_openai/langchain_openai.dart";
import "../utils/ai_agent_utils.dart";
import "../utils/either.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef DashChatMessage = dash_chat.ChatMessage;
typedef DashChatMedia = dash_chat.ChatMedia;

//TODO: also allow user to query about starknet
class AIAgentService {
  AIAgentService();
  static final memory = ConversationBufferMemory(returnMessages: true);
  static const historyKey = 'a823b5ac-51f0-8007-bc48-fa9b1829';

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
  }

  static Future<List<lang_chain.ChatMessage>> loadSavedMessages() async {
    final historyList = pref.get(historyKey);
    final List<lang_chain.ChatMessage> messages = [];
    if (historyList != null) {
      final List historyStore = jsonDecode(historyList);
      for (var history in historyStore) {
        final aiMessage = jsonToLangchainMessage(history);
        messages.add(aiMessage);
        await memory.chatHistory.addChatMessage(aiMessage);
      }
    }
    return messages;
  }

  ///throws error if user didn't approve transaction
  Future<void> authenticateCommand(String message) async {
    final context = NavigationService.navigatorKey.currentContext!;

    bool isApproved = await AwesomeDialog(
      closeIcon: const Icon(
        Icons.close,
      ),
      buttonsTextStyle: const TextStyle(color: Colors.white),
      context: context,
      btnOkColor: appBackgroundblue,
      dialogType: DialogType.info,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Confirm Transaction',
      desc: message,
      showCloseIcon: true,
      btnOkOnPress: () async {
        final confirmTX = await authenticate(
          NavigationService.navigatorKey.currentContext!,
        );
        Navigator.pop(context, confirmTX);
      },
      btnCancelOnPress: () {
        Navigator.pop(context, false);
      },
    ).show();

    if (!isApproved) {
      throw Exception(
        'User did not approve the transaction $message',
      );
    }
  }

  Future<Either<String, DashChatMessage>> sendTextMessage(
    DashChatMessage chatMessage,
  ) async {
    try {
      final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
      final llm = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: const ChatOpenAIOptions(
          temperature: 0,
        ),
      );

      final addressTool = Tool.fromFunction<_GetAddressInput, String>(
        name: 'QRY_getAddress',
        description: 'Tool for getting current user addres',
        inputJsonSchema: const {
          'type': 'object',
          'properties': {},
          'required': [],
        },
        func: (final _GetAddressInput toolInput) async {
          final address = await starkNetCoins.first.getAddress();
          try {
            starkNetCoins.first.validateAddress(address);
          } catch (e) {
            return 'Invalid address: $address';
          }
          return 'user address is $address';
        },
        getInputFromJson: _GetAddressInput.fromJson,
      );
      final balanceTool = Tool.fromFunction<_GetBalanceInput, String>(
        name: 'QRY_getBalance',
        description: 'Tool for checking STRK(Starknet) balance for any address',
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
          String? address = toolInput.address;

          address ??= await starkNetCoins.first.getAddress();

          try {
            starkNetCoins.first.validateAddress(address);
          } catch (e) {
            return 'Invalid address: $address';
          }
          final result = 'Checking $address balance';
          debugPrint(result);

          final balances = await Future.wait(
            [
              starkNetCoins.first.getUserBalance(
                contractAddress: strkNativeToken,
                address: address,
              ),
            ],
          );

          final balanceString = '$address have ${balances[0]} Starknet(STRK)';
          return balanceString;
        },
        getInputFromJson: _GetBalanceInput.fromJson,
      );
      final transferTool = Tool.fromFunction<_GetTransferInput, String>(
        name: 'CMD_transferBalance',
        description: 'Tool for transferring user STRK(Starknet) balance',
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
          final recipient = toolInput.recipient;
          final amount = toolInput.amount;

          final message =
              'Sending $recipient $amount Tokens on ${starkNetCoins.first.name}';
          try {
            starkNetCoins.first.validateAddress(recipient);
          } catch (e) {
            return 'Invalid address recipient: $recipient';
          }

          throw Exception(
            'User did not approve the transaction $message',
          );

          return message;

          // try {
          //
          // } catch (e) {
          //   print('Invalid recipient address: $e');
          // }

          // //TODO: find better way to do Human In The Loop (HITL)
          // await authenticateCommand(message);

          // String? txHash = await starkNetCoins.first.transferToken(
          //   amount.toString(),
          //   recipient,
          // );

          // debugPrint(message);
          // return '$message with transaction hash $txHash';
        },
        getInputFromJson: _GetTransferInput.fromJson,
      );
      final tools = [addressTool, balanceTool, transferTool];

      final agent = ToolsAgent.fromLLMAndTools(
        llm: llm,
        tools: tools,
        memory: memory,
        systemChatMessage: const SystemChatMessagePromptTemplate(
          prompt: PromptTemplate(
            inputVariables: {},
            template: """You are $walletName,
        a smart wallet that allows users to perform transactions,
        and query the blockchain using natural language.
        With your intuitive interface,
        users can seamlessly interact with the blockchain,
        making transactions, checking balances,
        and querying smart contracts—all through simple, conversational commands.""",
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

class _GetAddressInput {
  _GetAddressInput();

  factory _GetAddressInput.fromJson(Map<String, dynamic> json) {
    debugPrint('getBalanceInput: $json');
    return _GetAddressInput();
  }
}

class _GetBalanceInput {
  final String? address;

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
