import 'dart:async';
import 'package:flutter/foundation.dart';

import '../service/wallet_service.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/nft_image_webview.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../coins/nfts/multiv_nft_coin.dart';
import '../coins/multiversx_coin.dart';
import '../model/multix_nfts.dart';
import '../utils/send_multiver_nft.dart';

class ViewMultixNFTs extends StatefulWidget {
  final MultiversxCoin coin;
  const ViewMultixNFTs({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  State<ViewMultixNFTs> createState() => _ViewMultixNFTsState();
}

class _ViewMultixNFTsState extends State<ViewMultixNFTs>
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
        title: Text("${widget.coin.name} NFTs"),
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
                      coin: widget.coin,
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
  final MultiversxCoin coin;
  const BlockChainNFTs({
    Key? key,
    required this.controller,
    required this.coin,
    required this.nftLoaded,
  }) : super(key: key);

  @override
  State<BlockChainNFTs> createState() => _BlockChainNFTsState();
}

class _BlockChainNFTsState extends State<BlockChainNFTs> {
  late Timer timer;

  List<MultiversxNft>? nftData;

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
      final api = nft.coin.nftApi;
      final response = await nft.coin.importData(data);

      final nftsData = await multivrNFT(
        response.address,
        multiversxApi: api!,
        useCache: useCache,
      );

      if (useCache) useCache = false;

      if (nftsData['success'] != null && nftsData['success']) {
        List usrNFt = nftsData['msg'];
        List<MultiversxNft> nfts =
            usrNFt.map((x) => MultiversxNft.fromJson(x)).toList();
        if (nft.nftLoaded.value == false && nfts.isNotEmpty) {
          nft.nftLoaded.value = true;
        }
        if (nfts.isNotEmpty) {
          nftData = nfts;
          if (mounted) setState(() {});
        }
      }
    } catch (_, sk) {
      if (kDebugMode) {
        print(_);
        print(sk);
      }
    }
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
                height: WalletService.isViewKey() ? 290 : 340,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nftData!.length,
                    itemBuilder: (BuildContext context, int index) {
                      MultiversxNft nftDetails = nftData![index];
                      String name = nftDetails.name ?? '';
                      String identifier = nftDetails.identifier;
                      String ticker = nftDetails.ticker;
                      String collection = nftDetails.collection;
                      String description =
                          nftDetails.metadata?.description ?? '';
                      String tokenType = nftDetails.type;
                      int nonce = nftDetails.nonce;
                      String? image;

                      String balance = nftDetails.balance ?? "1";
                      try {
                        image = ipfsTohttp(nftDetails.url);
                      } catch (_) {}

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
                                      str: ticker,
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
                                            '#$identifier',
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
                                          ticker,
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
                                          nft.coin.name,
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
                                            final multivCoin = nft.coin;
                                            final coinDetails =
                                                MultiversxNFTCoin(
                                              ticker: ticker,
                                              identifier: identifier,
                                              description: description,
                                              collection: collection,
                                              balance: double.parse(balance),
                                              nonce: nonce,
                                              rpc: multivCoin.rpc,
                                              blockExplorer:
                                                  multivCoin.blockExplorer,
                                              default_: multivCoin.default_,
                                              symbol: multivCoin.symbol,
                                              image: multivCoin.image,
                                              name: multivCoin.name,
                                              tokenType: MultivNFTType.values
                                                  .byName(tokenType),
                                            );
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    SendMultiversxNFT(
                                                  coin: coinDetails,
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
