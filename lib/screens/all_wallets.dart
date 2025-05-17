import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../model/seed_phrase_root.dart';
import '../service/wallet_service.dart';
import '../utils/rpc_urls.dart';

class AllWallets extends StatefulWidget {
  const AllWallets({Key? key}) : super(key: key);
  @override
  State<AllWallets> createState() => _AllWalletsState();
}

class _AllWalletsState extends State<AllWallets> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController walletName = TextEditingController();

  List<SeedPhraseParams> mnemonics = WalletService.getActiveKeys(
    WalletType.secretPhrase,
  ) as List<SeedPhraseParams>;

  SeedPhraseParams? currentPhrase = WalletService.getActiveKey(
    WalletType.secretPhrase,
  ) as SeedPhraseParams?;
  List<ViewKeyParams> viewOnlyWallets = WalletService.getActiveKeys(
    WalletType.viewKey,
  ) as List<ViewKeyParams>;

  ViewKeyParams? currentView = WalletService.getActiveKey(
    WalletType.viewKey,
  ) as ViewKeyParams?;
  List<PrivateKeyParams> privateKeyWallets = WalletService.getActiveKeys(
    WalletType.privateKey,
  ) as List<PrivateKeyParams>;

  PrivateKeyParams? currentPrivate = WalletService.getActiveKey(
    WalletType.privateKey,
  ) as PrivateKeyParams?;

  @override
  void dispose() {
    walletName.dispose();
    super.dispose();
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(localization.wallet)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mnemonics.isNotEmpty) ...[
                  const Text(
                    'Seed Phrase Wallets',
                    style: TextStyle(fontSize: 15, color: grey),
                  ),
                  const SizedBox(height: 10),
                ],
                for (SeedPhraseParams seedParams in mnemonics) ...[
                  Dismissible(
                    onDismissed: (DismissDirection direction) {
                      setState(() {});
                    },
                    key: UniqueKey(),
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction.name == 'endToStart') {
                        return await _deleteWallet(
                          WalletType.secretPhrase,
                          seedParams,
                        );
                      }
                      return await _editWalletName(
                        WalletType.secretPhrase,
                        seedParams,
                      );
                    },
                    child: GestureDetector(
                      onTap: () async {
                        print('getting wallet: $currentPhrase');
                        if (currentPhrase == seedParams &&
                            WalletService.getType() ==
                                WalletType.secretPhrase) {
                          return;
                        }

                        await WalletService.setType(WalletType.secretPhrase);

                        final data =
                            WalletService.getActiveKey(walletImportType);

                        currentPhrase = data as SeedPhraseParams;

                        print('currentPhrase: $currentPhrase');

                        seedPhraseRoot = await compute(
                          seedFromMnemonic,
                          seedParams.data,
                        );

                        print('gtt: $seedPhraseRoot');

                        await WalletService.setActiveKey(
                          WalletType.secretPhrase,
                          seedParams,
                        );
                        await pref.put(
                          currentUserWalletNameKey,
                          seedParams.name,
                        );

                        if (!mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => const Wallet()),
                          (r) => false,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: 70,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 5),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    seedParams.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPhrase == seedParams &&
                                              WalletService.isPharseKey()
                                          ? Colors.blue
                                          : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: currentPhrase == seedParams &&
                                            WalletService.isPharseKey()
                                        ? const Icon(
                                            Icons.check,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : Container(),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
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
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                if (mnemonics.isNotEmpty)
                  const SizedBox(
                    height: 40,
                  ),
                if (privateKeyWallets.isNotEmpty) ...[
                  const Text(
                    'Private Key Wallets',
                    style: TextStyle(fontSize: 15, color: grey),
                  ),
                  const SizedBox(height: 10),
                ],
                for (PrivateKeyParams privateParams in privateKeyWallets) ...[
                  Dismissible(
                    onDismissed: (DismissDirection direction) {
                      setState(() {});
                    },
                    key: UniqueKey(),
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction.name == 'endToStart') {
                        return await _deleteWallet(
                          WalletType.privateKey,
                          privateParams,
                        );
                      }
                      return await _editWalletName(
                        WalletType.privateKey,
                        privateParams,
                      );
                    },
                    child: GestureDetector(
                      onTap: () async {
                        if (currentPrivate == privateParams &&
                            WalletService.getType() == WalletType.privateKey) {
                          return;
                        }
                        await WalletService.setType(WalletType.privateKey);

                        final data =
                            WalletService.getActiveKey(walletImportType);

                        currentPrivate = data as PrivateKeyParams;

                        await WalletService.setActiveKey(
                          WalletType.privateKey,
                          privateParams,
                        );
                        await pref.put(
                          currentUserWalletNameKey,
                          privateParams.name,
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => const Wallet()),
                          (r) => false,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: 70,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 5),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    privateParams.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPrivate == privateParams &&
                                              WalletService.isPrivateKey()
                                          ? Colors.blue
                                          : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: currentPrivate == privateParams &&
                                            WalletService.isPrivateKey()
                                        ? const Icon(
                                            Icons.check,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : Container(),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
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
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                if (privateKeyWallets.isNotEmpty)
                  const SizedBox(
                    height: 40,
                  ),
                if (viewOnlyWallets.isNotEmpty) ...[
                  const Text(
                    'View-Only Wallets',
                    style: TextStyle(fontSize: 15, color: grey),
                  ),
                  const SizedBox(height: 10),
                ],
                for (ViewKeyParams viewParams in viewOnlyWallets) ...[
                  Dismissible(
                    onDismissed: (DismissDirection direction) {
                      setState(() {});
                    },
                    key: UniqueKey(),
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction.name == 'endToStart') {
                        return await _deleteWallet(
                          WalletType.viewKey,
                          viewParams,
                        );
                      }
                      return await _editWalletName(
                        WalletType.viewKey,
                        viewParams,
                      );
                    },
                    child: GestureDetector(
                      onTap: () async {
                        if (currentView == viewParams &&
                            WalletService.getType() == WalletType.viewKey) {
                          return;
                        }
                        await WalletService.setType(WalletType.viewKey);

                        await WalletService.setActiveKey(
                          WalletType.viewKey,
                          viewParams,
                        );
                        await pref.put(
                          currentUserWalletNameKey,
                          viewParams.name,
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => const Wallet()),
                          (r) => false,
                        );
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: 70,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 5),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    viewParams.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentView == viewParams &&
                                              WalletService.isViewKey()
                                          ? Colors.blue
                                          : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: currentView == viewParams &&
                                            WalletService.isViewKey()
                                        ? const Icon(
                                            Icons.check,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : Container(),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
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
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _editWalletName(WalletType type, WalletParams anyKey) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final result = await AwesomeDialog(
      showCloseIcon: false,
      context: context,
      closeIcon: const Icon(
        Icons.close,
      ),
      onDismissCallback: (_) {},
      autoDismiss: false,
      animType: AnimType.scale,
      dialogType: DialogType.info,
      keyboardAware: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              localization.editWalletName,
            ),
            const SizedBox(
              height: 10,
            ),
            Material(
              elevation: 0,
              color: Colors.blueGrey.withAlpha(40),
              child: TextFormField(
                controller: walletName..text = (anyKey.name),
                autofocus: true,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: localization.walletName,
                  prefixIcon: const Icon(Icons.text_fields),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            AnimatedButton(
              isFixedHeight: false,
              text: localization.ok,
              pressEvent: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final walletNewName = walletName.text.trim();

                if (walletNewName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localization.enterName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context, false);
                  return;
                }

                List<WalletParams> params = [];
                switch (type) {
                  case WalletType.secretPhrase:
                    params = mnemonics;
                    break;
                  case WalletType.viewKey:
                    params = viewOnlyWallets;
                    break;
                  case WalletType.privateKey:
                    params = privateKeyWallets;
                    break;
                }
                for (var key in params) {
                  if (key == anyKey) {
                    key.name = walletNewName;
                    break;
                  }
                }

                await WalletService.editName(type, anyKey, walletNewName);

                mnemonics = WalletService.getActiveKeys(WalletType.secretPhrase)
                    as List<SeedPhraseParams>;

                Navigator.pop(context, true);
              },
            )
          ],
        ),
      ),
    ).show();
    return result ?? false;
  }

  Future<bool> _deleteWallet(WalletType type, WalletParams anyKey) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // check if active
    if (anyKey == WalletService.getActiveKey(walletImportType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.canNotDeleteCurrentWallet,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    bool deleted = await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      autoDismiss: false,
      closeIcon: const Icon(
        Icons.close,
      ),
      onDismissCallback: (type) {},
      dismissOnTouchOutside: true,
      title: localization.confirmWalletDelete,
      btnOkText: localization.delete,
      btnOkColor: Colors.red,
      btnCancelColor: appBackgroundblue,
      desc: localization.confirmWalletDeleteDescription,
      btnCancelOnPress: () {
        Navigator.pop(context, false);
      },
      btnOkOnPress: () async {
        if (await authenticate(context)) {
          await WalletService.deleteData(
            type,
            anyKey,
          );
          List<WalletParams> params = [];
          switch (type) {
            case WalletType.secretPhrase:
              params = mnemonics;
              break;
            case WalletType.viewKey:
              params = viewOnlyWallets;
              break;
            case WalletType.privateKey:
              params = privateKeyWallets;
              break;
          }

          params.removeWhere((element) => element == anyKey);

          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, false);
        }
      },
    ).show();

    return deleted;
  }
}
