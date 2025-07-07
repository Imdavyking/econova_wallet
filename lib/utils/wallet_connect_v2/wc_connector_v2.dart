// ignore_for_file: constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/screens/navigator_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/wallet_connect_v2/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:wallet_app/utils/wallet_connect_v2/models/ethereum/wc_ethereum_transaction.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/logger/logger.dart';
import 'package:web3dart/web3dart.dart';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' hide Wallet;
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../components/loader.dart';
import '../../interface/coin.dart';
import '../../screens/build_row.dart';
import '../../service/wallet_service.dart';
import '../../main.dart';

class EIP155WC {
  static const String name = 'eip155';
}

class WCRequestResponse {
  SessionNamespace namespace;
  List<Coin> coins;
  WCRequestResponse({
    required this.namespace,
    required this.coins,
  });
}

enum Eip155Events {
  CHAIN_CHANGED,
  ACCOUNTS_CHANGED,
}

enum Eip155Methods {
  PERSONAL_SIGN,
  ETH_SIGN,
  ETH_SIGN_TRANSACTION,
  ETH_SIGN_TYPED_DATA,
  ETH_SIGN_TYPED_DATA_V3,
  ETH_SIGN_TYPED_DATA_V4,
  ETH_SEND_RAW_TRANSACTION,
  ETH_SEND_TRANSACTION,
}

final Map<Eip155Methods, String> ethMethods = {
  Eip155Methods.PERSONAL_SIGN: 'personal_sign',
  Eip155Methods.ETH_SIGN: 'eth_sign',
  Eip155Methods.ETH_SIGN_TRANSACTION: 'eth_signTransaction',
  Eip155Methods.ETH_SIGN_TYPED_DATA: 'eth_signTypedData',
  Eip155Methods.ETH_SIGN_TYPED_DATA_V3: 'eth_signTypedData_v3',
  Eip155Methods.ETH_SIGN_TYPED_DATA_V4: 'eth_signTypedData_v4',
  Eip155Methods.ETH_SEND_RAW_TRANSACTION: 'eth_sendRawTransaction',
  Eip155Methods.ETH_SEND_TRANSACTION: 'eth_sendTransaction'
};

enum SolanaMethods { SOLANA_SIGN_TRANSACTION, SOLANA_SIGN_MESSAGE }

final Map<SolanaMethods, String> solanaMethods = {
  SolanaMethods.SOLANA_SIGN_TRANSACTION: 'solana_signTransaction',
  SolanaMethods.SOLANA_SIGN_MESSAGE: 'solana_signMessage'
};

extension Eip155MethodsStringX on String {
  Eip155Methods? toEip155Method() {
    final entries =
        ethMethods.entries.where((element) => element.value == this);
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

final Map<Eip155Events, String> events = {
  Eip155Events.CHAIN_CHANGED: 'chainChanged',
  Eip155Events.ACCOUNTS_CHANGED: 'accountsChanged',
};

class WcConnectorV2 {
  late BuildContext context;
  static late SignClient signClient;
  static String connEvent = 'connectedDapp';

  WcConnectorV2() {
    context = NavigationService.navigatorKey.currentContext!;
    init();
  }

  void log(dynamic value) {
    debugPrint(value.toString());
  }

  Future<void> init() async {
    const wcEndpoint = 'wss://relay.walletconnect.com';
    final channel = WebSocketChannel.connect(Uri.parse(wcEndpoint));
    await channel.ready.timeout(const Duration(seconds: 3));
    await channel.sink.close();
    signClient = await SignClient.init(
      projectId: walletConnectKey,
      relayUrl: wcEndpoint,
      metadata: const AppMetadata(
        name: walletName,
        url: walletURL,
        description: walletAbbr,
        icons: [walletIconURL],
      ),
      database: 'wallet.db',
      logger: Logger(
        filter: ProductionFilter(),
        level: Level.nothing,
      ),
    );

    signClient.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionPropose>;
      log('SESSION_PROPOSAL: $eventData');

      _onSessionRequest(eventData.id!, eventData.params!);
    });

    signClient.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionRequest>;
      log('SESSION_REQUEST: $eventData');
      final session = signClient.session.get(eventData.topic!);

      switch (eventData.params!.request.method.toEip155Method()) {
        case Eip155Methods.PERSONAL_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[0];
          final address = requestParams[1];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.PERSONAL_MESSAGE,
          );
          return _onSign(eventData, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.MESSAGE,
          );
          return _onSign(eventData, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(eventData, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V3:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V3,
          );
          return _onSign(eventData, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V4:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(eventData, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSignTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSendTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_RAW_TRANSACTION:
          break;
        default:
          debugPrint('Unsupported request.');
      }
    });

    signClient.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      log('SESSION_EVENT: $eventData');
    });

    signClient.on(SignClientEvent.SESSION_PING.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_PING: $eventData');
    });

    signClient.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_DELETE: $eventData');
      _onSessionClosed(9999, 'Ended.');
    });
  }

  Future<WCRequestResponse> _handleEIP155(
    MapEntry<String, ProposalRequiredNamespace> entry,
  ) async {
    List<EthereumCoin> ethCoins = [];
    final data = WalletService.getActiveKey(walletImportType)!.data;
    List<String> accounts = [];
    List<String> chainIds = entry.value.chains;

    for (String ids in chainIds) {
      final chainID = int.parse(ids.split(':').last);

      EthereumCoin? ethCoin = evmFromChainId(chainID);
      if (ethCoin == null) continue;
      final response = await ethCoin.importData(data);

      accounts.add(
        '${EIP155WC.name}:${ethCoin.chainId}:${response.address}',
      );

      ethCoins.add(ethCoin);
    }

    return WCRequestResponse(
      coins: ethCoins,
      namespace: SessionNamespace(
        accounts: accounts,
        methods: [
          "eth_sendTransaction",
          "eth_signTransaction",
          "eth_sign",
          "personal_sign",
          "eth_signTypedData",
        ],
        events: ["chainChanged", "accountsChanged"],
      ),
    );
  }

  Future<void> _onSessionRequest(int id, RequestSessionPropose proposal) async {
    final metadata = proposal.proposer.metadata;
    final entries = proposal.requiredNamespaces.entries;
    Map<String, SessionNamespace> namespaces = {};

    List<Widget> coinWidgets = [];

    SdkErrorKey? error;

    for (var entry in entries) {
      if (entry.key == EIP155WC.name) {
        WCRequestResponse ethCoins = await _handleEIP155(entry);
        if (entry.value.chains.length != ethCoins.coins.length) {
          error = SdkErrorKey.UNSUPPORTED_CHAINS;
          break;
        }
        namespaces[entry.key] = ethCoins.namespace;
        coinWidgets.addAll(
          ethCoins.coins.map(
            (e) => buildRow(e, isSelected: true),
          ),
        );
      } else {
        error = SdkErrorKey.UNSUPPORTED_ACCOUNTS;
        break;
      }
    }

    if (error != null) {
      signClient.reject(
        SessionRejectParams(
          id: id,
          reason: getSdkError(error),
        ),
      );
      return;
    }

    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          AppLocalizations localization = AppLocalizations.of(context)!;
          return SimpleDialog(
            title: Column(
              children: [
                if (metadata.icons.isNotEmpty)
                  Container(
                    height: 100.0,
                    width: 100.0,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: ipfsTohttp(metadata.icons.first),
                      placeholder: (context, url) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Loader(
                              color: appPrimaryColor,
                            ),
                          )
                        ],
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                Text(metadata.name),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
            children: [
              if (metadata.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(metadata.description),
                ),
              if (metadata.url.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('${localization.connectedTo} ${metadata.url}'),
                ),
              if (coinWidgets.isNotEmpty) ...coinWidgets,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () async {
                        try {
                          final params = SessionApproveParams(
                            id: id,
                            namespaces: namespaces,
                          );
                          await signClient.approve(params);

                          signClient.events.emit(WcConnectorV2.connEvent);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (_) {
                          signClient.reject(
                            SessionRejectParams(
                              id: id,
                              reason:
                                  getSdkError(SdkErrorKey.USER_DISCONNECTED),
                            ),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(localization.confirm),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        signClient.reject(
                          SessionRejectParams(
                            id: id,
                            reason: getSdkError(SdkErrorKey.USER_DISCONNECTED),
                          ),
                        );
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
  }

  _onSessionClosed(int? code, String? reason) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        AppLocalizations localization = AppLocalizations.of(context)!;
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(localization.close),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSignTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    _onTransaction(
      id: id,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: localization.signTransaction,
      chainId: chainId,
      onConfirm: () async {
        try {
          EthereumCoin coin = evmFromChainId(chainId)!;
          final walletData = WalletService.getActiveKey(walletImportType)!.data;
          final response = await coin.importData(walletData);
          String privateKey = response.privateKey!;
          Web3Client web3client = Web3Client(
            coin.rpc,
            http.Client(),
          );
          final creds = EthPrivateKey.fromHex(privateKey);
          final tx = await web3client.signTransaction(
            creds,
            wcEthTxToWeb3Tx(ethereumTransaction),
            chainId: chainId,
          );

          signClient.respond(
            SessionRespondParams(
              topic: session.topic,
              response: JsonRpcResult<String>(
                id: id,
                result: bytesToHex(
                  tx,
                  include0x: true,
                ),
              ),
            ),
          );
        } catch (e) {
          signClient.respond(
            SessionRespondParams(
              topic: session.topic,
              response: JsonRpcError(id: id),
            ),
          );
        } finally {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      onReject: () {
        signClient.respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcError(id: id),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  _onSendTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    _onTransaction(
      id: id,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: localization.sendTransaction,
      onConfirm: () async {
        try {
          EthereumCoin coin = evmFromChainId(chainId)!;
          final walletData = WalletService.getActiveKey(walletImportType)!.data;
          final response = await coin.importData(walletData);
          String privateKey = response.privateKey!;
          final creds = EthPrivateKey.fromHex(privateKey);
          Web3Client web3client = Web3Client(
            coin.rpc,
            http.Client(),
          );
          final txhash = await web3client.sendTransaction(
            creds,
            wcEthTxToWeb3Tx(ethereumTransaction),
            chainId: chainId,
          );
          debugPrint('txhash $txhash');

          signClient.respond(
            SessionRespondParams(
              topic: session.topic,
              response: JsonRpcResult<String>(
                id: id,
                result: txhash,
              ),
            ),
          );
        } catch (e) {
          signClient.respond(
            SessionRespondParams(
              topic: session.topic,
              response: JsonRpcError(id: id),
            ),
          );
        } finally {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      onReject: () {
        signClient.respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcError(id: id),
          ),
        );
        Navigator.pop(context);
      },
      chainId: chainId,
    );
  }

  _onTransaction({
    required int id,
    required SessionStruct session,
    required WCEthereumTransaction ethereumTransaction,
    required String title,
    required int chainId,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) async {
    List icons = session.peer.metadata.icons;

    await signEVMTransaction(
      gasPriceInWei_: ethereumTransaction.gasPrice,
      to: ethereumTransaction.to,
      from: ethereumTransaction.from,
      txData: ethereumTransaction.data,
      valueInWei_: ethereumTransaction.value,
      gasInWei_: ethereumTransaction.gas,
      networkIcon: icons.isNotEmpty ? icons[0] : null,
      context: context,
      symbol: evmFromChainId(chainId)?.getSymbol(),
      name: session.peer.metadata.name,
      onConfirm: onConfirm,
      onReject: onReject,
      title: title,
      chainId: chainId,
    );
  }

  _onSign(
    SignClientEventParams<RequestSessionRequest> data,
    String topic,
    SessionStruct session,
    WCEthereumSignMessage ethereumSignMessage,
  ) async {
    List icon = session.peer.metadata.icons;
    String messageType = '';
    if (ethereumSignMessage.type == WCSignType.PERSONAL_MESSAGE) {
      messageType = personalSignKey;
    } else if (ethereumSignMessage.type == WCSignType.MESSAGE) {
      messageType = normalSignKey;
    } else if ([
      WCSignType.TYPED_MESSAGE_V1,
      WCSignType.TYPED_MESSAGE_V3,
      WCSignType.TYPED_MESSAGE_V4
    ].contains(ethereumSignMessage.type)) {
      messageType = typedMessageSignKey;
    }

    await signMessage(
      messageType: messageType,
      context: context,
      data: ethereumSignMessage.data,
      networkIcon: icon.isNotEmpty ? icon[0] : null,
      name: session.peer.metadata.name,
      onConfirm: () async {
        final sessionChainId = data.params?.chainId.split(':').last;

        int? chainId =
            sessionChainId != null ? int.tryParse(sessionChainId) : null;

        EthereumCoin coin =
            chainId == null ? evmFromSymbol('ETH')! : evmFromChainId(chainId)!;
        final walletData = WalletService.getActiveKey(walletImportType)!.data;
        final response = await coin.importData(walletData);
        String privateKey = response.privateKey!;
        late String signedDataHex;
        final credentials = EthPrivateKey.fromHex(privateKey);
        if (ethereumSignMessage.type == WCSignType.TYPED_MESSAGE_V1) {
          signedDataHex = EthSigUtil.signTypedData(
            privateKey: privateKey,
            jsonData: ethereumSignMessage.data,
            version: TypedDataVersion.V1,
          );
        } else if (ethereumSignMessage.type == WCSignType.TYPED_MESSAGE_V3) {
          signedDataHex = EthSigUtil.signTypedData(
            privateKey: privateKey,
            jsonData: ethereumSignMessage.data,
            version: TypedDataVersion.V3,
          );
        } else if (ethereumSignMessage.type == WCSignType.TYPED_MESSAGE_V4) {
          signedDataHex = EthSigUtil.signTypedData(
            privateKey: privateKey,
            jsonData: ethereumSignMessage.data,
            version: TypedDataVersion.V4,
          );
        } else if (ethereumSignMessage.type == WCSignType.PERSONAL_MESSAGE) {
          Uint8List signedData = credentials.signPersonalMessageToUint8List(
            txDataToUintList(
              ethereumSignMessage.data,
            ),
          );
          signedDataHex = bytesToHex(signedData, include0x: true);
        } else if (ethereumSignMessage.type == WCSignType.MESSAGE) {
          try {
            signedDataHex = EthSigUtil.signMessage(
              privateKey: privateKey,
              message: txDataToUintList(
                ethereumSignMessage.data,
              ),
            );
          } catch (e) {
            Uint8List signedData = credentials.signPersonalMessageToUint8List(
              txDataToUintList(
                ethereumSignMessage.data,
              ),
            );
            signedDataHex = bytesToHex(signedData, include0x: true);
          }
        }
        debugPrint('SIGNED $signedDataHex');
        signClient.respond(
          SessionRespondParams(
            topic: topic,
            response: JsonRpcResult<String>(
              id: data.id!,
              result: signedDataHex,
            ),
          ),
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      onReject: () {
        signClient.respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcError(id: data.id!),
          ),
        );
        Navigator.pop(context);
      },
    );
  }
}

Transaction wcEthTxToWeb3Tx(WCEthereumTransaction ethereumTransaction) {
  return Transaction(
    from: EthereumAddress.fromHex(
      ethereumTransaction.from,
    ),
    to: ethereumTransaction.to == null
        ? null
        : EthereumAddress.fromHex(
            ethereumTransaction.to!,
          ),
    maxGas: ethereumTransaction.gasLimit != null
        ? int.tryParse(
            ethereumTransaction.gasLimit!,
          )
        : null,
    gasPrice: ethereumTransaction.gasPrice != null
        ? EtherAmount.inWei(
            BigInt.parse(
              ethereumTransaction.gasPrice!,
            ),
          )
        : null,
    value: EtherAmount.inWei(
      BigInt.parse(
        ethereumTransaction.value ?? '0',
      ),
    ),
    data: ethereumTransaction.data == null
        ? null
        : hexToBytes(ethereumTransaction.data!),
    nonce: ethereumTransaction.nonce != null
        ? int.tryParse(ethereumTransaction.nonce!)
        : null,
  );
}
