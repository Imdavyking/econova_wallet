import 'package:wallet_app/utils/app_config.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

abstract class Constants {
  static ChatUser user = ChatUser(id: "1");

  static ChatUser ai =
      ChatUser(id: "2", firstName: walletName, profileImage: "assets/logo.png");
}
