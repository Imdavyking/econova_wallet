import 'package:flutter/material.dart';
import 'package:wallet_app/main.dart';
import '../interface/coin.dart';
import 'build_row.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class SelectBlockchain extends StatefulWidget {
  /// Filter to select which coins to show (e.g. only EVM coins)
  final bool Function(Coin coin) filterFn;

  const SelectBlockchain({
    super.key,
    required this.filterFn,
  });

  @override
  State<SelectBlockchain> createState() => _SelectBlockchainState();
}

class _SelectBlockchainState extends State<SelectBlockchain> {
  final blockchains = ValueNotifier<List<Coin>>([]);
  final searchController = TextEditingController();

  late final List<Coin> filteredCoins;

  @override
  void initState() {
    super.initState();

    // Apply the external filterFn once at init
    filteredCoins = supportedChains.where(widget.filterFn).toList();
    blockchains.value = filteredCoins;
  }

  void _handleSearch(String query) {
    final q = query.toLowerCase();
    blockchains.value = filteredCoins.where((coin) {
      return coin.getName().toLowerCase().contains(q) ||
          coin.getSymbol().toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.selectBlockchains),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: searchController,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: localization.searchCoin,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<List<Coin>>(
                valueListenable: blockchains,
                builder: (context, value, _) {
                  return Column(
                    children: value.map((coin) {
                      return InkWell(
                        onTap: () => Navigator.pop(context, coin),
                        child: buildRow(coin, isSelected: false),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
