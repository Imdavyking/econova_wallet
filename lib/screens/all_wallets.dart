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

// ── Wallet section model ──────────────────────────────────────────────────────

class _WalletSection<T extends WalletParams> {
  final String title;
  final WalletType type;
  final List<T> wallets;
  final T? activeWallet;
  final bool Function() isActiveType;

  const _WalletSection({
    required this.title,
    required this.type,
    required this.wallets,
    required this.activeWallet,
    required this.isActiveType,
  });

  bool get isEmpty => wallets.isEmpty;
}

// ── Root widget ───────────────────────────────────────────────────────────────

class AllWallets extends StatefulWidget {
  const AllWallets({super.key});

  @override
  State<AllWallets> createState() => _AllWalletsState();
}

class _AllWalletsState extends State<AllWallets> {
  final _walletNameController = TextEditingController();

  late List<BIP39PhraseOrSeedHEXParams> _mnemonics;
  late List<PrivateKeyParams> _privateKeyWallets;
  late List<ViewKeyParams> _viewOnlyWallets;

  BIP39PhraseOrSeedHEXParams? _currentPhrase;
  PrivateKeyParams? _currentPrivate;
  ViewKeyParams? _currentView;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  void _loadWallets() {
    _mnemonics = WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex)
        as List<BIP39PhraseOrSeedHEXParams>;
    _privateKeyWallets = WalletService.getActiveKeys(WalletType.privateKey)
        as List<PrivateKeyParams>;
    _viewOnlyWallets =
        WalletService.getActiveKeys(WalletType.viewKey) as List<ViewKeyParams>;
    _currentPhrase = WalletService.getActiveKey(WalletType.bip39PhraseOrSeedHex)
        as BIP39PhraseOrSeedHEXParams?;
    _currentPrivate =
        WalletService.getActiveKey(WalletType.privateKey) as PrivateKeyParams?;
    _currentView =
        WalletService.getActiveKey(WalletType.viewKey) as ViewKeyParams?;
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    super.dispose();
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  List<_WalletSection> get _sections => [
        _WalletSection(
          title: 'Seed Phrase Wallets',
          type: WalletType.bip39PhraseOrSeedHex,
          wallets: _mnemonics,
          activeWallet: _currentPhrase,
          isActiveType: WalletService.isBip39PhraseOrSeedHexKey,
        ),
        _WalletSection(
          title: 'Private Key Wallets',
          type: WalletType.privateKey,
          wallets: _privateKeyWallets,
          activeWallet: _currentPrivate,
          isActiveType: WalletService.isPrivateKey,
        ),
        _WalletSection(
          title: 'View-Only Wallets',
          type: WalletType.viewKey,
          wallets: _viewOnlyWallets,
          activeWallet: _currentView,
          isActiveType: WalletService.isViewKey,
        ),
      ];

  // ── Switch wallet ─────────────────────────────────────────────────────────

  Future<void> _switchWallet(WalletType type, WalletParams params) async {
    await WalletService.setType(type);
    await WalletService.setActiveKey(type, params);
    await pref.put(currentUserWalletNameKey, params.name);

    if (type == WalletType.bip39PhraseOrSeedHex) {
      seedPhraseRoot = await compute(
          seedFromMnemonic, (params as BIP39PhraseOrSeedHEXParams).data);
    }

    if (!mounted || !context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Wallet()),
      (r) => false,
    );
  }

  // ── Edit wallet name ──────────────────────────────────────────────────────

  Future<bool> _editWalletName(WalletType type, WalletParams wallet) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final localization = AppLocalizations.of(context)!;

    final result = await AwesomeDialog(
      showCloseIcon: false,
      context: context,
      closeIcon: const Icon(Icons.close),
      onDismissCallback: (_) {},
      autoDismiss: false,
      animType: AnimType.scale,
      dialogType: DialogType.info,
      keyboardAware: true,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(localization.editWalletName),
            const SizedBox(height: 10),
            Material(
              elevation: 0,
              color: Colors.blueGrey.withAlpha(40),
              child: TextFormField(
                controller: _walletNameController..text = wallet.name,
                autofocus: true,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: localization.walletName,
                  prefixIcon: const Icon(Icons.text_fields),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedButton(
              isFixedHeight: false,
              text: localization.ok,
              pressEvent: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final newName = _walletNameController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(localization.enterName,
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ));
                  Navigator.pop(context, false);
                  return;
                }

                // Update in-memory list
                final list = _listForType(type);
                for (final key in list) {
                  if (key == wallet) {
                    key.name = newName;
                    break;
                  }
                }

                await WalletService.editName(type, wallet, newName);

                _mnemonics =
                    WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex)
                        as List<BIP39PhraseOrSeedHEXParams>;

                if (!context.mounted || !mounted) return;
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    ).show();

    return result ?? false;
  }

  // ── Delete wallet ─────────────────────────────────────────────────────────

  Future<bool> _deleteWallet(WalletType type, WalletParams wallet) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final localization = AppLocalizations.of(context)!;

    if (wallet == WalletService.getActiveKey(walletImportType)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(localization.canNotDeleteCurrentWallet,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
      return false;
    }

    final deleted = await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      autoDismiss: false,
      closeIcon: const Icon(Icons.close),
      onDismissCallback: (_) {},
      dismissOnTouchOutside: true,
      title: localization.confirmWalletDelete,
      desc: localization.confirmWalletDeleteDescription,
      btnOkText: localization.delete,
      btnOkColor: Colors.red,
      btnCancelColor: appBackgroundblue.withOpacity(0.5),
      btnCancelOnPress: () => Navigator.pop(context, false),
      btnOkOnPress: () async {
        if (await authenticate(context)) {
          await WalletService.deleteData(type, wallet);
          _listForType(type).removeWhere((e) => e == wallet);
          if (!context.mounted || !mounted) return;
          Navigator.pop(context, true);
        } else {
          if (!context.mounted || !mounted) return;
          Navigator.pop(context, false);
        }
      },
    ).show();

    return deleted ?? false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<WalletParams> _listForType(WalletType type) {
    switch (type) {
      case WalletType.bip39PhraseOrSeedHex:
        return _mnemonics;
      case WalletType.viewKey:
        return _viewOnlyWallets;
      case WalletType.privateKey:
        return _privateKeyWallets;
    }
  }

  bool _isActive(WalletType type, WalletParams wallet) {
    switch (type) {
      case WalletType.bip39PhraseOrSeedHex:
        return _currentPhrase == wallet &&
            WalletService.isBip39PhraseOrSeedHexKey();
      case WalletType.privateKey:
        return _currentPrivate == wallet && WalletService.isPrivateKey();
      case WalletType.viewKey:
        return _currentView == wallet && WalletService.isViewKey();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final visibleSections = _sections.where((s) => !s.isEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(localization.wallet)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < visibleSections.length; i++) ...[
                _WalletSectionView(
                  section: visibleSections[i],
                  isActive: (w) => _isActive(visibleSections[i].type, w),
                  onTap: (w) async {
                    if (_isActive(visibleSections[i].type, w)) return;
                    await _switchWallet(visibleSections[i].type, w);
                  },
                  onEdit: (w) async {
                    final changed =
                        await _editWalletName(visibleSections[i].type, w);
                    if (changed) setState(() {});
                  },
                  onDelete: (w) async {
                    final deleted =
                        await _deleteWallet(visibleSections[i].type, w);
                    if (deleted) setState(() {});
                  },
                ),
                if (i < visibleSections.length - 1) const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wallet section view ───────────────────────────────────────────────────────

class _WalletSectionView extends StatelessWidget {
  final _WalletSection section;
  final bool Function(WalletParams) isActive;
  final Future<void> Function(WalletParams) onTap;
  final Future<void> Function(WalletParams) onEdit;
  final Future<void> Function(WalletParams) onDelete;

  const _WalletSectionView({
    required this.section,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: section.title),
        const SizedBox(height: 10),
        for (final wallet in section.wallets)
          _WalletTile(
            wallet: wallet,
            isActive: isActive(wallet),
            onTap: () => onTap(wallet),
            onEdit: () => onEdit(wallet),
            onDelete: () => onDelete(wallet),
          ),
      ],
    );
  }
}

// ── Wallet tile ───────────────────────────────────────────────────────────────

class _WalletTile extends StatelessWidget {
  final WalletParams wallet;
  final bool isActive;
  final VoidCallback onTap;
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        } else {
          onEdit();
        }
        return false; // never auto-remove; let state handle it
      },
      background: const _SwipeBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const _SwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 70,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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

// ── Swipe background ──────────────────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, color: grey),
    );
  }
}
