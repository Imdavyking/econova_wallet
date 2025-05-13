// // ignore_for_file: deprecated_member_use_from_same_package
// @TestOn('vm')
// library; // Uses dart:io

import 'package:cryptowallet/utils/app_config.dart';
import 'package:langchain/langchain.dart'
    show AgentExecutor, ConversationBufferMemory, ToolsAgent;
import 'package:langchain_core/prompts.dart';
import 'package:langchain_core/tools.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void testAiAgent() async {
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

  final res = await executor
      .run('What is 40 raised to the 0.43 power with 3 decimals? ');

  print(res);
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
