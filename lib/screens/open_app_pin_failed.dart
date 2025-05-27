import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class OpenAppPinFailed extends StatefulWidget {
  final int? remainSec;
  const OpenAppPinFailed({super.key, this.remainSec});

  @override
  State<OpenAppPinFailed> createState() => _OpenAppPinFailedState();
}

class _OpenAppPinFailedState extends State<OpenAppPinFailed> {
  late CountdownTimerController controller;
  late int endTime;
  int minutesForUnlock = 1;

  @override
  void initState() {
    super.initState();
    endTime = DateTime.now().millisecondsSinceEpoch +
        1000 * (widget.remainSec ?? 60) * minutesForUnlock;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    controller.addListener(() async {
      final remaininTime = controller.currentRemainingTime;
      if (remaininTime == null) return;
      await pref.put(appUnlockTime, remaininTime.sec);
    });
  }

  bool hideHeader = false;
  void onEnd() async {
    setState(() {
      hideHeader = true;
    });
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const MyHomePage()),
    );
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/security_new.svg',
                width: 100,
              ),
              const SizedBox(
                height: 30,
              ),
              if (!hideHeader)
                Text(
                  localization.lockedAppMessage,
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(
                height: 10,
              ),
              CountdownTimer(
                endWidget: Text(
                  localization.expiredTimeMessage,
                  style: const TextStyle(fontSize: 18),
                ),
                controller: controller,
                onEnd: onEnd,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                endTime: endTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
