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
      print(
          'StacksHandler → ${jsData.name} (id=${jsData.id} isLeather=${jsData.isLeather})');
    }

    switch (jsData.name) {
      // ── Connection ──────────────────────────────────────────────────────
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

      // ── Signing ─────────────────────────────────────────────────────────
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

      // ── Broadcast ───────────────────────────────────────────────────────
      case 'sendTransfer':
      case 'stx_transferStx':
        await _transferStx(jsData, coin, sendingAddress);
        break;
      case 'stx_transferSip10Ft': // ← was missing
        await _signSIP010Transfer(jsData, sendingAddress);
        break;
      case 'stx_callContract':
        await _callContract(jsData, coin);
        break;
      case 'stx_deployContract':
        await _deployContract(jsData, coin);
        break;

      // ── Stubs ────────────────────────────────────────────────────────────
      case 'stx_transferSip9Nft':
        await _sendError('NFT transfers not yet supported', jsData.id);
        break;
      case 'stx_updateProfile':
        await _sendError('stx_updateProfile not supported', jsData.id);
        break;
      case 'signPsbt':
        await _sendError('signPsbt not supported by this wallet', jsData.id);
        break;

      default:
        await _sendError('Unsupported method: ${jsData.name}', jsData.id);
    }
  }

  // ── getInfo ───────────────────────────────────────────────────────────────

  Future<void> _getInfo(_StacksMessage jsData, StacksCoin coin) async {
    await _sendResponse(jsData.id, {
      'version': '1.0.0',
      'name': walletName,
      'network': coin.isTestnet ? 'testnet' : 'mainnet',
      'methods': [
        'getInfo',
        'getAddresses',
        'getAccounts',
        'signMessage',
        'sendTransfer',
        'signPsbt',
        'stx_callContract',
        'stx_deployContract',
        'stx_getAccounts',
        'stx_getAddresses',
        'stx_getNetworks',
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
    await _sendResponse(jsData.id, {
      'networks': [
        {
          'chainId': coin.isTestnet ? 2147483648 : 1,
          'networkName': coin.isTestnet ? 'testnet' : 'mainnet',
        }
      ],
    });
  }

  // ── getAddresses / stx_getAddresses ───────────────────────────────────────

  Future<void> _getAddresses(
    _StacksMessage jsData,
    String sendingAddress,
    AccountData accountDetail,
  ) async {
    final existing = await getWeb3Address('stacks', sendingAddress);
    if (existing != null) {
      await _sendResponse(
          jsData.id, _addressPayload(sendingAddress, accountDetail));
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _sendResponse(
              jsData.id, _addressPayload(sendingAddress, accountDetail));
          await saveWeb3Address('stacks', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData.id);
        _pop();
      },
    );
  }

  // ── getAccounts / stx_getAccounts ─────────────────────────────────────────

  Future<void> _getAccounts(
    _StacksMessage jsData,
    String sendingAddress,
    AccountData accountDetail,
    StacksCoin coin,
  ) async {
    final existing = await getWeb3Address('stacks', sendingAddress);
    if (existing != null) {
      await _sendResponse(
          jsData.id, _accountPayload(sendingAddress, accountDetail, coin));
      return;
    }
    if (!context.mounted) return;
    await connectWalletModal(
      context: context,
      url: jsData.url,
      onConfirm: () async {
        try {
          await _sendResponse(
              jsData.id, _accountPayload(sendingAddress, accountDetail, coin));
          await saveWeb3Address('stacks', sendingAddress);
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected connection', jsData.id);
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
            'symbol': 'STX'
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
          await _sendResponse(jsData.id, {
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected signature', jsData.id);
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
          final msgBytes = HEX.decode(
            messageHex.startsWith('0x') ? messageHex.substring(2) : messageHex,
          );
          final domBytes = HEX.decode(
            domainHex.startsWith('0x') ? domainHex.substring(2) : domainHex,
          );

          const prefix = [0x53, 0x49, 0x50, 0x30, 0x31, 0x38];
          final domHash = stacksSha256(Uint8List.fromList(domBytes));
          final msgHash = stacksSha256(Uint8List.fromList(msgBytes));
          final toSign =
              Uint8List.fromList([...prefix, ...domHash, ...msgHash]);
          final hash = stacksSha256(toSign);

          final privBytes = txDataToUintList(accountDetail.privateKey!);
          final sigBytes = _secp256k1SignRaw(privBytes, hash);

          await _sendResponse(jsData.id, {
            'signature': HEX.encode(sigBytes),
            'publicKey': accountDetail.publicKey,
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected signature', jsData.id);
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
          'stx_signTransaction requires a transaction hex', jsData.id);
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

          final rawTx = Uint8List.fromList(HEX.decode(
            txHex.startsWith('0x') ? txHex.substring(2) : txHex,
          ));

          final signedTx = stacksResignTx(rawTx, privBytes);

          await _sendResponse(jsData.id, {
            'transaction': HEX.encode(signedTx),
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData.id);
        _pop();
      },
    );
  }

  // ── sendTransfer / stx_transferStx ────────────────────────────────────────

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
          await _sendResponse(jsData.id, {'txid': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData.id);
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
          symbol.isEmpty ||
          decimals == null) {
        await _sendError(
          'Unknown token $contractAddress.$contractName — '
          'provide symbol and decimals to transfer an unregistered SIP-010 token',
          jsData.id,
        );
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
      data: 'Send $amount ${tokenCoin.symbol}\n'
          'Contract: ${tokenCoin.tokenAddress()}\n'
          'To: $to'
          '${memo != null ? '\nMemo: $memo' : ''}',
      networkIcon: null,
      name: '${tokenCoin.symbol} Transfer',
      onConfirm: () async {
        try {
          final txHash = await tokenCoin?.transferToken(
            amount,
            to,
            memo: memo,
          );
          await _sendResponse(jsData.id, {'txHash': txHash ?? ''});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected transaction', jsData.id);
        _pop();
      },
    );
  }

  // ── stx_callContract ─────────────────────────────────────────────────────

  Future<void> _callContract(
    _StacksMessage jsData,
    StacksCoin coin,
  ) async {
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
        jsData.id,
      );
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
      data: 'Contract: $contractAddress.$contractName\n'
          'Function: $functionName\n'
          'Args:\n$argSummary',
      networkIcon: null,
      name: 'Contract Call',
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

          final fullPayload = Uint8List.fromList([
            ...payload,
            for (final arg in encodedArgs) ...arg,
          ]);

          final txBytes = stacksBuildSignedTx(
            txVersion: coin.isTestnet ? 0x80 : 0x00,
            chainId: coin.isTestnet ? 0x80000000 : 0x00000001,
            privKey: privBytes,
            senderHash160: senderHash160,
            nonce: BigInt.from(nonce),
            fee: fee,
            payload: fullPayload,
          );

          final res = await http.post(
            Uri.parse(
                '${coin.isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so'}/v2/transactions'),
            headers: {'Content-Type': 'application/octet-stream'},
            body: txBytes,
          );

          if (res.statusCode ~/ 100 != 2) {
            throw Exception('broadcast failed: ${res.body}');
          }

          final txHash = jsonDecode(res.body) as String;
          await _sendResponse(jsData.id, {'txHash': txHash});
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected contract call', jsData.id);
        _pop();
      },
    );
  }

  // ── stx_deployContract ────────────────────────────────────────────────────

  Future<void> _deployContract(
    _StacksMessage jsData,
    StacksCoin coin,
  ) async {
    final obj = jsData.object;
    final contractName = obj['contractName'] as String? ?? '';
    final codeBody = obj['codeBody'] as String? ?? '';
    final clarityVersion = (obj['clarityVersion'] as num?)?.toInt() ?? 2;

    if (contractName.isEmpty || codeBody.isEmpty) {
      await _sendError(
        'stx_deployContract requires contractName and codeBody',
        jsData.id,
      );
      return;
    }

    if (!context.mounted) return;

    await signMessage(
      context: context,
      messageType: '',
      data: 'Deploy contract: $contractName\n'
          'Clarity version: $clarityVersion\n'
          'Code size: ${codeBody.length} chars',
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

          final res = await http.post(
            Uri.parse('$api/v2/transactions'),
            headers: {'Content-Type': 'application/octet-stream'},
            body: txBytes,
          );

          if (res.statusCode ~/ 100 != 2) {
            throw Exception('deploy failed: ${res.body}');
          }

          final txHash = jsonDecode(res.body) as String;
          await _sendResponse(jsData.id, {
            'txid': txHash,
            'contractId': '${keyPair.address}.$contractName'
          });
        } catch (e) {
          await _sendError(e.toString().replaceAll('"', "'"), jsData.id);
        } finally {
          _pop();
        }
      },
      onReject: () async {
        await _sendError('user rejected deploy', jsData.id);
        _pop();
      },
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Uint8List _secp256k1SignRaw(Uint8List privKey, Uint8List hash) =>
      stacksSignRaw(privKey, hash);

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

  // ── JS response helpers ───────────────────────────────────────────────────
  // Sends to BOTH bridges:
  //   window.stacks  — for dApps using the EcoNova/Xverse-style provider
  //   leatherSendResponse — for dApps using the Leather/Hiro provider

  Future<void> _sendResponse(dynamic id, Map<String, dynamic> result) async {
    final encoded = json.encode(result);
    final safeId = id is String ? '"$id"' : '$id';
    // window.stacks uses integer ids
    if (id is int) {
      await sendCustom('window.stacks?.sendResponse($id, $encoded)');
    }
    // Leather uses UUID string ids
    await sendCustom('window.leatherSendResponse?.($safeId, $encoded)');
  }

  Future<void> _sendError(String message, dynamic id) async {
    final safe = message.replaceAll('"', "'");
    final safeId = id is String ? '"$id"' : '$id';
    if (id is int) {
      await sendCustom('window.stacks?.sendError($id, "$safe")');
    }
    await sendCustom('window.leatherSendError?.($safeId, "$safe")');
  }

  // ── Misc ─────────────────────────────────────────────────────────────────

  void _pop() {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

// ─── Message model ────────────────────────────────────────────────────────────

class _StacksMessage {
  // Leather sends UUID strings; window.stacks sends ints.
  final dynamic id;
  final String name;
  final Map<String, dynamic> object;
  final String? url;

  const _StacksMessage({
    required this.id,
    required this.name,
    required this.object,
    this.url,
  });

  /// True if this message came from the Leather provider (UUID string id).
  bool get isLeather => id is String;

  factory _StacksMessage.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final dynamic parsedId =
        rawId is String ? rawId : (rawId as num?)?.toInt() ?? 0;
    return _StacksMessage(
      id: parsedId,
      name: json['name'] as String? ?? '',
      object: (json['object'] as Map<String, dynamic>?) ?? {},
      url: json['url'] as String?,
    );
  }
}
