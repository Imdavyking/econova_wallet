// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:polkadart_scale_codec/polkadart_scale_codec.dart';
import 'package:substrate_metadata/core/metadata_decoder.dart';

import '../../extensions/big_int_ext.dart';
import '../../interface/ft_explorer.dart';
import '../../main.dart';
import '../../utils/app_config.dart';
import '../polkadot_coin.dart';

/// Storage prefix for Assets.Account double map.
/// Key layout: xxh128('Assets') + xxh128('Account')
///           + blake2_128_concat(u32 assetId LE)
///           + blake2_128_concat(accountId 32 bytes)
final _assetsAccount = '0x${xxhashAsHex('Assets')}${xxhashAsHex('Account')}';

class PolkadotFungibleCoin extends PolkadotCoin implements FTExplorer {
  /// On-chain asset ID (e.g. 1984 for USDT, 1337 for USDC on Asset Hub)
  final int assetId;

  /// Decimals for this specific token
  final int mintDecimals;

  PolkadotFungibleCoin({
    required super.blockExplorer,
    required super.symbol,
    required super.default_,
    required super.image,
    required super.name,
    required super.api,
    required super.ss58Prefix,
    required super.path,
    required super.geckoID,
    required super.payScheme,
    required this.assetId,
    required this.mintDecimals,
  }) : super(
          coinDecimals: mintDecimals,
          rampID: '',
        );

  factory PolkadotFungibleCoin.fromJson(Map<String, dynamic> json) {
    return PolkadotFungibleCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      api: json['api'],
      ss58Prefix: json['ss58Prefix'],
      path: json['path'],
      geckoID: json['geckoID'],
      payScheme: json['payScheme'],
      assetId: json['assetId'],
      mintDecimals: json['mintDecimals'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'assetId': assetId,
      'mintDecimals': mintDecimals,
    };
  }

  // ── FTExplorer ──────────────────────────────────────────────────────────────

  @override
  String tokenAddress() => assetId.toString();

  @override
  String contractExplorer() {
    return getExplorer()
        .replaceFirst('/extrinsic/', '/assets/')
        .replaceFirst(blockExplorerPlaceholder, '$assetId');
  }

  @override
  String? get badgeImage {
    try {
      return getPolkadoBlockChains().firstWhere((c) => c.api == api).image;
    } catch (_) {
      return null;
    }
  }

  @override
  String savedTransKey() => 'polkadotFT${assetId}_$api Details';

  // ── Decimals ────────────────────────────────────────────────────────────────

  @override
  int decimals() => mintDecimals;

  // ── Balance via Assets.Account storage ─────────────────────────────────────

  @override
  Future<double> getUserBalance({required String address}) async {
    if (rpcMethods == null) {
      final result = await queryRpc('rpc_methods', []);
      rpcMethods = result!['result']['methods'];
    }

    String? getHead =
        rpcMethods!.firstWhere((element) => element == 'chain_getHead');
    getHead ??=
        rpcMethods!.firstWhere((element) => element == 'chain_getBlockHash');
    final blockHashRes = await queryRpc(getHead!, []);

    final decodedAddr = decodeDOTAddress(address);

    // assetId encoded as u32 little-endian (4 bytes) for the storage key
    final assetIdBytes = Uint8List(4);
    ByteData.view(assetIdBytes.buffer).setUint32(0, assetId, Endian.little);

    final assetIdKey = blake2_128_concat(assetIdBytes);
    final accountKey = blake2_128_concat(decodedAddr);

    final storageKey =
        '$_assetsAccount${HEX.encode(assetIdKey)}${HEX.encode(accountKey)}';

    String? getStorageAt = rpcMethods!.firstWhere(
      (element) => element == 'state_getStorageAt',
    );
    getStorageAt ??= rpcMethods!.firstWhere(
      (element) => element == 'state_getStorage',
    );

    final storageResult = await queryRpc(
      getStorageAt!,
      [storageKey, blockHashRes!['result']],
    );

    final result = storageResult?['result'];
    if (result == null || result == '0x') return 0;

    String storageData = (result as String).replaceFirst('0x', '');
    if (storageData.isEmpty) return 0;

    // AssetAccount layout: balance (u128 = 16 bytes = 32 hex chars) first
    final input = Input.fromHex(storageData.substring(0, 32));
    final BigInt balance = U128Codec.codec.decode(input);
    final base = BigInt.from(10);
    return balance / base.pow(mintDecimals);
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'polkadotFTBalance$address$api$assetId';

    final storedBalance = pref.get(key);
    double savedBalance = 0;
    if (storedBalance != null) savedBalance = storedBalance;
    if (useCache) return savedBalance;

    try {
      final userBal = await getUserBalance(address: address);
      await pref.put(key, userBal);
      return userBal;
    } catch (_) {
      return savedBalance;
    }
  }

  // ── Transfer via Assets.transfer_keep_alive ─────────────────────────────────

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final planck = amount.toBigIntDec(mintDecimals);
    final decodedAddr = decodeDOTAddress(to);
    final nonce = await getNonce();

    final metaData = await queryRpc('state_getMetadata', []);
    final decoded = MetadataDecoder.instance.decode(metaData!['result']);
    final chainInfo = await compute(decodeMetadataCompute, decoded);

    // Only this changes vs native transfer
    final transferArgument = MapEntry(
      'Assets',
      MapEntry(
        'transfer_keep_alive',
        {
          'id': assetId,
          'target': MapEntry('Id', Uint8List.fromList(decodedAddr)),
          'amount': planck,
        },
      ),
    );

    final ByteOutput output = ByteOutput();
    chainInfo.scaleCodec.registry.codecs['Call']!
        .encodeTo(transferArgument, output);
    final encodedCall = HEX.encode(output.toBytes());

    return buildAndSubmitExtrinsic(
      encodedCall: encodedCall,
      chainInfo: chainInfo,
      nonce: nonce,
    );
  }
}

// ── Token registry ────────────────────────────────────────────────────────────

List<PolkadotFungibleCoin> getPolkadotFungibleCoins() {
  List<PolkadotFungibleCoin> coins = [];

  if (enableTestNet) {
    // Asset Hub Westend doesn't have standard USDT/USDC,
    // but the structure is ready for any asset deployed there.
    coins.addAll([
      PolkadotFungibleCoin(
        name: 'USDC (Devnet)',
        symbol: 'USDC',
        default_: 'WND',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        assetId: 31337,
        mintDecimals: 6,
        api: 'https://westend-asset-hub-rpc.polkadot.io',
        blockExplorer:
            'https://assethub-westend.subscan.io/extrinsic/$blockExplorerPlaceholder',
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        payScheme: '',
      ),
    ]);
  } else {
    // Polkadot Asset Hub mainnet
    coins.addAll([
      PolkadotFungibleCoin(
        name: 'Tether USD',
        symbol: 'USDT',
        default_: 'DOT',
        image: 'assets/usdt.png',
        geckoID: 'tether',
        assetId: 1984,
        mintDecimals: 6,
        api: 'https://asset-hub-polkadot-rpc.dwellir.com',
        blockExplorer:
            'https://assethub-polkadot.subscan.io/extrinsic/$blockExplorerPlaceholder',
        ss58Prefix: 0,
        path: "m/44'/354'/0'/0'/0'",
        payScheme: 'polkadot',
      ),
      PolkadotFungibleCoin(
        name: 'USD Coin',
        symbol: 'USDC',
        default_: 'DOT',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        assetId: 1337,
        mintDecimals: 6,
        api: 'https://asset-hub-polkadot-rpc.dwellir.com',
        blockExplorer:
            'https://assethub-polkadot.subscan.io/extrinsic/$blockExplorerPlaceholder',
        ss58Prefix: 0,
        path: "m/44'/354'/0'/0'/0'",
        payScheme: 'polkadot',
      ),
    ]);
  }

  return coins;
}
