// ignore_for_file: library_private_types_in_public_api

import 'package:wallet_app/api/notification_api.dart';
import 'package:wallet_app/coins/nfts/erc_nft_coin.dart';
import 'package:wallet_app/coins/nfts/multiv_nft_coin.dart';
import 'package:wallet_app/coins/nfts/starknet_nft_coin.dart';
import 'package:wallet_app/screens/confirm_transfer_scaffold.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

// ── ERC NFT ───────────────────────────────────────────────────────────────────

class ConfirmERCNFTTransfer extends StatelessWidget {
  final ERCNFTCoin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;

  const ConfirmERCNFTTransfer({
    super.key,
    required this.coin,
    this.cryptoDomain,
    required this.recipient,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ConfirmTransferScaffold(
      coin: coin,
      amount: amount,
      recipient: recipient,
      onSend: () => coin.transferToken(amount, recipient),
      onSuccess: ({required txHash}) async {
        NotificationApi.showNotification(
          title: '${coin.getSymbol()} Sent',
          body: '#${coin.tokenId} ${coin.getSymbol()} sent to $recipient',
        );
      },
      rows: [
        TransferInfoRow(
          label: l.asset,
          value: Text(
            '${ellipsify(str: coin.getName())} (${ellipsify(str: coin.getSymbol())})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferFromRow(coin: coin, label: l.from),
        TransferInfoRow(
          label: l.to,
          value: Text(
            cryptoDomain != null ? '$cryptoDomain ($recipient)' : recipient,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferInfoRow(
          label: l.tokenId,
          value: Text('${coin.tokenId}', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

// ── Multiversx NFT ────────────────────────────────────────────────────────────

class ConfirmMultiversxNFTTransfer extends StatelessWidget {
  final MultiversxNFTCoin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;

  const ConfirmMultiversxNFTTransfer({
    super.key,
    required this.coin,
    this.cryptoDomain,
    required this.recipient,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ConfirmTransferScaffold(
      coin: coin,
      amount: amount,
      recipient: recipient,
      onSend: () => coin.transferToken(amount, recipient),
      onSuccess: ({required txHash}) async {
        NotificationApi.showNotification(
          title: '${coin.getSymbol()} Sent',
          body: '#${coin.identifier} ${coin.getSymbol()} sent to $recipient',
        );
      },
      rows: [
        TransferInfoRow(
          label: l.asset,
          value: Text(
            '${ellipsify(str: coin.ticker)} (${ellipsify(str: coin.identifier)})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferFromRow(coin: coin, label: l.from),
        TransferInfoRow(
          label: l.to,
          value: Text(
            cryptoDomain != null ? '$cryptoDomain ($recipient)' : recipient,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferInfoRow(
          label: l.tokenId,
          value: Text(coin.identifier, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

// ── Starknet NFT ──────────────────────────────────────────────────────────────

class ConfirmStarknetNFTTransfer extends StatelessWidget {
  final StarknetNFTCoin coin;
  final String? cryptoDomain;
  final String recipient;
  final String amount;

  const ConfirmStarknetNFTTransfer({
    super.key,
    required this.coin,
    this.cryptoDomain,
    required this.recipient,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ConfirmTransferScaffold(
      coin: coin,
      amount: amount,
      recipient: recipient,
      onSend: () => coin.transferToken(amount, recipient),
      onSuccess: ({required txHash}) async {
        NotificationApi.showNotification(
          title: '${coin.getSymbol()} Sent',
          body: '#${coin.tokenId} ${coin.getSymbol()} sent to $recipient',
        );
      },
      rows: [
        TransferInfoRow(
          label: l.asset,
          value: Text(
            '${ellipsify(str: coin.getName())} (${ellipsify(str: coin.getSymbol())})',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferFromRow(coin: coin, label: l.from),
        TransferInfoRow(
          label: l.to,
          value: Text(
            cryptoDomain != null ? '$cryptoDomain ($recipient)' : recipient,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TransferInfoRow(
          label: l.tokenId,
          value: Text('${coin.tokenId}', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
