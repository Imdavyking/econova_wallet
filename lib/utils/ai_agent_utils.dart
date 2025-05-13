import 'package:cryptowallet/utils/app_config.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

abstract class Constants {
  static ChatUser user = ChatUser(id: "1");

  static ChatUser ai = ChatUser(
    id: "2",
    firstName: walletName,
    // profileImage:
    //     "https://storage.googleapis.com/cms-storage-bucket/780e0e64d323aad2cdd5.png",
  );
}
