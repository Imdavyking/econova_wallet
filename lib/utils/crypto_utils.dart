import 'dart:async';
import 'dart:convert' hide Encoding;
import 'dart:io';
import 'dart:math';
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
import 'package:wallet_app/coins/cosmos_coin.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/coins/polkadot_coin.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import 'app_config.dart';

// ── Semaphore ──────────────────────────────────────────────────────────────
// class _Semaphore {
//   final int max;
//   int _active = 0;
//   final _queue = <Completer<void>>[];

//   _Semaphore(this.max);

//   Future<T> run<T>(Future<T> Function() task) async {
//     if (_active >= max) {
//       final waiter = Completer<void>();
//       _queue.add(waiter);
//       await waiter.future;
//     }
//     _active++;
//     try {
//       return await task();
//     } finally {
//       _active--;
//       if (_queue.isNotEmpty) _queue.removeAt(0).complete();
//     }
//   }
// }

Future<void> reInstianteSeedRoot() async {
  final params = WalletService.getActiveKey(WalletType.bip39PhraseOrSeedHex);
  if (params == null) return;
  seedPhraseRoot = await compute(seedFromMnemonic, params.data);
}

Future<void> importAllKeys(String mnemonic) async {
  // ── dedup ────────────────────────────────────────────────────────────────
  final seenCosmosPaths = <String>{};
  final seenPolkadotPaths = <String>{};
  final seenEvmCoinTypes = <int>{};

  final chains = supportedChains.where((c) {
    if (c.tokenAddress() != null) return false;
    if (c is EthereumCoin) return seenEvmCoinTypes.add(c.coinType);
    if (c is CosmosCoin) return seenCosmosPaths.add(c.path);
    if (c is PolkadotCoin) return seenPolkadotPaths.add(c.path);
    return true;
  }).toList();

  // ── batch: 10 at a time, wait for each batch to fully finish ─────────────
  const batchSize = 10;
  final failed = <String>[];

  debugPrint('chainsL ${chains.length}');

  for (var i = 0; i < chains.length; i += batchSize) {
    final batch = chains.skip(i).take(batchSize).toList();

    debugPrint('── batch ${i ~/ batchSize + 1} start ──');
    final batchSw = Stopwatch()..start();

    final results = await Future.wait(
      batch.map((coin) async {
        final sw = Stopwatch()..start();
        try {
          final result = await coin.importData(mnemonic);
          debugPrint('✓ ${coin.getName()} ${sw.elapsedMilliseconds}ms');
          return result;
        } catch (e) {
          debugPrint('✗ ${coin.getName()} ${sw.elapsedMilliseconds}ms — $e');
          return null;
        }
      }),
      eagerError: false,
    );

    await Coin.flushCache();

    debugPrint(
        '── batch ${i ~/ batchSize + 1} done ${batchSw.elapsedMilliseconds}ms ──');

    batch.indexed
        .where((e) => results[e.$1] == null)
        .forEach((e) => failed.add(e.$2.getName()));
  }

  if (failed.isNotEmpty) {
    debugPrint('Import failed for: ${failed.join(', ')}');
  }
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
    btnCancelColor: appBackgroundblue.withOpacity(0.5),
    btnOkColor: Colors.blue,
    btnCancelOnPress: () async {
      final file = await ImagePicker().pickImage(source: ImageSource.camera);
      if (file == null) return;
      onSelect(file);
    },
    btnOkOnPress: () async {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      onSelect(file);
    },
  ).show();
}

String generateSessionId([int length = 16]) {
  final rand = Random.secure();
  final bytes = Uint8List.fromList(
    List.generate(length, (_) => rand.nextInt(256)),
  );

  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

({Uint8List priv, Uint8List pub}) generateKeyPair() {
  final domain = ECDomainParameters('secp256k1');
  final seed = Uint8List.fromList(
    List.generate(32, (_) => Random.secure().nextInt(256)),
  );
  final rng = FortunaRandom()..seed(KeyParameter(seed));
  final keyGen = ECKeyGenerator()
    ..init(ParametersWithRandom(ECKeyGeneratorParameters(domain), rng));
  final pair = keyGen.generateKeyPair();

  final priv = pair.privateKey as ECPrivateKey;
  final pub = pair.publicKey as ECPublicKey;

  // private key → 32 bytes
  final privHex = priv.d!.toRadixString(16).padLeft(64, '0');
  final privBytes = Uint8List.fromList(
    List.generate(
        32, (i) => int.parse(privHex.substring(i * 2, i * 2 + 2), radix: 16)),
  );

  // public key → compressed 33 bytes
  final pubBytes = pub.Q!.getEncoded(true);

  return (priv: privBytes, pub: pubBytes);
}
