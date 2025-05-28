// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:image/image.dart' as img;
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
  final ImagePicker _picker = ImagePicker();

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
      debugPrint('${error.errorMsg} - ${error.permanent}');
    });
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    _micAnimationController.repeat(reverse: true);
  }

  void _stopListening() async {
    isListening.value = false;
    await _speechToText.stop();
    _micAnimationController.stop();
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    super.dispose();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.trim().isNotEmpty && isListening.value) {
      chatController.setText(result.recognizedWords);
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<ChatMedia> createImageMedia(String data, String? mimeType) async {
    final isExternal = Uri.tryParse(data)?.hasScheme ?? false;

    String imageUrl;
    if (isExternal) {
      imageUrl = data;
    } else {
      final bytes = base64Decode(data);
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File(filePath).writeAsBytes(bytes);
      imageUrl = file.path;
    }

    return ChatMedia(
      url: imageUrl,
      fileName: 'image.jpg',
      type: MediaType.image,
      customProperties: {'mimeType': mimeType},
    );
  }

  Future<void> loadHistory() async {
    if (messages.isNotEmpty) return;
    final List<ChatMessageWithDate> savedMessages =
        await AIAgentService.loadSavedMessages();

    if (savedMessages.isNotEmpty) {
      for (final savedMessage in savedMessages) {
        final message = savedMessage.message;
        if (message.runtimeType == lang_chain.HumanChatMessage) {
          final content = (message as lang_chain.HumanChatMessage).content;

          List<ChatMedia> medias = [];
          String text = '';

          if (content is lang_chain.ChatMessageContentText) {
            text = content.text;
          } else if (content is lang_chain.ChatMessageContentImage) {
            medias.add(await createImageMedia(content.data, content.mimeType));
          } else if (content is lang_chain.ChatMessageContentMultiModal) {
            for (final part in content.parts) {
              if (part is lang_chain.ChatMessageContentText) {
                text += part.text;
              } else if (part is lang_chain.ChatMessageContentImage) {
                medias.add(await createImageMedia(part.data, part.mimeType));
              }
            }
          }

          messages.add(
            ChatMessage(
              user: Constants.user,
              createdAt: DateTime.now(),
              text: text,
              medias: medias,
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
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.add_a_photo,
                    color: appPrimaryColor,
                  ),
                  onSelected: (String value) {
                    if (typingUsers.isEmpty) {
                      if (value == 'camera') {
                        _pickAndShowImageDialog(source: ImageSource.camera);
                      } else if (value == 'gallery') {
                        _pickAndShowImageDialog();
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'camera',
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt, color: appPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(color: appPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'gallery',
                      child: Row(
                        children: [
                          Icon(Icons.image, color: appPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(color: appPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
          showTraillingBeforeSend: true,
        ),
        onSend: _handleOnSendPressed,
        messages: messages,
      ),
    );
  }

  Future<void> _pickAndShowImageDialog({
    ImageSource source = ImageSource.gallery,
  }) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      if (!mounted) return;

      final result = await context.showImageCaptionDialog(image);

      result.fold<void>(
        (error) => context.showErrorMessage(error),
        (right) async {
          await _sendImageMessage(image: right.image, caption: right.caption);
        },
      );
    }
  }

  Future<void> _sendImageMessage({
    required XFile image,
    required String caption,
  }) async {
    final XFile(:mimeType, :name, :path) = image;

    // Read image file bytes
    final fileBytes = await File(path).readAsBytes();

    // Decode image
    final originalImage = img.decodeImage(fileBytes);
    if (originalImage == null) {
      throw Exception("Invalid image file");
    }

    // Resize image (adjust width as needed)
    final resizedImage = img.copyResize(originalImage, height: 500);

    // Compress image to JPEG with quality 70
    final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

    final tempDir = await getTemporaryDirectory();
    final compressedPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    final compressedFile =
        await File(compressedPath).writeAsBytes(compressedBytes);

    final userMessage = ChatMessage(
      user: Constants.user,
      createdAt: DateTime.now(),
      text: caption,
      medias: [
        ChatMedia(
          url: compressedFile.path,
          fileName: name,
          type: MediaType.image,
          customProperties: {
            "mimeType": mimeType,
          },
        ),
      ],
    );

    _addUserMessage(userMessage);

    final response = await _chatRepository.sendImageMessage(userMessage);

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

  void _handleOnSendPressed(ChatMessage textMessage) async {
    _stopListening();
    chatController.setText('');
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
