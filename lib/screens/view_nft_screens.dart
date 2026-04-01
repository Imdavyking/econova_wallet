import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/coins/multiversx_coin.dart';
import 'package:wallet_app/coins/nfts/erc_nft_coin.dart';
import 'package:wallet_app/coins/nfts/multiv_nft_coin.dart';
import 'package:wallet_app/coins/nfts/starknet_nft_coin.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/model/erc20_nfts_model.dart';
import 'package:wallet_app/model/multix_nfts.dart';
import 'package:wallet_app/screens/nft_list_page.dart';
import 'package:wallet_app/screens/send_form_nft.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import '../service/wallet_service.dart';

// ── ERC NFTs ──────────────────────────────────────────────────────────────────

class ViewErcNFTs extends StatelessWidget {
  final EthereumCoin ethCoin;
  const ViewErcNFTs({super.key, required this.ethCoin});

  @override
  Widget build(BuildContext context) {
    return NftListPage(
      title: '${ethCoin.name} NFTs',
      fetchNfts: (useCache) async {
        final data = WalletService.getActiveKey(walletImportType)!.data;
        final response = await ethCoin.importData(data);
        // ViewErcNFTs
        final result = await erc20NFTs(
          ethCoin.chainId,
          response.address,
          useCache: useCache,
        );
        if (!result.isOk) return [];
        final list = result.value.data['ownedNfts'] as List;
        return list.map((x) {
          final nft = ERC20NftDetails.fromMap(x);
          return NftCardData(
            name: nft.contractMetadata.name ?? 'NFT',
            symbol: nft.contractMetadata.symbol ?? 'NFT',
            balance: nft.balance,
            tokenId: nft.id.tokenId.toString(),
            contractAddress: nft.contract.address,
            tokenType: nft.contractMetadata.tokenType ?? '',
            description: nft.description ?? '',
            network: ethCoin.name,
            imageUrl: nft.metadata.image,
          );
        }).toList();
      },
      buildCard: (data, ctrl) => NftCard(
        data: data,
        pageController: ctrl,
        onSend:
            WalletService.isViewKey() ? null : () => _sendErc(context, data),
      ),
    );
  }

  void _sendErc(BuildContext context, NftCardData data) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SendERCNFT(
            coin: ERCNFTCoin(
              name: data.name,
              symbol: data.symbol,
              tokenId: BigInt.parse(data.tokenId.replaceFirst('#', '')),
              contractAddress_: data.contractAddress,
              rpc: ethCoin.rpc,
              chainId: ethCoin.chainId,
              coinType: ethCoin.coinType,
              default_: ethCoin.default_,
              tokenType: data.tokenType,
              blockExplorer: ethCoin.blockExplorer,
              image: '',
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }
}

// ── Multiversx NFTs ───────────────────────────────────────────────────────────

class ViewMultixNFTs extends StatelessWidget {
  final MultiversxCoin coin;
  const ViewMultixNFTs({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return NftListPage(
      title: '${coin.name} NFTs',
      cardHeight: 340,
      fetchNfts: (useCache) async {
        final data = WalletService.getActiveKey(walletImportType)!.data;
        final response = await coin.importData(data);
        final result = await multivrNFT(
          response.address,
          multiversxApi: coin.nftApi!,
          useCache: useCache,
        );
        if (!result.isOk) return [];
        final list = result.value.items;
        return list.map((x) {
          final nft = MultiversxNft.fromJson(x);
          String? image;
          try {
            image = ipfsTohttp(nft.url);
          } catch (_) {}
          return NftCardData(
            name: nft.name ?? '',
            symbol: nft.ticker,
            balance: nft.balance ?? '1',
            tokenId: nft.identifier,
            contractAddress: nft.ticker,
            tokenType: nft.type,
            description: nft.metadata?.description ?? '',
            network: coin.name,
            imageUrl: image,
          );
        }).toList();
      },
      buildCard: (data, ctrl) => NftCard(
        data: data,
        pageController: ctrl,
        onSend:
            WalletService.isViewKey() ? null : () => _sendMultix(context, data),
      ),
    );
  }

  void _sendMultix(BuildContext context, NftCardData data) async {
    try {
      final coinDetails = MultiversxNFTCoin(
        ticker: data.symbol,
        identifier: data.tokenId,
        description: data.description,
        collection: data.contractAddress,
        caipReference: '',
        balance: double.tryParse(data.balance) ?? 1,
        nonce: 0,
        rpc: coin.rpc,
        blockExplorer: coin.blockExplorer,
        default_: coin.default_,
        symbol: coin.symbol,
        image: coin.image,
        name: coin.name,
        tokenType: MultivNFTType.values.byName(data.tokenType),
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SendMultiversxNFT(coin: coinDetails)),
      );
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }
}

// ── Starknet NFTs ─────────────────────────────────────────────────────────────

class ViewStarknetNFTs extends StatelessWidget {
  final StarknetCoin starknetCoin;
  const ViewStarknetNFTs({super.key, required this.starknetCoin});

  @override
  Widget build(BuildContext context) {
    return NftListPage(
      title: '${starknetCoin.name} NFTs',
      cardHeight: 370,
      fetchNfts: (useCache) async {
        final data = WalletService.getActiveKey(walletImportType)!.data;
        final response = await starknetCoin.importData(data);
        final nfts = await starknetCoin.getStarknetNFTs(
          address: response.address,
          useCache: useCache,
        );
        return nfts
            .map((nft) => NftCardData(
                  name: nft.contractName,
                  symbol: nft.contractSymbol,
                  balance: nft.numberOfTokens,
                  tokenId: nft.tokenId,
                  contractAddress: nft.contractAddress,
                  tokenType: nft.contractType,
                  description: nft.description,
                  network: starknetCoin.name,
                  imageUrl: nft.imageUrl,
                ))
            .toList();
      },
      buildCard: (data, ctrl) => NftCard(
        data: data,
        pageController: ctrl,
        onSend: WalletService.isViewKey()
            ? null
            : () => _sendStarknet(context, data),
      ),
    );
  }

  void _sendStarknet(BuildContext context, NftCardData data) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SendStarknetNFT(
            coin: StarknetNFTCoin(
              name: data.name,
              symbol: data.symbol,
              tokenId: BigInt.parse(data.tokenId.replaceFirst('#', '')),
              contractAddress_: data.contractAddress,
              api: starknetCoin.api,
              default_: starknetCoin.default_,
              tokenType: data.tokenType.toUpperCase(),
              blockExplorer: starknetCoin.blockExplorer,
              classHash: starknetCoin.classHash,
              caipReference: '',
              image: '',
              useStarkToken: starknetCoin.useStarkToken,
              multiCallAddress: starknetCoin.multiCallAddress,
              factoryAddress: starknetCoin.factoryAddress,
              tokenClassHash: starknetCoin.tokenClassHash,
              tokenContractAddress: starknetCoin.tokenContractAddress,
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }
}

// ── Shared error snackbar ─────────────────────────────────────────────────────

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(message, style: const TextStyle(color: Colors.white)),
  ));
}
