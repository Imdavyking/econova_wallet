import 'package:cryptowallet/coins/ethereum_coin.dart';
import 'package:cryptowallet/screens/select_blockchain.dart';
import 'package:cryptowallet/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';

import '../coins/fungible_tokens/erc_fungible_coin.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';
import '../utils/qr_scan_view.dart';

class AddCustomToken extends StatefulWidget {
  const AddCustomToken({Key? key}) : super(key: key);

  @override
  _AddCustomTokenState createState() => _AddCustomTokenState();
}

class _AddCustomTokenState extends State<AddCustomToken> {
  ValueNotifier<EthereumCoin> coinNotifier =
      ValueNotifier<EthereumCoin>(evmChains[0]);
  late AppLocalizations localization;
  @override
  void initState() {
    super.initState();
    contractAddrContrl.addListener(() async {
      await _autoFillNameDecimalSymbol(
        contractAddrContrl.text,
      );
    });
  }

  final contractAddrContrl = TextEditingController();
  final nameContrl = TextEditingController();
  final symbolCtrl = TextEditingController();
  final decimalCtrl = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _emptyInput() {
    nameContrl.setText('');
    symbolCtrl.setText('');
    decimalCtrl.setText('');
  }

  _autoFillNameDecimalSymbol(String contrAddr) async {
    _emptyInput();
    if (contrAddr.isEmpty) return;
    try {
      final coin = ERCFungibleCoin(
        contractAddress_: contrAddr.trim(),
        geckoID: '',
        rpc: coinNotifier.value.rpc,
        blockExplorer: coinNotifier.value.blockExplorer,
        image: coinNotifier.value.image,
        chainId: coinNotifier.value.chainId,
        coinType: coinNotifier.value.coinType,
        default_: coinNotifier.value.default_,
        mintDecimals: 18,
        name: '',
        symbol: '',
      );
      final erc20Details = await coin.getERC20Meta();
      if (erc20Details == null) return;
      nameContrl.setText(erc20Details.name);
      symbolCtrl.setText(erc20Details.symbol);
      decimalCtrl.setText(erc20Details.decimals.toString());
    } catch (_) {}
  }

  @override
  void dispose() {
    contractAddrContrl.dispose();
    nameContrl.dispose();
    symbolCtrl.dispose();
    decimalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          localization.addToken,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.network,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Coin? coin = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const SelectBlockchain(
                              evmOnly: true,
                            ),
                          ),
                        );

                        if (coin == null) return;

                        if (coin is! EthereumCoin) return;

                        coinNotifier.value = coin;
                        _emptyInput();
                      },
                      child: ValueListenableBuilder(
                        valueListenable: coinNotifier,
                        builder: (context, value, child) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              coinNotifier.value.getImage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: contractAddrContrl,
                  decoration: InputDecoration(
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                          ),
                          onPressed: () async {
                            String? contractAddr = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const QRScanView(),
                              ),
                            );
                            if (contractAddr == null) return;
                            contractAddrContrl.setText(contractAddr);
                          },
                        ),
                        InkWell(
                          onTap: () async {
                            ClipboardData? cdata =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            if (cdata == null) return;
                            if (cdata.text == null) return;
                            contractAddrContrl.setText(cdata.text!);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localization.paste,
                            ),
                          ),
                        ),
                      ],
                    ),

                    hintText: localization.enterContractAddress,
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ), // you
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  readOnly: true,
                  controller: nameContrl,
                  decoration: InputDecoration(
                    hintText: localization.name,
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none), // you
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  readOnly: true,
                  controller: symbolCtrl,
                  decoration: InputDecoration(
                    hintText: localization.symbol,
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none), // you
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: decimalCtrl,
                  decoration: InputDecoration(
                    hintText: localization.decimals,
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none), // you
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.red[100],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localization.anyoneCanCreateToken,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          localization.includingScamTokens,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => appBackgroundblue),
                      shape: WidgetStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textStyle: WidgetStateProperty.resolveWith(
                        (states) => const TextStyle(color: Colors.white),
                      ),
                    ),
                    child: Text(
                      localization.done,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      final contractAddr = contractAddrContrl.text.trim();
                      final contractName = nameContrl.text.trim();
                      final contractSymbol = symbolCtrl.text.trim();
                      final contractDecimals = decimalCtrl.text.trim();
                      final decimals = int.tryParse(contractDecimals);
                      bool nameEmpty = contractName.isEmpty;
                      bool decEmpty = contractDecimals.isEmpty;
                      bool symbolEmpty = contractSymbol.isEmpty;
                      bool conAddrEmpty = contractAddr.isEmpty;
                      final coin = coinNotifier.value;

                      if (nameEmpty || decEmpty || symbolEmpty) {
                        await _autoFillNameDecimalSymbol(contractAddr);
                        return;
                      }

                      if (decimals == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.decimals,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      if (conAddrEmpty ||
                          nameEmpty ||
                          decEmpty ||
                          symbolEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.enterContractAddress,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      for (ERCFungibleCoin ercCoin in erc20Coins) {
                        final conAddrLow = contractAddr.toLowerCase();
                        final currAddrlow =
                            ercCoin.tokenAddress().toLowerCase();
                        if (conAddrLow == currAddrlow &&
                            coin.chainId == ercCoin.chainId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                localization.tokenImportedAlready,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      final ethToken = ERCFungibleCoin(
                        contractAddress_: contractAddr,
                        name: contractName,
                        geckoID: '',
                        symbol: contractSymbol,
                        mintDecimals: decimals,
                        chainId: coin.chainId,
                        rpc: coin.rpc,
                        blockExplorer: coin.blockExplorer,
                        coinType: coin.coinType,
                        default_: coin.default_,
                        image: 'assets/ethereum-2.png',
                      );

                      bool added = await ethToken.addCoinToStore();

                      if (!added) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              localization.tokenImportedAlready,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      getAllBlockchains.add(ethToken);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const Wallet(),
                        ),
                        (r) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
