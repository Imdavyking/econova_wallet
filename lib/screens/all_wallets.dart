import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/components/wallet_name_field.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/model/seed_phrase_root.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

class AllWallets extends StatefulWidget {
  const AllWallets({super.key});

  @override
  State<AllWallets> createState() => _AllWalletsState();
}

class _AllWalletsState extends State<AllWallets> {
  var _mnemonics = <BIP39PhraseOrSeedHEXParams>[];
  var _privateKeys = <PrivateKeyParams>[];
  var _viewKeys = <ViewKeyParams>[];

  BIP39PhraseOrSeedHEXParams? _activeMnemonic;
  PrivateKeyParams? _activePrivate;
  ViewKeyParams? _activeView;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  void _reload() {
    _mnemonics = WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex)
        .cast<BIP39PhraseOrSeedHEXParams>();
    _privateKeys = WalletService.getActiveKeys(WalletType.privateKey)
        .cast<PrivateKeyParams>();
    _viewKeys =
        WalletService.getActiveKeys(WalletType.viewKey).cast<ViewKeyParams>();
    _activeMnemonic =
        WalletService.getActiveKey(WalletType.bip39PhraseOrSeedHex)
            as BIP39PhraseOrSeedHEXParams?;
    _activePrivate =
        WalletService.getActiveKey(WalletType.privateKey) as PrivateKeyParams?;
    _activeView =
        WalletService.getActiveKey(WalletType.viewKey) as ViewKeyParams?;
  }

  List<WalletParams> _listFor(WalletType type) => switch (type) {
        WalletType.bip39PhraseOrSeedHex => _mnemonics,
        WalletType.privateKey => _privateKeys,
        WalletType.viewKey => _viewKeys,
      };

  bool _isActive(WalletType type, WalletParams w) => switch (type) {
        WalletType.bip39PhraseOrSeedHex =>
          w == _activeMnemonic && WalletService.isBip39PhraseOrSeedHexKey(),
        WalletType.privateKey =>
          w == _activePrivate && WalletService.isPrivateKey(),
        WalletType.viewKey => w == _activeView && WalletService.isViewKey(),
      };

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _switchWallet(WalletType type, WalletParams wallet) async {
    // setActiveKey handles setType internally.
    await WalletService.setActiveKey(type, wallet);
    await pref.put(currentUserWalletNameKey, wallet.name);

    if (type == WalletType.bip39PhraseOrSeedHex) {
      seedPhraseRoot = await compute(
        seedFromMnemonic,
        (wallet as BIP39PhraseOrSeedHEXParams).data,
      );
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Wallet()),
      (_) => false,
    );
  }

  Future<void> _editName(WalletType type, WalletParams wallet) async {
    final loc = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: wallet.name);
    final nameKey = GlobalKey<WalletNameFieldState>();

    final saved = await AwesomeDialog(
      context: context,
      showCloseIcon: false,
      autoDismiss: false,
      animType: AnimType.scale,
      dialogType: DialogType.info,
      keyboardAware: true,
      onDismissCallback: (_) {},
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(loc.editWalletName),
            const SizedBox(height: 10),
            WalletNameField(
              key: nameKey,
              controller: nameCtrl,
              editingWallet: wallet,
            ),
            const SizedBox(height: 10),
            AnimatedButton(
              isFixedHeight: false,
              text: loc.ok,
              pressEvent: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                if (!nameKey.currentState!.validateOnSubmit()) return;
                await WalletService.editName(
                    type, wallet, nameCtrl.text.trim());
                if (!mounted) return;
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    ).show();

    nameCtrl.dispose();
    if (saved == true) setState(_reload);
  }

  Future<void> _deleteWallet(WalletType type, WalletParams wallet) async {
    final loc = AppLocalizations.of(context)!;

    if (wallet == WalletService.getActiveKey(walletImportType)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(loc.canNotDeleteCurrentWallet,
            style: const TextStyle(color: Colors.white)),
      ));
      return;
    }

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      autoDismiss: false,
      dismissOnTouchOutside: true,
      onDismissCallback: (_) {},
      title: loc.confirmWalletDelete,
      desc: loc.confirmWalletDeleteDescription,
      btnOkText: loc.delete,
      btnOkColor: Colors.red,
      btnCancelColor: appBackgroundblue.withOpacity(0.5),
      btnCancelOnPress: () => Navigator.pop(context),
      btnOkOnPress: () async {
        if (!await authenticate(context)) {
          if (mounted) Navigator.pop(context);
          return;
        }
        await WalletService.deleteData(type, wallet);
        if (!mounted) return;
        Navigator.pop(context);
        setState(() => _listFor(type).removeWhere((e) => e == wallet));
      },
    ).show();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final sections = [
      (
        title: 'Seed Phrase Wallets',
        type: WalletType.bip39PhraseOrSeedHex,
        wallets: _mnemonics,
      ),
      (
        title: 'Private Key Wallets',
        type: WalletType.privateKey,
        wallets: _privateKeys,
      ),
      (
        title: 'View-Only Wallets',
        type: WalletType.viewKey,
        wallets: _viewKeys,
      ),
    ].where((s) => s.wallets.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.wallet)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 40),
          itemBuilder: (_, i) {
            final s = sections[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title,
                    style: const TextStyle(fontSize: 15, color: grey)),
                const SizedBox(height: 10),
                for (final wallet in s.wallets)
                  _WalletTile(
                    wallet: wallet,
                    isActive: _isActive(s.type, wallet),
                    onTap: _isActive(s.type, wallet)
                        ? null
                        : () => _switchWallet(s.type, wallet),
                    onEdit: () => _editName(s.type, wallet),
                    onDelete: () => _deleteWallet(s.type, wallet),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Wallet tile ───────────────────────────────────────────────────────────────

class _WalletTile extends StatelessWidget {
  final WalletParams wallet;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WalletTile({
    required this.wallet,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) {},
      confirmDismiss: (dir) async {
        dir == DismissDirection.endToStart ? onDelete() : onEdit();
        return false;
      },
      background: const _SwipeBg(
        color: Colors.blue,
        icon: Icons.edit,
        align: Alignment.centerLeft,
      ),
      secondaryBackground: const _SwipeBg(
        color: Colors.red,
        icon: Icons.delete,
        align: Alignment.centerRight,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      wallet.name,
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive)
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.check,
                          size: 20, color: Colors.white),
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

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment align;

  const _SwipeBg(
      {required this.color, required this.icon, required this.align});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(icon, color: Colors.white),
    );
  }
}
