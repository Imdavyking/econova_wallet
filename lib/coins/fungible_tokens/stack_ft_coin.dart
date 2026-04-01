// coins/fungible/sip010_coin.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import '../../save_goal/usdcx_goal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

import '../../coins/stack_coin.dart';
import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../main.dart';
import '../../service/wallet_service.dart';
import '../../service/x402_service.dart';
import '../../utils/app_config.dart';
import '../../utils/c32check.dart';
import '../../utils/rpc_urls.dart';
import '../../utils/stack_tx_utils.dart';

class SIP010Coin extends StacksCoin implements FTExplorer {
  final String contractAddress;
  final String contractName;
  final int mintDecimals;

  SIP010Coin({
    required super.isTestnet,
    required super.derivationPath,
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.geckoID,
    required super.rampID,
    required super.payScheme,
    required super.caipReference,
    required this.contractAddress,
    required this.contractName,
    required this.mintDecimals,
  });

  // ─── FTExplorer ─────────────────────────────────────────────────────────────

  @override
  Widget? getNFTPage() => null;

  @override
  int decimals() => mintDecimals;

  @override
  String tokenAddress() => '$contractAddress.$contractName';
  @override
  Widget? getGoalPage() {
    if (contractName == 'usdcx') return USDCxGoalsPage(coin: this);
    return null;
  }

  @override
  String contractExplorer() {
    final chain = isTestnet ? 'testnet' : 'mainnet';
    return 'https://explorer.hiro.so/token/${tokenAddress()}?chain=$chain';
  }

  @override
  String? get badgeImage => getStacksBlockchains().first.image;

  @override
  String getGeckoId() => geckoID;

  @override
  String savedTransKey() =>
      '${tokenAddress()}${stacksApiUrl(isTestnet)}Details';

  // ─── x402 support ───────────────────────────────────────────────────────────

  /// SIP-010 tokens use a contract call to `transfer`, not a simple STX
  /// transfer. Mirrors wrapAxiosWithPayment's makeContractCall path.
  /// Calls encodePayload from StacksCoin (public, not file-private).
  @override
  Future<String?> signX402Payment(
    X402PaymentOption option, {
    int version = 1,
  }) async {
    if (!isStacksNetwork(option.network)) {
      debugPrint('SIP010Coin: declining non-Stacks network ${option.network}');
      return null;
    }

    if (option.payTo.isEmpty) {
      debugPrint('SIP010Coin x402: payTo missing');
      return null;
    }

    try {
      final walletData = WalletService.getActiveKey(walletImportType)!.data;
      final accountData = await importData(walletData);
      final privBytes = txDataToUintList(accountData.privateKey!);
      final senderHash160 = hash160(compressedPubKey(privBytes));

      final txHex = await buildSip010X402TransferHex(
        option: option,
        privBytes: privBytes,
        senderHash160: senderHash160,
        senderAddress: accountData.address,
      );

      // encodePayload is public in StacksCoin — accessible across files
      return encodePayload(
        version: version,
        option: option,
        txHex: txHex,
      );
    } catch (e) {
      debugPrint('SIP010Coin x402 sign error: $e');
      return null;
    }
  }

  /// Builds and signs a SIP-010 `transfer` contract call.
  /// Returns hex WITHOUT 0x prefix — matches wrapAxiosWithPayment.
  Future<String> buildSip010X402TransferHex({
    required X402PaymentOption option,
    required Uint8List privBytes,
    required Uint8List senderHash160,
    required String senderAddress,
  }) async {
    final tokenUnits = BigInt.parse(option.maxAmountRequired);
    final nonce = await stacksFetchNonce(isTestnet, senderAddress);
    final feeRate = await stacksFetchFeeRate(isTestnet);
    final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);

    final senderDecoded = c32checkDecode(senderAddress.substring(1));
    final senderHash =
        Uint8List.fromList(HEX.decode(senderDecoded[1] as String));

    final recipDecoded = c32checkDecode(option.payTo.substring(1));
    final recipHash = Uint8List.fromList(HEX.decode(recipDecoded[1] as String));

    final contractDecoded = c32checkDecode(contractAddress.substring(1));
    final contractHash160 =
        Uint8List.fromList(HEX.decode(contractDecoded[1] as String));
    final memoRaw =
        'x402:${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    final memo = memoRaw.substring(0, memoRaw.length.clamp(0, 34));

    final payload = stacksBuildContractCallPayload(
      contractVersion: contractDecoded[0] as int,
      contractHash160: contractHash160,
      contractName: contractName,
      functionName: 'transfer',
      args: [
        clarityUInt(tokenUnits),
        clarityStandardPrincipal(senderDecoded[0] as int, senderHash),
        clarityStandardPrincipal(recipDecoded[0] as int, recipHash),
        clarityOptionalMemo(memo),
      ],
    );

    final txBytes = stacksBuildSignedTx(
      txVersion: stacksTxVersion(isTestnet),
      chainId: stacksChainId(isTestnet),
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: payload,
    );

    return HEX.encode(txBytes); // no 0x prefix
  }

  // ─── Serialization ───────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'contractAddress': contractAddress,
        'contractName': contractName,
        'mintDecimals': mintDecimals,
      };

  factory SIP010Coin.fromJson(Map<String, dynamic> json) => SIP010Coin(
        isTestnet: json['isTestnet'],
        blockExplorer: json['blockExplorer'],
        symbol: json['symbol'],
        default_: json['default'],
        image: json['image'],
        name: json['name'],
        geckoID: json['geckoID'],
        rampID: json['rampID'] ?? '',
        payScheme: json['payScheme'] ?? 'stacks',
        derivationPath: json['derivationPath'],
        contractAddress: json['contractAddress'],
        contractName: json['contractName'],
        mintDecimals: json['mintDecimals'],
        caipReference: json['caipReference'],
      );

  // ─── Balance ────────────────────────────────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(
      Uri.parse(
          '${stacksApiUrl(isTestnet)}/extended/v1/address/$address/balances'),
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('SIP010 balance fetch failed');
    }

    final fts = jsonDecode(res.body)['fungible_tokens'] as Map<String, dynamic>;
    final prefix = '${tokenAddress()}::';
    final entry = fts.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value as Map<String, dynamic>)
        .firstOrNull;

    if (entry == null) return 0.0;
    final raw = BigInt.parse(entry['balance'] as String);
    return raw / BigInt.from(10).pow(mintDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'SIP010Balance${tokenAddress()}$address';
    final stored = pref.get(key) as double?;
    if (useCache) return stored ?? 0.0;
    try {
      final bal = await getUserBalance(address: address);
      await pref.put(key, bal);
      return bal;
    } catch (_) {
      return stored ?? 0.0;
    }
  }

  // ─── Fee ────────────────────────────────────────────────────────────────────

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final ratePerByte = await stacksFetchFeeRate(isTestnet);
    return (ratePerByte * stacksEstimatedContractCallBytes) / stacksMicroPerStx;
  }

  // ─── Transfer ───────────────────────────────────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);

    final privBytes = txDataToUintList(keyPair.privateKey!);
    final senderHash160 = hash160(compressedPubKey(privBytes));
    final nonce = await stacksFetchNonce(isTestnet, keyPair.address);
    final feeRate = await stacksFetchFeeRate(isTestnet);
    final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);
    final tokenUnits = amount.toBigIntDec(mintDecimals);

    final senderDecoded = c32checkDecode(keyPair.address.substring(1));
    final senderHash =
        Uint8List.fromList(HEX.decode(senderDecoded[1] as String));

    final recipDecoded = c32checkDecode(to.substring(1));
    final recipHash = Uint8List.fromList(HEX.decode(recipDecoded[1] as String));

    final contractDecoded = c32checkDecode(contractAddress.substring(1));
    final contractHash160 =
        Uint8List.fromList(HEX.decode(contractDecoded[1] as String));

    final payload = stacksBuildContractCallPayload(
      contractVersion: contractDecoded[0] as int,
      contractHash160: contractHash160,
      contractName: contractName,
      functionName: 'transfer',
      args: [
        clarityUInt(tokenUnits),
        clarityStandardPrincipal(senderDecoded[0] as int, senderHash),
        clarityStandardPrincipal(recipDecoded[0] as int, recipHash),
        clarityOptionalMemo(memo),
      ],
    );

    final txBytes = stacksBuildSignedTx(
      txVersion: stacksTxVersion(isTestnet),
      chainId: stacksChainId(isTestnet),
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: payload,
    );

    final res = await http.post(
      Uri.parse('${stacksApiUrl(isTestnet)}/v2/transactions'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: txBytes,
    );

    if (res.statusCode ~/ 100 != 2) {
      if (kDebugMode) print(res.body);
      throw Exception('SIP010 broadcast failed: ${res.body}');
    }

    return (
      txHash: jsonDecode(res.body) as String,
      txRaw: HEX.encode(txBytes),
    );
  }
}

// ─── Factory ──────────────────────────────────────────────────────────────────

List<SIP010Coin> getSIP010Coins() {
  if (enableTestNet) {
    return [
      SIP010Coin(
        name: 'USDCX',
        symbol: 'USDCX',
        default_: 'STX',
        isTestnet: true,
        blockExplorer:
            'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=testnet',
        image: 'assets/wusd.png',
        derivationPath: "m/44'/5757'/0'/0/0",
        geckoID: 'usd-coin',
        rampID: '',
        payScheme: 'stacks',
        contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        contractName: 'usdcx',
        mintDecimals: 6,
        caipReference: '2147483648',
      ),
    ];
  }

  return [
    SIP010Coin(
      name: 'USDCX',
      symbol: 'USDCX',
      default_: 'STX',
      isTestnet: false,
      blockExplorer:
          'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=mainnet',
      image: 'assets/wusd.png',
      derivationPath: "m/44'/5757'/0'/0/0",
      geckoID: 'usd-coin',
      rampID: '',
      payScheme: 'stacks',
      contractAddress: 'SP120SBRBQJ00MCWS7TM5R8WJNTTKD5K0HFRC2CNE',
      contractName: 'usdcx',
      mintDecimals: 6,
      caipReference: '1',
    ),
    SIP010Coin(
      name: 'sBTC',
      symbol: 'sBTC',
      default_: 'STX',
      isTestnet: false,
      blockExplorer:
          'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=mainnet',
      image: 'assets/sbtc.webp',
      derivationPath: "m/44'/5757'/0'/0/0",
      geckoID: 'bitcoin',
      rampID: '',
      payScheme: 'stacks',
      contractAddress: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4',
      contractName: 'sbtc-token',
      mintDecimals: 8,
      caipReference: '1',
    ),
  ];
}
