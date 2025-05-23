// ignore_for_file: library_private_types_in_public_api

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:wallet_app/extensions/build_context_extension.dart';
import 'package:wallet_app/extensions/chat_message_ext.dart';
import 'package:wallet_app/service/ai_agent_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:pinput/pinput.dart';
import "../utils/ai_agent_utils.dart";
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import "package:langchain/langchain.dart" as lang_chain;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIAgent extends StatefulWidget {
  final String referralAddress;
  const AIAgent({super.key, this.referralAddress = zeroAddress});

  @override
  _AIAgent createState() => _AIAgent();
}

class _AIAgent extends State<AIAgent>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<ChatMessage> messages = <ChatMessage>[];
  List<ChatUser> typingUsers = [];
  var isMobiletPlatform = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  final AIAgentService _chatRepository = AIAgentService();
  lang_chain.ConversationBufferMemory memory = AIAgentService.memory;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool speechEnabled = false;
  late AppLocalizations localization;
  late AnimationController _micAnimationController;
  late Animation<double> _micScaleAnimation;
  TextEditingController chatController = TextEditingController();
  ValueNotifier<bool> isListening = ValueNotifier(false);

  @override
  initState() {
    super.initState();
    _initSpeech();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _micScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );
    loadHistory();
  }

  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize(onStatus: (status) {
      isListening.value = status == 'listening';
    }, onError: (error) {
      isListening.value = false;
      setState(() {});
    });
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    _micAnimationController.repeat(reverse: true);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    _micAnimationController.stop();
    setState(() {});
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    super.dispose();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.trim().isNotEmpty) {
      chatController.setText(result.recognizedWords);
    }
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
          textController: chatController,
          trailing: [
            if (isMobiletPlatform)
              ValueListenableBuilder(
                valueListenable: isListening,
                builder: (context, value, child) {
                  return IconButton(
                    icon: value
                        ? ScaleTransition(
                            scale: _micScaleAnimation,
                            child: const Icon(
                              Icons.mic,
                              color: appPrimaryColor,
                            ),
                          )
                        : const Icon(
                            Icons.mic_off,
                            color: appPrimaryColor,
                          ),
                    onPressed: !value ? _startListening : _stopListening,
                  );
                },
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
    _stopListening();
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
