// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/components/testnet_banner.dart';
import 'package:wallet_app/eip/eip681.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/coin_pay.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../interface/coin.dart';
import '../interface/ft_explorer.dart';
import 'launch_url.dart';

class ReceivePayParams {
  final String? requestUrl;
  final String? amount;

  const ReceivePayParams({this.amount, this.requestUrl});
}

class ReceiveToken extends StatefulWidget {
  final Coin coin;
  const ReceiveToken({super.key, required this.coin});

  @override
  _ReceiveTokenState createState() => _ReceiveTokenState();
}

class _ReceiveTokenState extends State<ReceiveToken> {
  final _amountController = TextEditingController();
  final _receiveParams =
      ValueNotifier<ReceivePayParams>(const ReceivePayParams());

  // ← cached once — not recreated on every build
  late final Future<String> _addressFuture;
  String _userAddress = '';
  final size = 250.0;

  late Coin _coin;

  @override
  void initState() {
    super.initState();
    _coin = widget.coin;
    _addressFuture = _coin.getAddress().then((addr) {
      _userAddress = addr;
      return addr;
    });
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _amountController.dispose();
    _receiveParams.dispose();
    super.dispose();
  }

  void _createPayment() {
    FocusManager.instance.primaryFocus?.unfocus();
    final raw = _amountController.text.trim();
    if (double.tryParse(raw) == null) return;

    final amount = Decimal.parse(raw);

    try {
      String? requestUrl;

      if (_coin is EthereumCoin) {
        final eth = _coin as EthereumCoin;
        final power = Decimal.parse('${pow(10, eth.decimals())}');
        requestUrl = EIP681.build(
          targetAddress: _coin.tokenAddress()!,
          chainId: eth.chainId.toString(),
          functionName: 'transfer',
          parameters: {
            'uint256': '${amount * power}',
            'address': _userAddress,
          },
        );
      } else if (_coin is! FTExplorer) {
        requestUrl = CoinPay(
          coinScheme: _coin.getPayScheme(),
          amount: amount.toDouble(),
          recipient: _userAddress,
        ).toUri();
      }

      _receiveParams.value = ReceivePayParams(
        requestUrl: requestUrl,
        amount: '+$raw ${_coin.getSymbol()}',
      );
      _amountController.clear();
    } catch (_) {}
  }

  void _copyAddress() async {
    await Clipboard.setData(ClipboardData(text: _userAddress));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.copiedToClipboard),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.receive} ${_coin.getSymbol()}'),
        actions: [
          IconButton(
            onPressed: () async {
              final url = await _coin.addressExplorer();
              if (!context.mounted) return;
              await launchPageUrl(context: context, url: url);
            },
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Column(
        children: [
          const TestnetBanner(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: FutureBuilder<String>(
                    future: _addressFuture, // ← cached
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      return ValueListenableBuilder<ReceivePayParams>(
                        valueListenable: _receiveParams,
                        builder: (context, params, _) {
                          return Column(
                            children: [
                              // QR code
                              SizedBox(
                                width: 270,
                                height: 270,
                                child: Card(
                                  color: const Color(0xffF1F1F1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        QrImageView(
                                          data:
                                              params.requestUrl ?? _userAddress,
                                          size: size,
                                          gapless:
                                              false, // false leaves a quiet zone so center stays clear
                                          errorCorrectionLevel: QrErrorCorrectLevel
                                              .H, // H gives more redundancy to survive the center cutout
                                        ),
                                        Container(
                                          width: size * 0.22,
                                          height: size * 0.22,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: _coin.getExplorerIdenticon(
                                            params.requestUrl ?? _userAddress,
                                          ), // anything here — identicon, logo, icon
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Tappable address card
                              GestureDetector(
                                onTap: _copyAddress,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: colorForAddress,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      _userAddress,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              if (params.amount != null) Text(params.amount!),
                              const SizedBox(height: 40),
                              Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                    text: l.sendOnly(
                                        '${_coin.getName()} (${_coin.getSymbol()})'),
                                  ),
                                ]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              // Action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _ReceiveAction(
                                    icon: Icons.copy,
                                    label: l.copy,
                                    onTap: _copyAddress,
                                  ),
                                  _ReceiveAction(
                                    icon: Icons.share,
                                    label: l.share,
                                    onTap: () => Share.share(
                                      '${l.publicAddressToReceive} ${_coin.getSymbol()} $_userAddress',
                                    ),
                                  ),
                                  _ReceiveAction(
                                    icon: Icons.add,
                                    label: l.request,
                                    iconBackground: Colors.black,
                                    iconColor: Colors.white,
                                    onTap: () => _showRequestDialog(context, l),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context, AppLocalizations l) {
    AwesomeDialog(
      showCloseIcon: true,
      context: context,
      closeIcon: const Icon(Icons.close),
      animType: AnimType.scale,
      dialogType: DialogType.info,
      keyboardAware: true,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(l.requestPayment),
            const SizedBox(height: 10),
            Material(
              elevation: 0,
              color: Colors.blueGrey.withAlpha(40),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _amountController,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: l.amount,
                  prefixIcon: const Icon(Icons.text_fields),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedButton(
              isFixedHeight: false,
              text: l.ok,
              pressEvent: () {
                _createPayment();
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ).show();
  }
}

// ── Action button component ───────────────────────────────────────────────────

class _ReceiveAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconBackground;
  final Color iconColor;

  const _ReceiveAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackground = appPrimaryColor,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackground,
            ),
            child: Icon(icon, color: iconColor),
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
