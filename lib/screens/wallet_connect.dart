import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallet_app/screens/wallet_connect_preview_v1.dart';
import 'package:wallet_app/screens/wallet_connect_preview_v2.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
// import 'package:wallet_app/utils/wallet_connect_v1/wc_connector.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';
import '../components/loader.dart';
import '../service/wallet_connect_service.dart';
import '../utils/app_config.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../utils/qr_scan_view.dart';
import '../utils/wallet_connect_v2/wc_connector_v2.dart';

class WalletConnect extends StatefulWidget {
  const WalletConnect({Key? key}) : super(key: key);

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
    List<SignClientEvent> events = [
      SignClientEvent.SESSION_DELETE,
      SignClientEvent.SESSION_UPDATE,
      SignClientEvent.SESSION_EXPIRE
    ];
    for (SignClientEvent event in events) {
      WcConnectorV2.signClient.on(event.value, (data) async {
        sessions.value = WcConnectorV2.signClient.session.getAll();
      });
    }

    event = WcConnectorV2.signClient.events.on(WcConnectorV2.connEvent,
        (data) async {
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
      appBar: AppBar(
        title: const Text('WalletConnect'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() {});
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => appBackgroundblue),
                        shape: WidgetStateProperty.resolveWith(
                          (states) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/Qrcode.svg',
                              color: Colors.transparent,
                            ),
                            Text(
                              localization.connectViAQR,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SvgPicture.asset(
                              'assets/Qrcode.svg',
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      onPressed: () async {
                        String? value = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRScanView(),
                          ),
                        );
                        if (value != null) {
                          value = value.trim();
                          await WCService.qrScanHandler(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.resolveWith(
                          (states) => 0,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Theme.of(context).scaffoldBackgroundColor,
                        ),
                        shape: WidgetStateProperty.resolveWith(
                          (states) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          localization.connectViACode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: localization.pasteCode,
                            pageBuilder: (context, _, __) {
                              return SimpleDialog(
                                title: Text(
                                  localization.pasteCode,
                                ),
                                titlePadding: const EdgeInsets.fromLTRB(
                                    16.0, 16.0, 16.0, .0),
                                contentPadding: const EdgeInsets.all(16.0),
                                children: [
                                  TextFormField(
                                    controller: wcUriCntrl,
                                    decoration: InputDecoration(
                                      label: Text(
                                        localization.enterCode,
                                      ),

                                      focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide.none),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide.none),
                                      enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide.none), // you
                                      filled: true,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          localization.confirm,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).then((_) {
                          if (wcUriCntrl.text.isNotEmpty) {
                            final url = wcUriCntrl.text.trim();
                            WCService.qrScanHandler(url);
                            wcUriCntrl.clear();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<List<SessionStruct>>(
                    valueListenable: sessions,
                    builder: (context, value, child) {
                      return Column(
                        children: sessions.value.map((struct) {
                          return Column(
                            children: [
                              Dismissible(
                                onDismissed: (DismissDirection direction) {},
                                direction: DismissDirection.none,
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  alignment: Alignment.centerRight,
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                background: Container(
                                  color: Colors.blue,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  alignment: Alignment.centerLeft,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                key: UniqueKey(),
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  if (direction.name == 'endToStart') {
                                    try {
                                      // WcConnectorV2.signClient.session.delete(e.id); //TODO: delete
                                      return true;
                                    } catch (_) {
                                      return false;
                                    }
                                  }
                                  return false;
                                },
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            WalletConnectPreviewV2(
                                          data: WalletConnectDataV2
                                              .fromSessionStruct(
                                            struct,
                                          ),
                                        ),
                                      ),
                                    );
                                    sessions.value = WcConnectorV2
                                        .signClient.session
                                        .getAll();
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                if (struct.peer.metadata.icons
                                                    .isNotEmpty)
                                                  Container(
                                                    height: 50.0,
                                                    width: 50.0,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: ipfsTohttp(
                                                        struct.peer.metadata
                                                            .icons[0],
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Loader(
                                                              color:
                                                                  appPrimaryColor,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
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
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        struct
                                                            .peer.metadata.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        struct
                                                            .peer.metadata.url,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  ...WCService.getSessionsV1().map(
                    (session) {
                      return Column(
                        children: [
                          Dismissible(
                            onDismissed: (DismissDirection direction) {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            direction: DismissDirection.endToStart,
                            secondaryBackground: Container(
                              color: Colors.red,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            background: Container(
                              color: Colors.blue,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerLeft,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            key: UniqueKey(),
                            confirmDismiss: (DismissDirection direction) async {
                              if (direction.name == 'endToStart') {
                                try {
                                  bool removed =
                                      await WCService.removeSessionV1(session);
                                  return removed;
                                } catch (_) {
                                  return false;
                                }
                              }
                              return false;
                            },
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => WalletConnectPreviewV1(
                                      data: WalletConnectData.fromSessionStruct(
                                        session,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            if (session.sessionStore.peerMeta
                                                .icons.isNotEmpty)
                                              Container(
                                                height: 50.0,
                                                width: 50.0,
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: ipfsTohttp(
                                                    session.sessionStore
                                                        .peerMeta.icons[0],
                                                  ),
                                                  placeholder: (context, url) =>
                                                      Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: const [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: Loader(
                                                          color:
                                                              appPrimaryColor,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    session.sessionStore
                                                        .peerMeta.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    session.sessionStore
                                                        .peerMeta.url,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
