// coins/fungible/sip010_coin.dart
// SIP-010 fungible token support for the Stacks blockchain.
//
// Architecture mirrors ERCFungibleCoin / SplTokenCoin / ESDTCoin:
//   SIP010Coin extends StacksCoin implements FTExplorer
//
// Transfer encoding follows the SIP-010 trait:
//   (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
//
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;

import '../../coins/stack_coin.dart';
import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../main.dart';
import '../../service/wallet_service.dart';
import '../../utils/app_config.dart';
import '../../utils/c32check.dart';
import '../../utils/rpc_urls.dart';
import '../../utils/stack_tx_utils.dart';

// ─── Coin ─────────────────────────────────────────────────────────────────────

class SIP010Coin extends StacksCoin implements FTExplorer {
  /// Deployer address, e.g. "SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9"
  final String contractAddress;

  /// Contract name, e.g. "age000-governance-token"
  final String contractName;

  /// Token decimal places (from get-decimals on-chain)
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
    required this.contractAddress,
    required this.contractName,
    required this.mintDecimals,
  });

  // ─── FTExplorer ─────────────────────────────────────────────────────────────

  @override
  Widget? getNFTPage() => null;

  @override
  int decimals() => mintDecimals;

  /// Canonical identifier: "contractAddress.contractName"
  @override
  String tokenAddress() => '$contractAddress.$contractName';

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
  String savedTransKey() => '${tokenAddress()}${_api}Details';

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
      );

  // ─── Balance ────────────────────────────────────────────────────────────────

  /// Fetches all FT balances in a single call via the Hiro extended API.
  /// The response map keys are in the form "contract.name::asset-name".
  @override
  Future<double> getUserBalance({required String address}) async {
    final res = await http.get(
      Uri.parse('$_api/extended/v1/address/$address/balances'),
    );
    if (res.statusCode ~/ 100 != 2) {
      throw Exception('SIP010 balance fetch failed');
    }

    final fts =
        (jsonDecode(res.body)['fungible_tokens'] as Map<String, dynamic>);
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
    final ratePerByte = await _fetchFeeRate();
    return (ratePerByte * stacksEstimatedContractCallBytes) / stacksMicroPerStx;
  }

  // ─── Transfer ───────────────────────────────────────────────────────────────

  /// Builds and broadcasts a SIP-010 contract-call transaction.
  ///
  /// Calls:  (transfer amount sender recipient memo)
  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await importData(data);

    final privBytes = txDataToUintList(keyPair.privateKey!);
    final senderHash160 = stacksHash160(stacksCompressedPubKey(privBytes));

    final nonce = await _fetchNonce(keyPair.address);
    final feeRate = await _fetchFeeRate();
    final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);

    // Token amount in smallest units
    final tokenUnits = amount.toBigIntDec(mintDecimals);

    // Decode sender principal
    final senderDecoded = c32checkDecode(keyPair.address.substring(1));
    final senderVersion = senderDecoded[0] as int;
    final senderHash =
        Uint8List.fromList(HEX.decode(senderDecoded[1] as String));

    // Decode recipient principal
    final recipDecoded = c32checkDecode(to.substring(1));
    final recipVersion = recipDecoded[0] as int;
    final recipHash = Uint8List.fromList(HEX.decode(recipDecoded[1] as String));

    // Decode contract address principal
    final contractDecoded = c32checkDecode(contractAddress.substring(1));
    final contractVersion = contractDecoded[0] as int;
    final contractHash160 =
        Uint8List.fromList(HEX.decode(contractDecoded[1] as String));

    final payload = _buildContractCallPayload(
      contractVersion: contractVersion,
      contractHash160: contractHash160,
      contractName: contractName,
      functionName: 'transfer',
      args: [
        _clarityUInt(tokenUnits),
        _clarityStandardPrincipal(senderVersion, senderHash),
        _clarityStandardPrincipal(recipVersion, recipHash),
        _clarityOptionalMemo(memo),
      ],
    );

    final txBytes = stacksBuildSignedTx(
      txVersion: _txVersion,
      chainId: _chainId,
      privKey: privBytes,
      senderHash160: senderHash160,
      nonce: BigInt.from(nonce),
      fee: fee,
      payload: payload,
    );

    final res = await http.post(
      Uri.parse('$_api/v2/transactions'),
      headers: {'Content-Type': 'application/octet-stream'},
      body: txBytes,
    );

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('SIP010 broadcast failed: ${res.body}');
    }
    return jsonDecode(res.body) as String;
  }

  // ─── Contract-call payload ───────────────────────────────────────────────────

  /// Serialises a contract-call payload (payload type 0x02).
  ///
  /// Wire layout:
  ///   [1]       payload_type  (0x02)
  ///   [1]       contract address version
  ///   [20]      contract address hash160
  ///   [1+N]     contract name  (1-byte length, then UTF-8 bytes)
  ///   [1+N]     function name  (1-byte length, then UTF-8 bytes)
  ///   [4]       argument count (big-endian uint32)
  ///   [N*]      Clarity-encoded arguments
  static Uint8List _buildContractCallPayload({
    required int contractVersion,
    required Uint8List contractHash160,
    required String contractName,
    required String functionName,
    required List<Uint8List> args,
  }) {
    final nameBytes = utf8.encode(contractName);
    final fnBytes = utf8.encode(functionName);

    final bb = BytesBuilder()
      ..addByte(stacksPayloadContractCall)
      // Contract address
      ..addByte(contractVersion)
      ..add(contractHash160)
      // Contract name: 1-byte length prefix
      ..addByte(nameBytes.length)
      ..add(nameBytes)
      // Function name: 1-byte length prefix
      ..addByte(fnBytes.length)
      ..add(fnBytes)
      // Argument list: 4-byte count
      ..add(stacksU32BE(args.length));

    for (final arg in args) {
      bb.add(arg);
    }
    return bb.toBytes();
  }

  // ─── Clarity value encoders ──────────────────────────────────────────────────

  /// Clarity UInt: type byte 0x01 | 16-byte big-endian unsigned integer.
  static Uint8List _clarityUInt(BigInt value) {
    final buf = Uint8List(17)..[0] = 0x01;
    var v = value.toUnsigned(128);
    for (int i = 16; i >= 1; i--) {
      buf[i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
    return buf;
  }

  /// Clarity standard principal: type 0x05 | address version | hash160 (20 bytes).
  static Uint8List _clarityStandardPrincipal(int version, Uint8List hash160) =>
      (BytesBuilder()
            ..addByte(0x05)
            ..addByte(version)
            ..add(hash160))
          .toBytes();

  /// Clarity (optional (buff 34)):
  ///   - None  → 0x09
  ///   - Some  → 0x0a | 0x02 | 4-byte length | bytes
  ///
  /// SIP-010 accepts an optional buffer memo; we send None when blank.
  static Uint8List _clarityOptionalMemo(String? memo) {
    final text = (memo ?? '').trim();
    if (text.isEmpty) {
      return Uint8List(1)..[0] = 0x09; // none
    }
    final content = utf8.encode(text);
    final len = content.length.clamp(0, stacksMemoMaxBytes);
    return (BytesBuilder()
          ..addByte(0x0a) // some
          ..addByte(0x02) // buff type
          ..add(stacksU32BE(len))
          ..add(content.sublist(0, len)))
        .toBytes();
  }

  // ─── Private API helpers ─────────────────────────────────────────────────────

  String get _api =>
      isTestnet ? 'https://api.testnet.hiro.so' : 'https://api.hiro.so';

  // These intentionally mirror StacksCoin._fetchFeeRate / _fetchNonce so that
  // SIP010Coin is self-contained (StacksCoin's versions are file-private).
  Future<int> _fetchFeeRate() async {
    try {
      final res = await http.get(Uri.parse('$_api/v2/fees/transfer'));
      if (res.statusCode ~/ 100 == 2) {
        return int.parse(jsonDecode(res.body).toString());
      }
    } catch (_) {}
    return 10;
  }

  Future<int> _fetchNonce(String address) async {
    final res = await http.get(Uri.parse('$_api/v2/accounts/$address?proof=0'));
    if (res.statusCode ~/ 100 != 2) throw Exception('STX nonce fetch failed');
    return jsonDecode(res.body)['nonce'] as int;
  }

  int get _txVersion => isTestnet ? 0x80 : 0x00;

  int get _chainId => isTestnet ? 0x80000000 : 0x00000001;
}

// ─── Factory ──────────────────────────────────────────────────────────────────
List<SIP010Coin> getSIP010Coins() {
  if (enableTestNet) {
    return [
      SIP010Coin(
        name: 'USDX',
        symbol: 'USDX',
        default_: 'STX',
        isTestnet: true,
        blockExplorer:
            'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=testnet',
        image: 'assets/wusd.png',
        derivationPath: "m/44'/5757'/0'/0/0",
        geckoID: '',
        rampID: '',
        payScheme: 'stacks',
        contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        contractName: 'usdcx-v1',
        mintDecimals: 6,
      ),
      SIP010Coin(
        name: 'sBTC',
        symbol: 'sBTC',
        default_: 'STX',
        isTestnet: true,
        blockExplorer:
            'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=testnet',
        image: 'assets/sbtc.webp',
        derivationPath: "m/44'/5757'/0'/0/0",
        geckoID: 'bitcoin',
        rampID: '',
        payScheme: 'stacks',
        contractAddress: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4',
        contractName: 'sbtc-token',
        mintDecimals: 8,
      ),
    ];
  }

  return [
    SIP010Coin(
      name: 'USDX',
      symbol: 'USDX',
      default_: 'STX',
      isTestnet: false,
      blockExplorer:
          'https://explorer.hiro.so/txid/$blockExplorerPlaceholder?chain=mainnet',
      image: 'assets/wusd.png',
      derivationPath: "m/44'/5757'/0'/0/0",
      geckoID: '',
      rampID: '',
      payScheme: 'stacks',
      contractAddress: 'SP120SBRBQJ00MCWS7TM5R8WJNTTKD5K0HFRC2CNE',
      contractName: 'usdcx',
      mintDecimals: 6,
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
    ),
  ];
}
