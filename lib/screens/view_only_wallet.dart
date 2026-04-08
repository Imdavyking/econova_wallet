import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';
import 'package:wallet_app/components/wallet_name_field.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/qr_scan_view.dart';

class ViewOnlyWallet extends StatefulWidget {
  final Coin coin;
  const ViewOnlyWallet({super.key, required this.coin});

  @override
  State<ViewOnlyWallet> createState() => _ViewOnlyWalletState();
}

class _ViewOnlyWalletState extends State<ViewOnlyWallet> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nameKey = GlobalKey<WalletNameFieldState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final localization = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Real-time field already shows errors; this is the final gate.
    if (!_nameKey.currentState!.validateOnSubmit()) return;

    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      _showError(localization.invalidAddress);
      return;
    }

    try {
      widget.coin.validateAddress(address);
    } catch (_) {
      _showError(localization.invalidAddress);
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final params = ViewKeyParams(
        data: address,
        defaultCoin: widget.coin.getDefault(),
        name: _nameCtrl.text.trim(),
        coinName: widget.coin.getName(),
      );

      // setActiveKey handles setType internally.
      await WalletService.setActiveKey(WalletType.viewKey, params);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Wallet()),
          (_) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('View ${widget.coin.getName()}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-time cross-type duplicate check built in.
              WalletNameField(key: _nameKey, controller: _nameCtrl),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  hintText: '${widget.coin.getName()} ${localization.address}',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () async {
                          final result = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QRScanView(),
                            ),
                          );
                          if (result != null) _addressCtrl.setText(result);
                        },
                      ),
                      InkWell(
                        onTap: () async {
                          final data =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            _addressCtrl.setText(data!.text!);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(localization.paste),
                        ),
                      ),
                    ],
                  ),
                  focusedBorder: _border,
                  border: _border,
                  enabledBorder: _border,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appBackgroundblue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onConfirm,
                  child: Text(
                    localization.confirm,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _border = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide.none,
);
