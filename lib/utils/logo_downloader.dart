import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<String?> downloadLogo(String url, String tokenName) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    // Hash the tokenName + current date to generate unique file name
    final hash = md5.convert(utf8.encode('$tokenName-${DateTime.now().day}')).toString();
    final extension = url.split('.').last.split('?').first; // get file extension
    final fileName = '$hash.$extension';

    // Get local app cache directory
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } catch (_) {
    return null;
  }
}