import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/screens/navigator_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3dart/web3dart.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' hide Wallet;
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../interface/coin.dart';
import '../../screens/select_blockchain.dart';
import '../../service/wallet_connect_service.dart';
import '../../service/wallet_service.dart';
import '../../main.dart';

class WcConnectorV1 {
  late BuildContext context;
  static late WCClient wcClient;

  WcConnectorV1() {
    context = NavigationService.navigatorKey.currentContext!;
    wcClient = WCClient(
      onSessionRequest: _onSessionRequest,
      onFailure: _onSessionError,
      onDisconnect: _onSessionClosed,
      onEthSign: _onSign,
      onEthSignTransaction: _onSignTransaction,
      onEthSendTransaction: _onSendTransaction,
      onCustomRequest: (int id, String request) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('id $id request $request.'),
        ));
      },
      onWalletSwitchNetwork: _onSwitchNetwork,
    );
    WCService.wcReconnectV1();
  }

  void _onSessionRequest(int id, WCPeerMeta peerMeta) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        final AppLocalizations localization = AppLocalizations.of(context)!;
        return SimpleDialog(
          title: Column(
            children: [
              WCDappIcon(
                iconUrl: peerMeta.icons.isNotEmpty ? peerMeta.icons[0] : null,
                size: 100,
              ),
              const SizedBox(height: 8),
              Text(peerMeta.name),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            if (peerMeta.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(peerMeta.description),
              ),
            if (peerMeta.url.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('${localization.connectedTo} ${peerMeta.url}'),
              ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      try {
                        final Coin? coin = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => SelectBlockchain(
                              filterFn: (coin) =>
                                  coin is EthereumCoin &&
                                  coin.tokenAddress() == null,
                            ),
                          ),
                        );

                        if (coin is EthereumCoin) {
                          final walletData =
                              WalletService.getActiveKey(walletImportType)!
                                  .data;
                          final response = await coin.importData(walletData);
                          wcClient.approveSession(
                            accounts: [response.address],
                            chainId: coin.chainId,
                          );
                          await WCService.saveSessionV1(
                            WCSessionAddr(
                              sessionStore: wcClient.sessionStore,
                              address: response.address,
                              date: DateTime.now().microsecondsSinceEpoch,
                            ),
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        wcClient.rejectSession();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(localization.confirm),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      wcClient.rejectSession();
                      Navigator.pop(context);
                    },
                    child: Text(localization.reject),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onSessionError(dynamic message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        final AppLocalizations localization = AppLocalizations.of(context)!;
        return SimpleDialog(
          title: Text(localization.error),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('${localization.someErrorOccured}. $message'),
            ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(localization.close),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onSessionClosed(int? code, String? reason) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        final AppLocalizations localization = AppLocalizations.of(context)!;
        return SimpleDialog(
          title: Text(localization.sessionEnded),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child:
                  Text('${localization.someErrorOccured}. ERROR CODE: $code'),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('${localization.failureReason}: $reason'),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(localization.close),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onSignTransaction(
    int id,
    WCEthereumTransaction ethereumTransaction,
  ) {
    final AppLocalizations localization = AppLocalizations.of(context)!;
    _onTransaction(
      id: id,
      ethereumTransaction: ethereumTransaction,
      title: localization.signTransaction,
      onConfirm: () async {
        try {
          final EthereumCoin coin = evmFromChainId(wcClient.chainId!)!;
          final walletData = WalletService.getActiveKey(walletImportType)!.data;
          final response = await coin.importData(walletData);
          final String privateKey = response.privateKey!;
          final Web3Client web3client = Web3Client(coin.rpc, http.Client());
          final creds = EthPrivateKey.fromHex(privateKey);
          final tx = await web3client.signTransaction(
            creds,
            wcEthTxToWeb3Tx(ethereumTransaction),
            chainId: wcClient.chainId,
          );
          wcClient.approveRequest<String>(
            id: id,
            result: bytesToHex(tx, include0x: true),
          );
        } catch (e) {
          wcClient.rejectRequest(id: id);
        } finally {
          if (context.mounted) Navigator.pop(context);
        }
      },
      onReject: () {
        wcClient.rejectRequest(id: id);
        Navigator.pop(context);
      },
    );
  }

  void _onSwitchNetwork(int id, int chainIdNew) async {
    if (wcClient.chainId == chainIdNew) {
      wcClient.rejectRequest(id: id);
      return;
    }

    final currentChain = evmFromChainId(wcClient.chainId!);
    final switchChain = evmFromChainId(chainIdNew);

    if (currentChain == null || switchChain == null) {
      wcClient.rejectRequest(id: id);
      return;
    }

    switchEthereumChain(
      context: context,
      currentChain: currentChain,
      switchChain: switchChain,
      onConfirm: () async {
        await wcClient.updateSession(chainId: chainIdNew);
        wcClient.approveRequest<void>(id: id, result: null);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Changed network to $chainIdNew.')),
        );
        Navigator.pop(context);
      },
      onReject: () async {
        wcClient.rejectRequest(id: id);
        Navigator.pop(context);
      },
    );
  }

  void _onSendTransaction(
    int id,
    WCEthereumTransaction ethereumTransaction,
  ) {
    final AppLocalizations localization = AppLocalizations.of(context)!;
    _onTransaction(
      id: id,
      ethereumTransaction: ethereumTransaction,
      title: localization.sendTransaction,
      onConfirm: () async {
        try {
          final EthereumCoin coin = evmFromChainId(wcClient.chainId!)!;
          final walletData = WalletService.getActiveKey(walletImportType)!.data;
          final response = await coin.importData(walletData);
          final String privateKey = response.privateKey!;
          final creds = EthPrivateKey.fromHex(privateKey);
          final Web3Client web3client = Web3Client(coin.rpc, http.Client());
          final txhash = await web3client.sendTransaction(
            creds,
            wcEthTxToWeb3Tx(ethereumTransaction),
            chainId: wcClient.chainId,
          );
          debugPrint('txhash $txhash');
          wcClient.approveRequest<String>(id: id, result: txhash);
        } catch (e) {
          wcClient.rejectRequest(id: id);
        } finally {
          if (context.mounted) Navigator.pop(context);
        }
      },
      onReject: () {
        wcClient.rejectRequest(id: id);
        Navigator.pop(context);
      },
    );
  }

  void _onTransaction({
    required int id,
    required WCEthereumTransaction ethereumTransaction,
    required String title,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) async {
    final List icons = wcClient.remotePeerMeta!.icons;
    await signTransactionUI(
      gasPriceInWei_: ethereumTransaction.gasPrice,
      to: ethereumTransaction.to,
      from: ethereumTransaction.from,
      txData: ethereumTransaction.data,
      valueInWei_: ethereumTransaction.value,
      gasInWei_: ethereumTransaction.gas,
      networkIcon: icons.isNotEmpty ? icons[0] as String : null,
      context: context,
      symbol: evmFromChainId(wcClient.chainId!)?.getSymbol(),
      name: wcClient.remotePeerMeta!.name,
      onConfirm: onConfirm,
      onReject: onReject,
      title: title,
      chainId: wcClient.chainId!,
    );
  }

  void _onSign(
    int id,
    WCEthereumSignMessage ethereumSignMessage,
  ) async {
    final List icon = wcClient.remotePeerMeta!.icons;
    String messageType = '';
    if (ethereumSignMessage.type == WCSignType.PERSONAL_MESSAGE) {
      messageType = personalSignKey;
    } else if (ethereumSignMessage.type == WCSignType.MESSAGE) {
      messageType = normalSignKey;
    } else if (ethereumSignMessage.type == WCSignType.TYPED_MESSAGE) {
      messageType = typedMessageSignKey;
    }

    await signMessage(
      messageType: messageType,
      context: context,
      data: ethereumSignMessage.data,
      networkIcon: icon.isNotEmpty ? icon[0] as String : null,
      name: wcClient.remotePeerMeta?.name,
      onConfirm: () async {
        final EthereumCoin coin = evmFromChainId(wcClient.chainId!)!;
        final walletData = WalletService.getActiveKey(walletImportType)!.data;
        final response = await coin.importData(walletData);
        final String privateKey = response.privateKey!;
        late String signedDataHex;
        final credentials = EthPrivateKey.fromHex(privateKey);

        if (ethereumSignMessage.type == WCSignType.TYPED_MESSAGE) {
          signedDataHex = EthSigUtil.signTypedData(
            privateKey: privateKey,
            jsonData: ethereumSignMessage.data!,
            version: TypedDataVersion.V4,
          );
        } else if (ethereumSignMessage.type == WCSignType.PERSONAL_MESSAGE) {
          final Uint8List signedData =
              credentials.signPersonalMessageToUint8List(
            txDataToUintList(ethereumSignMessage.data!),
          );
          signedDataHex = bytesToHex(signedData, include0x: true);
        } else if (ethereumSignMessage.type == WCSignType.MESSAGE) {
          try {
            signedDataHex = EthSigUtil.signMessage(
              privateKey: privateKey,
              message: txDataToUintList(ethereumSignMessage.data!),
            );
          } catch (e) {
            final Uint8List signedData =
                credentials.signPersonalMessageToUint8List(
              txDataToUintList(ethereumSignMessage.data!),
            );
            signedDataHex = bytesToHex(signedData, include0x: true);
          }
        }

        debugPrint('SIGNED $signedDataHex');
        wcClient.approveRequest<String>(id: id, result: signedDataHex);
        if (context.mounted) Navigator.pop(context);
      },
      onReject: () {
        wcClient.rejectRequest(id: id);
        Navigator.pop(context);
      },
    );
  }
}
