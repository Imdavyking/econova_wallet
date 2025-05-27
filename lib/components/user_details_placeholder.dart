import 'package:wallet_app/components/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../main.dart';
import '../screens/identicons.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../service/wallet_service.dart';

class UserDetailsPlaceHolder extends StatefulWidget {
  final double? size;

  final double? textSize;

  const UserDetailsPlaceHolder({super.key, this.size, this.textSize});

  @override
  State<UserDetailsPlaceHolder> createState() => _UserDetailsPlaceHolderState();
}

class _UserDetailsPlaceHolderState extends State<UserDetailsPlaceHolder> {
  Map ethInfo = {};
  Future<void> getETHDetails() async {
    try {
      final currentWalletName = pref.get(currentUserWalletNameKey);
      final data = WalletService.getActiveKey(walletImportType)!.data;

      final web3Response = await evmFromSymbol('ETH')!.importData(data);

      final String useraddress = web3Response.address;

      Map userDetails = {
        'user_address': useraddress.toLowerCase(),
      };
      userDetails['name'] = currentWalletName;

      if (mounted) {
        setState(() {
          ethInfo = userDetails;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void didUpdateWidget(UserDetailsPlaceHolder widget) {
    super.didUpdateWidget(widget);
    getETHDetails();
  }

  @override
  void initState() {
    super.initState();
    getETHDetails();
  }

  @override
  Widget build(BuildContext context) {
    const loader = SizedBox(
      width: 20,
      height: 20,
      child: Loader(
        color: appBackgroundblue,
      ),
    );
    if (ethInfo.isEmpty) {
      return loader;
    }

    if (ethInfo['name'] == null) {
      ethInfo['name'] = AppLocalizations.of(context)!.user;
    }
    return Row(
      children: [
        Identicon(address: ethInfo['user_address']),
        const SizedBox(
          width: 10,
        ),
        Text(
          ellipsify(str: ethInfo['name']),
          style: TextStyle(
            fontSize: widget.textSize,
          ),
        )
      ],
    );
  }
}
