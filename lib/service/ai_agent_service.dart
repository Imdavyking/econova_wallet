import "dart:convert";
import "dart:io";
import "package:wallet_app/extensions/to_real_json_langchain.dart";
import "package:wallet_app/interface/coin.dart";
import "package:wallet_app/main.dart";
import "package:wallet_app/service/ai_tools.dart";
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

  // ── Coin context ─────────────────────────────────────────────────────────────

  /// Builds the coin context for the bot prompt.
  ///
  /// - [fungibleTokens]  — tokens on the active coin's network.
  ///                       Resolved automatically — user never needs to switch.
  /// - [switchableCoins] — native coins of other blockchains.
  ///                       Require CMD_switchCoin to use.
  static ({
    String currentCoin,
    List<String> fungibleTokens,
    String switchableCoins,
  }) _buildCoinContext() {
    final coin = AItools.coin;

    final currentCoin = 'name: ${coin.getName().split('(')[0]}, '
        'symbol: (${coin.getSymbol()}), '
        'coinGeckoId: ${coin.getGeckoId()}, '
        'default_: ${coin.getDefault()}';

    final List<String> fungibleTokens = [];

    final switchableCoins = supportedChains
        .where((Coin value) {
          // ── Same-network tokens ─────────────────────────────────────────
          // Collect tokens on the active coin's network into fungibleTokens.
          // These are resolved automatically — user never needs to switch.
          if (value.tokenAddress() != null &&
              value.getExplorer() == coin.getExplorer()) {
            final geckoId = value.getGeckoId().isNotEmpty
                ? ', coinGeckoId: ${value.getGeckoId()}'
                : '';
            fungibleTokens.add(
              'name: ${value.getName().split('(')[0].trim()}, '
              'symbol: (${value.getSymbol()}), '
              'tokenAddress: ${value.tokenAddress()}'
              '$geckoId',
            );
            return false; // exclude from switchable coins list
          }

          // ── Switchable networks ─────────────────────────────────────────
          // Only native coins of other networks — not tokens, not the
          // current coin, not badges.
          return coinGeckoIDs.contains(value.getGeckoId()) &&
              value.getSymbol() == value.getDefault() &&
              value.badgeImage == null &&
              value != coin;
        })
        .map((token) => 'name: ${token.getName().split('(')[0]}, '
            'symbol: (${token.getSymbol()}), '
            'coinGeckoId: ${token.getGeckoId()}, '
            'default_: ${token.getDefault()}')
        .join(', ');

    return (
      currentCoin: currentCoin,
      fungibleTokens: fungibleTokens,
      switchableCoins: switchableCoins,
    );
  }

  // ── Bot prompt ───────────────────────────────────────────────────────────────

  static String _buildBotPrompt({
    required String currentCoin,
    required List<String> fungibleTokens,
    required String otherCoins,
    required String tokenAddress,
  }) {
    return '''You are $walletName,
        a smart wallet that allows users to perform transactions,
        and query the blockchain using natural language.
        With your intuitive interface,
        users can seamlessly interact with the blockchain,
        making transactions, checking balances,
        and querying smart contracts — all through simple, conversational commands.
        For sending, always use memo if available.

        ── CURRENT NETWORK ──────────────────────────────────────────────────────
        Active network: $currentCoin
        Native token address: $tokenAddress
        Tokens on this network: ${fungibleTokens.isNotEmpty ? fungibleTokens.join(', ') : 'none'}
        Other available networks: $otherCoins

        ── TOKEN RESOLUTION — NO SWITCHING NEEDED ───────────────────────────────
        Tokens on the current network (e.g. USDC on Solana, USDCX on Stacks,
        BUSD on BNB) are resolved AUTOMATICALLY by CMD_transferBalance and
        CMD_x402Pay. Do NOT use CMD_switchCoin for tokens — only use it to
        switch to a completely different blockchain (e.g. Stacks → Ethereum).

        ⚠️ Use the token address shown above as the true source of identity
        for this coin, especially in testnet or non-standard environments.
        Do NOT rely on known token maps or CoinGecko IDs for address resolution
        — the address given here is authoritative.

        ── x402 PAYMENT PROTOCOL — STRICT RULES ────────────────────────────────
        - When a URL returns 402 Payment Required, use CMD_x402Pay exclusively.
        - NEVER use CMD_transferBalance as a substitute for x402 payments.
        - NEVER send tokens directly to the payTo address as a workaround.
        - x402 is a signed authorization protocol — a direct transfer will NOT
          unlock the resource.
        - Tokens on the current network are resolved automatically inside
          CMD_x402Pay — no coin switch is needed for same-network tokens.
        - Only if CMD_x402Pay returns a network mismatch error (a completely
          different blockchain is required), use CMD_switchCoin then retry
          CMD_x402Pay automatically without asking the user.
        - If CMD_x402Pay fails for any other reason, report it — do NOT retry
          with CMD_transferBalance
        ── PREMIUM DATA FEEDS — x402 GATED ─────────────────────────────────
        $stacksMarketUrl → Full market report for STX, BTC, and ETH.
        Includes price, 1h/24h/7d change, market cap, volume, and ATH.
        Use QRY_httpRequest first. If 402 returned, call CMD_x402Pay automatically.
        Triggers: "market report", "full STX analysis", "how is the market today".
        ── ERROR REPORTING — STRICT ──────────────────────────────────────────
        When a tool returns an error, copy the exact error string to the user
        without any rewording, softening, or summarizing. Show every detail
        including exception type, field names, and nested causes exactly as
        returned. Never replace a specific error with a generic phrase(users should not need to ask for more details).
        ''';
  }

  // ── LLM ─────────────────────────────────────────────────────────────────────

  final llm = ChatOpenAI(
    apiKey: dotenv.env['OPENROUTER_API_KEY'],
    baseUrl: 'https://openrouter.ai/api/v1',
    defaultOptions: const ChatOpenAIOptions(
      temperature: 0,
      model: 'openai/gpt-4o-mini',
    ),
  );

  // ── Message deserialization ──────────────────────────────────────────────────

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
        final List<Map<String, dynamic>> contents =
            (json['content'] as List).cast<Map<String, dynamic>>();

        final List<lang_chain.ChatMessageContent> chatContents = [];

        for (final content in contents) {
          switch (content['type']) {
            case 'text':
              chatContents.add(
                lang_chain.ChatMessageContent.text(content['data'] as String),
              );
              break;
            case 'image':
              chatContents.add(
                lang_chain.ChatMessageContent.image(
                  data: content['data'] as String,
                  mimeType: content['mimeType'] as String? ?? 'image/jpeg',
                ),
              );
              break;
            case 'multi-modal':
              final List<Map<String, dynamic>> parts =
                  (content['data'] as List).cast<Map<String, dynamic>>();

              final parsedParts = parts.map((part) {
                switch (part['type']) {
                  case 'text':
                    return lang_chain.ChatMessageContent.text(
                        part['data'] as String);
                  case 'image':
                    return lang_chain.ChatMessageContent.image(
                      data: part['data'] as String,
                      mimeType: part['mimeType'] as String? ?? 'image/jpeg',
                    );
                  default:
                    return lang_chain.ChatMessageContent.text('Unknown part');
                }
              }).toList();

              chatContents.add(
                lang_chain.ChatMessageContent.multiModal(parsedParts),
              );
              break;

            default:
              chatContents.add(
                lang_chain.ChatMessageContent.text('Unsupported content type'),
              );
          }
        }

        return lang_chain.ChatMessage.human(
          chatContents.length == 1
              ? chatContents.first
              : lang_chain.ChatMessageContent.multiModal(chatContents),
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

  // ── History ──────────────────────────────────────────────────────────────────

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
              DateTime.parse(history['date']),
            ),
          )
          .toList();

      messages.addAll(convertedMessages);
      await memory.clear();
      for (final saved in convertedMessages.reversed) {
        await memory.chatHistory.addChatMessage(saved.message);
      }
    }

    return messages;
  }

  // ── Text message ─────────────────────────────────────────────────────────────

  Future<Either<String, DashChatMessage>> sendTextMessage(
    DashChatMessage chatMessage,
  ) async {
    try {
      final ctx = _buildCoinContext();
      final botPrompt = _buildBotPrompt(
        currentCoin: ctx.currentCoin,
        fungibleTokens: ctx.fungibleTokens,
        otherCoins: ctx.switchableCoins,
        tokenAddress: AItools.coin.tokenAddress() ?? defaultCoinTokenAddress,
      );

      final agent = ToolsAgent.fromLLMAndTools(
        llm: llm,
        tools: AItools().getTools(),
        memory: memory,
        systemChatMessage: SystemChatMessagePromptTemplate(
          prompt: PromptTemplate(
            inputVariables: const {},
            template: botPrompt,
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

  // ── Image message ─────────────────────────────────────────────────────────────

  Future<Either<String, DashChatMessage>> sendImageMessage(
    DashChatMessage chatMessage,
  ) async {
    final medias = chatMessage.medias ?? <DashChatMedia>[];
    final mediaContents = <ChatMessageContent>[];

    try {
      if (medias.isNotEmpty) {
        for (final DashChatMedia(:url, :customProperties) in medias) {
          final isExternal = Uri.tryParse(url)?.hasScheme ?? false;
          final data =
              isExternal ? url : base64Encode(File(url).readAsBytesSync());

          mediaContents.add(
            ChatMessageContent.image(
              mimeType: customProperties?["mimeType"] ?? "image/jpeg",
              data: data,
            ),
          );
        }
      }

      final ctx = _buildCoinContext();
      final botPrompt = _buildBotPrompt(
        currentCoin: ctx.currentCoin,
        fungibleTokens: ctx.fungibleTokens,
        otherCoins: ctx.switchableCoins,
        tokenAddress: AItools.coin.tokenAddress() ?? defaultCoinTokenAddress,
      );

      final history = await memory.loadMemoryVariables();
      final info = ChatMessage.human(
        ChatMessageContent.multiModal([
          ChatMessageContent.text(chatMessage.text),
          ...mediaContents,
        ]),
      );

      final prompt = PromptValue.chat([
        ChatMessage.system('$botPrompt\n$history'),
        info,
      ]);

      final chain = llm.pipe(const StringOutputParser());
      final response = await chain.invoke(prompt);

      await memory.chatHistory.addChatMessage(info);
      await memory.chatHistory.addAIChatMessage(response);
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
      debugPrint("sendImageMessage error: $error, stackTrace: $stackTrace");

      if (error is OpenAIClientException) {
        await loadSavedMessages();
        return Left(error.message);
      }

      return const Left("Something went wrong. Try again Later.");
    }
  }
}
