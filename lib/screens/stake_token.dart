// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../service/wallet_service.dart';
import 'package:pinput/pinput.dart';

class StakeToken extends StatefulWidget {
  final Coin tokenData;
  final String? amount;
  final String? recipient;
  const StakeToken({
    required this.tokenData,
    super.key,
    this.amount,
    this.recipient,
  });

  @override
  _StakeTokenState createState() => _StakeTokenState();
}

class _StakeTokenState extends State<StakeToken> {
  final amountContrl = TextEditingController();
  final memoContrl = TextEditingController();
  bool isLoading = false;
  bool isStaking = true;
  late Coin coin;
  late AppLocalizations localization;

  @override
  void initState() {
    super.initState();
    coin = widget.tokenData;
    amountContrl.setText(widget.amount ?? '');
  }

  @override
  void dispose() {
    amountContrl.dispose();
    memoContrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${isStaking ? localization.stake : localization.unstakeToken} ${coin.getSymbol()}',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton(true, localization.stake),
                  const SizedBox(width: 10),
                  _buildToggleButton(false, localization.unstakeToken),
                ],
              ),
              const SizedBox(height: 30),

              // Amount Input
              TextFormField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: amountContrl,
                decoration: InputDecoration(
                  hintText: localization.amount,
                  suffixIconConstraints: const BoxConstraints(minWidth: 100),
                  suffixIcon: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Text(localization.max),
                    onPressed: () async {
                      final maxTransfer = await coin.getMaxTransfer();
                      amountContrl.text = maxTransfer.toString();
                    },
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Stake/Unstake Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: isStaking
                      ? const Icon(
                          Icons.trending_up,
                          color: Colors.black,
                        )
                      : const Icon(
                          Icons.trending_down,
                          color: Colors.black,
                        ),
                  label: isLoading
                      ? const Loader()
                      : Text(
                          isStaking
                              ? localization.stake
                              : localization.unstakeToken,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(appBackgroundblue),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool stake, String label) {
    final isSelected = stake == isStaking;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() => isStaking = stake);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? appBackgroundblue : Colors.grey[300],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _handleAction() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    FocusManager.instance.primaryFocus?.unfocus();
    final amount = amountContrl.text.trim();
    String? memo = memoContrl.text.trim();

    if (amount.isEmpty || double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            localization.pleaseEnterAmount,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (memo.isEmpty) memo = null;

    if (WalletService.isPharseKey()) {
      await reInstianteSeedRoot();
    }

    setState(() => isLoading = true);

    try {
      final txHash = isStaking
          ? await widget.tokenData.stakeToken(amount)
          : await widget.tokenData.unstakeToken(amount);

      if (txHash == null) throw Exception("Transaction failed");

      if (context.mounted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              isStaking ? localization.stake : localization.unstakeToken,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
      if (context.mounted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              isStaking
                  ? localization.failedToStake
                  : localization.failedToUnStake,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }
}
