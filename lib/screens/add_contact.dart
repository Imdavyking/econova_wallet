import 'package:cryptowallet/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../service/contact_service.dart';
import '../utils/app_config.dart';
import '../utils/qr_scan_view.dart';

class AddContact extends StatefulWidget {
  final ContactParams params;
  const AddContact({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final memoController = TextEditingController();
  late AppLocalizations localization;
  late ContactParams params;

  @override
  void initState() {
    super.initState();
    params = widget.params;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        bool willPop = false;
        await showDialogWithMessage(
          context: context,
          btnCancelColor: Colors.blue,
          btnOkColor: Colors.red[400]!,
          message: localization.confirmClose,
          onConfirm: () {
            willPop = true;
          },
          onCancel: () {
            willPop = false;
          },
        );

        return willPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${params.coin.getName()} Contact',
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController..text = params.name ?? '',
                      decoration: InputDecoration(
                        hintText: localization.name,
                        focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none), // you
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: addressController
                        ..text = params.address ?? '',
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                              ),
                              onPressed: () async {
                                String? addr = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => const QRScanView(),
                                  ),
                                );
                                if (addr == null) return;
                                addressController.setText(addr);
                              },
                            ),
                            InkWell(
                              onTap: () async {
                                ClipboardData? cdata = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                if (cdata == null) return;
                                if (cdata.text == null) return;
                                addressController.setText(cdata.text!);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  localization.paste,
                                ),
                              ),
                            ),
                          ],
                        ),

                        hintText: localization.address,
                        focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none), // you
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (params.coin.requireMemo()) ...[
                      TextFormField(
                        controller: memoController..text = params.memo ?? '',
                        decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                ),
                                onPressed: () async {
                                  String? memo = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => const QRScanView(),
                                    ),
                                  );
                                  if (memo == null) return;
                                  memoController.setText(memo);
                                },
                              ),
                              InkWell(
                                onTap: () async {
                                  ClipboardData? cdata =
                                      await Clipboard.getData(
                                          Clipboard.kTextPlain);
                                  if (cdata == null) return;
                                  if (cdata.text == null) return;
                                  memoController.setText(cdata.text!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localization.paste,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          hintText: localization.memo,
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide.none),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide.none),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide.none), // you
                          filled: true,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    Container(
                      color: Colors.transparent,
                      width: double.infinity,
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
                          textStyle: WidgetStateProperty.resolveWith(
                            (states) => const TextStyle(color: Colors.white),
                          ),
                        ),
                        child: Text(
                          localization.save,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          final name = nameController.text.trim();
                          final memo = memoController.text.trim();
                          final address = addressController.text.trim();

                          if (name.isEmpty || address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  localization.enterNameAndAddress,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            params.coin.validateAddress(address);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  localization.invalidAddress,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }

                          final argsParams = ContactParams(
                            address: address,
                            coin: params.coin,
                            memo: memo,
                            name: name,
                            id: params.id,
                          );

                          await ContactService.setContact(argsParams);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                localization.done,
                              ),
                            ),
                          );

                          Navigator.pop(context, ContactService.getContacts());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
