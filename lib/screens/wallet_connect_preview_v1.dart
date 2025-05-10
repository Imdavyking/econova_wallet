import 'package:cached_network_image/cached_network_image.dart';
import 'package:cryptowallet/components/loader.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../coins/ethereum_coin.dart';
import '../service/wallet_connect_service.dart';
import '../utils/get_token_image.dart';
import '../utils/rpc_urls.dart';

class RemotePeerMeta {
  final String name;
  final String url;
  final List<String> icons;

  RemotePeerMeta({
    required this.name,
    required this.url,
    required this.icons,
  });

  // Add a factory constructor to create an instance from a Map if needed

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

  WalletConnectData({
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

  const WalletConnectPreviewV1({
    Key? key,
    required this.data,
  }) : super(key: key);

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
    AppLocalizations localization = AppLocalizations.of(context)!;
    EthereumCoin? ethCoin = evmFromChainId(widget.data.chainId);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.connectionDetails),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (icons.isNotEmpty)
                            Container(
                              width: 50.0,
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: ipfsTohttp(
                                  icons[0],
                                ),
                                placeholder: (context, url) => const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Loader(
                                        color: appPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          else
                            const SizedBox(
                              height: 50.0,
                              width: 50.0,
                            ),
                          if (icons.isNotEmpty)
                            const SizedBox(
                              width: 10,
                            ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.data.remotePeerMeta.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.data.remotePeerMeta.url,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Connected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${trnDate.day} ${months[trnDate.month - 1]}, ${trnDate.hour}:${trnDate.minute}',
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
              const SizedBox(
                height: 10,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      if (ethCoin != null)
                        GetTokenImage(
                          currCoin: ethCoin,
                        ),
                      const SizedBox(
                        width: 20,
                      ),
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
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  await WCService.removeSessionV1(widget.data.session);
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
