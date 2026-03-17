import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:wallet_app/coins/fungible_tokens/stack_ft_coin.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';
import 'package:wallet_app/utils/c32check.dart';
import '../coins/stack_coin.dart';
import '../service/wallet_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';
import 'base_handler.dart';
import 'package:http/http.dart' as http;

// ─── Handler ──────────────────────────────────────────────────────────────────
//
// Handles TWO provider paths:
//
// 1. request() path — Leather v8 / @stacks/connect v8
//    id = UUID string, name = 'stx_transferStx' etc.
//    Response via: window.leatherSendResponse(id, result)
//
// 2. Legacy hiroWallet* path — old @stacks/connect / Xverse
//    id = JWT string, name = 'hiroWalletStacksTransactionRequest' etc.
//    Response via: window.legacySendResponse(responseName, payload)

class StacksHandler extends BaseWebViewHandler {
  StacksHandler({required super.context});

  @override
  void registerHandlers() {
    controller!.addJavaScriptHandler(
      handlerName: 'StacksHandler',
      callback: _onMessage,
    );
  }

  // ── Dispatcher ────────────────────────────────────────────────────────────

  Future<void> _onMessage(List<dynamic> callback) async {
    final jsData = _StacksMessage.fromJson(
        json.decode(callback[0] as String) as Map<String, dynamic>);

    final coin = getStacksBlockchains().first;
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final accountDetail = await coin.importData(data);
    final sendingAddress = accountDetail.address;

    if (kDebugMode) {
      print('StacksHandler → ${jsData.name} isLegacy=${jsData.isLegacy}');
    }

    switch (jsData.name) {
      // ── Connection ────────────────────────────────────────────────────────
      case 'getInfo':
        await _getInfo(jsData, coin);
        break;
      case 'getAddresses':
      case 'stx_getAddresses':
        await _getAddresses(jsData, sendingAddress, accountDetail);
        break;
      case 'getAccounts':
      case 'stx_getAccounts':
        await _getAccounts(jsData, sendingAddress, accountDetail, coin);
        break;
      case 'stx_getNetworks':
        await _getNetworks(jsData, coin);
        break;
      case 'disconnect':
        await removeWeb3Address('stacks', sendingAddress);
        break;

      // ── request() signing ─────────────────────────────────────────────────
      case 'signMessage':
      case 'stx_signMessage':
        await _signMessage(jsData, coin, accountDetail);
        break;
      case 'stx_signStructuredMessage':
        await _signStructuredMessage(jsData, coin, accountDetail);
        break;
      case 'stx_signTransaction':
        await _signTransaction(jsData, coin, sendingAddress);
        break;

      // ── request() broadcast ───────────────────────────────────────────────
      case 'sendTransfer':
      case 'stx_transferStx':
        await _transferStx(jsData, coin, sendingAddress);
        break;
      case 'stx_transferSip10Ft':
        await _signSIP010Transfer(jsData, sendingAddress);
        break;
      case 'stx_callContract':
        await _callContract(jsData, coin);
        break;
      case 'stx_deployContract':
        await _deployContract(jsData, coin);
        break;

      // ── Legacy hiroWallet* events (old @stacks/connect / Xverse) ──────────
      case 'hiroWalletStacksTransactionRequest':
        await _legacyTransactionRequest(jsData, coin, accountDetail);
        break;
      case 'hiroWalletStacksAuthenticationRequest':
        await _legacyAuthenticationRequest(
            jsData, sendingAddress, accountDetail);
        break;
      case 'hiroWalletSignatureRequest':
        await _legacySignatureRequest(jsData, coin, accountDetail,
            structured: false);
        break;
      case 'hiroWalletStructuredDataSignatureRequest':
        await _legacySignatureRequest(jsData, coin, accountDetail,
            structured: true);
        break;

      // ── Stubs ──────────────────────────────────────────────────────────────
      case 'stx_transferSip9Nft':
        await _sendError('NFT transfers not yet supported', jsData);
        break;
      case 'stx_updateProfile':
        await _sendError('stx_updateProfile not supported', jsData);
        break;
      case 'signPsbt':
        await _sendError('signPsbt not supported by this wallet', jsData);
        break;

      default:
        await _sendError('Unsupported method: ${jsData.name}', jsData);
    }
  }

  // ── getInfo ───────────────────────────────────────────────────────────────

  Future<void> _getInfo(_StacksMessage jsData, StacksCoin coin) async {
    await _sendResponse(jsData, {
      'version': '1.0.0',
      'name': walletName,
      'network': coin.isTestnet ? 'testnet' : 'mainnet',
      'methods': [
        'getInfo',
        'getAddresses',
        'getAccounts',
        'stx_getNetworks',
        'signMessage',
        'sendTransfer',
        'signPsbt',
        'stx_callContract',
        'stx_deployContract',
        'stx_getAccounts',
        'stx_getAddresses',
        'stx_signMessage',
        'stx_signStructuredMessage',
        'stx_signTransaction',
        'stx_transferStx',
        'stx_transferSip10Ft',
      ],
    });
  }

  // ── stx_getNetworks ───────────────────────────────────────────────────────

  Future<void> _getNetworks(_StacksMessage jsData, StacksCoin coin) async {
    await _sendResponse(jsData, {
      'networks': [
        {
          'chainId': coin.isTestnet ? 2147483648 : 1,
          'networkName': coin.isTestnet ? 'testnet' : 'mainnet',
        }
      ],
    });
  }

  // ── getAddresses ──────────────────────────────────────────────────────────

  Future<void> _getAddresses(
    _StacksMessage jsData,
    String sendingAddress,
    AccountData accountDetail,
  ) async {
    final existing = await getWeb3Address('stacks', sendingAddress);
    if (existing != null) {
      await _sendResponse(
          jsData, _addressPayload(sendingAddress, accountDetail));
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _sendResponse(
              jsData, _addressPayload(sendingAddress, accountDetail));
          await saveWeb3Address('stacks', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData);
        _pop();
      },
    );
  }

  // ── getAccounts ───────────────────────────────────────────────────────────

  Future<void> _getAccounts(
    _StacksMessage jsData,
    String sendingAddress,
    AccountData accountDetail,
    StacksCoin coin,
  ) async {
    final existing = await getWeb3Address('stacks', sendingAddress);
    if (existing != null) {
      await _sendResponse(
          jsData, _accountPayload(sendingAddress, accountDetail, coin));
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _sendResponse(
              jsData, _accountPayload(sendingAddress, accountDetail, coin));
          await saveWeb3Address('stacks', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData);
        _pop();
      },
    );
  }

  Map<String, dynamic> _addressPayload(String address, AccountData d) => {
        'addresses': [
          {
            'symbol': 'STX',
            'type': 'p2pkh',
            'address': address,
            'publicKey': d.publicKey
          },
        ],
      };

  Map<String, dynamic> _accountPayload(
          String address, AccountData d, StacksCoin coin) =>
      {
        'accounts': [
          {
            'address': address,
            'publicKey': d.publicKey,
            'network': coin.isTestnet ? 'testnet' : 'mainnet',
            'symbol': 'STX',
          },
        ],
      };

  // ── stx_signMessage ───────────────────────────────────────────────────────

  Future<void> _signMessage(
    _StacksMessage jsData,
    StacksCoin coin,
    AccountData accountDetail,
  ) async {
    final rawMessage = (jsData.object['message'] as String?) ?? '';
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: personalSignKey,
      data: rawMessage,
      networkIcon: null,
      name: null,
      onConfirm: () async {
        try {
          final sigBytes = await coin.signMessage(rawMessage);
          await _sendResponse(jsData, {
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected signature', jsData);
        _pop();
      },
    );
  }

  // ── stx_signStructuredMessage ─────────────────────────────────────────────

  Future<void> _signStructuredMessage(
    _StacksMessage jsData,
    StacksCoin coin,
    AccountData accountDetail,
  ) async {
    final messageHex = (jsData.object['message'] as String?) ?? '';
    final domainHex = (jsData.object['domain'] as String?) ?? '';
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: typedMessageSignKey,
      data: 'Domain: $domainHex\nMessage: $messageHex',
      networkIcon: null,
      name: 'Sign Structured Message',
      onConfirm: () async {
        try {
          final msgBytes = HEX.decode(messageHex.startsWith('0x')
              ? messageHex.substring(2)
              : messageHex);
          final domBytes = HEX.decode(
              domainHex.startsWith('0x') ? domainHex.substring(2) : domainHex);
          const prefix = [0x53, 0x49, 0x50, 0x30, 0x31, 0x38];
          final domHash = stacksSha256(Uint8List.fromList(domBytes));
          final msgHash = stacksSha256(Uint8List.fromList(msgBytes));
          final hash = stacksSha256(
              Uint8List.fromList([...prefix, ...domHash, ...msgHash]));
          final privBytes = txDataToUintList(accountDetail.privateKey!);
          final sigBytes = stacksSignRaw(privBytes, hash);
          await _sendResponse(jsData, {
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected signature', jsData);
        _pop();
      },
    );
  }

  // ── stx_signTransaction ───────────────────────────────────────────────────

  Future<void> _signTransaction(
    _StacksMessage jsData,
    StacksCoin coin,
    String sendingAddress,
  ) async {
    final txHex = (jsData.object['transaction'] as String?) ?? '';
    if (txHex.isEmpty) {
      await _sendError(
          'stx_signTransaction requires a transaction hex', jsData);
      return;
    }
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data: txHex,
      networkIcon: null,
      name: 'Sign Transaction',
      onConfirm: () async {
        try {
          final data = WalletService.getActiveKey(walletImportType)!.data;
          final keyPair = await coin.importData(data);
          final privBytes = txDataToUintList(keyPair.privateKey!);
          final rawTx = Uint8List.fromList(
              HEX.decode(txHex.startsWith('0x') ? txHex.substring(2) : txHex));
          final signedTx = stacksResignTx(rawTx, privBytes);
          await _sendResponse(jsData, {'transaction': HEX.encode(signedTx)});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData);
        _pop();
      },
    );
  }

  // ── stx_transferStx ───────────────────────────────────────────────────────

  Future<void> _transferStx(
    _StacksMessage jsData,
    StacksCoin coin,
    String sendingAddress,
  ) async {
    final obj = jsData.object;
    final to = obj['recipient'] as String? ?? obj['to'] as String? ?? '';
    final amount =
        (obj['amount'] as String?) ?? (obj['value'] as String?) ?? '0';
    final memo = obj['memo'] as String?;
    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data: 'Send $amount µSTX\nTo: $to${memo != null ? '\nMemo: $memo' : ''}',
      networkIcon: null,
      name: 'STX Transfer',
      onConfirm: () async {
        try {
          final displayAmount = (BigInt.tryParse(amount) ?? BigInt.zero) /
              BigInt.from(stacksMicroPerStx);
          final txHash = await coin.transferToken(displayAmount.toString(), to,
              memo: memo);
          await _sendResponse(jsData, {'txid': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData);
        _pop();
      },
    );
  }

  // ── stx_transferSip10Ft ───────────────────────────────────────────────────

  Future<void> _signSIP010Transfer(
    _StacksMessage jsData,
    String sendingAddress,
  ) async {
    final obj = jsData.object;
    final contractAddress = obj['contractAddress'] as String? ?? '';
    final contractName = obj['contractName'] as String? ?? '';
    final to = obj['recipient'] as String? ?? '';
    final amount = obj['amount'] as String? ?? '0';
    final memo = obj['memo'] as String?;

    final allSip010 = getSIP010Coins();
    SIP010Coin? tokenCoin = allSip010.cast<SIP010Coin?>().firstWhere(
          (c) =>
              c!.contractAddress == contractAddress &&
              c.contractName == contractName,
          orElse: () => null,
        );

    if (tokenCoin == null) {
      final symbol = obj['symbol'] as String?;
      final decimals = (obj['decimals'] as num?)?.toInt();
      if (contractAddress.isEmpty ||
          contractName.isEmpty ||
          symbol == null ||
          decimals == null) {
        await _sendError('Unknown token — provide symbol and decimals', jsData);
        return;
      }
      final baseCoin = getStacksBlockchains().first;
      tokenCoin = SIP010Coin(
        isTestnet: baseCoin.isTestnet,
        derivationPath: baseCoin.derivationPath,
        blockExplorer: baseCoin.blockExplorer,
        symbol: symbol,
        default_: baseCoin.default_,
        image: obj['image'] as String? ?? baseCoin.image,
        name: obj['name'] as String? ?? symbol,
        geckoID: obj['geckoID'] as String? ?? '',
        rampID: '',
        payScheme: baseCoin.payScheme,
        contractAddress: contractAddress,
        contractName: contractName,
        mintDecimals: decimals,
      );
    }

    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data:
          'Send $amount ${tokenCoin.symbol}\nContract: ${tokenCoin.tokenAddress()}\nTo: $to${memo != null ? '\nMemo: $memo' : ''}',
      networkIcon: null,
      name: '${tokenCoin.symbol} Transfer',
      onConfirm: () async {
        try {
          final txHash = await tokenCoin?.transferToken(amount, to, memo: memo);
          await _sendResponse(jsData, {'txHash': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData);
        _pop();
      },
    );
  }

  // ── stx_callContract ─────────────────────────────────────────────────────

  Future<void> _callContract(_StacksMessage jsData, StacksCoin coin) async {
    final obj = jsData.object;
    final contractAddress = obj['contractAddress'] as String? ?? '';
    final contractName = obj['contractName'] as String? ?? '';
    final functionName = obj['functionName'] as String? ?? '';
    final rawArgs = (obj['functionArgs'] as List?)?.cast<String>() ?? [];

    if (contractAddress.isEmpty ||
        contractName.isEmpty ||
        functionName.isEmpty) {
      await _sendError(
          'callContract requires contractAddress, contractName, functionName',
          jsData);
      return;
    }
    if (!context.mounted) return;

    final argSummary = rawArgs.isEmpty
        ? 'none'
        : rawArgs
            .asMap()
            .entries
            .map((e) => 'arg${e.key}: ${e.value}')
            .join('\n');

    await signMessage(
      context: context,
      messageType: '',
      data:
          'Contract: $contractAddress.$contractName\nFunction: $functionName\nArgs:\n$argSummary',
      networkIcon: null,
      name: 'Contract Call',
      onConfirm: () async {
        try {
          final txHash = await _buildAndBroadcastContractCall(
            coin: coin,
            contractAddress: contractAddress,
            contractName: contractName,
            functionName: functionName,
            rawArgs: rawArgs,
          );
          await _sendResponse(jsData, {'txHash': txHash});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected contract call', jsData);
        _pop();
      },
    );
  }

  // ── stx_deployContract ────────────────────────────────────────────────────

  Future<void> _deployContract(_StacksMessage jsData, StacksCoin coin) async {
    final obj = jsData.object;
    final contractName = obj['contractName'] as String? ?? '';
    final codeBody = obj['codeBody'] as String? ?? '';
    final clarityVersion = (obj['clarityVersion'] as num?)?.toInt() ?? 2;

    if (contractName.isEmpty || codeBody.isEmpty) {
      await _sendError(
          'stx_deployContract requires contractName and codeBody', jsData);
      return;
    }
    if (!context.mounted) return;

    await signMessage(
      context: context,
      messageType: '',
      data:
          'Deploy contract: $contractName\nClarity version: $clarityVersion\nCode size: ${codeBody.length} chars',
      networkIcon: null,
      name: 'Deploy Contract',
      onConfirm: () async {
        try {
          final data = WalletService.getActiveKey(walletImportType)!.data;
          final keyPair = await coin.importData(data);
          final privBytes = txDataToUintList(keyPair.privateKey!);
          final senderHash160 =
              stacksHash160(stacksCompressedPubKey(privBytes));
          final nonce = await _fetchNonce(coin);
          final feeRate = await _fetchFeeRate(coin);
          final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);
          final nameBytes = utf8.encode(contractName);
          final codeBytes = utf8.encode(codeBody);
          final payload = (BytesBuilder()
                ..addByte(0x01)
                ..addByte(clarityVersion)
                ..addByte(nameBytes.length)
                ..add(nameBytes)
                ..add(stacksU32BE(codeBytes.length))
                ..add(codeBytes))
              .toBytes();
          final api = coin.isTestnet
              ? 'https://api.testnet.hiro.so'
              : 'https://api.hiro.so';
          final txBytes = stacksBuildSignedTx(
            txVersion: coin.isTestnet ? 0x80 : 0x00,
            chainId: coin.isTestnet ? 0x80000000 : 0x00000001,
            privKey: privBytes,
            senderHash160: senderHash160,
            nonce: BigInt.from(nonce),
            fee: fee,
            payload: payload,
          );
          final res = await http.post(Uri.parse('$api/v2/transactions'),
              headers: {'Content-Type': 'application/octet-stream'},
              body: txBytes);
          if (res.statusCode ~/ 100 != 2) {
            throw Exception('deploy failed: ${res.body}');
          }
          final txHash = jsonDecode(res.body) as String;
          await _sendResponse(jsData, {
            'txid': txHash,
            'contractId': '${keyPair.address}.$contractName'
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected deploy', jsData);
        _pop();
      },
    );
  }

  // ── Legacy hiroWallet* handlers ───────────────────────────────────────────

  /// CHANGED: Added Path 3 — contract_call without txHex in JWT.
  /// Old @stacks/connect sends txType='contract_call' with contractAddress,
  /// contractName, functionName, functionArgs but no pre-serialized txHex.
  /// We now build and broadcast the transaction ourselves.
  Future<void> _legacyTransactionRequest(
    _StacksMessage jsData,
    StacksCoin coin,
    AccountData accountDetail,
  ) async {
    final jwtValue =
        jsData.object['transactionRequest'] as String? ?? jsData.id.toString();
    final responseName =
        jsData.legacyResponseName ?? 'hiroWalletTransactionResponse';

    final decoded = _decodeJwt(jwtValue);
    final txType = decoded?['txType'] as String? ?? 'transaction';
    final recipient = decoded?['recipient'] as String? ?? '';
    final amount = decoded?['amount'] as String? ?? '';
    final contractAddress = decoded?['contractAddress'] as String? ?? '';
    final contractName = decoded?['contractName'] as String? ?? '';
    final functionName = decoded?['functionName'] as String? ?? '';
    // functionArgs from old @stacks/connect are hex-encoded Clarity values
    final rawFunctionArgs =
        (decoded?['functionArgs'] as List?)?.whereType<String>().toList() ?? [];

    String displayInfo;
    if (txType == 'contract_call' && functionName.isNotEmpty) {
      displayInfo =
          'Contract call: $contractAddress.$contractName\nFunction: $functionName';
    } else if (txType == 'token_transfer' && recipient.isNotEmpty) {
      displayInfo = 'Transfer $amount µSTX to $recipient';
    } else if (txType == 'smart_contract') {
      displayInfo = 'Deploy contract: ${decoded?['contractName'] ?? ''}';
    } else {
      displayInfo = 'Transaction type: $txType';
    }

    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: '',
      data: displayInfo,
      networkIcon: null,
      name: 'Confirm Transaction',
      onConfirm: () async {
        try {
          String txHash;
          final txHex = decoded?['txHex'] as String?;

          if (txHex != null && txHex.isNotEmpty) {
            // ── Path 1: pre-built txHex — resign and broadcast ─────────────
            final privBytes = txDataToUintList(accountDetail.privateKey!);
            final rawTx = Uint8List.fromList(HEX
                .decode(txHex.startsWith('0x') ? txHex.substring(2) : txHex));
            final signedTx = stacksResignTx(rawTx, privBytes);
            final api = coin.isTestnet
                ? 'https://api.testnet.hiro.so'
                : 'https://api.hiro.so';
            final res = await http.post(Uri.parse('$api/v2/transactions'),
                headers: {'Content-Type': 'application/octet-stream'},
                body: signedTx);
            if (res.statusCode ~/ 100 != 2) {
              throw Exception('broadcast failed: ${res.body}');
            }
            txHash = jsonDecode(res.body) as String;
          } else if (txType == 'token_transfer' && recipient.isNotEmpty) {
            // ── Path 2: STX transfer ───────────────────────────────────────
            final displayAmount = (BigInt.tryParse(amount) ?? BigInt.zero) /
                BigInt.from(stacksMicroPerStx);
            txHash =
                await coin.transferToken(displayAmount.toString(), recipient) ??
                    '';
          } else if (txType == 'contract_call' &&
              contractAddress.isNotEmpty &&
              contractName.isNotEmpty &&
              functionName.isNotEmpty) {
            // ── Path 3: contract_call without txHex — build it here ────────
            txHash = await _buildAndBroadcastContractCall(
              coin: coin,
              contractAddress: contractAddress,
              contractName: contractName,
              functionName: functionName,
              rawArgs: rawFunctionArgs,
            );
          } else {
            throw Exception(
                'Cannot process txType=$txType without txHex in JWT');
          }

          await _legacySendResponse(responseName, {
            'transactionRequest': jwtValue,
            'transactionResponse': {'txid': txHash},
          });
        } catch (e) {
          await _legacySendCancel(responseName, 'transactionRequest', jwtValue);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _legacySendCancel(responseName, 'transactionRequest', jwtValue);
        _pop();
      },
    );
  }

  /// CHANGED: authenticationResponse is now an unsecured JWT string instead
  /// of a plain {address, publicKey} object.
  ///
  /// Why: dApps call decodeToken(authenticationResponse) expecting a JWT.
  /// If they receive an object, decodeToken() throws, extractStxAddress()
  /// returns "", cachedStxAddress stays empty, and any subsequent
  /// signatureRequest() call is blocked with "Run authenticationRequest first".
  ///
  /// Fix: build an unsecured JWT (alg=none, format: header.payload.) whose
  /// payload includes both payload.address (extractStxAddress fallback) and
  /// payload.profile.stxAddress.testnet (primary check in extractStxAddress).
  Future<void> _legacyAuthenticationRequest(
    _StacksMessage jsData,
    String sendingAddress,
    AccountData accountDetail,
  ) async {
    final jwtValue = jsData.object['authenticationRequest'] as String? ??
        jsData.id.toString();
    final responseName =
        jsData.legacyResponseName ?? 'hiroWalletAuthenticationResponse';

    // Decode the INCOMING request JWT to surface app info in the modal
    final decoded = _decodeJwt(jwtValue);
    final appName = (decoded?['appDetails'] as Map?)?['name'] as String? ??
        decoded?['domain_name'] as String? ??
        jsData.url ??
        'Unknown App';

    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: appName,
      onConfirm: () async {
        try {
          await saveWeb3Address('stacks', sendingAddress);

          // Build a proper ES256K-signed authenticationResponse JWT
          // that mirrors what the real Leather wallet returns
          final authResponseJwt = _buildSignedAuthResponse(
            accountDetail: accountDetail,
            sendingAddress: sendingAddress,
            requestJwt: jwtValue,
          );

          await _legacySendResponse(responseName, {
            'authenticationRequest': jwtValue,
            'authenticationResponse': authResponseJwt,
          });
        } catch (e) {
          await _legacySendCancel(
              responseName, 'authenticationRequest', jwtValue);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _legacySendCancel(
            responseName, 'authenticationRequest', jwtValue);
        _pop();
      },
    );
  }

  String _buildSignedAuthResponse({
    required AccountData accountDetail,
    required String sendingAddress,
    required String requestJwt,
  }) {
    final privBytes = txDataToUintList(accountDetail.privateKey!);
    final pubKey = accountDetail.publicKey;

    // base64url without padding
    String b64url(String s) =>
        base64Url.encode(utf8.encode(s)).replaceAll('=', '');

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Header — ES256K so dApps know it's properly signed
    final header = b64url('{"typ":"JWT","alg":"ES256K"}');

    // Payload mirrors the real Leather authenticationResponse structure
    final payload = b64url(json.encode({
      'jti': '${now}_auth_response',
      'iat': now,
      'exp': now + 86400,
      // iss = the wallet's DID derived from the STX address
      'iss': 'did:btc-addr:$sendingAddress',
      'public_keys': [pubKey],
      'profile': {
        'stxAddress': {
          'mainnet': sendingAddress,
          'testnet': sendingAddress,
        },
        'walletProvider': walletName,
      },
      'core_token': null,
      'email': null,
      'profile_url': null,
      'hubUrl': 'https://hub.hiro.so',
      'version': '1.4.0',
    }));

    final signingInput = '$header.$payload';

    // Sign with the wallet's secp256k1 private key (same key used for STX txs)
    final hash = stacksSha256(Uint8List.fromList(utf8.encode(signingInput)));
    final sigBytes = stacksSignRaw(privBytes, hash);
    final sig = base64Url.encode(sigBytes).replaceAll('=', '');

    return '$signingInput.$sig';
  }

  Future<void> _legacySignatureRequest(
    _StacksMessage jsData,
    StacksCoin coin,
    AccountData accountDetail, {
    required bool structured,
  }) async {
    final jwtValue =
        jsData.object['signatureRequest'] as String? ?? jsData.id.toString();
    final responseName = jsData.legacyResponseName ??
        (structured
            ? 'hiroWalletStructuredDataSignatureResponse'
            : 'hiroWalletSignatureResponse');

    final decoded = _decodeJwt(jwtValue);
    final message = decoded?['message'] as String? ?? '(encoded message)';
    final domain = decoded?['domain'] as String? ?? '';

    final displayData = structured
        ? 'Sign structured message\nDomain: ${domain.substring(0, domain.length.clamp(0, 20))}...\nMessage: ${message.substring(0, message.length.clamp(0, 20))}...'
        : message;

    if (!context.mounted) return;
    await signMessage(
      context: context,
      messageType: structured ? typedMessageSignKey : personalSignKey,
      data: displayData,
      networkIcon: null,
      name: structured ? 'Sign Structured Message' : 'Sign Message',
      onConfirm: () async {
        try {
          final privBytes = txDataToUintList(accountDetail.privateKey!);
          Uint8List sigBytes;

          if (structured) {
            final messageHex = decoded?['message'] as String? ?? '';
            final domainHex = decoded?['domain'] as String? ?? '';
            final msgBytes = HEX.decode(messageHex.startsWith('0x')
                ? messageHex.substring(2)
                : messageHex);
            final domBytes = HEX.decode(domainHex.startsWith('0x')
                ? domainHex.substring(2)
                : domainHex);
            const prefix = [0x53, 0x49, 0x50, 0x30, 0x31, 0x38];
            final domHash = stacksSha256(Uint8List.fromList(domBytes));
            final msgHash = stacksSha256(Uint8List.fromList(msgBytes));
            final hash = stacksSha256(
                Uint8List.fromList([...prefix, ...domHash, ...msgHash]));
            sigBytes = stacksSignRaw(privBytes, hash);
          } else {
            sigBytes = await coin.signMessage(message, isLegacy: false);
          }
          print({
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
          await _legacySendResponse(responseName, {
            'signatureRequest': jwtValue,
            'signatureResponse': {
              'signature': HEX.encode(sigBytes),
              'publicKey': accountDetail.publicKey,
            },
          });
        } catch (e) {
          await _legacySendCancel(responseName, 'signatureRequest', jwtValue);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _legacySendCancel(responseName, 'signatureRequest', jwtValue);
        _pop();
      },
    );
  }

  // ── JWT helpers ───────────────────────────────────────────────────────────

  /// Decodes any JWT (including unsecured alg=none) and returns the payload.
  static Map<String, dynamic>? _decodeJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Builds an RFC 7519 unsecured JWT (alg=none).
  /// Format: base64url(header) . base64url(payload) . (empty signature)
  /// Parseable by jsontokens' decodeToken() on the JS/TS side.
  static String _buildUnsecuredJwt(Map<String, dynamic> payload) {
    // base64url with no padding
    String b64url(String input) =>
        base64Url.encode(utf8.encode(input)).replaceAll('=', '');

    final header = b64url('{"typ":"JWT","alg":"none"}');
    final pay = b64url(json.encode(payload));
    return '$header.$pay.'; // trailing dot = empty signature segment
  }

  // ── Shared contract-call builder / broadcaster ────────────────────────────
  //
  // Extracted from _callContract so _legacyTransactionRequest can reuse it
  // for contract_call JWTs that don't include a pre-serialized txHex.

  Future<String> _buildAndBroadcastContractCall({
    required StacksCoin coin,
    required String contractAddress,
    required String contractName,
    required String functionName,
    required List<String> rawArgs,
  }) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await coin.importData(data);
    final privBytes = txDataToUintList(keyPair.privateKey!);
    final senderHash160 = stacksHash160(stacksCompressedPubKey(privBytes));
    final nonce = await _fetchNonce(coin);
    final feeRate = await _fetchFeeRate(coin);
    final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);

    final contractDecoded = c32checkDecode(contractAddress.substring(1));
    final contractVersion = contractDecoded[0] as int;
    final contractHash160 =
        Uint8List.fromList(HEX.decode(contractDecoded[1] as String));

    final encodedArgs = rawArgs
        .map((hex) => Uint8List.fromList(
            HEX.decode(hex.startsWith('0x') ? hex.substring(2) : hex)))
        .toList();

    final nameBytes = utf8.encode(contractName);
    final fnBytes = utf8.encode(functionName);

    final payload = (BytesBuilder()
          ..addByte(stacksPayloadContractCall)
          ..addByte(contractVersion)
          ..add(contractHash160)
          ..addByte(nameBytes.length)
          ..add(nameBytes)
          ..addByte(fnBytes.length)
          ..add(fnBytes)
          ..add(stacksU32BE(encodedArgs.length)))
        .toBytes();

    final fullPayload =
        Uint8List.fromList([...payload, for (final arg in encodedArgs) ...arg]);

    final txBytes = stacksBuildSignedTx(
      txVersion: coin.isTestnet ? 0x80 : 0x00,
      chainId: coin.isTestnet ? 0x80000000 : 0x00000001,
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: fullPayload,
    );

    final api =
        coin.isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';
    final res = await http.post(
      Uri.parse('$api/v2/transactions'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: txBytes,
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('broadcast failed: ${res.body}');
    }
    return jsonDecode(res.body) as String;
  }

  // ── Response helpers ──────────────────────────────────────────────────────

  Future<void> _sendResponse(
      _StacksMessage jsData, Map<String, dynamic> result) async {
    final encoded = json.encode(result);

    if (jsData.isLegacy) {
      final responseName = jsData.legacyResponseName;
      if (responseName != null) await _legacySendResponse(responseName, result);
    } else {
      final safeId = jsData.id is String ? '"${jsData.id}"' : '${jsData.id}';
      await sendCustom('window.leatherSendResponse?.($safeId, $encoded)');
    }
  }

  Future<void> _sendError(String message, _StacksMessage jsData) async {
    final safe = message.replaceAll('"', "'");

    if (jsData.isLegacy) {
      final responseName = jsData.legacyResponseName;
      final payloadKey = _legacyPayloadKey(jsData.name);
      if (responseName != null && payloadKey != null) {
        await _legacySendCancel(responseName, payloadKey, jsData.id.toString());
      }
    } else {
      final safeId = jsData.id is String ? '"${jsData.id}"' : '${jsData.id}';
      await sendCustom('window.leatherSendError?.($safeId, "$safe")');
    }
  }

  Future<void> _legacySendResponse(
      String responseName, Map<String, dynamic> payload) async {
    await sendCustom(
        'window.legacySendResponse?.("$responseName", ${json.encode(payload)})');
  }

  Future<void> _legacySendCancel(
      String responseName, String requestKey, String requestValue) async {
    await sendCustom(
        'window.legacySendCancel?.("$responseName", "$requestKey", ${json.encode(requestValue)})');
  }

  String? _legacyPayloadKey(String eventName) {
    return switch (eventName) {
      'hiroWalletStacksTransactionRequest' => 'transactionRequest',
      'hiroWalletStacksAuthenticationRequest' => 'authenticationRequest',
      'hiroWalletSignatureRequest' => 'signatureRequest',
      'hiroWalletStructuredDataSignatureRequest' => 'signatureRequest',
      _ => null,
    };
  }

  // ── Chain helpers ─────────────────────────────────────────────────────────

  Future<int> _fetchFeeRate(StacksCoin coin) async {
    final api =
        coin.isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';
    try {
      final res = await http.get(Uri.parse('$api/v2/fees/transfer'));
      if (res.statusCode ~/ 100 == 2) {
        return int.parse(jsonDecode(res.body).toString());
      }
    } catch (_) {}
    return 10;
  }

  Future<int> _fetchNonce(StacksCoin coin) async {
    final api =
        coin.isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await coin.importData(data);
    final res = await http
        .get(Uri.parse('$api/v2/accounts/${keyPair.address}?proof=0'));
    if (res.statusCode ~/ 100 != 2) throw Exception('nonce fetch failed');
    return jsonDecode(res.body)['nonce'] as int;
  }

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
  }
}

// ─── Message model ────────────────────────────────────────────────────────────

class _StacksMessage {
  final dynamic id;
  final String name;
  final Map<String, dynamic> object;
  final String? url;
  final String? legacyResponseName;

  const _StacksMessage({
    required this.id,
    required this.name,
    required this.object,
    this.url,
    this.legacyResponseName,
  });

  bool get isLegacy => name.startsWith('hiroWallet');

  factory _StacksMessage.fromJson(Map<String, dynamic> json) {
    return _StacksMessage(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      object: (json['object'] as Map<String, dynamic>?) ?? {},
      url: json['url'] as String?,
      legacyResponseName: json['legacyResponseName'] as String?,
    );
  }
}
