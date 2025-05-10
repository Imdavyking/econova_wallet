import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

// Use the icloud storage package
import 'package:icloud_storage/icloud_storage.dart';

const fileContentFileName = 'fileContent';
const privateAppFolderName = 'appDataFolder';

Future<String> getAppPackageName() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.packageName;
}

Future<String> _getContainerID() async {
  final yourAppPackage = await getAppPackageName();
  return '$yourAppPackage.container';
}

class ICloudClient {
  // Downloads the wanted file to the device in the specified folder
  Future<String?> _downloadFileToDevice(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final containerId = await _getContainerID();
      await ICloudStorage.download(
        containerId: containerId,
        relativePath: '$privateAppFolderName/$fileName',
        destinationFilePath: '${directory.path}/$fileName',
        onProgress: (stream) {
          stream.listen(
            (progress) {
              if (kDebugMode) print('Download Progress: $progress');
            },
            onDone: () {
              if (kDebugMode) print('Download done');
            },
            onError: (err) {
              if (kDebugMode) print('Download err: $err');
            },
            cancelOnError: true,
          );
        },
      );
      var created = io.File("${directory.path}/$fileName");
      final contents = await created.readAsString();
      return contents;
    } catch (e) {
      return null;
    }
  }

  // Creates a file with the content, and uploads it to iCloud
  Future<bool> _uploadFileToIcloud(String fileName, {String? content}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      if (content != null) {
        final directory = await getApplicationDocumentsDirectory();
        var created = io.File("${directory.path}/$fileName");
        created.writeAsString(content);
      }
      final containerId = await _getContainerID();
      await ICloudStorage.upload(
          containerId: containerId,
          filePath: "${directory.path}/$fileName",
          destinationRelativePath: '$privateAppFolderName/$fileName',
          onProgress: (stream) {
            stream.listen(
              (progress) {
                if (kDebugMode) print('Upload Progress: $progress');
              },
              onDone: () {
                if (kDebugMode) print('Upload done');
              },
              onError: (err) {
                if (kDebugMode) print('Upload err: $err');
              },
              cancelOnError: true,
            );
          });
      return true;
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      return false;
    }
  }

  // Public client API:
  uploadFile(String fileContent) async {
    try {
      await _uploadFileToIcloud(fileContentFileName, content: fileContent);
      return true;
    } catch (e) {
      return null;
    }
  }

  Future<String?> downloadFile() async {
    try {
      return await _downloadFileToDevice(fileContentFileName);
    } catch (e) {
      return null;
    }
  }
}
