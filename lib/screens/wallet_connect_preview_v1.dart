// wallet_connect_preview_v1.dart
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../service/wallet_connect_service.dart';
import '../utils/get_token_image.dart';

class RemotePeerMeta {
  final String name;
  final String url;
  final List<String> icons;

  const RemotePeerMeta({
    required this.name,
    required this.url,
    required this.icons,
  });

  factory RemotePeerMeta.fromWCPeerData(WCPeerMeta metadata) {
    return RemotePeerMeta(
      name: metadata.name,
      url: metadata.url,
      icons: List<String>.from(metadata.icons),
    );
  }

  factory RemotePeerMeta.fromAppMetaDataV2(AppMetadata metadata) {
    return RemotePeerMeta(
      name: metadata.name,
      url: metadata.url,
      icons: List<String>.from(metadata.icons),
    );
  }
}

class WalletConnectData {
  final RemotePeerMeta remotePeerMeta;
  final int date;
  final int chainId;
  final String address;
  final WCSessionAddr session;

  const WalletConnectData({
    required this.remotePeerMeta,
    required this.date,
    required this.chainId,
    required this.address,
    required this.session,
  });

  factory WalletConnectData.fromSessionStruct(WCSessionAddr session) {
    return WalletConnectData(
      remotePeerMeta:
          RemotePeerMeta.fromWCPeerData(session.sessionStore.peerMeta),
      date: session.date,
      chainId: session.sessionStore.chainId,
      session: session,
      address: session.address,
    );
  }
}

class WalletConnectPreviewV1 extends StatefulWidget {
  final WalletConnectData data;

  const WalletConnectPreviewV1({super.key, required this.data});

  @override
  State<WalletConnectPreviewV1> createState() => _WalletConnectPreviewV1State();
}

class _WalletConnectPreviewV1State extends State<WalletConnectPreviewV1> {
  late List<String> icons;
  late DateTime trnDate;

  @override
  void initState() {
    super.initState();
    icons = widget.data.remotePeerMeta.icons;
    trnDate = DateTime.fromMicrosecondsSinceEpoch(widget.data.date);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localization = AppLocalizations.of(context)!;
    final EthereumCoin? ethCoin = evmFromChainId(widget.data.chainId);
    return Scaffold(
      appBar: AppBar(title: Text(localization.connectionDetails)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              DappInfoCard(
                name: widget.data.remotePeerMeta.name,
                url: widget.data.remotePeerMeta.url,
                iconUrl: icons.isNotEmpty ? icons[0] : null,
              ),
              const SizedBox(height: 10),
              ConnectedAtCard(trnDate: trnDate),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      if (ethCoin != null) GetTokenImage(currCoin: ethCoin),
                      const SizedBox(width: 20),
                      Column(
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
                            ellipsify(
                              str: widget.data.address,
                              maxLength: 20,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => WCService.removeSessionV1(widget.data.session),
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
// Shared sub-widgets for preview screens
// ---------------------------------------------------------------------------

class DappInfoCard extends StatelessWidget {
  final String name;
  final String url;
  final String? iconUrl;

  const DappInfoCard({super.key, 
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

class ConnectedAtCard extends StatelessWidget {
  final DateTime trnDate;
  const ConnectedAtCard({required this.trnDate});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Connected',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
