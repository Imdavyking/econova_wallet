import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> downloadFile(String url, [String? filename]) async {
  var hasStoragePermission = await Permission.storage.isGranted;
  if (!hasStoragePermission) {
    hasStoragePermission = (await Permission.storage.request()).isGranted;
  }
  if (hasStoragePermission) {
    return await FlutterDownloader.enqueue(
      url: url,
      headers: {},
      savedDir: (await getTemporaryDirectory()).path,
      saveInPublicStorage: true,
      fileName: filename,
    );
  }
  return null;
}
