import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/screens/wallet_connect_preview_v1.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../service/wallet_connect_service.dart';
import '../utils/get_token_image.dart';

class WalletConnectDataV2 {
  final RemotePeerMeta remotePeerMeta;
  final int date;
  final List<SessionNamespace> connAccts;
  final SessionStruct struct;

  const WalletConnectDataV2({
    required this.remotePeerMeta,
    required this.date,
    required this.struct,
    required this.connAccts,
  });

  factory WalletConnectDataV2.fromSessionStruct(SessionStruct struct) {
    return WalletConnectDataV2(
      remotePeerMeta: RemotePeerMeta.fromAppMetaDataV2(struct.peer.metadata),
      date: struct.expiry,
      connAccts: struct.namespaces.values.toList(),
      struct: struct,
    );
  }
}

class WalletConnectPreviewV2 extends StatefulWidget {
  final WalletConnectDataV2 data;

  const WalletConnectPreviewV2({super.key, required this.data});

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
    // expiry is a Unix timestamp (seconds), not microseconds
    trnDate = DateTime.fromMillisecondsSinceEpoch(
      widget.data.date * 1000,
    );
  }

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
              DappInfoCard(
                name: widget.data.remotePeerMeta.name,
                url: widget.data.remotePeerMeta.url,
                iconUrl: icons.isNotEmpty ? icons[0] : null,
              ),
              const SizedBox(height: 10),
              ConnectedAtCard(trnDate: trnDate),
              const SizedBox(height: 10),
              for (final nameSpace in widget.data.connAccts)
                ...nameSpace.accounts.map((e) {
                  final parts = e.split(':');
                  final int? chainID = int.tryParse(parts[1]);
                  final EthereumCoin? ethCoin =
                      chainID != null ? evmFromChainId(chainID) : null;

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
                            if (ethCoin != null)
                              GetTokenImage(currCoin: ethCoin),
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
                                    str: parts.last,
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
                  );
                }),
              InkWell(
                onTap: () async {
                  await WCService.removeSessionV2(widget.data.struct);
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
