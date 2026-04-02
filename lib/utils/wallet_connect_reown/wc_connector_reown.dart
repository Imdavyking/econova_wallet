import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/build_row.dart';
import 'package:wallet_app/screens/navigator_service.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart' hide wcEthTxToWeb3Tx;
import 'package:wallet_app/utils/wallet_connect_v2/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:wallet_app/utils/wallet_connect_v2/models/ethereum/wc_ethereum_transaction.dart';
import 'package:wallet_app/utils/wallet_connect_v2/wc_connector_v2.dart';
import 'package:wallet_app/utils/wc_dapp_icon.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';
import 'package:solana/solana.dart' as solana;
import 'package:wallet_app/coins/solana_coin.dart';

class WCConnectorReown {
  // Static accessor — mirrors the pattern used by WcConnectorV2.signClient so
  // that WCService and the preview screen can reach sessions without a ref.
  static WCConnectorReown? _instance;
  static WCConnectorReown get instance {
    assert(
        _instance != null, 'WCConnectorReown has not been instantiated yet.');
    return _instance!;
  }

  late ReownWalletKit _walletKit;
  late BuildContext _context;
  bool _isInitialized = false;
  String? tempScheme;

  WCConnectorReown() {
    _instance = this;
    _context = NavigationService.navigatorKey.currentContext!;
    init();
  }

  ReownWalletKit get walletKit {
    if (!_isInitialized) {
      throw StateError(
          'WalletConnectService is not initialized. Call init() first.');
    }
    return _walletKit;
  }

  bool get isInitialized => _isInitialized;

  /// Returns all active Reown sessions.
  List<SessionData> getSessions() =>
      _isInitialized ? _walletKit.sessions.getAll() : [];

  /// Terminates a session by topic and disconnects its underlying pairing.
  Future<void> disconnectSession(String topic) async {
    try {
      await _walletKit.disconnectSession(
        topic: topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
      );
    } catch (_) {}
    // Also clean up the pairing if one still exists for this topic.
    final session = _walletKit.sessions.get(topic);
    if (session != null) {
      try {
        await _walletKit.core.pairing.disconnect(topic: session.pairingTopic);
      } catch (_) {}
    }
  }

  void setTempScheme(String? scheme) {
    tempScheme = scheme;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _walletKit = ReownWalletKit(
      core: ReownCore(
        projectId: walletConnectKey,
        logLevel: LogLevel.nothing,
      ),
      metadata: const PairingMetadata(
        name: walletName,
        url: walletURL,
        description: walletAbbr,
        icons: [walletIconURL],
        redirect: Redirect(
          native: 'econova://',
          universal: 'https://econova.app.links',
          linkMode: true,
        ),
      ),
    );

    _setupListeners();
    await _walletKit.init();
    debugPrint('[econova] _walletKit init success');
    _isInitialized = true;
    getAllPairedLinks();
  }

  String getMessageFromCode(int code, [String fallbackMsg = fallbackMessage]) {
    return errorMessages[code]?['message'] ?? fallbackMsg;
  }

  void _setupListeners() {
    _walletKit.core.addLogListener(_logListener);
    _walletKit.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _walletKit.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _walletKit.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
    _walletKit.core.relayClient.onRelayClientMessage
        .subscribe(_onRelayClientMessage);
    _walletKit.onSessionProposalError.subscribe(_onSessionProposalError);
    _walletKit.onSessionConnect.subscribe(_onSessionConnect);
    _walletKit.onSessionAuthRequest.subscribe(_onSessionAuthRequest);
    _walletKit.onSessionProposal.subscribe(_onSessionProposal);
    _walletKit.onSessionRequest.subscribe(onSessionRequest);
  }

  void onHandleErrorReject(SessionRequestEvent? event, int code) {
    if (event != null) {
      _walletKit.respondSessionRequest(
        topic: event.topic,
        response: JsonRpcResponse(
          id: event.id,
          jsonrpc: '2.0',
          error: JsonRpcError(
            code: code,
            message: getMessageFromCode(code),
          ),
        ),
      );
    }
  }

  void onSessionRequest(SessionRequestEvent? event) async {
    if (event == null) return;

    final method = event.method;
    final topic = event.topic;
    PairingMetadata? dAppMetadata;
    final session = walletKit.sessions.get(topic);
    try {
      if (session != null) {
        dAppMetadata = session.peer.metadata;
      }
    } catch (_) {}

    final sessionChainId = event.chainId.split(':').last;
    final int? chainId = int.tryParse(sessionChainId);

    // ── Normalise params ────────────────────────────────────────────────────
    // Relay mode  → event.params is the raw List  e.g. ["0xmsg", "0xaddr"]
    // Link-mode   → event.params is a Map         e.g. {"params": [...], "scheme": "..."}
    final dynamic rawParams = event.params;
    final List<dynamic> paramsList;
    final String? scheme;

    if (rawParams is Map<String, dynamic>) {
      paramsList = rawParams['params'] as List<dynamic>? ?? [];
      scheme = rawParams['scheme'] as String?;
    } else if (rawParams is List<dynamic>) {
      paramsList = rawParams;
      scheme = null;
    } else {
      onHandleErrorReject(event, ErrorCodes.invalidParams);
      return;
    }
    // ───────────────────────────────────────────────────────────────────────

    switch (method) {
      case 'personal_sign':
      case 'eth_sign':
      case 'eth_signTypedData':
      case 'eth_signTypedData_v4':
        {
          String messageType = '';
          WCSignType signType = WCSignType.MESSAGE;

          if (method == ethMethods[Eip155Methods.PERSONAL_SIGN]) {
            messageType = personalSignKey;
            signType = WCSignType.PERSONAL_MESSAGE;
          } else if (method == ethMethods[Eip155Methods.ETH_SIGN]) {
            messageType = normalSignKey;
            signType = WCSignType.MESSAGE;
          } else if (method == ethMethods[Eip155Methods.ETH_SIGN_TYPED_DATA] ||
              method == ethMethods[Eip155Methods.ETH_SIGN_TYPED_DATA_V4]) {
            messageType = typedMessageSignKey;
            signType = WCSignType.TYPED_MESSAGE_V4;
          }

          final requestParams = paramsList.cast<String>();
          // personal_sign: [message, address]; eth_sign: [address, message]
          final message = (signType == WCSignType.PERSONAL_MESSAGE)
              ? requestParams[0]
              : requestParams[1];

          final iconUrl = dAppMetadata?.icons.isNotEmpty == true
              ? dAppMetadata!.icons[0]
              : '';

          await signMessage(
            messageType: messageType,
            context: _context,
            data: message,
            networkIcon: iconUrl,
            name: dAppMetadata?.name ?? 'Unknown',
            onConfirm: () async {
              try {
                final coin = chainId == null
                    ? evmFromSymbol('ETH')!
                    : evmFromChainId(chainId)!;

                final walletData =
                    WalletService.getActiveKey(walletImportType)!.data;
                final response = await coin.importData(walletData);
                final privateKey = response.privateKey!;
                final credentials = EthPrivateKey.fromHex(privateKey);

                late String signedDataHex;

                if (signType == WCSignType.TYPED_MESSAGE_V4) {
                  signedDataHex = EthSigUtil.signTypedData(
                    privateKey: privateKey,
                    jsonData: message,
                    version: TypedDataVersion.V4,
                  );
                } else if (signType == WCSignType.PERSONAL_MESSAGE) {
                  final signedBytes =
                      credentials.signPersonalMessageToUint8List(
                          txDataToUintList(message));
                  signedDataHex = bytesToHex(signedBytes, include0x: true);
                } else {
                  // WCSignType.MESSAGE — fallback to personal sign on failure
                  try {
                    signedDataHex = EthSigUtil.signMessage(
                      privateKey: privateKey,
                      message: txDataToUintList(message),
                    );
                  } catch (_) {
                    final fallbackBytes =
                        credentials.signPersonalMessageToUint8List(
                            txDataToUintList(message));
                    signedDataHex = bytesToHex(fallbackBytes, include0x: true);
                  }
                }

                await _walletKit.respondSessionRequest(
                  topic: event.topic,
                  response: JsonRpcResponse(
                    id: event.id,
                    jsonrpc: '2.0',
                    result: signedDataHex,
                  ),
                );
                handleRedirect(scheme);
                if (_context.mounted) Navigator.pop(_context);
              } catch (e) {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                if (_context.mounted) Navigator.pop(_context);
              }
            },
            onReject: () {
              onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
              if (_context.mounted) Navigator.pop(_context);
            },
          );
        }
        break;

      case 'eth_signTransaction':
        {
          if (chainId == null) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
            break;
          }
          final AppLocalizations localization = AppLocalizations.of(_context)!;
          final ethereumTransaction = WCEthereumTransaction.fromJson(
            paramsList.first as Map<String, dynamic>,
          );
          _onTransaction(
            session: session,
            ethereumTransaction: ethereumTransaction,
            title: localization.signTransaction,
            chainId: chainId,
            onConfirm: () async {
              try {
                final EthereumCoin coin = evmFromChainId(chainId)!;
                final walletData =
                    WalletService.getActiveKey(walletImportType)!.data;
                final response = await coin.importData(walletData);
                final String privateKey = response.privateKey!;
                final Web3Client web3client =
                    Web3Client(coin.rpc, http.Client());
                final creds = EthPrivateKey.fromHex(privateKey);
                final tx = await web3client.signTransaction(
                  creds,
                  wcEthTxToWeb3Tx(ethereumTransaction),
                  chainId: chainId,
                );
                await _walletKit.respondSessionRequest(
                  topic: event.topic,
                  response: JsonRpcResponse(
                    id: event.id,
                    jsonrpc: '2.0',
                    result: tx,
                  ),
                );
                handleRedirect(scheme);
              } catch (e) {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
              } finally {
                if (_context.mounted) Navigator.pop(_context);
              }
            },
            onReject: () {
              onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
              if (_context.mounted) Navigator.pop(_context);
            },
          );
        }
        break;

      case 'eth_sendTransaction':
        {
          if (chainId == null) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
            break;
          }
          final AppLocalizations localization = AppLocalizations.of(_context)!;
          final ethereumTransaction = WCEthereumTransaction.fromJson(
            paramsList.first as Map<String, dynamic>,
          );
          _onTransaction(
            session: session,
            ethereumTransaction: ethereumTransaction,
            title: localization.sendTransaction,
            onConfirm: () async {
              try {
                final EthereumCoin coin = evmFromChainId(chainId)!;
                final walletData =
                    WalletService.getActiveKey(walletImportType)!.data;
                final response = await coin.importData(walletData);
                final String privateKey = response.privateKey!;
                final creds = EthPrivateKey.fromHex(privateKey);
                final Web3Client web3client =
                    Web3Client(coin.rpc, http.Client());
                final txhash = await web3client.sendTransaction(
                  creds,
                  wcEthTxToWeb3Tx(ethereumTransaction),
                  chainId: chainId,
                );
                debugPrint('txhash $txhash');
                await _walletKit.respondSessionRequest(
                  topic: event.topic,
                  response: JsonRpcResponse(
                    id: event.id,
                    jsonrpc: '2.0',
                    result: txhash,
                  ),
                );
                handleRedirect(scheme);
              } catch (e) {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
              } finally {
                if (_context.mounted) Navigator.pop(_context);
              }
            },
            onReject: () {
              onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
              if (_context.mounted) Navigator.pop(_context);
            },
            chainId: chainId,
          );
        }
        break;

      case 'wallet_switchEthereumChain':
        {
          try {
            final switchParams = paramsList.first as Map<String, dynamic>;
            final hexChainId = switchParams['chainId'] as String;
            final newChainId = int.parse(
              hexChainId.replaceFirst('0x', ''),
              radix: 16,
            );
            final currentCoin =
                chainId != null ? evmFromChainId(chainId) : null;
            final switchCoin = evmFromChainId(newChainId);

            if (switchCoin == null) {
              onHandleErrorReject(event, ErrorCodes.notSupportChain);
              break;
            }

            switchEthereumChain(
              context: _context,
              currentChain: currentCoin ?? evmFromSymbol('ETH')!,
              switchChain: switchCoin,
              onConfirm: () async {
                await _walletKit.respondSessionRequest(
                  topic: event.topic,
                  response: JsonRpcResponse(
                    id: event.id,
                    jsonrpc: '2.0',
                    result: null,
                  ),
                );
                handleRedirect(scheme);
                if (_context.mounted) Navigator.pop(_context);
              },
              onReject: () {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                if (_context.mounted) Navigator.pop(_context);
              },
            );
          } catch (_) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
          }
        }
        break;

      case 'wallet_addEthereumChain':
        {
          try {
            final addParams = paramsList.first as Map<String, dynamic>;
            final hexChainId = addParams['chainId'] as String;
            final newChainId = int.parse(
              hexChainId.replaceFirst('0x', ''),
              radix: 16,
            );
            if (evmFromChainId(newChainId) != null) {
              await _walletKit.respondSessionRequest(
                topic: event.topic,
                response: JsonRpcResponse(
                  id: event.id,
                  jsonrpc: '2.0',
                  result: null,
                ),
              );
              handleRedirect(scheme);
            } else {
              onHandleErrorReject(event, ErrorCodes.notSupportChain);
            }
          } catch (_) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
          }
        }
        break;
      case 'solana_signMessage':
        {
          try {
            // params: [{ message: "<base58>", pubkey: "<base58>" }]
            // or link-mode wraps in { params: [...], scheme: "..." }
            final msgParams = paramsList.first as Map<String, dynamic>;
            final messageBase58 = msgParams['message'] as String;
            final iconUrl = dAppMetadata?.icons.isNotEmpty == true
                ? dAppMetadata!.icons[0]
                : '';

            await signMessage(
              messageType: personalSignKey,
              context: _context,
              data: messageBase58,
              networkIcon: iconUrl,
              name: dAppMetadata?.name ?? 'Unknown',
              onConfirm: () async {
                try {
                  final walletData =
                      WalletService.getActiveKey(walletImportType)!.data;
                  final coin = getSolanaBlockChains().first;
                  final response = await coin.importData(walletData);
                  final privateKeyBytes = HEX.decode(response.privateKey!);
                  final keyPair =
                      await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
                          privateKey: privateKeyBytes);

                  // Decode the base58 message bytes and sign
                  final msgBytes = base58.decode(messageBase58);
                  final sig = await keyPair.sign(msgBytes);
                  final sigBase58 = base58.encode(sig.bytes as Uint8List);

                  await _walletKit.respondSessionRequest(
                    topic: event.topic,
                    response: JsonRpcResponse(
                      id: event.id,
                      jsonrpc: '2.0',
                      result: {'signature': sigBase58},
                    ),
                  );
                  handleRedirect(scheme);
                  if (_context.mounted) Navigator.pop(_context);
                } catch (e) {
                  onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                  if (_context.mounted) Navigator.pop(_context);
                }
              },
              onReject: () {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                if (_context.mounted) Navigator.pop(_context);
              },
            );
          } catch (_) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
          }
        }
        break;

      case 'solana_signTransaction':
        {
          try {
            final txParams = paramsList.first as Map<String, dynamic>;
            final txBase58 = txParams['transaction'] as String;

            final iconUrl = dAppMetadata?.icons.isNotEmpty == true
                ? dAppMetadata!.icons[0]
                : '';
            final coin = getSolanaBlockChains().first;

            // Decode for fee/simulation display
            final txBytes = base58.decode(txBase58);
            final feeMessageB64 = base64Encode(txBytes);
            final fee = await coin.getFeeForMessage(feeMessageB64);
            if (!_context.mounted) return;
            await signTransactionUI(
              // Reuse the EVM sign sheet — swap for a Solana-specific one if you have it
              gasPriceInWei_: null,
              to: null,
              from: '',
              txData: txBase58,
              valueInWei_: null,
              gasInWei_: fee.toString(),
              networkIcon: iconUrl,
              context: _context,
              symbol: 'SOL',
              name: dAppMetadata?.name ?? 'Unknown',
              title: 'Sign Transaction',
              chainId: chainId ?? 101,
              onConfirm: () async {
                try {
                  final signedBytes = await coin.signVersionTx(
                    Uint8List.fromList(txBytes),
                  );
                  final signedBase58 =
                      base58.encode(Uint8List.fromList(signedBytes));

                  await _walletKit.respondSessionRequest(
                    topic: event.topic,
                    response: JsonRpcResponse(
                      id: event.id,
                      jsonrpc: '2.0',
                      result: {'transaction': signedBase58},
                    ),
                  );
                  handleRedirect(scheme);
                } catch (e) {
                  onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                } finally {
                  if (_context.mounted) Navigator.pop(_context);
                }
              },
              onReject: () {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                if (_context.mounted) Navigator.pop(_context);
              },
            );
          } catch (_) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
          }
        }
        break;

      case 'solana_signAndSendTransaction':
        {
          try {
            final txParams = paramsList.first as Map<String, dynamic>;
            final txBase58 = txParams['transaction'] as String;
            final iconUrl = dAppMetadata?.icons.isNotEmpty == true
                ? dAppMetadata!.icons[0]
                : '';
            final coin = getSolanaBlockChains().first;
            final txBytes = base58.decode(txBase58);
            final feeMessageB64 = base64Encode(txBytes);
            final fee = await coin.getFeeForMessage(feeMessageB64);

            if (!_context.mounted) return;

            await signTransactionUI(
              gasPriceInWei_: null,
              to: null,
              from: '',
              txData: txBase58,
              valueInWei_: null,
              gasInWei_: fee.toString(),
              networkIcon: iconUrl,
              context: _context,
              symbol: 'SOL',
              name: dAppMetadata?.name ?? 'Unknown',
              title: 'Send Transaction',
              chainId: chainId ?? 101,
              onConfirm: () async {
                try {
                  final signedBytes = await coin.signVersionTx(
                    Uint8List.fromList(txBytes),
                  );

                  final txHash =
                      await coin.getProxy().rpcClient.sendTransaction(
                            base64Encode(signedBytes),
                          );

                  await _walletKit.respondSessionRequest(
                    topic: event.topic,
                    response: JsonRpcResponse(
                      id: event.id,
                      jsonrpc: '2.0',
                      result: {'signature': txHash},
                    ),
                  );
                  handleRedirect(scheme);
                } catch (e) {
                  onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                } finally {
                  if (_context.mounted) Navigator.pop(_context);
                }
              },
              onReject: () {
                onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
                if (_context.mounted) Navigator.pop(_context);
              },
            );
          } catch (_) {
            onHandleErrorReject(event, ErrorCodes.invalidParams);
          }
        }
        break;
      default:
        onHandleErrorReject(event, ErrorCodes.unsupportMethod);
    }
  }

  void _onTransaction({
    required SessionData? session,
    required WCEthereumTransaction ethereumTransaction,
    required String title,
    required int chainId,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) async {
    final List icons =
        session != null ? session.peer.metadata.icons : <String>[];

    await signTransactionUI(
      gasPriceInWei_: ethereumTransaction.gasPrice,
      to: ethereumTransaction.to,
      from: ethereumTransaction.from,
      txData: ethereumTransaction.data,
      valueInWei_: ethereumTransaction.value,
      gasInWei_: ethereumTransaction.gas,
      networkIcon: icons.isNotEmpty ? icons[0] as String : null,
      context: _context,
      symbol: evmFromChainId(chainId)?.getSymbol(),
      name: session != null ? session.peer.metadata.name : '',
      onConfirm: onConfirm,
      onReject: onReject,
      title: title,
      chainId: chainId,
    );
  }

  void _logListener(String event) {
    debugPrint('[WalletKit] $event');
  }

  void _onRelayClientError(ErrorEvent? args) {
    debugPrint('[WalletConnect] _onRelayClientError ${args?.error}');
  }

  void _onPairingInvalid(PairingInvalidEvent? args) {
    debugPrint('[WalletConnect] _onPairingInvalid $args');
  }

  void _onPairingCreate(PairingEvent? args) {
    debugPrint('[WalletConnect] _onPairingCreate $args');
  }

  void _onRelayClientMessage(MessageEvent? event) async {
    if (event != null) {
      debugPrint('[WalletConnect] _onRelayClientMessage $event');
    }
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    debugPrint('[WalletConnect] _onSessionProposalError $args');
    if (args != null) {
      String errorMessage = args.error.message;
      if (args.error.code == 5100) {
        errorMessage =
            errorMessage.replaceFirst('Requested:', '\n\nRequested:');
        errorMessage =
            errorMessage.replaceFirst('Supported:', '\n\nSupported:');
      }
      debugPrint('[WalletConnect] error detail: $errorMessage');
    }
  }

  void _onSessionAuthRequest(SessionAuthRequest? args) {
    if (args != null) {
      debugPrint('[WalletConnect] _onSessionAuthRequest $args');
    }
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      debugPrint(
          '[WalletConnect] _onSessionConnect ${jsonEncode(args.session.toJson())}');
    }
  }

  /// FIX #1 & #2: builds accounts by extracting chains from [chainIds] rather
  /// than relying on a hardcoded empty list. Called from [_onSessionProposal].
  Future<(List<String> accounts, List<EthereumCoin> ethCoins)>
      _buildAccountsForChains(List<String> chainIds) async {
    final List<EthereumCoin> ethCoins = [];
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final List<String> accounts = [];

    for (final ids in chainIds) {
      final chainID = int.tryParse(ids.split(':').last);
      if (chainID == null) continue;
      final EthereumCoin? ethCoin = evmFromChainId(chainID);
      if (ethCoin == null) continue;
      final response = await ethCoin.importData(data);
      accounts.add('${EIP155WC.name}:${ethCoin.chainId}:${response.address}');
      ethCoins.add(ethCoin);
    }
    return (accounts, ethCoins);
  }

  Future<(List<String> accounts, List<SolanaCoin> solCoins)>
      _buildSolanaAccounts(List<String> chainIds) async {
    final List<SolanaCoin> solCoins = [];
    final List<String> accounts = [];
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final availableChains = getSolanaBlockChains();

    for (final id in chainIds) {
      // chainId format: "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"
      final ref = id.split(':').last;
      final SolanaCoin? coin = availableChains.cast<SolanaCoin?>().firstWhere(
            (c) => c?.caipReference == ref,
            orElse: () => null,
          );
      if (coin == null) continue;
      final response = await coin.importData(data);
      accounts.add('solana:$ref:${response.address}');
      solCoins.add(coin);
    }
    return (accounts, solCoins);
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    if (args == null) return;
    debugPrint('[SampleWallet] _onSessionProposal ${jsonEncode(args.params)}');

    final proposer = args.params.proposer;

    // ── EVM chains ──────────────────────────────────────────────────────────
    final requiredEvmChains =
        args.params.requiredNamespaces['eip155']?.chains ?? [];
    final optionalEvmChains =
        args.params.optionalNamespaces['eip155']?.chains ?? [];
    final allEvmChains = {...requiredEvmChains, ...optionalEvmChains}.toList();
    final (evmAccounts, ethCoins) = await _buildAccountsForChains(allEvmChains);

    if (requiredEvmChains.isNotEmpty && evmAccounts.isEmpty) {
      await _walletKit.rejectSession(
          id: args.id,
          reason: Errors.getSdkError(Errors.UNSUPPORTED_CHAINS).toSignError());
      return;
    }

    // ── Solana chains ───────────────────────────────────────────────────────
    final requiredSolChains =
        args.params.requiredNamespaces['solana']?.chains ?? [];
    final optionalSolChains =
        args.params.optionalNamespaces['solana']?.chains ?? [];
    final allSolChains = {...requiredSolChains, ...optionalSolChains}.toList();
    final (solAccounts, solCoins) = await _buildSolanaAccounts(allSolChains);

    if (requiredSolChains.isNotEmpty && solAccounts.isEmpty) {
      await _walletKit.rejectSession(
          id: args.id,
          reason: Errors.getSdkError(Errors.UNSUPPORTED_CHAINS).toSignError());
      return;
    }

    // ── Build namespaces ────────────────────────────────────────────────────
    final Map<String, Namespace> namespaces = {};

    if (evmAccounts.isNotEmpty) {
      namespaces['eip155'] = Namespace(
        accounts: evmAccounts,
        methods: [
          'eth_sendTransaction',
          'eth_signTransaction',
          'personal_sign',
          'eth_sign',
          'eth_signTypedData',
          'eth_signTypedData_v4',
          'wallet_switchEthereumChain',
          'wallet_addEthereumChain',
        ],
        events: ['accountsChanged', 'chainChanged'],
      );
    }

    if (solAccounts.isNotEmpty) {
      namespaces['solana'] = Namespace(
        accounts: solAccounts,
        methods: [
          'solana_signMessage',
          'solana_signTransaction',
          'solana_signAndSendTransaction',
        ],
        events: [],
      );
    }

    if (!_context.mounted) return;
    showDialog(
      barrierDismissible: false,
      context: _context,
      builder: (_) {
        final AppLocalizations localization = AppLocalizations.of(_context)!;
        final metadata = proposer.metadata;

        // Merge EVM + Solana coin widgets for the dialog
        final allCoinWidgets = [
          ...ethCoins.map((e) => buildRow(e, isSelected: true)),
          ...solCoins.map((e) => buildRow(e, isSelected: true)),
        ];

        return _WCSessionProposalDialog(
          metadata: metadata,
          coinWidgets: allCoinWidgets,
          localization: localization,
          onConfirm: () async {
            try {
              await _walletKit.approveSession(
                id: args.id,
                namespaces: namespaces,
                sessionProperties: args.params.sessionProperties,
              );
              handleRedirect(tempScheme);
            } catch (error) {
              debugPrint('showConnectAction===0,$error');
            } finally {
              if (_context.mounted) Navigator.pop(_context);
            }
          },
          onReject: () async {
            final error =
                Errors.getSdkError(Errors.USER_REJECTED).toSignError();
            await _walletKit.rejectSession(id: args.id, reason: error);
            await _walletKit.core.pairing
                .disconnect(topic: args.params.pairingTopic);
            if (_context.mounted) Navigator.pop(_context);
          },
        );
      },
    );
  }

  void handleRedirect(String? scheme) async {
    if (!Platform.isAndroid) return;
    if (scheme == null || scheme.isEmpty) return;

    const MethodChannel channel = MethodChannel('browser_launcher');
    try {
      await channel.invokeMethod('openBrowser', {'packageName': scheme});
    } on PlatformException catch (e) {
      debugPrint("Failed to open browser: '${e.message}'");
      if (_context.mounted) {
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Failed to open browser: '${e.message}'",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> pair(Uri uri) async {
    await _walletKit.pair(uri: uri);
  }

  Future<void> disconnect(String topic) async {
    await _walletKit.core.pairing.disconnect(topic: topic);
  }

  Future<void> clearAllPairings() async {
    final pairings = _walletKit.core.pairing.getPairings();
    for (final pairing in pairings) {
      try {
        await _walletKit.core.pairing.disconnect(topic: pairing.topic);
      } catch (_) {}
    }
  }

  List<PairingInfo> getAllPairedLinks() {
    return _walletKit.core.pairing.getPairings();
  }

  Future<void> dispatchEnvelope(String uri) async {
    await _walletKit.dispatchEnvelope(uri);
  }

  /// FIX #5: emit accountsChanged for the `eip155` namespace (was `mina`).
  Future<void> emitAccountsChanged(String newAccount) async {
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) return;

    for (final session in sessions) {
      final topic = session.topic;
      final eip155Namespace = session.namespaces['eip155'];
      if (eip155Namespace == null) continue;

      final supportedChains = eip155Namespace.accounts
          .map((account) => account.split(':')[1])
          .toSet();

      for (final chain in supportedChains) {
        _walletKit.emitSessionEvent(
          topic: topic,
          chainId: '${EIP155WC.name}:$chain',
          event: SessionEventParams(
            name: 'accountsChanged',
            data: ['${EIP155WC.name}:$chain:$newAccount'],
          ),
        );
      }
    }
  }

  /// FIX #5: emit chainChanged for the `eip155` namespace (was `mina`).
  Future<void> emitChainChanged(String newChainId) async {
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) return;

    for (final session in sessions) {
      final topic = session.topic;
      if (!session.namespaces.containsKey('eip155')) continue;

      _walletKit.emitSessionEvent(
        topic: topic,
        chainId: newChainId,
        event: SessionEventParams(
          name: 'chainChanged',
          data: newChainId,
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Extracted dialog widget — keeps _onSessionProposal lean and testable
// ---------------------------------------------------------------------------

class _WCSessionProposalDialog extends StatelessWidget {
  final PairingMetadata metadata;
  final List<Widget> coinWidgets;
  final AppLocalizations localization;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const _WCSessionProposalDialog({
    required this.metadata,
    required this.coinWidgets,
    required this.localization,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: [
          WCDappIcon(
            iconUrl: metadata.icons.isNotEmpty ? metadata.icons[0] : null,
            size: 100,
          ),
          const SizedBox(height: 8),
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: onConfirm,
                child: Text(localization.confirm),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: onReject,
                child: Text(localization.reject),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error codes & messages
// ---------------------------------------------------------------------------

class ErrorCodes {
  static const int userRejectedRequest = 1002;
  static const int userDisconnect = 1001;
  static const int noWallet = 20001;
  static const int verifyFailed = 20002;
  static const int invalidParams = 20003;
  static const int notSupportChain = 20004;
  static const int zkChainPending = 20005;
  static const int unsupportMethod = 20006;
  static const int addressNotExist = 20007;
  static const int internal = 21001;
  static const int throwError = 22001;
  static const int originDismatch = 23001;
  static const int notFound = 404;
}

const Map<int, Map<String, String>> errorMessages = {
  ErrorCodes.userRejectedRequest: {'message': 'User rejected the request.'},
  ErrorCodes.userDisconnect: {
    'message': 'User disconnect, please connect first.'
  },
  ErrorCodes.noWallet: {'message': 'Please create or restore wallet first.'},
  ErrorCodes.verifyFailed: {'message': 'Verify failed.'},
  ErrorCodes.invalidParams: {'message': 'Invalid method parameter(s).'},
  ErrorCodes.notSupportChain: {'message': 'Not support chain.'},
  ErrorCodes.addressNotExist: {'message': 'Address not exist.'},
  ErrorCodes.zkChainPending: {
    'message': 'Request already pending. Please wait.'
  },
  ErrorCodes.unsupportMethod: {'message': 'Method not supported.'},
  ErrorCodes.internal: {'message': 'Transaction error.'},
  ErrorCodes.throwError: {'message': fallbackMessage},
  ErrorCodes.originDismatch: {'message': 'Origin dismatch.'},
  ErrorCodes.notFound: {'message': 'Not found.'},
};
