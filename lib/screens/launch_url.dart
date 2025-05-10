import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("Browser Created!");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) print("Started $url");
  }

  @override
  Future onLoadStop(url) async {
    if (kDebugMode) print("Stopped $url");
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    if (kDebugMode) {
      print("Can't load ${request.url}.. Error: ${error.description}");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (kDebugMode) print("Progress: $progress");
  }

  @override
  void onExit() {
    if (kDebugMode) print("Browser closed!");
  }
}

Future<void> launchPageUrl({
  required BuildContext context,
  required String url,
}) async {
  if (url.trim().isEmpty || Uri.tryParse(url) == null) {
    final snack = ScaffoldMessenger.of(context);
    snack.clearSnackBars();
    snack.showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Invalid URL',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
    return;
  }
  final settings = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(
      hideUrlBar: true,
    ),
    webViewSettings: InAppWebViewSettings(
      javaScriptEnabled: true,
      isInspectable: kDebugMode,
    ),
  );
  final browser = MyInAppBrowser();
  await browser.openUrlRequest(
    urlRequest: URLRequest(url: WebUri(url)),
    settings: settings,
  );
}
