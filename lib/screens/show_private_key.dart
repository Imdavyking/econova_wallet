import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowPrivateKey extends StatelessWidget {
  final String data;
  const ShowPrivateKey({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.showPrivateKey,
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                        text: data,
                      ));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localization.copiedToClipboard,
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 270,
                        height: 270,
                        child: Card(
                          color: const Color(0xffF1F1F1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Align(
                            alignment: Alignment.center,
                            child: QrImage(
                              padding: const EdgeInsets.all(10),
                              data: data,
                              version: QrVersions.auto,
                              size: 250,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.red[100],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localization.neverShareYourPrivateKey,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
