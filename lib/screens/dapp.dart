import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptowallet/coins/ethereum_coin.dart';
import 'package:cryptowallet/screens/custom_image.dart';
// ignore: unused_import
import 'package:cryptowallet/screens/main_screen.dart';
import 'package:cryptowallet/screens/saved_urls.dart';
import 'package:cryptowallet/screens/select_blockchain.dart';
import 'package:cryptowallet/screens/webview_tab.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:cryptowallet/utils/slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/rpc_urls.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class Dapp extends StatefulWidget {
  final String provider;
  final String init;
  final String data;
  final String webNotifier;
  const Dapp({
    Key? key,
    required this.data,
    required this.provider,
    required this.init,
    required this.webNotifier,
  }) : super(key: key);
  @override
  State<Dapp> createState() => _DappState();
}

class _DappState extends State<Dapp> {
  ValueNotifier loadingPercent = ValueNotifier<double>(0);
  String urlLoaded = '';
  bool showWebViewTabsViewer = false;
  String initJs = '';
  List<WebViewTab> webViewTabs = [];
  int currentTabIndex = 0;
  final chainId = pref.get(dappChainIdKey);
  late ValueNotifier<EthereumCoin> coinNotifier;
  @override
  initState() {
    super.initState();
    coinNotifier = ValueNotifier<EthereumCoin>(evmFromChainId(chainId)!);
    initJs = widget.init;
    webViewTabs.add(createWebViewTab());
  }

  @override
  void dispose() {
    try {
      webViewTabs[currentTabIndex].browserController!.dispose();
    } catch (_) {}
    super.dispose();
  }

  WebViewTab createWebViewTab({String? url, int? windowId}) {
    late WebViewTab? webViewTab;

    if (url == null && windowId == null) {
      url = walletURL;
    }

    webViewTab = WebViewTab(
      key: GlobalKey(),
      url: url!,
      provider: widget.provider,
      init: widget.init,
      webNotifier: widget.webNotifier,
      data: widget.data,
      windowId: windowId,
      onStateUpdated: () {
        setState(() {});
      },
      onCloseTabRequested: () {
        if (webViewTab != null) {
          _closeWebViewTab(webViewTab);
        }
      },
      onCreateTabRequested: (createWindowAction) {
        _addWebViewTab(windowId: createWindowAction.windowId);
      },
    );
    return webViewTab;
  }

  Widget? _buildWebViewTabAppBar() {
    final localize = AppLocalizations.of(context)!;
    final historyTitle = localize.history;
    final historyEmpty = localize.noHistory;
    return PreferredSize(
      child: SafeArea(
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.close,
                ),
              ),
              Flexible(
                child: TextFormField(
                  autocorrect: false,
                  onFieldSubmitted: (value) async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (webViewTabs[currentTabIndex].controller != null) {
                      Uri uri = blockChainToHttps(value.trim());

                      await webViewTabs[currentTabIndex].controller!.loadUrl(
                            urlRequest: URLRequest(url: WebUri.uri(uri)),
                          );
                    }
                  },
                  textInputAction: TextInputAction.search,
                  controller: webViewTabs[currentTabIndex].browserController,
                  decoration: InputDecoration(
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 35, maxWidth: 35),
                    contentPadding: const EdgeInsets.all(0),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 35, maxWidth: 35),
                    prefixIcon: webViewTabs[currentTabIndex].isSecure != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Icon(
                                webViewTabs[currentTabIndex].isSecure == true
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color: webViewTabs[currentTabIndex].isSecure ==
                                        true
                                    ? Colors.green
                                    : Colors.red,
                                size: 18),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8),
                            child: Icon(Icons.lock_open,
                                color: Colors.red, size: 18),
                          ),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.cancel,
                      ),
                      onPressed: () {
                        webViewTabs[currentTabIndex].browserController!.clear();
                      },
                    ),
                    hintText: localize.searchOrEnterUrl,

                    filled: true,
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ), // you
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 35),
                onPressed: () {
                  if (webViewTabs[currentTabIndex].controller == null) return;

                  final bookMark = pref.get(bookMarkKey);
                  final url =
                      webViewTabs[currentTabIndex].browserController!.text;
                  List savedBookMarks = [];

                  if (bookMark != null) {
                    savedBookMarks.addAll(
                      jsonDecode(bookMark) as List,
                    );
                  }
                  final bookMarkIndex = savedBookMarks.indexWhere(
                    (bookmark) => bookmark != null && bookmark['url'] == url,
                  );

                  bool urlBookMarked = bookMarkIndex != -1;
                  slideUpPanel(
                    context,
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  await _goForward();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_forward),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localize.forward,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  await _goBack();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_back),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localize.back,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  if (webViewTabs[currentTabIndex].controller !=
                                      null) {
                                    await webViewTabs[currentTabIndex]
                                        .readloadWeb3_();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.replay_outlined),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localize.reload,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  if (webViewTabs[currentTabIndex].controller !=
                                      null) {
                                    await Share.share(url);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.share),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        localize.share,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                  onTap: () async {
                                    if (urlBookMarked) {
                                      savedBookMarks.removeAt(
                                        bookMarkIndex,
                                      );
                                    } else if (webViewTabs[currentTabIndex]
                                            .controller !=
                                        null) {
                                      final title =
                                          await webViewTabs[currentTabIndex]
                                              .controller!
                                              .getTitle();

                                      savedBookMarks.addAll([
                                        {'url': url, 'title': title}
                                      ]);
                                    }

                                    await pref.put(
                                      bookMarkKey,
                                      jsonEncode(
                                        savedBookMarks,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.bookmark,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          urlBookMarked
                                              ? localize.removeBookMark
                                              : localize.bookMark,
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                  onTap: () async {
                                    if (webViewTabs[currentTabIndex]
                                            .controller !=
                                        null) {
                                      await InAppWebViewController
                                          .clearAllCache();

                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            localize.clearBrowserCache,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  List historyList = [];

                                  final savedHistory = pref.get(historyKey);

                                  if (savedHistory != null) {
                                    historyList =
                                        jsonDecode(savedHistory) as List;
                                  }
                                  final historyUrl =
                                      await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => SavedUrls(
                                        historyTitle,
                                        historyEmpty,
                                        historyKey,
                                        data: historyList,
                                      ),
                                    ),
                                  );

                                  if (historyUrl != null) {
                                    webViewTabs[currentTabIndex]
                                        .controller!
                                        .loadUrl(
                                          urlRequest: URLRequest(
                                            url: WebUri(historyUrl),
                                          ),
                                        );
                                  }
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.history),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          localize.history,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                  onTap: () async {
                                    Coin? coin = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            const SelectBlockchain(
                                          evmOnly: true,
                                        ),
                                      ),
                                    );

                                    if (coin == null) return;

                                    if (coin is EthereumCoin) {
                                      await webViewTabs[currentTabIndex]
                                          .switchWeb3(
                                        coin.chainId,
                                        coin.rpc,
                                      );
                                      coinNotifier.value = coin;
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          const Icon(FontAwesomeIcons.ethereum),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ValueListenableBuilder(
                                            valueListenable: coinNotifier,
                                            builder: (context, value, child) =>
                                                Text(
                                              '${coinNotifier.value.name} (${coinNotifier.value.chainId})',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  return;
                },
                icon: const Icon(
                  Icons.more_vert,
                ),
              )
            ],
          ),
        ),
      ),
      preferredSize: const Size.fromHeight(100),
    );
  }

  Widget _buildWebViewTabs() {
    return IndexedStack(index: currentTabIndex, children: webViewTabs);
  }

  PreferredSize? _buildWebViewTabViewerAppBar() {
    return PreferredSize(
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _addWebViewTab();
                  setState(() {
                    showWebViewTabsViewer = false;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(
                          width: 20,
                        ),
                        Text('New Tab'),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _closeAllWebViewTabs();
                },
                icon: const Icon(Icons.clear_all),
              )
            ],
          ),
        ),
        preferredSize: const Size.fromHeight(150));
  }

  Widget _buildWebViewTabsViewer() {
    return GridView.count(
      crossAxisCount: 2,
      children: webViewTabs.map((webViewTab) {
        return _buildWebViewTabGrid(webViewTab);
      }).toList(),
    );
  }

  Widget _buildWebViewTabGrid(WebViewTab webViewTab) {
    final webViewIndex = webViewTabs.indexOf(webViewTab);

    Uint8List? screenshotData = webViewTab.screenshot;
    Favicon? favicon = webViewTab.favicon;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
          side: currentTabIndex == webViewIndex
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          )),
      child: InkWell(
        onTap: () {
          _selectWebViewTab(webViewTab);
        },
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.black12,
              selected: currentTabIndex == webViewIndex,
              selectedColor: Colors.white,
              selectedTileColor: Colors.black,
              contentPadding: const EdgeInsets.only(left: 10),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: Row(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: favicon != null
                      ? CustomImage(
                          url: favicon.url, maxWidth: 20.0, height: 20.0)
                      : null,
                ),
                Expanded(
                    child: Text(
                  webViewTab.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ))
              ]),
              trailing: IconButton(
                  onPressed: () {
                    _closeWebViewTab(webViewTab);
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  )),
            ),
            Expanded(
                child: Ink(
              decoration: screenshotData != null
                  ? BoxDecoration(
                      image: DecorationImage(
                      image: MemoryImage(screenshotData),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ))
                  : null,
            ))
          ],
        ),
      ),
    );
  }

  void _addWebViewTab({String? url, int? windowId}) {
    webViewTabs.add(createWebViewTab(url: url, windowId: windowId));
    setState(() {
      currentTabIndex = webViewTabs.length - 1;
    });
  }

  void _selectWebViewTab(WebViewTab webViewTab) {
    final webViewIndex = webViewTabs.indexOf(webViewTab);
    webViewTabs[currentTabIndex].pause();
    webViewTab.resume();
    setState(() {
      currentTabIndex = webViewIndex;
      showWebViewTabsViewer = false;
    });
  }

  void _closeWebViewTab(WebViewTab webViewTab) {
    final webViewIndex = webViewTabs.indexOf(webViewTab);
    webViewTabs.remove(webViewTab);
    if (currentTabIndex > webViewIndex) {
      currentTabIndex--;
    }
    if (webViewTabs.isEmpty) {
      webViewTabs.add(createWebViewTab());
      currentTabIndex = 0;
    }
    setState(() {
      currentTabIndex = max(0, min(webViewTabs.length - 1, currentTabIndex));
    });
  }

  void _closeAllWebViewTabs() {
    webViewTabs.clear();
    webViewTabs.add(createWebViewTab());
    setState(() {
      currentTabIndex = 0;
    });
  }

  Future<bool> _goBack() async {
    if (webViewTabs[currentTabIndex].controller != null &&
        await webViewTabs[currentTabIndex].controller!.canGoBack()) {
      webViewTabs[currentTabIndex].controller!.goBack();
      return true;
    }
    return false;
  }

  Future<bool> _goForward() async {
    if (webViewTabs[currentTabIndex].controller != null &&
        await webViewTabs[currentTabIndex].controller!.canGoForward()) {
      webViewTabs[currentTabIndex].controller!.goForward();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final useWidget = showWebViewTabsViewer
        ? _buildWebViewTabViewerAppBar()
        : _buildWebViewTabAppBar();
    return WillPopScope(
      child: Scaffold(
          appBar: useWidget as PreferredSizeWidget?,
          body: IndexedStack(
            index: showWebViewTabsViewer ? 1 : 0,
            children: [_buildWebViewTabs(), _buildWebViewTabsViewer()],
          )),
      onWillPop: () async {
        if (showWebViewTabsViewer) {
          setState(() {
            showWebViewTabsViewer = false;
          });
        } else if (await webViewTabs[currentTabIndex].canGoBack()) {
          webViewTabs[currentTabIndex].goBack();
        } else {
          return true;
        }
        return false;
      },
    );
  }
}
