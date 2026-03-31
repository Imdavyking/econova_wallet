import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

// ── DApp data model ───────────────────────────────────────────────────────────

class _DappEntry {
  final String name;
  final String description;
  final String url;
  final String? svgAsset;
  final String? networkHint; // shown as a badge e.g. "Polygon"
  final bool isNew;

  const _DappEntry({
    required this.name,
    required this.description,
    required this.url,
    this.svgAsset,
    this.networkHint,
    this.isNew = false,
  });
}

// ── Root widget ───────────────────────────────────────────────────────────────

class DappUI extends StatefulWidget {
  const DappUI({super.key});

  @override
  State<DappUI> createState() => _DappUIState();
}

class _DappUIState extends State<DappUI> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── DApp registry ─────────────────────────────────────────────────────────

  List<_DappEntry> get _allDapps => [
        const _DappEntry(
          name: 'NFT Marketplace',
          description: 'Buy, sell and discover NFTs',
          url: marketPlaceUrl,
          svgAsset: 'assets/social_dapp.svg',
          isNew: true,
        ),
        const _DappEntry(
          name: 'Polymarket',
          description: 'Predict real-world events with USDC',
          url: 'https://polymarket.com',
          svgAsset: 'assets/browser_dapp.svg',
          networkHint: 'Polygon',
          isNew: true,
        ),
        const _DappEntry(
          name: 'Blog',
          description: 'News and updates',
          url: blogUrl,
          svgAsset: 'assets/news.svg',
        ),
      ];

  List<_DappEntry> get _filteredDapps {
    if (_query.isEmpty) return _allDapps;
    return _allDapps.where((d) {
      return d.name.toLowerCase().contains(_query) ||
          d.description.toLowerCase().contains(_query);
    }).toList();
  }

  // ── Quick action entries ──────────────────────────────────────────────────

  late final _quickActions = [
    const _QuickAction(
      label: 'Dex',
      svgAsset: 'assets/swap_dapp.svg',
      url: walletDexProviderUrl,
    ),
    const _QuickAction(
      labelKey: 'stake',
      svgAsset: 'assets/stake_dapp.svg',
      url: stakeDexProviderUrl,
    ),
    const _QuickAction(
      labelKey: 'fiat',
      svgAsset: 'assets/fiat_dapp.svg',
      url: fiatDexProviderUrl,
    ),
    _QuickAction(
      labelKey: 'browser',
      svgAsset: 'assets/browser_dapp.svg',
      url: browserUrl,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Dapps')),
      body: Column(
        children: [
          const TestnetBanner(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header banner
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/header_dapp.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search bar
                    _SearchBar(controller: _searchController),
                    const SizedBox(height: 24),

                    // Quick actions — hide when searching
                    if (_query.isEmpty) ...[
                      _SectionHeader(title: localization.favourites),
                      const SizedBox(height: 12),
                      _QuickActionsGrid(actions: _quickActions),
                      const SizedBox(height: 24),
                    ],

                    // All dApps list
                    _SectionHeader(title: localization.all),
                    const SizedBox(height: 12),
                    if (_filteredDapps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No dApps found for "$_query"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredDapps.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _DappListTile(
                          entry: _filteredDapps[i],
                          onTap: () => navigateToDappBrowser(
                            context,
                            _filteredDapps[i].url,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search dApps...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, val, __) => val.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: controller.clear,
                )
              : const SizedBox.shrink(),
        ),
        filled: true,
        isDense: true,
        focusedBorder: _border,
        border: _border,
        enabledBorder: _border,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickAction {
  final String? label;
  final String? labelKey; // for localized labels
  final String svgAsset;
  final String url;

  const _QuickAction({
    this.label,
    this.labelKey,
    required this.svgAsset,
    required this.url,
  });

  String resolveLabel(AppLocalizations l) {
    if (label != null) return label!;
    switch (labelKey) {
      case 'stake':
        return l.stake;
      case 'fiat':
        return l.fiat;
      case 'browser':
        return l.browser;
      default:
        return labelKey ?? '';
    }
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickAction> actions;
  const _QuickActionsGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3,
      children: actions
          .map((a) => _QuickActionCard(
                action: a,
                label: a.resolveLabel(localization),
              ))
          .toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final String label;

  const _QuickActionCard({
    required this.action,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToDappBrowser(context, action.url),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SvgPicture.asset(action.svgAsset, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DApp list tile ────────────────────────────────────────────────────────────

class _DappListTile extends StatelessWidget {
  final _DappEntry entry;
  final VoidCallback onTap;

  const _DappListTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
              ),
              padding: const EdgeInsets.all(10),
              child: entry.svgAsset != null
                  ? SvgPicture.asset(entry.svgAsset!)
                  : const Icon(Icons.web, size: 22),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.isNew) ...[
                        const SizedBox(width: 6),
                        SvgPicture.asset('assets/new_dapp.svg', height: 14),
                      ],
                      if (entry.networkHint != null) ...[
                        const SizedBox(width: 6),
                        _NetworkBadge(label: entry.networkHint!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Network badge ─────────────────────────────────────────────────────────────

class _NetworkBadge extends StatelessWidget {
  final String label;
  const _NetworkBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.purple.withOpacity(0.12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.purple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
