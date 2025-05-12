import 'package:cached_network_image/cached_network_image.dart';
import 'package:cryptowallet/components/loader.dart';
import 'package:cryptowallet/screens/wallet_connect_preview_v1.dart';
import 'package:cryptowallet/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../coins/ethereum_coin.dart';
import '../service/wallet_connect_service.dart';
import '../utils/get_token_image.dart';
import '../utils/rpc_urls.dart';

class WalletConnectDataV2 {
  final RemotePeerMeta remotePeerMeta;
  final int date;
  final List<SessionNamespace> connAccts;
  final SessionStruct struct;

  WalletConnectDataV2({
    required this.remotePeerMeta,
    required this.date,
    required this.struct,
    required this.connAccts,
  });

  factory WalletConnectDataV2.fromSessionStruct(SessionStruct struct) {
    List<SessionNamespace> connAccts = struct.namespaces.entries.map((e) {
      return e.value;
    }).toList();

    return WalletConnectDataV2(
      remotePeerMeta: RemotePeerMeta.fromAppMetaDataV2(struct.peer.metadata),
      date: struct.expiry,
      connAccts: connAccts,
      struct: struct,
    );
  }
}

class WalletConnectPreviewV2 extends StatefulWidget {
  final WalletConnectDataV2 data;

  const WalletConnectPreviewV2({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<WalletConnectPreviewV2> createState() => _WalletConnectPreviewV2State();
}

class _WalletConnectPreviewV2State extends State<WalletConnectPreviewV2> {
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
              for (SessionNamespace nameSpce in widget.data.connAccts)
                ...nameSpce.accounts.map((e) {
                  int? chainID = int.tryParse(e.split(":")[1]);
                  EthereumCoin? ethCoin = evmFromChainId(chainID!);

                  return Card(
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
                                  str: e.split(":").last,
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
                  );
                }).toList(),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  await WCService.removeSessionV2(
                    widget.data.struct,
                  );
                  Navigator.pop(context, true);
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
