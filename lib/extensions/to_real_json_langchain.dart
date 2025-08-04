import "package:langchain/langchain.dart" as lang_chain;

extension LangChainExt<T> on lang_chain.ChatMessage {
  // Helper to serialize a HumanChatMessage with full content detail
  Map<String, dynamic> humanChatMessageToJson(
      lang_chain.HumanChatMessage message) {
    final content = message.content;

    // Recursive parser for multimodal content
    List<Map<String, dynamic>> parseContentParts(
        List<lang_chain.ChatMessageContent> parts) {
      return parts.map((part) {
        if (part is lang_chain.ChatMessageContentText) {
          return {
            'type': 'text',
            'data': part.text,
          };
        } else if (part is lang_chain.ChatMessageContentImage) {
          return {
            'type': 'image',
            'data': part.data,
            'mimeType': part.mimeType,
          };
        } else if (part is lang_chain.ChatMessageContentMultiModal) {
          return {
            'type': 'multi-modal',
            'data': parseContentParts(part.parts),
          };
        } else {
          return {
            'type': 'unknown',
            'data': part.toString(),
          };
        }
      }).toList();
    }

    // Normalize to a list for consistent parsing
    final parsedContent = content is lang_chain.ChatMessageContentMultiModal
        ? parseContentParts(content.parts)
        : parseContentParts([content]);

    return {
      'type': message.runtimeType.toString(),
      'content': parsedContent,
      'date': DateTime.now().toIso8601String(),
    };
  }

  // Entry point for json stringification of any ChatMessage type
  Map<String, dynamic> jsonStringify() {
    if (this is lang_chain.SystemChatMessage) {
      final message = this as lang_chain.SystemChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': contentAsString,
        'date': DateTime.now().toIso8601String(),
      };
    } else if (this is lang_chain.AIChatMessage) {
      final message = this as lang_chain.AIChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': contentAsString,
        'date': DateTime.now().toIso8601String(),
        'toolCalls': message.toolCalls.map((tool) {
          return {
            'id': tool.id,
            'name': tool.name,
            'argumentsRaw': tool.argumentsRaw,
            'arguments': tool.arguments,
          };
        }).toList(),
      };
    } else if (this is lang_chain.HumanChatMessage) {
      final message = this as lang_chain.HumanChatMessage;
      return humanChatMessageToJson(message);
    } else if (this is lang_chain.ToolChatMessage) {
      final message = this as lang_chain.ToolChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': message.contentAsString,
        'date': DateTime.now().toIso8601String(),
        'toolCallId': message.toolCallId,
      };
    } else if (this is lang_chain.CustomChatMessage) {
      final message = this as lang_chain.CustomChatMessage;
      return {
        'type': message.runtimeType.toString(),
        'content': message.contentAsString,
        'date': DateTime.now().toIso8601String(),
        'role': message.role,
      };
    } else {
      throw Exception('Cannot convert to JSON: $runtimeType');
    }
  }
}
