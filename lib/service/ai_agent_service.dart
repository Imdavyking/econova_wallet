import "package:cryptowallet/coins/starknet_coin.dart";
import "package:cryptowallet/main.dart";
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

//TODO: also allow user to query about starknet
class AIAgentService {
  AIAgentService();
  final memory = ConversationBufferMemory(returnMessages: true);

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

      final balanceTool = Tool.fromFunction<_GetBalanceInput, String>(
        name: 'QUERY_getBalance',
        description: 'Tool for checking user STRK(Starknet) balance',
        inputJsonSchema: const {
          'type': 'object',
          'properties': {
            'address': {
              'type': 'string',
              'description': 'The address to check balance',
            },
          },
          'required': [],
        },
        func: (final _GetBalanceInput toolInput) async {
          String? address = toolInput.address;

          address ??= await starkNetCoins.first.getAddress();

          final result = 'Checking $address balance';
          debugPrint(result);

          final balances = await Future.wait(
            [
              starkNetCoins.first.getUserBalance(
                contractAddress: strkNativeToken,
                address: address,
              ),
              starkNetCoins.first.getUserBalance(
                contractAddress: strkEthNativeToken,
                address: address,
              ),
            ],
          );

          final balanceString = '${balances[0]} STRK, ${balances[1]} ETH';
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
          final result = 'Sending $recipient $amount Tokens';
          debugPrint(result);
          return result;
        },
        getInputFromJson: _GetTransferInput.fromJson,
      );
      final tools = [balanceTool, transferTool];

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

class _GetBalanceInput {
  final String? address;

  _GetBalanceInput({required this.address});

  factory _GetBalanceInput.fromJson(Map<String, dynamic> json) =>
      _GetBalanceInput(
        address: json['address'] as String,
      );
}

// 0x021446826596B924989b7c49Ce5ed8392987cEE8272f73aBc9c016dBB09E3A73
class _GetTransferInput {
  final String recipient;
  final num amount;

  _GetTransferInput({required this.recipient, required this.amount});

  factory _GetTransferInput.fromJson(Map<String, dynamic> json) {
    return _GetTransferInput(
      recipient: json['recipient'] as String,
      amount: json['amount'] as num,
    );
  }
}
