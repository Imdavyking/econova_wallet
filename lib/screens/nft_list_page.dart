import 'dart:async';
import 'package:wallet_app/screens/nft_image_webview.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../service/wallet_service.dart';

// ── Shared data class passed into NftCard ────────────────────────────────────

class NftCardData {
  final String name;
  final String symbol;
  final String balance;
  final String tokenId;
  final String contractAddress;
  final String tokenType;
  final String description;
  final String network;
  final String? imageUrl;

  const NftCardData({
    required this.name,
    required this.symbol,
    required this.balance,
    required this.tokenId,
    required this.contractAddress,
    required this.tokenType,
    required this.description,
    required this.network,
    this.imageUrl,
  });
}

// ── Shared NFT card ───────────────────────────────────────────────────────────

class NftCard extends StatelessWidget {
  final NftCardData data;
  final ScrollController pageController;
  final VoidCallback? onSend; // null → no send button (view-key mode)

  const NftCard({
    super.key,
    required this.data,
    required this.pageController,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final image = data.imageUrl != null ? ipfsTohttp(data.imageUrl!) : null;
    final hasImage = image != null && image.isNotEmpty;

    return SizedBox(
      width: 250,
      height: 300,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: NotificationListener<OverscrollNotification>(
            onNotification: (event) {
              _handleOverscroll(event, pageController);
              return true;
            },
            child: ListView(
              children: [
                // Image
                SizedBox(
                  height: 150,
                  child: hasImage
                      ? NFTImageWebview(imageUrl: image)
                      : Center(
                          child: Text(
                            l.couldNotFetchData,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                // Name
                Text(
                  ellipsify(str: data.name, maxLength: 20),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                // Balance + symbol
                Text(
                  '${ellipsify(str: data.balance)} ${ellipsify(str: data.symbol)}',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Expansion details
                ListTileTheme(
                  dense: true,
                  horizontalTitleGap: 0,
                  minLeadingWidth: 0,
                  contentPadding: EdgeInsets.zero,
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    expandedAlignment: Alignment.centerLeft,
                    title: Text(
                      data.tokenType,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    children: [
                      _NftDetailRow(
                          label: l.tokenId, value: '#${data.tokenId}'),
                      if (data.description.isNotEmpty)
                        _NftDetailRow(
                            label: l.description, value: data.description),
                      _NftDetailRow(
                          label: l.contractAddress,
                          value: data.contractAddress),
                      _NftDetailRow(label: l.network, value: data.network),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                if (onSend != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                            (_) => appBackgroundblue),
                        shape: WidgetStateProperty.resolveWith(
                          (_) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      onPressed: onSend,
                      child: Text(
                        l.send,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleOverscroll(OverscrollNotification event, ScrollController ctrl) {
    if (event.overscroll < 0 && ctrl.offset + event.overscroll <= 0) {
      if (ctrl.offset != 0) ctrl.jumpTo(0);
      return;
    }
    if (ctrl.offset + event.overscroll >= ctrl.position.maxScrollExtent) {
      if (ctrl.offset != ctrl.position.maxScrollExtent) {
        ctrl.jumpTo(ctrl.position.maxScrollExtent);
      }
      return;
    }
    ctrl.jumpTo(ctrl.offset + event.overscroll);
  }
}

// ── Detail row inside expansion tile ─────────────────────────────────────────

class _NftDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _NftDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.fade,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ── Shared NFT page scaffold ──────────────────────────────────────────────────
//
// Supply [fetchNfts] which returns a list of [NftCardData] plus the
// coin-specific send route via [buildCard].

class NftListPage extends StatefulWidget {
  final String title;

  /// Called periodically. Returns the list of NFT card data.
  final Future<List<NftCardData>> Function(bool useCache) fetchNfts;

  /// Builds one card for a given NFT. The caller constructs the coin-specific
  /// send route here.
  final Widget Function(NftCardData data, ScrollController ctrl) buildCard;

  final double cardHeight;

  const NftListPage({
    super.key,
    required this.title,
    required this.fetchNfts,
    required this.buildCard,
    this.cardHeight = 350,
  });

  @override
  State<NftListPage> createState() => _NftListPageState();
}

class _NftListPageState extends State<NftListPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _hasNfts = ValueNotifier(false);
  List<NftCardData> _nfts = [];
  bool _useCache = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(httpPollingDelay, (_) => _fetch());
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _hasNfts.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final nfts = await widget.fetchNfts(_useCache);
      if (_useCache) _useCache = false;
      if (nfts.isNotEmpty) {
        if (!_hasNfts.value) _hasNfts.value = true;
        if (mounted) setState(() => _nfts = nfts);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _hasNfts,
                    builder: (_, hasNfts, __) => hasNfts
                        ? const SizedBox()
                        : Text(l.yourAssetWillAppear,
                            style: const TextStyle(fontSize: 18)),
                  ),
                  if (_nfts.isNotEmpty) ...[
                    SizedBox(
                      height: WalletService.isViewKey()
                          ? widget.cardHeight - 50
                          : widget.cardHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _nfts.length,
                        itemBuilder: (_, i) =>
                            widget.buildCard(_nfts[i], _scrollController),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
