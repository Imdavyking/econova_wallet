import 'dart:async';

import 'package:wallet_app/coins/nfts/starknet_nft_coin.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/nft_image_webview.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:wallet_app/utils/send_starknet_nft.dart';
import '../service/wallet_service.dart';

class ViewStarknetNFTs extends StatefulWidget {
  final StarknetCoin starknetCoin;
  const ViewStarknetNFTs({
    super.key,
    required this.starknetCoin,
  });

  @override
  State<ViewStarknetNFTs> createState() => _ViewStarknetNFTsState();
}

class _ViewStarknetNFTsState extends State<ViewStarknetNFTs>
    with AutomaticKeepAliveClientMixin {
  bool isLoaded = false;
  ScrollController controller = ScrollController();
  ValueNotifier nftLoaded = ValueNotifier(false);
  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.starknetCoin.name} NFTs"),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: nftLoaded,
                      builder: (context, value, _) {
                        return value == true
                            ? Container()
                            : Text(
                                localization.yourAssetWillAppear,
                                style: const TextStyle(fontSize: 18),
                              );
                      },
                    ),
                    BlockChainNFTs(
                      nftLoaded: nftLoaded,
                      starknetCoin: widget.starknetCoin,
                      controller: controller,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BlockChainNFTs extends StatefulWidget {
  final ValueNotifier nftLoaded;
  final ScrollController controller;
  final StarknetCoin starknetCoin;
  const BlockChainNFTs({
    super.key,
    required this.controller,
    required this.starknetCoin,
    required this.nftLoaded,
  });

  @override
  State<BlockChainNFTs> createState() => _BlockChainNFTsState();
}

class _BlockChainNFTsState extends State<BlockChainNFTs> {
  late Timer timer;

  List<StarknetNFT>? nftData;

  bool useCache = true;
  late ScrollController controller;
  late BlockChainNFTs nft;
  @override
  void initState() {
    super.initState();
    nft = widget;
    controller = widget.controller;
    getAllNFTs();
    timer = Timer.periodic(
      httpPollingDelay,
      (Timer t) async => await getAllNFTs(),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future getAllNFTs() async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final response = await nft.starknetCoin.importData(data);
      final allNFTs =
          await nft.starknetCoin.getStarknetNFTs(address: response.address);

      if (useCache) useCache = false;

      if (allNFTs.isNotEmpty) {
        if (widget.nftLoaded.value == false && allNFTs.isNotEmpty) {
          widget.nftLoaded.value = true;
        }
        if (allNFTs.isNotEmpty) {
          nftData = allNFTs;

          if (mounted) setState(() {});
        }
      }
    } catch (_) {}
  }

  late AppLocalizations localization;
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return nftData == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: WalletService.isViewKey() ? 300 : 370,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nftData!.length,
                    itemBuilder: (BuildContext context, int index) {
                      StarknetNFT nftDetails = nftData![index];
                      String name = nftDetails.contractName;
                      String symbol = nftDetails.contractSymbol;
                      BigInt tokenId = BigInt.parse(nftDetails.tokenId);
                      String contractAddress = nftDetails.contractAddress;
                      String tokenType = nftDetails.contractType;
                      String description = nftDetails.description;

                      String balance = nftDetails.numberOfTokens;
                      String? image = nftDetails.imageUrl;

                      return SizedBox(
                        width: 250,
                        height: 300,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: NotificationListener<OverscrollNotification>(
                              onNotification: (OverscrollNotification value) {
                                if (value.overscroll < 0 &&
                                    controller.offset + value.overscroll <= 0) {
                                  if (controller.offset != 0) {
                                    controller.jumpTo(0);
                                  }
                                  return true;
                                }
                                if (controller.offset + value.overscroll >=
                                    controller.position.maxScrollExtent) {
                                  if (controller.offset !=
                                      controller.position.maxScrollExtent) {
                                    controller.jumpTo(
                                        controller.position.maxScrollExtent);
                                  }
                                  return true;
                                }
                                controller.jumpTo(
                                    controller.offset + value.overscroll);
                                return true;
                              },
                              child: ListView(
                                children: [
                                  if (image.isNotEmpty)
                                    SizedBox(
                                      height: 150,
                                      child: NFTImageWebview(
                                        imageUrl: image,
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: Center(
                                        child: Text(
                                          localization.couldNotFetchData,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    ellipsify(
                                      str: name,
                                      maxLength: 20,
                                    ),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${ellipsify(
                                      str: balance,
                                    )} ${ellipsify(
                                      str: symbol,
                                    )}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ListTileTheme(
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    minLeadingWidth: 0,
                                    contentPadding: const EdgeInsets.all(0),
                                    child: ExpansionTile(
                                      tilePadding:
                                          const EdgeInsets.only(left: 0),
                                      expandedCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      expandedAlignment: Alignment.centerLeft,
                                      title: Text(
                                        tokenType,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      children: [
                                        Text(
                                          localization.tokenId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '#$tokenId',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (description != '') ...[
                                          Text(
                                            localization.description,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.fade,
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          localization.contractAddress,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          contractAddress,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.fade,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          localization.network,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          nft.starknetCoin.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.fade,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  if (!WalletService.isViewKey())
                                    Container(
                                      color: Colors.transparent,
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          textStyle:
                                              WidgetStateProperty.resolveWith(
                                            (states) => const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                            (states) => appBackgroundblue,
                                          ),
                                          shape:
                                              WidgetStateProperty.resolveWith(
                                            (states) => RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            final starkCoinInfo =
                                                nft.starknetCoin;

//                                                 The named parameter 'contractAddress' is required, but there's no corresponding argument.
// Try adding the required argument.dartmissing_required_argument
// The named parameter 'multiCallAddress' is required, but there's no corresponding argument.
// Try adding the required argument.dartmissing_required_argument
// The named parameter 'factoryAddress' is required, but there's no corresponding argument.
// Try adding the required argument.dartmissing_required_argument
// The named parameter 'tokenClassHash' is required, but there's no corresponding argument.
// Try adding the required argument.da
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    SendStarknetNFT(
                                                  coin: StarknetNFTCoin(
                                                    name: name,
                                                    symbol: symbol,
                                                    tokenId: tokenId,
                                                    contractAddress_:
                                                        contractAddress,
                                                    api: starkCoinInfo.api,
                                                    default_:
                                                        starkCoinInfo.default_,
                                                    tokenType: tokenType,
                                                    blockExplorer: starkCoinInfo
                                                        .blockExplorer,
                                                    classHash:
                                                        starkCoinInfo.classHash,
                                                    image: '',
                                                    useStarkToken: starkCoinInfo
                                                        .useStarkToken,
                                                    multiCallAddress:
                                                        starkCoinInfo
                                                            .multiCallAddress,
                                                    factoryAddress:
                                                        starkCoinInfo
                                                            .factoryAddress,
                                                    tokenClassHash:
                                                        starkCoinInfo
                                                            .tokenClassHash,
                                                    contractAddress:
                                                        starkCoinInfo
                                                            .contractAddress,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    e.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          localization.send,
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
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
  }
}
