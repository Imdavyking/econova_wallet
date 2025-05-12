import "package:dash_chat_2/dash_chat_2.dart";

extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    ChatUser? user,
    DateTime? createdAt,
    bool? isMarkdown,
    String? text,
    List<ChatMedia>? medias,
    List<QuickReply>? quickReplies,
    Map<String, dynamic>? customProperties,
    List<Mention>? mentions,
    MessageStatus? status,
    ChatMessage? replyTo,
  }) {
    return ChatMessage(
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      isMarkdown: isMarkdown ?? this.isMarkdown,
      text: text ?? this.text,
      medias: medias ?? this.medias,
      quickReplies: quickReplies ?? this.quickReplies,
      customProperties: customProperties ?? this.customProperties,
      mentions: mentions ?? this.mentions,
      status: status ?? this.status,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}
