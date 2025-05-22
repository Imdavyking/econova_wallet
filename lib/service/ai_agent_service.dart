import "dart:convert";
import "package:wallet_app/extensions/to_real_json_langchain.dart";
import "package:wallet_app/interface/coin.dart";
import "package:wallet_app/main.dart";
import "package:wallet_app/service/ai_tools.dart";
import "package:wallet_app/service/contact_service.dart";
import "package:wallet_app/utils/all_coins.dart";
import "package:wallet_app/utils/app_config.dart";
import "package:dash_chat_2/dash_chat_2.dart" as dash_chat;
import "package:langchain/langchain.dart" as lang_chain;
import "package:flutter/material.dart";
import "package:langchain/langchain.dart";
import "package:logger/logger.dart";
import "package:langchain_openai/langchain_openai.dart";
import "../utils/ai_agent_utils.dart";
import "../utils/either.dart";
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
  static const defaultCoinTokenAddress = '0xdefault';

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
      await memory.clear();
      for (ChatMessageWithDate savedMessages in convertedMessages.reversed) {
        await memory.chatHistory.addChatMessage(savedMessages.message);
      }
    }

    return messages;
  }

  Future<Either<String, DashChatMessage>> sendTextMessage(
    DashChatMessage chatMessage,
  ) async {
    try {
      final coin = AItools.coin;

      final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
      final currentCoin =
          "name: ${coin.getName().split('(')[0]},symbol: (${coin.getSymbol()}),coinGeckoId: ${coin.getGeckoId()}) default_: ${coin.getDefault()}";
      final llm = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: const ChatOpenAIOptions(
          temperature: 0,
        ),
      );

      final List<String> listFungibleToken = [];

      final otherCoins = supportedChains
          .where((Coin value) {
            if (value.tokenAddress() != null &&
                value.getExplorer() == coin.getExplorer()) {
              final geckoId = value.getGeckoId().isNotEmpty
                  ? 'coinGeckoId: ${value.getGeckoId()}'
                  : '';
              final tokenDescription =
                  'name: ${value.getName().split('(')[0].trim()}, '
                  'symbol: (${value.getSymbol()}) '
                  'on ${coin.getName().split('(')[0]} is ${value.tokenAddress()} '
                  '$geckoId';

              listFungibleToken.add(tokenDescription);

              return false;
            }
            return coinGeckoIDs.contains(value.getGeckoId()) &&
                value.getSymbol() == value.getDefault() &&
                value.badgeImage == null &&
                value != coin;
          })
          .toList()
          .map(
            (token) =>
                "name: ${token.getName().split('(')[0]}, symbol: (${token.getSymbol()}), coinGeckoId: ${token.getGeckoId()}), default_: ${token.getDefault()}",
          )
          .toList()
          .join(',');
      final contacts = ContactService.getContacts().map((contact) {
        final name = contact.name;
        final coin = contact.coin.getDefault();
        final address = contact.address;
        final memo = (contact.memo != null && contact.memo!.isNotEmpty)
            ? ' with memo: ${contact.memo}'
            : '';

        return 'Saved contact "$name" for $coin at address: $address$memo.';
      });

      final prompt = """You are $walletName,
        a smart wallet that allows users to perform transactions,
        and query the blockchain using natural language.
        With your intuitive interface,
        users can seamlessly interact with the blockchain,
        making transactions, checking balances,
        check the current coin is correct or ask the user to switch to the coin needed,
        and querying smart contracts—all through simple, conversational commands.
        $contacts
        current coin is $currentCoin coinGeckoId: ${coin.getGeckoId()} with tokenAddress ${coin.tokenAddress() ?? defaultCoinTokenAddress}.
        ${listFungibleToken.isNotEmpty ? 'current fungible tokens are: ${listFungibleToken.join(',')}' : ''}
        other coins are $otherCoins.
        """;

      debugPrint(prompt);

      final agent = ToolsAgent.fromLLMAndTools(
        llm: llm,
        tools: AItools().getTools(),
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
        await loadSavedMessages();
        return Left(error.message);
      }

      return const Left("Something went wrong. Try again Later.");
    }
  }
}
