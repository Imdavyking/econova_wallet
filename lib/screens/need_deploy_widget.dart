import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class NeedDeploymentWidget extends StatefulWidget {
  final Coin coin;
  const NeedDeploymentWidget({super.key, required this.coin});

  @override
  State<NeedDeploymentWidget> createState() => _NeedDeploymentWidgetState();
}

class _NeedDeploymentWidgetState extends State<NeedDeploymentWidget> {
  // ← cached future — not recreated on every build
  late final Future<bool> _needDeployFuture;
  bool _needsDeploy = false;
  bool _isDeploying = false;

  @override
  void initState() {
    super.initState();
    _needDeployFuture = widget.coin.needDeploy();
  }

  Future<void> _deploy() async {
    setState(() => _isDeploying = true);
    try {
      final deployed = await widget.coin.deployAccount();
      if (mounted) setState(() => _needsDeploy = !deployed);
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content:
              Text(e.toString(), style: const TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeploying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: _needDeployFuture,
      builder: (context, snapshot) {
        // Not loaded yet or doesn't need deploy
        if (!snapshot.hasData || snapshot.data == false) {
          return const SizedBox.shrink();
        }

        // Snapshot says needs deploy — but user may have deployed since
        if (!_needsDeploy && snapshot.data == true) {
          // first time — sync local state with snapshot
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (mounted) setState(() => _needsDeploy = true);
            },
          );
          return const SizedBox.shrink();
        }

        if (!_needsDeploy) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(appBackgroundblue),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            onPressed: _isDeploying ? null : _deploy,
            child: _isDeploying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Loader(color: black),
                  )
                : Text(
                    localization.deployAccount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
