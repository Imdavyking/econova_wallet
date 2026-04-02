import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:http/http.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:web3dart/web3dart.dart' as web3;
import '../coins/fungible_tokens/erc_fungible_coin.dart';
import '../components/loader.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import '../utils/slide_up_panel.dart';

Future<void> signTransactionUI({
  required BuildContext context,
  required Function onConfirm,
  required Function()? onReject,
  required String from,
  required int chainId,
  String? gasPriceInWei_,
  String? valueInWei_,
  String? gasInWei_,
  String? txData,
  String? to,
  String? networkIcon,
  String? name,
  String? symbol,
  String? title,
}) async {
  final coin = evmFromChainId(chainId)!;
  final wcClient = web3.Web3Client(coin.rpc, Client());
  final localization = AppLocalizations.of(context)!;

  final value =
      valueInWei_ == null ? 0.0 : BigInt.parse(valueInWei_).toDouble();
  final gasPrice =
      gasPriceInWei_ == null ? 0.0 : BigInt.parse(gasPriceInWei_).toDouble();
  txData ??= '0x';

  double userBalance = 0;
  double transactionFee = 0;
  String message = '';

  final trxDataList = txDataToUintList(txData);
  final decodedFunction = decodeAbi(txData);
  final decodedName = decodedFunction?.name;
  final isSigning = ValueNotifier(false);

  // Cache the future so it isn't recreated on every build
  final detailsFuture = () async {
    userBalance =
        (await wcClient.getBalance(web3.EthereumAddress.fromHex(from)))
            .getInWei
            .toDouble();
    transactionFee = await getEtherTransactionFee(
      coin.rpc,
      trxDataList,
      web3.EthereumAddress.fromHex(from),
      to == null ? null : web3.EthereumAddress.fromHex(to),
      value: value,
      gasPrice: web3.EtherAmount.inWei(BigInt.from(gasPrice)),
    );
    if (decodedFunction == null) return true;
    final decodedResult = decodedFunction.decodedInputs;
    if (decodedName == 'safeBatchTransferFrom') {
      final nftIds = decodedResult[2] as List;
      final nftAmounts = decodedResult[3] as List;
      BigInt total = BigInt.zero;
      for (final a in nftAmounts) total += a as BigInt;
      message =
          '$total ${total == BigInt.one ? 'NFT' : 'NFTs'} (IDs: ${nftIds.join(', ')}) would be sent from ${decodedResult[0]} to ${decodedResult[1]}.';
    } else if (decodedName == 'safeTransferFrom') {
      message =
          'Transfer NFT ${decodedResult[2]} ($to) from ${decodedResult[0]} to ${decodedResult[1]}';
    } else if (decodedName == 'approve') {
      final ftCoin = _ftCoin(to!, coin);
      final meta = await ftCoin.getERC20Meta();
      final amount =
          (decodedResult[1] as BigInt) / BigInt.from(pow(10, meta!.decimals));
      message =
          'Allow ${decodedResult[0]} to spend $amount ${meta.symbol} ($to)';
    } else if (decodedName == 'transfer') {
      final ftCoin = _ftCoin(to!, coin);
      final meta = await ftCoin.getERC20Meta();
      final amount =
          (decodedResult[1] as BigInt) / BigInt.from(pow(10, meta!.decimals));
      message = 'Transfer $amount ${meta.symbol} ($to) to ${decodedResult[0]}';
    } else if (decodedName == 'transferFrom') {
      final ftCoin = _ftCoin(to!, coin);
      final meta = await ftCoin.getERC20Meta();
      final amount =
          (decodedResult[2] as BigInt) / BigInt.from(pow(10, meta!.decimals));
      message =
          'Transfer $amount ${meta.symbol} ($to) from ${decodedResult[0]} to ${decodedResult[1]}';
    }
    return true;
  }();

  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(children: [
        _txHeader(localization.signTransaction, context, onReject),
        const SizedBox(
          height: 50,
          child: TabBar(tabs: [
            Tab(
                icon: Text('Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
            Tab(
                icon: Text('Data',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
            Tab(
                icon: Text('Hex',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt))),
          ]),
        ),
        Expanded(
          child: TabBarView(children: [
            // ── Details tab ──────────────────────────────────────────────
            FutureBuilder(
              future: detailsFuture, // ← cached, not recreated on rebuild
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(localization.couldNotFetchData,
                          style: const TextStyle(fontSize: 16)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Loader());
                }
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (networkIcon != null) _netIcon(networkIcon),
                        if (name != null)
                          Text(name, style: const TextStyle(fontSize: 16)),
                        if (message.isNotEmpty)
                          _txField(localization.info, message),
                        if (to != null)
                          _txField(localization.receipientAddress, to),
                        _txField(localization.balance,
                            '${userBalance / pow(10, etherDecimals)} $symbol'),
                        _txField(localization.transactionAmount,
                            '${value / pow(10, etherDecimals)} $symbol'),
                        _txField(localization.transactionFee,
                            '${transactionFee / pow(10, etherDecimals)} $symbol'),
                        if (transactionFee + value > userBalance)
                          Text(localization.insufficientBalance,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: red,
                                  fontSize: 16)),
                        ValueListenableBuilder<bool>(
                          valueListenable: isSigning,
                          builder: (_, signing, __) {
                            if (signing) {
                              return const Row(children: [Loader()]);
                            }
                            return _evmButtons(context, localization, isSigning,
                                onConfirm, onReject);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Data tab ─────────────────────────────────────────────────
            if (decodedFunction != null)
              SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(localization.functionType,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(decodedFunction.methodId,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            // ── Hex tab ──────────────────────────────────────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Hex',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [
                      Text(txData, style: const TextStyle(fontSize: 16))
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    ),
    canDismiss: false,
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

ERCFungibleCoin _ftCoin(String contractAddress, dynamic coin) =>
    ERCFungibleCoin(
      contractAddress_: contractAddress,
      geckoID: '',
      rpc: coin.rpc,
      blockExplorer: coin.blockExplorer,
      chainId: coin.chainId,
      coinType: coin.coinType,
      image: '',
      default_: coin.default_,
      mintDecimals: 18,
      name: '',
      symbol: '',
    );

// ← context passed explicitly — no more dangling _ctx global
Widget _txHeader(String title, BuildContext context, Function()? onReject) =>
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconButton(
              onPressed: null,
              icon: Icon(Icons.close, color: Colors.transparent)),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) onReject?.call();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );

Widget _txField(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ]),
    );

Widget _netIcon(String url) => SizedBox(
      height: 50,
      width: 50,
      child: CachedNetworkImage(
        imageUrl: ipfsTohttp(url),
        placeholder: (_, __) =>
            const SizedBox(width: 20, height: 20, child: Loader()),
        errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.red),
      ),
    );

Row _evmButtons(
  BuildContext context,
  AppLocalizations loc,
  ValueNotifier<bool> isSigning,
  Function onConfirm,
  Function()? onReject,
) =>
    Row(children: [
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: appBackgroundblue),
          onPressed: () async {
            if (await authenticate(context)) {
              isSigning.value = true;
              try {
                await onConfirm();
              } catch (_) {}
              isSigning.value = false;
            } else {
              onReject?.call();
            }
          },
          child: Text(loc.confirm,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: appBackgroundblue),
          onPressed: onReject,
          child: Text(loc.reject,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    ]);
