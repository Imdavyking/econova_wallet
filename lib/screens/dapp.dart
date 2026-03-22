import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/screens/custom_image.dart';
import 'package:wallet_app/screens/saved_urls.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:wallet_app/screens/webview_tab.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../utils/rpc_urls.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kMaxTabs = 10;

// ── Root widget ───────────────────────────────────────────────────────────────

class Dapp extends StatefulWidget {
  final String provider;
  final String init;
  final String data;
  final String webNotifier;

  const Dapp({
    super.key,
    required this.data,
    required this.provider,
    required this.init,
    required this.webNotifier,
  });

  @override
  State<Dapp> createState() => _DappState();
}

class _DappState extends State<Dapp> with TickerProviderStateMixin {
  bool _showTabSwitcher = false;
  List<WebViewTab> _tabs = [];
  int _currentIndex = 0;
  final _chainId = pref.get(dappChainIdKey);
  late ValueNotifier<EthereumCoin> _coinNotifier;

  // Tab switcher animation
  late AnimationController _tabSwitcherAnim;
  late Animation<double> _tabSwitcherScale;

  @override
  void initState() {
    super.initState();
    _coinNotifier = ValueNotifier<EthereumCoin>(evmFromChainId(_chainId)!);
    _tabs.add(_createTab());

    _tabSwitcherAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _tabSwitcherScale = CurvedAnimation(
      parent: _tabSwitcherAnim,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    try {
      _tabs[_currentIndex].browserController?.dispose();
    } catch (_) {}
    _tabSwitcherAnim.dispose();
    _coinNotifier.dispose();
    super.dispose();
  }

  // ── Tab management ────────────────────────────────────────────────────────

  WebViewTab _createTab({String? url, int? windowId}) {
    WebViewTab? tab;
    tab = WebViewTab(
      key: GlobalKey(),
      url: url ?? walletURL,
      provider: widget.provider,
      init: widget.init,
      webNotifier: widget.webNotifier,
      data: widget.data,
      windowId: windowId,
      onStateUpdated: () => setState(() {}),
      onCloseTabRequested: () {
        if (tab != null) _closeTab(tab!);
      },
      onCreateTabRequested: (action) {
        _addTab(windowId: action.windowId);
      },
    );
    return tab;
  }

  void _addTab({String? url, int? windowId}) {
    if (_tabs.length >= _kMaxTabs) {
      _showMaxTabsSnackbar();
      return;
    }
    _tabs.add(_createTab(url: url, windowId: windowId));
    setState(() {
      _currentIndex = _tabs.length - 1;
      _showTabSwitcher = false;
    });
  }

  void _selectTab(WebViewTab tab) {
    final idx = _tabs.indexOf(tab);
    _tabs[_currentIndex].pause();
    tab.resume();
    setState(() {
      _currentIndex = idx;
      _showTabSwitcher = false;
    });
    _tabSwitcherAnim.reverse();
  }

  void _closeTab(WebViewTab tab) {
    final idx = _tabs.indexOf(tab);
    _tabs.remove(tab);
    if (_currentIndex >= idx && _currentIndex > 0) _currentIndex--;
    if (_tabs.isEmpty) {
      _tabs.add(_createTab());
      _currentIndex = 0;
    }
    setState(() {
      _currentIndex = max(0, min(_tabs.length - 1, _currentIndex));
    });
  }

  void _closeAllTabs() {
    _tabs.clear();
    _tabs.add(_createTab());
    setState(() {
      _currentIndex = 0;
      _showTabSwitcher = false;
    });
    _tabSwitcherAnim.reverse();
  }

  void _toggleTabSwitcher() {
    setState(() => _showTabSwitcher = !_showTabSwitcher);
    if (_showTabSwitcher) {
      _tabSwitcherAnim.forward();
    } else {
      _tabSwitcherAnim.reverse();
    }
  }

  void _showMaxTabsSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Maximum $_kMaxTabs tabs reached'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<bool> _goBack() async {
    final ctrl = _tabs[_currentIndex].controller;
    if (ctrl != null && await ctrl.canGoBack()) {
      ctrl.goBack();
      return true;
    }
    return false;
  }

  Future<bool> _goForward() async {
    final ctrl = _tabs[_currentIndex].controller;
    if (ctrl != null && await ctrl.canGoForward()) {
      ctrl.goForward();
      return true;
    }
    return false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_showTabSwitcher) {
          _toggleTabSwitcher();
        } else if (await _tabs[_currentIndex].canGoBack()) {
          _tabs[_currentIndex].goBack();
        } else {
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: _BrowserAppBar(
          tab: _tabs[_currentIndex],
          coinNotifier: _coinNotifier,
          onBack: _goBack,
          onForward: _goForward,
          onMoreOptions: _showMoreOptions,
          onClose: () => Navigator.pop(context),
        ),
        body: Stack(
          children: [
            // WebView tabs (always rendered for performance)
            IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
            // Tab switcher overlay
            if (_showTabSwitcher)
              ScaleTransition(
                scale: _tabSwitcherScale,
                alignment: Alignment.bottomCenter,
                child: _TabSwitcherOverlay(
                  tabs: _tabs,
                  currentIndex: _currentIndex,
                  onSelect: _selectTab,
                  onClose: _closeTab,
                  onAdd: () => _addTab(),
                  onCloseAll: _closeAllTabs,
                ),
              ),
          ],
        ),
        bottomNavigationBar: _BrowserBottomBar(
          tab: _tabs[_currentIndex],
          tabCount: _tabs.length,
          showingTabSwitcher: _showTabSwitcher,
          onBack: _goBack,
          onForward: _goForward,
          onToggleTabs: _toggleTabSwitcher,
          onReload: () => _tabs[_currentIndex].readloadWeb3_(),
          onHome: () => _tabs[_currentIndex].controller?.loadUrl(
                urlRequest: URLRequest(url: WebUri(walletURL)),
              ),
        ),
      ),
    );
  }

  // ── More options panel ────────────────────────────────────────────────────

  void _showMoreOptions() {
    final localize = AppLocalizations.of(context)!;
    final url = _tabs[_currentIndex].browserController?.text ?? '';

    final bookMark = pref.get(bookMarkKey);
    List savedBookMarks = bookMark != null ? jsonDecode(bookMark) as List : [];
    final bookMarkIndex =
        savedBookMarks.indexWhere((b) => b != null && b['url'] == url);
    final isBookmarked = bookMarkIndex != -1;

    slideUpPanel(
      context,
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              _MenuOption(
                icon: Icons.arrow_back,
                label: localize.back,
                onTap: () async {
                  await _goBack();
                  if (mounted) Navigator.pop(context);
                },
              ),
              _MenuOption(
                icon: Icons.arrow_forward,
                label: localize.forward,
                onTap: () async {
                  await _goForward();
                  if (mounted) Navigator.pop(context);
                },
              ),
              _MenuOption(
                icon: Icons.replay_outlined,
                label: localize.reload,
                onTap: () async {
                  await _tabs[_currentIndex].readloadWeb3_();
                  if (mounted) Navigator.pop(context);
                },
              ),
              _MenuOption(
                icon: Icons.share,
                label: localize.share,
                onTap: () async {
                  await Share.share(url);
                  if (mounted) Navigator.pop(context);
                },
              ),
              _MenuOption(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label:
                    isBookmarked ? localize.removeBookMark : localize.bookMark,
                onTap: () async {
                  if (isBookmarked) {
                    savedBookMarks.removeAt(bookMarkIndex);
                  } else {
                    final title =
                        await _tabs[_currentIndex].controller?.getTitle();
                    savedBookMarks.add({'url': url, 'title': title});
                  }
                  await pref.put(bookMarkKey, jsonEncode(savedBookMarks));
                  if (mounted) Navigator.pop(context);
                },
              ),
              _MenuOption(
                icon: Icons.delete_outline,
                label: localize.clearBrowserCache,
                onTap: () async {
                  await InAppWebViewController.clearAllCache();
                  if (mounted && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              _MenuOption(
                icon: Icons.history,
                label: localize.history,
                onTap: () async {
                  List historyList = [];
                  final saved = pref.get(historyKey);
                  if (saved != null) historyList = jsonDecode(saved) as List;

                  final historyUrl = await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedUrls(
                        localize.history,
                        localize.noHistory,
                        historyKey,
                        data: historyList,
                      ),
                    ),
                  );
                  if (historyUrl != null) {
                    _tabs[_currentIndex].controller?.loadUrl(
                          urlRequest:
                              URLRequest(url: WebUri(historyUrl as String)),
                        );
                  }
                },
              ),
              _MenuOption(
                icon: FontAwesomeIcons.ethereum,
                label: ValueListenableBuilder<EthereumCoin>(
                  valueListenable: _coinNotifier,
                  builder: (_, coin, __) =>
                      Text('${coin.name} (${coin.chainId})'),
                ),
                onTap: () async {
                  final coin = await Navigator.push<Coin>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectBlockchain(
                        filterFn: (c) =>
                            c is EthereumCoin && c.tokenAddress() == null,
                      ),
                    ),
                  );
                  if (coin is EthereumCoin) {
                    await _tabs[_currentIndex]
                        .switchWeb3(coin.chainId, coin.rpc);
                    _coinNotifier.value = coin;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Browser AppBar ────────────────────────────────────────────────────────────

class _BrowserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final WebViewTab tab;
  final ValueNotifier<EthereumCoin> coinNotifier;
  final AsyncCallback onBack;
  final AsyncCallback onForward;
  final VoidCallback onMoreOptions;
  final VoidCallback onClose;

  const _BrowserAppBar({
    required this.tab,
    required this.coinNotifier,
    required this.onBack,
    required this.onForward,
    required this.onMoreOptions,
    required this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;

    return PreferredSize(
      preferredSize: preferredSize,
      child: SafeArea(
        child: SizedBox(
          height: kToolbarHeight + 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                iconSize: 22,
              ),
              Expanded(
                child: _UrlBar(tab: tab, localize: localize),
              ),
              const SizedBox(width: 4),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 38),
                icon: const Icon(Icons.more_vert),
                onPressed: onMoreOptions,
                iconSize: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── URL Bar ───────────────────────────────────────────────────────────────────

class _UrlBar extends StatelessWidget {
  final WebViewTab tab;
  final AppLocalizations localize;

  const _UrlBar({required this.tab, required this.localize});

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      autocorrect: false,
      textInputAction: TextInputAction.search,
      controller: tab.browserController,
      onFieldSubmitted: (value) async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (tab.controller != null) {
          final uri = blockChainToHttps(value.trim());
          await tab.controller!.loadUrl(
            urlRequest: URLRequest(url: WebUri.uri(uri)),
          );
        }
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        filled: true,
        prefixIconConstraints: const BoxConstraints(minWidth: 34, maxWidth: 34),
        suffixIconConstraints: const BoxConstraints(minWidth: 34, maxWidth: 34),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            tab.isSecure == true ? Icons.lock : Icons.lock_open,
            color: tab.isSecure == true ? Colors.green : Colors.red,
            size: 16,
          ),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.cancel, size: 16),
          onPressed: () => tab.browserController?.clear(),
          padding: EdgeInsets.zero,
        ),
        hintText: localize.searchOrEnterUrl,
        focusedBorder: border,
        border: border,
        enabledBorder: border,
      ),
    );
  }
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────

class _BrowserBottomBar extends StatelessWidget {
  final WebViewTab tab;
  final int tabCount;
  final bool showingTabSwitcher;
  final AsyncCallback onBack;
  final AsyncCallback onForward;
  final VoidCallback onToggleTabs;
  final VoidCallback onReload;
  final VoidCallback onHome;

  const _BrowserBottomBar({
    required this.tab,
    required this.tabCount,
    required this.showingTabSwitcher,
    required this.onBack,
    required this.onForward,
    required this.onToggleTabs,
    required this.onReload,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BarButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          _BarButton(icon: Icons.arrow_forward_ios, onTap: onForward),
          _BarButton(
              icon: Icons.home_outlined,
              onTap: () async {
                onHome();
              }),
          _BarButton(
              icon: Icons.refresh,
              onTap: () async {
                onReload();
              }),
          // Tab count badge button
          GestureDetector(
            onTap: onToggleTabs,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: showingTabSwitcher
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color ?? Colors.grey,
                  width: showingTabSwitcher ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$tabCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: showingTabSwitcher
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final AsyncCallback onTap;

  const _BarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// ── Tab switcher overlay ──────────────────────────────────────────────────────

class _TabSwitcherOverlay extends StatelessWidget {
  final List<WebViewTab> tabs;
  final int currentIndex;
  final void Function(WebViewTab) onSelect;
  final void Function(WebViewTab) onClose;
  final VoidCallback onAdd;
  final VoidCallback onCloseAll;

  const _TabSwitcherOverlay({
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
    required this.onClose,
    required this.onAdd,
    required this.onCloseAll,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Text(
                  '${tabs.length} Tab${tabs.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onCloseAll,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Close All'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                  tooltip: 'New Tab',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: tabs.length,
              itemBuilder: (_, i) => _TabCard(
                tab: tabs[i],
                isActive: i == currentIndex,
                onTap: () => onSelect(tabs[i]),
                onClose: () => onClose(tabs[i]),
              ),
            ),
          ),
          // New tab bar at bottom
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('New Tab'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab card ──────────────────────────────────────────────────────────────────

class _TabCard extends StatelessWidget {
  final WebViewTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabCard({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenshot = tab.screenshot;
    final favicon = tab.favicon;
    final title = tab.title ?? '';
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? primaryColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              // Tab header
              Container(
                height: 36,
                color: isActive
                    ? primaryColor.withOpacity(0.12)
                    : Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (favicon != null)
                      CustomImage(
                        url: favicon.url,
                        maxWidth: 14,
                        height: 14,
                      )
                    else
                      const Icon(Icons.language, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title.isEmpty ? 'New Tab' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? primaryColor : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, size: 14),
                    ),
                  ],
                ),
              ),
              // Screenshot preview
              Expanded(
                child: screenshot != null
                    ? Image.memory(
                        screenshot,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.6),
                        child: Center(
                          child: Icon(
                            Icons.web,
                            size: 32,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu option ───────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final dynamic label; // String or Widget
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 14),
            if (label is String) Text(label as String) else label as Widget,
          ],
        ),
      ),
    );
  }
}
