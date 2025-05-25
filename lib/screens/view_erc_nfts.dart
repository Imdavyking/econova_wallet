import 'dart:async';

import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/nft_image_webview.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/send_erc_nft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../coins/nfts/erc_nft_coin.dart';
import '../model/erc20_nfts_model.dart';
import '../service/wallet_service.dart';
import '../coins/ethereum_coin.dart';

class ViewErcNFTs extends StatefulWidget {
  final EthereumCoin ethCoin;
  const ViewErcNFTs({
    super.key,
    required this.ethCoin,
  });

  @override
  State<ViewErcNFTs> createState() => _ViewErcNFTsState();
}

class _ViewErcNFTsState extends State<ViewErcNFTs>
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
        title: Text("${widget.ethCoin.name} NFTs"),
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
                      ethCoin: widget.ethCoin,
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
  final EthereumCoin ethCoin;
  const BlockChainNFTs({
    super.key,
    required this.controller,
    required this.ethCoin,
    required this.nftLoaded,
  });

  @override
  State<BlockChainNFTs> createState() => _BlockChainNFTsState();
}

class _BlockChainNFTsState extends State<BlockChainNFTs> {
  late Timer timer;

  List<ERC20NftDetails>? nftData;

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
      final response = await nft.ethCoin.importData(data);
      final allNFTs = await erc20NFTs(
        nft.ethCoin.chainId,
        response.address,
        useCache: useCache,
      );

      if (useCache) useCache = false;

      if (allNFTs['success'] != null && allNFTs['success']) {
        List usrNFt = allNFTs['msg']['ownedNfts'];

        List<ERC20NftDetails> nfts =
            usrNFt.map((x) => ERC20NftDetails.fromMap(x)).toList();

        if (widget.nftLoaded.value == false && nfts.isNotEmpty) {
          widget.nftLoaded.value = true;
        }
        if (nfts.isNotEmpty) {
          nftData = nfts;

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
                height: WalletService.isViewKey() ? 300 : 350,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nftData!.length,
                    itemBuilder: (BuildContext context, int index) {
                      ERC20NftDetails nftDetails = nftData![index];
                      String name = nftDetails.contractMetadata.name ?? 'NFT';
                      String symbol =
                          nftDetails.contractMetadata.symbol ?? 'NFT';
                      BigInt tokenId = nftDetails.id.tokenId;
                      String contractAddress = nftDetails.contract.address;
                      String tokenType =
                          nftDetails.contractMetadata.tokenType ?? '';
                      String description = nftDetails.description ?? '';

                      String balance = nftDetails.balance;
                      String? image = nftDetails.metadata.image;

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
                                  if (image != null && image.isNotEmpty)
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
                                          nft.ethCoin.name,
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
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) => SendERCNFT(
                                                  coin: ERCNFTCoin(
                                                    name: name,
                                                    symbol: symbol,
                                                    tokenId: tokenId,
                                                    contractAddress_:
                                                        contractAddress,
                                                    rpc: nft.ethCoin.rpc,
                                                    chainId:
                                                        nft.ethCoin.chainId,
                                                    coinType:
                                                        nft.ethCoin.coinType,
                                                    default_:
                                                        nft.ethCoin.default_,
                                                    tokenType: tokenType,
                                                    blockExplorer: nft
                                                        .ethCoin.blockExplorer,
                                                    image: '',
                                                  ),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
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
