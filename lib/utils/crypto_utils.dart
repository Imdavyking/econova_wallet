import 'dart:convert' hide Encoding;
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sui/utils/sha.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/service/crypto_transaction.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import 'app_config.dart';

Future<void> reInstianteSeedRoot() async {
  final params = WalletService.getActiveKey(WalletType.secretPhrase);
  if (params == null) return;
  seedPhraseRoot = await compute(seedFromMnemonic, params.data);
}

Future<void> importAllKeys(String mnemonic) async {
  await Future.wait(
    supportedChains.map((blockchain) {
      EventBusService.instance
          .fire(SeedPharseInitializationEvent(coin: blockchain));
      return blockchain.importData(mnemonic);
    }),
  );
}

String _getKeys(String password) {
  final hash = sha256(utf8.encode(password));
  return base64.encode(hash);
}

String encryptText(String plainText, String password) {
  final aesEncrKey = encrypt.Key.fromBase64(_getKeys(password));
  final encrypter = Encrypter(AES(aesEncrKey));
  return encrypter.encrypt(plainText, iv: iv).base64;
}

String decryptText(String encrypted, String password) {
  final aesEncrKey = encrypt.Key.fromBase64(_getKeys(password));
  final encrypter = Encrypter(AES(aesEncrKey));
  return encrypter.decrypt(Encrypted.fromBase64(encrypted), iv: iv);
}

Future<void> enableScreenShot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

Future<void> disEnableScreenShot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

Future<String?> upload(
  File imageFile,
  String imagefileName,
  MediaType imageMediaType,
  String uploadURL,
  Map fieldsMap,
) async {
  try {
    final stream = http.ByteStream(imageFile.openRead())..cast();
    final length = await imageFile.length();
    final request = http.MultipartRequest('POST', Uri.parse(uploadURL));
    for (final key in fieldsMap.keys) {
      request.fields[key] = fieldsMap[key];
    }
    request.files.add(http.MultipartFile(
      imagefileName,
      stream,
      length,
      filename: basename(imageFile.path),
      contentType: imageMediaType,
    ));
    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseBody = String.fromCharCodes(responseData);
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      if (kDebugMode) print(responseBody);
      throw Exception(responseBody);
    }
    return responseBody;
  } catch (e) {
    if (kDebugMode) print(e.toString());
    return null;
  }
}

selectImage({
  required BuildContext context,
  required Function(XFile) onSelect,
}) {
  final localization = AppLocalizations.of(context)!;
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    closeIcon: const Icon(Icons.close),
    title: localization.chooseImageSource,
    desc: localization.imageSource,
    showCloseIcon: true,
    btnOkText: localization.gallery,
    btnCancelText: localization.camera,
    btnCancelColor: Colors.blue,
    btnOkColor: Colors.blue,
    btnCancelOnPress: () async {
      final file =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (file == null) return;
      onSelect(file);
    },
    btnOkOnPress: () async {
      final file =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      onSelect(file);
    },
  ).show();
}
