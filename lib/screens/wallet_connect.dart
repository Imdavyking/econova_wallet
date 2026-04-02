// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/screens/wallet_connect_preview_v1.dart';
import 'package:wallet_app/screens/wallet_connect_preview_v2.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';
import '../service/wallet_connect_service.dart';
import '../utils/app_config.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../utils/qr_scan_view.dart';
import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WalletConnect extends StatefulWidget {
  const WalletConnect({super.key});

  @override
  _WalletConnectState createState() => _WalletConnectState();
}

class _WalletConnectState extends State<WalletConnect> {
  final TextEditingController wcUriCntrl = TextEditingController();
  ValueNotifier<List<SessionStruct>> sessions =
      ValueNotifier(WcConnectorV2.signClient.session.getAll());
  late Listener<String> event;

  @override
  void initState() {
    super.initState();
    for (final e in [
      SignClientEvent.SESSION_DELETE,
      SignClientEvent.SESSION_UPDATE,
      SignClientEvent.SESSION_EXPIRE,
    ]) {
      WcConnectorV2.signClient.on(e.value, (_) async {
        sessions.value = WcConnectorV2.signClient.session.getAll();
      });
    }
    event =
        WcConnectorV2.signClient.events.on(WcConnectorV2.connEvent, (_) async {
      sessions.value = WcConnectorV2.signClient.session.getAll();
    });
  }

  @override
  void dispose() {
    wcUriCntrl.dispose();
    event.cancel();
    super.dispose();
  }

  late AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('WalletConnect')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) setState(() {});
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── QR scan button ───────────────────────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
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
                      onPressed: () async {
                        final String? value = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QRScanView()),
                        );
                        if (value != null) {
                          await WCService.qrScanHandler(value.trim());
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset('assets/Qrcode.svg',
                              color: Colors.transparent),
                          Text(
                            localization.connectViAQR,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SvgPicture.asset('assets/Qrcode.svg',
                              color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Paste-code button ────────────────────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.resolveWith((_) => 0),
                        backgroundColor: WidgetStateProperty.resolveWith(
                            (_) => Theme.of(context).scaffoldBackgroundColor),
                        shape: WidgetStateProperty.resolveWith(
                          (_) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: localization.pasteCode,
                          pageBuilder: (context, _, __) => SimpleDialog(
                            title: Text(localization.pasteCode),
                            titlePadding:
                                const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            contentPadding: const EdgeInsets.all(16.0),
                            children: [
                              TextFormField(
                                controller: wcUriCntrl,
                                decoration: InputDecoration(
                                  label: Text(localization.enterCode),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide.none,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(localization.confirm),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).then((_) {
                          if (wcUriCntrl.text.isNotEmpty) {
                            WCService.qrScanHandler(wcUriCntrl.text.trim());
                            wcUriCntrl.clear();
                          }
                        });
                      },
                      child: Text(
                        localization.connectViACode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── v2 sessions ──────────────────────────────────────────
                  ValueListenableBuilder<List<SessionStruct>>(
                    valueListenable: sessions,
                    builder: (context, value, _) {
                      return Column(
                        children: value.map((struct) {
                          final iconUrl = struct.peer.metadata.icons.isNotEmpty
                              ? struct.peer.metadata.icons[0]
                              : null;
                          return _SessionTile(
                            key: ValueKey(struct.topic),
                            iconUrl: iconUrl,
                            name: struct.peer.metadata.name,
                            url: struct.peer.metadata.url,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WalletConnectPreviewV2(
                                    data: WalletConnectDataV2.fromSessionStruct(
                                        struct),
                                  ),
                                ),
                              );
                              sessions.value =
                                  WcConnectorV2.signClient.session.getAll();
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // ── v1 sessions ──────────────────────────────────────────
                  ...WCService.getSessionsV1().map((session) {
                    final iconUrl =
                        session.sessionStore.peerMeta.icons.isNotEmpty
                            ? session.sessionStore.peerMeta.icons[0]
                            : null;
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        if (mounted) setState(() {});
                      },
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          try {
                            return await WCService.removeSessionV1(session);
                          } catch (_) {
                            return false;
                          }
                        }
                        return false;
                      },
                      secondaryBackground: Container(
                        color: Colors.red,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      background: Container(
                        color: Colors.blue,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                      child: _SessionTile(
                        iconUrl: iconUrl,
                        name: session.sessionStore.peerMeta.name,
                        url: session.sessionStore.peerMeta.url,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletConnectPreviewV1(
                              data:
                                  WalletConnectData.fromSessionStruct(session),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extracted tile used for both v1 and v2 session rows
// ---------------------------------------------------------------------------

class _SessionTile extends StatelessWidget {
  final String? iconUrl;
  final String name;
  final String url;
  final VoidCallback onTap;

  const _SessionTile({
    super.key,
    this.iconUrl,
    required this.name,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      WCDappIcon(iconUrl: iconUrl, size: 50),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
