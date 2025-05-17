import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:flutter/material.dart';

import '../interface/coin.dart';
import 'build_row.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class SelectBlockchain extends StatefulWidget {
  final bool evmOnly;
  final bool removeCoin;
  const SelectBlockchain(
      {Key? key, this.evmOnly = false, this.removeCoin = true})
      : super(key: key);

  @override
  State<SelectBlockchain> createState() => _SelectBlockchainState();
}

class _SelectBlockchainState extends State<SelectBlockchain> {
  final blockchains = ValueNotifier<List<Coin>>([]);
  final searchController = TextEditingController();

  List<Coin> savedCoins = [];

  @override
  void initState() {
    super.initState();

    savedCoins = widget.evmOnly ? evmChains : getAllBlockchains;

    blockchains.value = savedCoins;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.selectBlockchains,
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    onChanged: (String value) {
                      blockchains.value = savedCoins.where((blockchain) {
                        final name = blockchain.getName().toLowerCase();
                        final symbol = blockchain.getSymbol().toLowerCase();
                        final userInput = value.toLowerCase();
                        if (name.contains(userInput) ||
                            symbol.contains(userInput)) {
                          return true;
                        }
                        return false;
                      }).toList();
                    },
                    controller: searchController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 30.0,
                      ),
                      hintText: localization.searchCoin,
                      focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide.none),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide.none),
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide.none), // you
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: blockchains,
                  builder: (context, value, child) {
                    final removeCoins = widget.removeCoin;
                    return Column(
                      children: [
                        for (Coin blockchain in blockchains.value) ...[
                          if (!WalletService.removeCoin(blockchain) ||
                              !removeCoins)
                            InkWell(
                              onTap: () {
                                Navigator.pop(context, blockchain);
                              },
                              child: buildRow(
                                blockchain,
                                isSelected: false,
                              ),
                            )
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
