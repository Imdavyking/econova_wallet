import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class NeedDeploymentWidget extends StatelessWidget {
  NeedDeploymentWidget({super.key, required this.coin});
  final ValueNotifier<bool> needDeployment = ValueNotifier(false);
  final ValueNotifier<bool> isDeploying = ValueNotifier(false);
  final Coin coin;
  late final AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return FutureBuilder<bool>(
      future: coin.needDeploy(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.data == false) {
          return Container();
        }

        needDeployment.value = snapshot.data!;

        return ValueListenableBuilder<bool>(
            valueListenable: isDeploying,
            builder: (context, isDeployingAccount, child) {
              return ValueListenableBuilder<bool>(
                  valueListenable: needDeployment,
                  builder: (context, value, child) {
                    if (!needDeployment.value) {
                      return Container();
                    }

                    return Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => appBackgroundblue,
                          ),
                          shape: WidgetStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          textStyle: WidgetStateProperty.resolveWith(
                            (states) => const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: isDeployingAccount
                            ? Container(
                                color: Colors.transparent,
                                width: 20,
                                height: 20,
                                child: const Loader(color: black),
                              )
                            : Text(
                                localization.deployAccount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                        onPressed: () async {
                          try {
                            isDeploying.value = true;
                            bool isDeployed = await coin.deployAccount();
                            needDeployment.value = !isDeployed;
                          } catch (e) {
                            debugPrint(e.toString());
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  e.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          } finally {
                            isDeploying.value = false;
                          }
                        },
                      ),
                    );
                  });
            });
      },
    );
  }
}
