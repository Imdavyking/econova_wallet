import 'package:wallet_app/extensions/build_context_extension.dart';
import 'package:wallet_app/extensions/chat_message_ext.dart';
import 'package:wallet_app/service/ai_agent_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import "../utils/ai_agent_utils.dart";
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import "package:langchain/langchain.dart" as lang_chain;

class AIAgent extends StatefulWidget {
  final String referralAddress;
  const AIAgent({Key? key, this.referralAddress = zeroAddress})
      : super(key: key);

  @override
  _AIAgentState createState() => _AIAgentState();
}

class _AIAgentState extends State<AIAgent> with AutomaticKeepAliveClientMixin {
  List<ChatMessage> messages = <ChatMessage>[];
  List<ChatUser> typingUsers = [];
  var isMobiletPlatform = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  final AIAgentService _chatRepository = AIAgentService();
  lang_chain.ConversationBufferMemory memory = AIAgentService.memory;

  late AppLocalizations localization;

  @override
  initState() {
    super.initState();
    loadHistory();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> loadHistory() async {
    if (messages.isNotEmpty) return;
    final List<ChatMessageWithDate> savedMessages =
        await AIAgentService.loadSavedMessages();

    if (savedMessages.isNotEmpty) {
      for (final savedMessage in savedMessages) {
        final message = savedMessage.message;
        if (message.runtimeType == lang_chain.HumanChatMessage) {
          messages.add(
            ChatMessage(
              user: Constants.user,
              text: message.contentAsString,
              createdAt: savedMessage.date,
            ),
          );
        } else if (message.runtimeType == lang_chain.AIChatMessage) {
          messages.add(
            ChatMessage(
              user: Constants.ai,
              text: message.contentAsString,
              createdAt: savedMessage.date,
              isMarkdown: true,
            ),
          );
        }
      }

      if (messages.isNotEmpty && mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(localization.clearHistory),
                    content: Text(localization.clearHistoryDescription),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(localization.ok),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(localization.back),
                      ),
                    ],
                  );
                },
              );

              if (result == true) {
                await AIAgentService.clearSavedMessages();
                setState(() {
                  messages = [];
                });
              }
            },
          ),
        ],
      ),
      body: DashChat(
        typingUsers: typingUsers,
        currentUser: Constants.user,
        messageOptions: const MessageOptions(
          timeTextColor: Colors.white,
          showTime: true,
          showCurrentUserAvatar: true,
          showOtherUsersAvatar: true,
          containerColor: Color.fromRGBO(127, 76, 222, 0.8),
          showOtherUsersName: true,
        ),
        inputOptions: InputOptions(
          trailing: [
            if (isMobiletPlatform)
              IconButton(
                icon: const Icon(
                  Icons.mic,
                  color: appPrimaryColor,
                ),
                onPressed: () {},
              ),
          ],
          inputDecoration: InputDecoration(
            hintText: "${localization.hi}, I am $walletName",
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide.none,
            ),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide.none,
            ), // you
            filled: true,
          ),
          inputDisabled: typingUsers.isNotEmpty,
          sendOnEnter: true,
          alwaysShowSend: true,
        ),
        onSend: _handleOnSendPressed,
        messages: messages,
      ),
    );
  }

  void _handleOnSendPressed(ChatMessage textMessage) async {
    final userMessage = textMessage.copyWith(
      user: Constants.user,
      createdAt: DateTime.now(),
    );

    _addUserMessage(userMessage);

    final response = await _chatRepository.sendTextMessage(userMessage);

    setState(() {
      typingUsers.remove(Constants.ai);
    });

    response.fold<void>(
      (error) => _handleSendError(error: error, userMessage: userMessage),
      (chatMessage) => _handleSendSuccess(
        userMessage: userMessage,
        aiMessage: chatMessage,
      ),
    );
  }

  void _addUserMessage(ChatMessage message) {
    setState(() {
      typingUsers.add(Constants.ai);
      messages.insert(0, message);
    });
  }

  void _handleSendError({
    required String error,
    required ChatMessage userMessage,
  }) {
    context.showErrorMessage(error);
  }

  void _handleSendSuccess({
    required ChatMessage userMessage,
    required ChatMessage aiMessage,
  }) {
    setState(() {
      messages = [
        aiMessage,
        ...messages.map((m) {
          if (m.user.id == userMessage.user.id &&
              m.createdAt == userMessage.createdAt) {
            return m;
          }
          return m;
        }),
      ];
    });
  }
}
