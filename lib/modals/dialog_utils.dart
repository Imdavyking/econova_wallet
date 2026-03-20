import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../utils/app_config.dart';

Future<void> showDialogWithMessage({
  required BuildContext context,
  String? message,
  dynamic Function()? onConfirm,
  dynamic Function()? onCancel,
  Color? btnOkColor,
  Color? btnCancelColor,
}) async {
  final localization = AppLocalizations.of(context)!;
  await AwesomeDialog(
    closeIcon: const Icon(Icons.close),
    buttonsTextStyle: const TextStyle(color: Colors.white),
    context: context,
    btnOkColor: btnOkColor ?? appBackgroundblue,
    dialogType: DialogType.info,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: localization.info,
    desc: message,
    showCloseIcon: true,
    btnCancelColor: btnCancelColor,
    btnOkOnPress: onConfirm ?? () {},
    btnCancelOnPress: onCancel,
  ).show();
}
