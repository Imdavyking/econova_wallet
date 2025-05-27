// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  _QRScanViewState createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> with WidgetsBindingObserver {
  final ScanController controller = ScanController();
  bool cameraOn = false;
  late AppLocalizations localizations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.resume();
        break;

      case AppLifecycleState.paused:
        controller.pause();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              ScanView(
                controller: controller,
                scanAreaScale: 1,
                scanLineColor: appBackgroundblue,
                onCapture: (data) {
                  Navigator.pop(context, data);
                },
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: cameraOn ? Colors.grey : Colors.white,
                    size: 35,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  onPressed: () {
                    controller.toggleTorchMode();

                    setState(() {
                      cameraOn = !cameraOn;
                    });
                  },
                  icon: Icon(
                    FontAwesomeIcons.bolt,
                    color: cameraOn ? Colors.grey : Colors.white,
                    size: 35,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: () {
                    selectImage(
                        context: context,
                        onSelect: (XFile file) async {
                          final data = await Scan.parse(file.path);
                          if (!context.mounted) return;
                          if (data != null) {
                            Navigator.pop(context, data);
                          } else {
                            showDialogWithMessage(
                              context: context,
                              message: localizations.errorTryAgain,
                            );
                          }
                        });
                  },
                  icon: const Icon(
                    Icons.image,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
