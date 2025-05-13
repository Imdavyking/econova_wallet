import "dart:convert";
import "dart:io";
import "package:cryptowallet/utils/app_config.dart";
import "package:dash_chat_2/dash_chat_2.dart" as dash_chat;
import "package:flutter/foundation.dart";
import "package:langchain/langchain.dart";
import "package:langchain_openai/langchain_openai.dart";
import "../utils/ai_agent.dart";
import "../utils/either.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef DashChatMessage = dash_chat.ChatMessage;
typedef DashChatMedia = dash_chat.ChatMedia;

class AIAgentService {
  AIAgentService();

  static final apiKey = dotenv.env['OPENAI_API_KEY'];

  static final chatModel = ChatOpenAI(
    apiKey: apiKey,
    defaultOptions: const ChatOpenAIOptions(
      model: "gpt-4o",
      temperature: 0,
    ),
  ).bind(ChatOpenAIOptions(tools: [tool]));

  static final tool = Tool.fromFunction<_SearchInput, String>(
    name: 'search',
    description: 'Tool for searching the web.',
    inputJsonSchema: const {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'The query to search for',
        },
        'n': {
          'type': 'number',
          'description': 'The number of results to return',
        },
      },
      'required': ['query'],
    },
    func: (final _SearchInput toolInput) async {
      final n = toolInput.n;
      final res = List<String>.generate(n, (final i) => 'Result ${i + 1}');
      return 'Results:\n${res.join('\n')}';
    },
    getInputFromJson: _SearchInput.fromJson,
  );

  static final memory = ConversationBufferWindowMemory(
    aiPrefix: Constants.ai.firstName ?? AIChatMessage.defaultPrefix,
    humanPrefix: Constants.user.firstName ?? HumanChatMessage.defaultPrefix,
  );

  final aiPrompt = """
        You are $walletName,
        a smart wallet that allows users to perform transactions,
        and query the blockchain using natural language.

        With your intuitive interface,
        users can seamlessly interact with the blockchain,
        making transactions, checking balances,
        and querying smart contracts—all through simple, conversational commands.
          Guidelines for responses:
          - Use **Flutter-specific terminology** and relevant examples wherever
            possible.
          - Provide **clear, step-by-step guidance** for technical topics.
          - Ensure all responses are beautifully formatted in **Markdown**:
              - Use headers (`#`, `##`) to structure content.
              - Highlight important terms with **bold** or *italicized* text.
              - Include inline code (`code`) or code blocks (```language) for
                code snippets.
              - Use lists, tables, and blockquotes for clarity and emphasis.
          - Maintain a friendly, approachable tone.
      
          This is the history of the conversation so far:""";

  Future<Either<String, DashChatMessage>> sendTextMessageV2(
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

      final tool = Tool.fromFunction<_SearchInput, String>(
        name: 'search',
        description: 'Tool for searching the web.',
        inputJsonSchema: const {
          'type': 'object',
          'properties': {
            'query': {
              'type': 'string',
              'description': 'The query to search for',
            },
            'n': {
              'type': 'number',
              'description': 'The number of results to return',
            },
          },
          'required': ['query'],
        },
        func: (final _SearchInput toolInput) async {
          final n = toolInput.n;
          final res = List<String>.generate(n, (final i) => 'Result ${i + 1}');
          return 'Results:\n${res.join('\n')}';
        },
        getInputFromJson: _SearchInput.fromJson,
      );

      final tools = [tool];

      final memory = ConversationBufferMemory(returnMessages: true);
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

      final response = await executor
          .run('What is 40 raised to the 0.43 power with 3 decimals? ');
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

  Future<Either<String, DashChatMessage>> sendTextMessage(
    DashChatMessage chatMessage,
  ) async {
    try {
      final history = await memory.loadMemoryVariables();

      debugPrint("history: $history");

      var humanMessage = chatMessage.text;

      final prompt = PromptValue.chat([
        ChatMessage.system(
          "$aiPrompt$history",
        ),
        ChatMessage.human(
          ChatMessageContent.text(humanMessage),
        ),
      ]);

      final chain = chatModel.pipe(const StringOutputParser());
      final response = await chain.invoke(prompt);

      debugPrint("response: $response");

      await memory.saveContext(
        inputValues: {"input": humanMessage},
        outputValues: {"output": response},
      );

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

  Future<Either<String, DashChatMessage>> sendImageMessage(
    DashChatMessage chatMessage,
  ) async {
    final medias = chatMessage.medias ?? <DashChatMedia>[];

    final mediaContents = <ChatMessageContent>[];

    try {
      if (medias.isNotEmpty) {
        for (final media in medias) {
          final url = media.url;
          final customProperties = media.customProperties;

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

      final history = await memory.loadMemoryVariables();

      var humanMessage = chatMessage.text;

      final prompt = PromptValue.chat([
        ChatMessage.system(
          "$aiPrompt$history",
        ),
        ChatMessage.human(
          ChatMessageContent.multiModal([
            ChatMessageContent.text(humanMessage),
            ...mediaContents,
          ]),
        ),
      ]);

      final chain = chatModel.pipe(const StringOutputParser());

      final response = await chain.invoke(prompt);

      debugPrint("response: $response");

      await memory.saveContext(
        inputValues: {"input": humanMessage},
        outputValues: {"output": response},
      );

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
        return Left(error.message);
      }

      return const Left("Something went wrong. Try again Later.");
    }
  }
}

class _SearchInput {
  final String query;
  final int n;

  _SearchInput({required this.query, this.n = 3});

  factory _SearchInput.fromJson(Map<String, dynamic> json) => _SearchInput(
        query: json['query'] as String,
        n: json['n'] as int? ?? 3,
      );
}
