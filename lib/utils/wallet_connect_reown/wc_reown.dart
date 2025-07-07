import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:wallet_app/screens/navigator_service.dart';
import 'package:wallet_app/utils/app_config.dart';

class WalletConnectReownService {
  late ReownWalletKit _walletKit;
  BuildContext? _context;
  bool _isInitialized = false;
  String? tempScheme;

  WalletConnectReownService();

  ReownWalletKit get walletKit {
    if (!_isInitialized) {
      throw StateError(
          'WalletConnectService is not initialized. Call init() first.');
    }
    return _walletKit;
  }

  bool get isInitialized => _isInitialized;
  void setContext(BuildContext context) async {
    _context = context;
  }

  void setTempScheme(String? scheme) {
    tempScheme = scheme;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    setContext(NavigationService.navigatorKey.currentContext!);
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
          universal: 'https://www.econova.com/links',
          linkMode: true,
        ),
      ),
    );

    _setupListeners();
    await _walletKit.init();
    debugPrint("[econova] _walletKit init success");
    _isInitialized = true;
    getAllPairedLinks();
  }

  List<String> getAllSupportChains() {
    List<String> currentSupportChainList = [];
    debugPrint("[econova] currentSupportChainList: $currentSupportChainList");
    return currentSupportChainList;
  }

  String getMessageFromCode(int code,
      [String fallbackMessage = fallbackMessage]) {
    final Map<String, String>? messageMap = errorMessages[code];

    final String? message = messageMap?["message"];

    return message ?? fallbackMessage;
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

  void onHandleSignTransactionDialog(SessionRequestEvent? event,
      {WalletData? signWallet, PairingMetadata? dAppMetadata}) async {
    if (event != null) {
      Map? params = event.params;
      dynamic signType;
      switch (event.method) {
        case "mina_sendPayment":
          signType = SignTxDialogType.Payment;
          break;
        case "mina_sendStakeDelegation":
          signType = SignTxDialogType.Delegation;
          break;
        case "mina_sendTransaction":
          signType = SignTxDialogType.zkApp;
          break;
        default:
      }

      List<String> checkAddressAction = [
        "mina_sendPayment",
        "mina_sendStakeDelegation"
      ];

      if (checkAddressAction.contains(event.method)) {
        if (params?['to'] == null || !ifAddressValid(params?['to'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }

      if (event.method == "mina_sendPayment") {
        if (!Fmt.isNumber(params?['amount'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }

      if (params?['fee'] != null && (params?['fee'] as String).isNotEmpty) {
        if (!Fmt.isNumber(params?['fee'])) {
          onHandleErrorReject(event, ErrorCodes.invalidParams);
          return;
        }
      }
      String toAddress = "";

      if (event.method != "mina_sendTransaction") {
        toAddress = params?['to'];
      }

      if (signType != null) {
        dynamic nextTx = null;
        try {
          if (params?['transaction'] != null) {
            if (params?['transaction'].runtimeType == String) {
              nextTx = params?['transaction'];
            } else {
              nextTx = jsonEncode(params?['transaction']);
            }
          }
        } catch (e) {}

        String? nextChainId;
        if (event.chainId != appStore.settings?.currentNode?.networkID) {
          nextChainId = event.chainId;
        }

        String iconUrl = "";
        String zkUrl = "";
        if (dAppMetadata == null) {
          iconUrl = "";
          zkUrl = "";
        } else {
          iconUrl = dAppMetadata.icons.length > 0 ? dAppMetadata.icons[0] : "";
          zkUrl = dAppMetadata.url;
        }

        await UI.showSignTransactionAction(
          context: _context!,
          signType: signType,
          to: toAddress,
          nonce: int.parse(appStore
                  .assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ??
              "0"),
          zkNonce: Fmt.isNumber(params?['nonce'])
              ? (params?['nonce'].toString())
              : "",
          amount: Fmt.isNumber(params?['amount'])
              ? (params?['amount'].toString())
              : "",
          fee: Fmt.isNumber(params?['fee']) ? (params?['fee'].toString()) : "",
          memo: params?['memo'],
          transaction: nextTx,
          feePayer: params?['feePayer'],
          onlySign: params?['onlySign'],
          url: zkUrl,
          iconUrl: iconUrl,
          walletConnectChainId: nextChainId,
          signWallet: signWallet,
          fromAddress: params?["from"],
          onConfirm: (Map<String, dynamic> result) async {
            Map<String, dynamic> responseData = {};
            if (params?['onlySign'].runtimeType == bool &&
                params?['onlySign']) {
              responseData = {"signedData": result['signedData']};
            } else {
              responseData = {
                "hash": result['hash'],
                "paymentId": result['paymentId']
              };
            }
            _walletKit.respondSessionRequest(
              topic: event.topic,
              response: JsonRpcResponse(
                id: event.id,
                jsonrpc: '2.0',
                result: responseData,
              ),
            );
            handleRedirect(params?["scheme"]);
            return "";
          },
          onCancel: () {
            onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
          },
        );
      }
    }
  }

  void onHandleSignMessageDialog(SessionRequestEvent? event,
      {WalletData? signWallet, PairingMetadata? dAppMetadata}) async {
    if (event != null) {
      Map? params = event.params;
      Object message = params?["message"];
      String? nextChainId;
      if (event.chainId != appStore.settings?.currentNode?.networkID) {
        nextChainId = event.chainId;
      }
      String iconUrl = "";
      String zkUrl = "";
      if (dAppMetadata == null) {
        iconUrl = "";
        zkUrl = "";
      } else {
        iconUrl = dAppMetadata.icons.length > 0 ? dAppMetadata.icons[0] : "";
        zkUrl = dAppMetadata.url;
      }

      await UI.showSignatureAction(
        method: event.method,
        context: _context!,
        content: message,
        iconUrl: iconUrl,
        url: zkUrl,
        walletConnectChainId: nextChainId,
        signWallet: signWallet,
        fromAddress: params?["from"],
        onConfirm: (Map data) async {
          await _walletKit.respondSessionRequest(
            topic: event.topic,
            response: JsonRpcResponse(
              id: event.id,
              jsonrpc: '2.0',
              result: data,
            ),
          );
          handleRedirect(params?["scheme"]);
        },
        onCancel: () {
          onHandleErrorReject(event, ErrorCodes.userRejectedRequest);
        },
      );
    }
  }

  

  void onSessionRequest(SessionRequestEvent? event) async {
    if (event == null) return;

    final method = event.method;
    final params = event.params;

    switch (method) {
      case 'personal_sign':
      case 'eth_sign':
        handleSignMessage(event);
        break;
      case 'eth_signTypedData':
      case 'eth_signTypedData_v4':
        handleTypedDataSign(event);
        break;
      case 'eth_sendTransaction':
        handleSendTransaction(event);
        break;
      default:
        onHandleErrorReject(event, ErrorCodes.unsupportMethod);
    }
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
    }
  }

  void _onSessionAuthRequest(SessionAuthRequest? args) {
    if (args != null) {}
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      debugPrint(
          '[WalletConnect] _onSessionConnect ${jsonEncode(args.session.toJson())}');
    }
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    debugPrint('[SampleWallet] _onSessionProposal ${jsonEncode(args?.params)}');

    if (args != null && _context != null) {
      final proposer = args.params.proposer;
      List<String> supportChains = getAllSupportChains();
      List<String> accountsNs = supportChains
          .map((chain) => '$chain:${appStore.wallet!.currentAddress}')
          .toList();

      Map<String, Namespace> defaultNamespaces = {
        'eip155': Namespace(
          accounts: ['eip155:1:$ethAddress'], // Replace with current address
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
        ),
      };
      UI.showConnectAction(
        context: _context!,
        url: proposer.metadata.url,
        iconUrl: proposer.metadata.icons.isNotEmpty
            ? proposer.metadata.icons.first
            : "",
        onConfirm: () async {
          try {
            await _walletKit.approveSession(
              id: args.id,
              namespaces: defaultNamespaces,
              sessionProperties: args.params.sessionProperties,
            );
            handleRedirect(tempScheme);
          } catch (error) {
            debugPrint('showConnectAction===0,$error');
          }
        },
        onCancel: () async {
          final error = Errors.getSdkError(Errors.USER_REJECTED).toSignError();
          await _walletKit.rejectSession(id: args.id, reason: error);
          await _walletKit.core.pairing
              .disconnect(topic: args.params.pairingTopic);
        },
      );
    }
  }

  void handleRedirect(String? scheme) async {
    if (Platform.isAndroid) {
      if (scheme != null && scheme.isNotEmpty) {
        const MethodChannel channel = MethodChannel('browser_launcher');
        String targetPackageName = scheme;

        try {
          await channel
              .invokeMethod('openBrowser', {'packageName': targetPackageName});
        } on PlatformException catch (e) {
          debugPrint("Failed to open browser: '${e.message}'");
          ScaffoldMessenger.of(_context!).showSnackBar(
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
    final pairings = _walletKit.core.pairing.getPairings();
    if (pairings.isEmpty) {
      return [];
    }

    return pairings;
  }

  Future<void> dispatchEnvelope(String uri) async {
    await _walletKit.dispatchEnvelope(uri);
  }

  /// Emit the `accountsChanged` event to notify the dApp of a change in the selected account.
  Future<void> emitAccountsChanged(String newAccount) async {
    // Get all active sessions
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) {
      return;
    }
    // Update the namespace with the new account
    for (var session in sessions) {
      final topic = session.topic;
      final minaNamespace = session.namespaces['mina'];
      if (minaNamespace != null) {
        // Emit the accountsChanged event for each supported chain
        final supportedChains = minaNamespace.accounts
            .map((account) =>
                account.split(':')[1]) // Extract chain (e.g., mainnet, devnet)
            .toSet()
            .toList();
        for (var chain in supportedChains) {
          _walletKit.emitSessionEvent(
            topic: topic,
            chainId: 'mina:$chain',
            event: SessionEventParams(
              name: 'accountsChanged',
              data: ['mina:$chain:$newAccount'],
            ),
          );
        }
      }
    }
  }

  /// Emit the `chainChanged` event to notify the dApp of a change in the selected chain.
  Future<void> emitChainChanged(String newChainId) async {
    final sessions = _walletKit.sessions.getAll();
    if (sessions.isEmpty) {
      return;
    }
    // Emit the chainChanged event for each session
    for (var session in sessions) {
      final topic = session.topic;
      final minaNamespace = session.namespaces['mina'];
      if (minaNamespace != null) {
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
}

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
  ErrorCodes.userRejectedRequest: {
    "message": "User rejected the request.",
  },
  ErrorCodes.userDisconnect: {
    "message": "User disconnect, please connect first.",
  },
  ErrorCodes.noWallet: {
    "message": "Please create or restore wallet first.",
  },
  ErrorCodes.verifyFailed: {
    "message": "Verify failed.",
  },
  ErrorCodes.invalidParams: {
    "message": "Invalid method parameter(s).",
  },
  ErrorCodes.notSupportChain: {
    "message": "Not support chain.",
  },
  ErrorCodes.addressNotExist: {
    "message": "Address not exist.",
  },
  ErrorCodes.zkChainPending: {
    "message": "Request already pending. Please wait.",
  },
  ErrorCodes.unsupportMethod: {
    "message": "Method not supported.",
  },
  ErrorCodes.internal: {
    "message": "Transaction error.",
  },
  ErrorCodes.throwError: {
    "message": fallbackMessage,
  },
  ErrorCodes.originDismatch: {
    "message": "Origin dismatch.",
  },
  ErrorCodes.notFound: {
    "message": "Not found.",
  },
};
