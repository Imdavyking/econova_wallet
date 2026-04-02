import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/service/wallet_connect_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/get_token_image.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';

/// Data model wrapping a Reown [SessionData] for the preview screen.
class WalletConnectDataReown {
  final String name;
  final String url;
  final List<String> icons;
  final DateTime expiry;

  /// All `eip155:chainId:address` account strings across every namespace.
  final List<String> accounts;
  final SessionData session;

  const WalletConnectDataReown({
    required this.name,
    required this.url,
    required this.icons,
    required this.expiry,
    required this.accounts,
    required this.session,
  });

  factory WalletConnectDataReown.fromSessionData(SessionData session) {
    final meta = session.peer.metadata;
    final List<String> accounts = [
      for (final ns in session.namespaces.values) ...ns.accounts,
    ];
    return WalletConnectDataReown(
      name: meta.name,
      url: meta.url,
      icons: List<String>.from(meta.icons),
      // expiry is a Unix timestamp in seconds
      expiry: DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000),
      accounts: accounts,
      session: session,
    );
  }
}

class WalletConnectPreviewReown extends StatefulWidget {
  final WalletConnectDataReown data;

  const WalletConnectPreviewReown({super.key, required this.data});

  @override
  State<WalletConnectPreviewReown> createState() =>
      _WalletConnectPreviewReownState();
}

class _WalletConnectPreviewReownState extends State<WalletConnectPreviewReown> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localization.connectionDetails)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ── dApp identity card ──────────────────────────────────────
              _DappInfoCard(
                name: widget.data.name,
                url: widget.data.url,
                iconUrl:
                    widget.data.icons.isNotEmpty ? widget.data.icons[0] : null,
              ),
              const SizedBox(height: 10),

              // ── Session expiry card ─────────────────────────────────────
              _ConnectedAtCard(trnDate: widget.data.expiry, label: 'Expires'),

              const SizedBox(height: 10),

              // ── Per-account chain cards ─────────────────────────────────
              ...widget.data.accounts.map((account) {
                final parts = account.split(':');
                // Format: "eip155:chainId:address"
                final int? chainId =
                    parts.length >= 3 ? int.tryParse(parts[1]) : null;
                final String address = parts.length >= 3 ? parts.last : account;
                final EthereumCoin? ethCoin =
                    chainId != null ? evmFromChainId(chainId) : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          if (ethCoin != null) GetTokenImage(currCoin: ethCoin),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (ethCoin != null)
                                  Text(
                                    ethCoin.getSymbol(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                Text(
                                  ellipsify(str: address, maxLength: 20),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // ── Disconnect ──────────────────────────────────────────────
              InkWell(
                onTap: () async {
                  await WCService.removeSessionReown(widget.data.session);
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text(
                  'Disconnect',
                  style: TextStyle(
                    color: red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

// ---------------------------------------------------------------------------
// Re-use the shared sub-widgets from wallet_connect_preview_v1.dart
// ---------------------------------------------------------------------------

/// Thin card showing the dApp name + URL + icon in a row.
class _DappInfoCard extends StatelessWidget {
  final String name;
  final String url;
  final String? iconUrl;

  const _DappInfoCard({
    required this.name,
    required this.url,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            WCDappIcon(iconUrl: iconUrl, size: 50),
            if (iconUrl != null) const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    url,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing a date with a leading label (e.g. "Connected" or "Expires").
class _ConnectedAtCard extends StatelessWidget {
  final DateTime trnDate;
  final String label;

  const _ConnectedAtCard({
    required this.trnDate,
    this.label = 'Connected',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${trnDate.day} ${months[trnDate.month - 1]}, '
              '${trnDate.hour}:${trnDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
