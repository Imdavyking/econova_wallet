import "package:langchain/langchain.dart" as lang_chain;

extension LangChainExt<T> on lang_chain.ChatMessage {
  Map<String, dynamic> jsonStringify() {
    if (runtimeType == lang_chain.SystemChatMessage) {
      final message = this as lang_chain.SystemChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': contentAsString,
        'date': DateTime.now().toIso8601String(),
      };
    } else if (runtimeType == lang_chain.AIChatMessage) {
      final message = this as lang_chain.AIChatMessage;
      final toolCalls = message.toolCalls;
      return {
        'type': message.runtimeType.toString(),
        'content': contentAsString,
        'date': DateTime.now().toIso8601String(),
        'toolCalls': toolCalls.map((tool) {
          return Map<String, dynamic>.from({
            'id': tool.id,
            'name': tool.name,
            'argumentsRaw': tool.argumentsRaw,
            'arguments': tool.arguments,
          });
        }).toList()
      };
    } else if (runtimeType == lang_chain.HumanChatMessage) {
      final message = this as lang_chain.HumanChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': message.contentAsString,
        'date': DateTime.now().toIso8601String(),
      };
    } else if (runtimeType == lang_chain.ToolChatMessage) {
      final message = this as lang_chain.ToolChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': message.contentAsString,
        'date': DateTime.now().toIso8601String(),
        'toolCallId': message.toolCallId
      };
    } else if (runtimeType == lang_chain.CustomChatMessage) {
      final message = this as lang_chain.CustomChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': message.contentAsString,
        'date': DateTime.now().toIso8601String(),
        'role': message.role
      };
    } else {
      throw Exception('can not convert to json $runtimeType');
    }
  }
}
