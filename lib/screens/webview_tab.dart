import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:wallet_app/api/notification_api.dart';
import 'package:pinput/pinput.dart';
import '../main.dart';
import '../service/wallet_connect_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/web_notifications.dart';
import '../handlers/base_handler.dart';
import '../handlers/crypto_handler.dart';
import '../handlers/ethereum_handler.dart';
import '../handlers/multiversx_handler.dart';
import '../handlers/near_handler.dart';
import '../handlers/solana_handler.dart';
import '../handlers/stacks_handler.dart';
import '../handlers/starknet_handler.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class WebViewTab extends StatefulWidget {
  final String? url;
  final int? windowId;
  final String provider;
  final String init;
  final String? data;
  final String webNotifier;

  final Function() onStateUpdated;
  final Function(CreateWindowAction) onCreateTabRequested;
  final Function() onCloseTabRequested;

  // ── Accessors forwarded to state ──────────────────────────────────────────

  String? get currentUrl =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.url;
  bool? get isSecure =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.isSecure;
  InAppWebViewController? get controller =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.controller;
  TextEditingController? get browserController =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.browserController;
  Uint8List? get screenshot =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.screenshot;
  String? get title =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.title;
  Favicon? get favicon =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.favicon;

  const WebViewTab({
    GlobalKey? key,
    required this.url,
    required this.onStateUpdated,
    required this.onCloseTabRequested,
    required this.onCreateTabRequested,
    required this.data,
    required this.provider,
    required this.webNotifier,
    required this.init,
    this.windowId,
  }) : super(key: key);

  @override
  State<WebViewTab> createState() => _WebViewTabState();

  Future<void> updateScreenshot() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)
          ?.updateScreenshot();
  Future<void> pause() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.pause();
  Future<void> resume() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.resume();
  Future<bool> canGoBack() async =>
      await ((key as GlobalKey).currentState as _WebViewTabState?)
          ?.canGoBack() ??
      false;
  Future<void> goBack() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.goBack();
  Future<bool> canGoForward() async =>
      await ((key as GlobalKey).currentState as _WebViewTabState?)
          ?.canGoForward() ??
      false;
  Future<void> goForward() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.goForward();
  Future<void> readloadWeb3_() async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)?.reloadWeb3_();
  Future<void> switchWeb3(int chainId, String rpc) async =>
      ((key as GlobalKey).currentState as _WebViewTabState?)
          ?.switchWeb3_(chainId, rpc);
}

// ─── State ────────────────────────────────────────────────────────────────────

class _WebViewTabState extends State<WebViewTab> with WidgetsBindingObserver {
  // ── Public accessors used by WebViewTab getters ───────────────────────────
  InAppWebViewController? controller;
  final browserController = TextEditingController();
  Uint8List? screenshot;
  String url = '';
  bool isSecure = false;
  String title = '';
  Favicon? favicon;

  // ── Private state ─────────────────────────────────────────────────────────
  final ValueNotifier<double> _progress = ValueNotifier(0);
  String _initJs = '';
  final _jsonNotification =
      jsonEncode(WebNotificationPermissionDb.getPermissions());
  WebNotificationController? _webNotificationController;
  late List<UserScript> _webNotification;

  final ReceivePort _port = ReceivePort();
  final _httpAuthUsername = TextEditingController();
  final _httpAuthPassword = TextEditingController();
  late PullToRefreshController _pullToRefreshController;
  final _findInteraction = FindInteractionController();
  final List<ContentBlocker> _contentBlockers = [];

  InAppWebViewSettings get _settings => InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        isFraudulentWebsiteWarningEnabled: true,
        safeBrowsingEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        useOnDownloadStart: true,
        useHybridComposition: true,
        resourceCustomSchemes: ['wc'],
        forceDark: Theme.of(context).brightness == Brightness.dark
            ? ForceDark.ON
            : ForceDark.OFF,
      );

  // ── Handlers ──────────────────────────────────────────────────────────────
  late final EthereumHandler _ethHandler;
  late final SolanaHandler _solHandler;
  late final CryptoHandler _cryptoHandler;
  late final MultiversxHandler _multiversxHandler;
  late final NearHandler _nearHandler;
  late final StarknetHandler _starknetHandler;
  late final StacksHandler _stacksHandler;

  List<BaseWebViewHandler> get _allHandlers => [
        _cryptoHandler,
        _multiversxHandler,
        _nearHandler,
        _starknetHandler,
        _stacksHandler,
      ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initJs = widget.init;

    _webNotification = [
      UserScript(
        source: widget.webNotifier,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
      UserScript(
        source: '''
(function(window) {
  var db = $_jsonNotification;
  if (db[window.location.host] === 'granted') {
    Notification._permission = 'granted';
  }
})(window);
''',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ];

    // Initialise handlers (controller set later in onWebViewCreated)
    _ethHandler = EthereumHandler(
      context: context,
      onSwitchChain: (chainId, rpc) => setupWebViewWalletBridge(chainId, rpc),
    );
    _solHandler = SolanaHandler(context: context);
    _cryptoHandler = CryptoHandler(
      context: context,
      ethHandler: _ethHandler,
      solHandler: _solHandler,
    );
    _multiversxHandler = MultiversxHandler(context: context);
    _nearHandler = NearHandler(context: context);
    _starknetHandler = StarknetHandler(context: context);
    _stacksHandler = StacksHandler(context: context);

    WidgetsBinding.instance.addObserver(this);
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      final id = data[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;
      if (kDebugMode) print('Download $id: $progress%');
      if (status == DownloadTaskStatus.complete) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Download $id completed!')));
      }
    });

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: reloadWeb3_,
    );

    FlutterDownloader.registerCallback(_downloadCallback);
    url = widget.url ?? '';
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  @override
  void dispose() {
    controller = null;
    WidgetsBinding.instance.removeObserver(this);
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _httpAuthUsername.dispose();
    _httpAuthPassword.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (state == AppLifecycleState.resumed) {
      resume();
      controller?.resumeTimers();
    } else {
      pause();
      controller?.pauseTimers();
    }
  }

  // ── WebView callbacks ─────────────────────────────────────────────────────

  Future<void> _onWebViewCreated(InAppWebViewController ctrl) async {
    controller = ctrl;
    await _changeUserAgent();
    await _blockAds(false);

    _webNotificationController = WebNotificationController(ctrl);

    // Register notification handlers
    ctrl.addJavaScriptHandler(
      handlerName: 'Notification.requestPermission',
      callback: (_) async =>
          (await _onNotificationRequestPermission()).name.toLowerCase(),
    );
    ctrl.addJavaScriptHandler(
      handlerName: 'Notification.show',
      callback: (args) =>
          _onShowNotification(WebNotification.fromJson(args[0], ctrl)),
    );
    ctrl.addJavaScriptHandler(
      handlerName: 'Notification.close',
      callback: (args) => _onCloseNotification(args[0] as int),
    );

    // Attach all blockchain handlers and keep context fresh
    for (final h in _allHandlers) {
      h.context = context;
      h.attach(ctrl);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Keep handler contexts fresh on rebuilds
    for (final h in _allHandlers) {
      h.context = context;
    }

    return Column(children: [
      Expanded(
        child: Stack(children: [
          Container(color: Colors.white),
          InAppWebView(
            findInteractionController: _findInteraction,
            pullToRefreshController: _pullToRefreshController,
            initialUrlRequest:
                URLRequest(url: WebUri(widget.data ?? walletURL)),
            initialSettings: _settings,
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: widget.provider + _initJs,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
              ..._webNotification,
            ]),
            onWebViewCreated: _onWebViewCreated,
            onPermissionRequest: _onPermissionRequest,
            onUpdateVisitedHistory: (_, newUrl, __) {
              if (newUrl != null) {
                url = newUrl.toString();
                browserController.setText(url);
                widget.onStateUpdated();
              }
            },
            onDownloadStartRequest: (_, req) =>
                _tryDownloadFile('${req.url}', req.suggestedFilename),
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
            onLoadResourceWithCustomScheme: _onCustomScheme,
            onLoadStart: _onLoadStart,
            onTitleChanged: (_, t) {
              title = t ?? '';
              widget.onStateUpdated();
            },
            onProgressChanged: (_, progress) {
              if (mounted) {
                _progress.value = progress / 100;
                if (progress == 100) _pullToRefreshController.endRefreshing();
              }
            },
            onLoadStop: _onLoadStop,
            onConsoleMessage: (_, msg) {
              if (kDebugMode &&
                  !msg.toString().contains('externalDetectWallets')) {
                print(msg);
              }
            },
            onReceivedHttpAuthRequest: _onHttpAuth,
          ),
          ValueListenableBuilder(
            valueListenable: _progress,
            builder: (_, value, __) => _progress.value < 1.0
                ? LinearProgressIndicator(value: _progress.value)
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    ]);
  }

  // ── InAppWebView event handlers ───────────────────────────────────────────

  Future<PermissionResponse> _onPermissionRequest(
      InAppWebViewController _, PermissionRequest request) async {
    final resources = <PermissionResourceType>[];
    if (request.resources.contains(PermissionResourceType.CAMERA)) {
      if (!(await Permission.camera.request()).isDenied) {
        resources.add(PermissionResourceType.CAMERA);
      }
    }
    if (request.resources.contains(PermissionResourceType.MICROPHONE)) {
      if (!(await Permission.microphone.request()).isDenied) {
        resources.add(PermissionResourceType.MICROPHONE);
      }
    }
    if (request.resources
        .contains(PermissionResourceType.CAMERA_AND_MICROPHONE)) {
      if (!(await Permission.camera.request()).isDenied &&
          !(await Permission.microphone.request()).isDenied) {
        resources.add(PermissionResourceType.CAMERA_AND_MICROPHONE);
      }
    }
    return PermissionResponse(
      resources: resources,
      action: resources.isEmpty
          ? PermissionResponseAction.DENY
          : PermissionResponseAction.GRANT,
    );
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController _, NavigationAction action) async {
    final uri = action.request.url!;
    final uriStr = uri.toString();

    if (uriStr.contains('wc?uri=')) {
      await WCService.qrScanHandler(
          Uri.decodeFull(Uri.parse(uriStr).queryParameters['uri']!));
      return NavigationActionPolicy.CANCEL;
    }
    if (uriStr.startsWith('wc:')) {
      await WCService.qrScanHandler(uriStr);
      return NavigationActionPolicy.CANCEL;
    }

    const allowed = [
      'http',
      'https',
      'file',
      'chrome',
      'data',
      'javascript',
      'about'
    ];
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      if ((action.shouldPerformDownload ?? false) &&
          action.request.url != null) {
        _tryDownloadFile('${action.request.url}');
        return NavigationActionPolicy.DOWNLOAD;
      }
    }
    if (!allowed.contains(uri.scheme)) {
      try {
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      } catch (_) {}
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  Future<CustomSchemeResponse?> _onCustomScheme(
      InAppWebViewController ctrl, WebResourceRequest req) async {
    if (req.url.scheme == 'wc') {
      await ctrl.stopLoading();
      await WCService.qrScanHandler('${req.url}');
    }
    return null;
  }

  Future<void> _onLoadStart(InAppWebViewController ctrl, Uri? u) async {
    browserController.setText(u.toString());
    final docTitle = await ctrl.getTitle();

    List history = [
      {'url': u.toString(), 'title': docTitle}
    ];
    final saved = pref.get(historyKey);
    if (saved != null) history.addAll(jsonDecode(saved as String) as List);
    history.length = maximumBrowserHistoryToSave;

    favicon = null;
    title = '';
    url = u.toString();
    isSecure = urlIsSecure(u!);
    widget.onStateUpdated();
    await pref.put(historyKey, jsonEncode(history));
  }

  Future<void> _onLoadStop(InAppWebViewController ctrl, Uri? u) async {
    await updateScreenshot();
    _pullToRefreshController.endRefreshing();
    if (u != null) {
      final cert = await ctrl.getCertificate();
      url = u.toString();
      isSecure = cert != null || urlIsSecure(u);
    }
    try {
      final favicons = await controller?.getFavicons();
      if (favicons != null && favicons.isNotEmpty) {
        for (final f in favicons) {
          if (favicon == null || (f.width ?? 0) > (favicon?.width ?? 0)) {
            favicon = f;
          }
        }
      }
    } catch (_) {}
    if (mounted) widget.onStateUpdated();
  }

  Future<HttpAuthResponse> _onHttpAuth(
      InAppWebViewController _, URLAuthenticationChallenge challenge) async {
    var action = HttpAuthResponseAction.CANCEL;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(challenge.protectionSpace.host),
          TextField(
            decoration: const InputDecoration(labelText: 'Username'),
            controller: _httpAuthUsername,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            controller: _httpAuthPassword,
            obscureText: true,
          ),
        ]),
        actions: [
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              action = HttpAuthResponseAction.CANCEL;
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('Ok'),
            onPressed: () {
              action = HttpAuthResponseAction.PROCEED;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    return HttpAuthResponse(
      username: _httpAuthUsername.text.trim(),
      password: _httpAuthPassword.text,
      action: action,
      permanentPersistence: true,
    );
  }

  // ── Notification helpers ──────────────────────────────────────────────────

  Future<WebNotificationPermission> _onNotificationRequestPermission() async {
    final u = await controller!.getUrl();
    if (u != null) {
      final saved = WebNotificationPermissionDb.getPermission(u.host);
      if (saved != null) return saved;
    }
    if (!context.mounted || !mounted) return WebNotificationPermission.DEFAULT;

    final permission = await showDialog<WebNotificationPermission>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('${u?.host} wants to show notifications'),
            actions: [
              ElevatedButton(
                child: const Text('Deny'),
                onPressed: () =>
                    Navigator.pop(context, WebNotificationPermission.DENIED),
              ),
              ElevatedButton(
                child: const Text('Grant'),
                onPressed: () =>
                    Navigator.pop(context, WebNotificationPermission.GRANTED),
              ),
            ],
          ),
        ) ??
        WebNotificationPermission.DENIED;

    if (u != null) {
      await WebNotificationPermissionDb.savePermission(u.host, permission);
    }
    return permission;
  }

  void _onShowNotification(WebNotification notification) async {
    _webNotificationController?.notifications[notification.id] = notification;
    Uri? iconUrl = notification.icon.trim().isNotEmpty
        ? Uri.tryParse(notification.icon)
        : null;
    if (iconUrl != null && !iconUrl.hasScheme) {
      iconUrl =
          Uri.tryParse('${await controller?.getUrl()}${iconUrl.toString()}');
    }
    await NotificationApi.showNotification(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      imageUrl: iconUrl?.toString(),
      onclick: (_) async => notification.dispatchClick(),
      onclose: () async => notification.close(),
    );
    final vibrate = notification.vibrate;
    if ((await Vibration.hasVibrator()) && vibrate.isNotEmpty) {
      if (vibrate.length.isOdd) vibrate.add(0);
      final intensities = [
        for (int i = 0; i < vibrate.length; i++)
          (i.isEven && vibrate[i] > 0) ? 255 : 0
      ];
      await Vibration.vibrate(pattern: vibrate, intensities: intensities);
    }
  }

  void _onCloseNotification(int id) async {
    final n = _webNotificationController?.notifications[id];
    await NotificationApi.closeNotification(id: id);
    if (n != null) {
      _webNotificationController?.notifications.remove(id);
    }
  }

  // ── User agent / ad-blocking ──────────────────────────────────────────────

  Future<void> _changeUserAgent() async {
    final def = await InAppWebViewController.getDefaultUserAgent();
    String? ua;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        ua = def.replaceFirst('; wv)', ')');
        break;
      case TargetPlatform.iOS:
        ua = '$def Safari/604.1';
        break;
      default:
        ua = null;
    }
    await controller?.setSettings(
        settings: InAppWebViewSettings(userAgent: ua));
  }

  Future<void> _blockAds(bool block) async {
    if (!block) return;
    const filters = [
      '.*.doubleclick.net/.*',
      '.*.ads.pubmatic.com/.*',
      '.*.googlesyndication.com/.*',
      '.*.google-analytics.com/.*',
      '.*.adservice.google.*/.*',
      '.*.adbrite.com/.*',
      '.*.exponential.com/.*',
      '.*.quantserve.com/.*',
      '.*.scorecardresearch.com/.*',
      '.*.zedo.com/.*',
      '.*.adsafeprotected.com/.*',
      '.*.teads.tv/.*',
      '.*.outbrain.com/.*',
    ];
    for (final f in filters) {
      _contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: f),
        action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
      ));
    }
    _contentBlockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: '.*'),
      action: ContentBlockerAction(
        type: ContentBlockerActionType.CSS_DISPLAY_NONE,
        selector: '.banner, .banners, .ads, .ad, .advert',
      ),
    ));
    await controller?.setSettings(
        settings: InAppWebViewSettings(contentBlockers: _contentBlockers));
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<void> updateScreenshot() async {
    screenshot = await controller!
        .takeScreenshot(
          screenshotConfiguration: ScreenshotConfiguration(
            compressFormat: CompressFormat.JPEG,
            quality: 20,
          ),
        )
        .timeout(const Duration(milliseconds: 1500), onTimeout: () => null);
  }

  Future<void> pause() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await controller?.setAllMediaPlaybackSuspended(suspended: true);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await controller?.pause();
    }
  }

  Future<void> resume() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await controller?.setAllMediaPlaybackSuspended(suspended: false);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await controller?.resume();
    }
  }

  Future<bool> canGoBack() async => await controller?.canGoBack() ?? false;
  Future<void> goBack() async {
    if (await canGoBack()) await controller?.goBack();
  }

  Future<bool> canGoForward() async =>
      await controller?.canGoForward() ?? false;
  Future<void> goForward() async {
    if (await canGoForward()) await controller?.goForward();
  }

  Future<void> switchWeb3_(int chainId, String rpc) async {
    _initJs = await setupWebViewWalletBridge(chainId, rpc) as String;
    await reloadWeb3_();
  }

  Future<void> reloadWeb3_() async {
    await controller!.removeAllUserScripts();
    await controller!.addUserScripts(userScripts: [
      UserScript(
        source: widget.provider + _initJs,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
      ..._webNotification,
    ]);
    await controller!.reload();
  }

  void _tryDownloadFile(String fileUrl, [String? filename]) {
    final snack = ScaffoldMessenger.of(context);
    snack.clearSnackBars();
    snack.showSnackBar(SnackBar(
      content: Text('Allow download $fileUrl?'),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () => downloadFile(fileUrl, filename),
      ),
    ));
  }
}
