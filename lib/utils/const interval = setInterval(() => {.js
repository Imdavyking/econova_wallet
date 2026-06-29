const interval = setInterval(() => {
  if (window.isFlutterInAppWebViewReady) {
    clearInterval(interval);
    window.ZkBridgeReady = {
      postMessage: (msg) =>
        window.flutter_inappwebview.callHandler("ZkBridgeReady", msg),
    };
    window.ZkBridge = {
      postMessage: (msg) =>
        window.flutter_inappwebview.callHandler("ZkBridge", msg),
    };
  }
}, 100);
