// ignore_for_file: non_constant_identifier_names, constant_identifier_names

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
    required super.caipReference,
    required this.assetId,
    required this.mintDecimals,
  }) : super(
          coinDecimals: mintDecimals,
          rampID: '',
        );

  /// Inherits chain-level fields (ss58, path, payScheme, caipReference,
  /// default_) from [parent]. Pass [api] and [blockExplorer] explicitly since
  /// Asset Hub uses different endpoints than the relay chain.
  factory PolkadotFungibleCoin.fromParent({
    required PolkadotCoin parent,
    required String name,
    required String symbol,
    required String image,
    required String geckoID,
    required int assetId,
    required int mintDecimals,
  }) =>
      PolkadotFungibleCoin(
        // ── inherited from relay-chain parent ─────────────
        ss58Prefix: parent.ss58Prefix,
        path: parent.path,
        payScheme: parent.payScheme,
        caipReference: parent.caipReference,
        default_: parent.default_,
        // ── Asset Hub specific ─────────────────────────────
        api: parent.api,
        blockExplorer: parent.blockExplorer,
        // ── token-specific ─────────────────────────────────
        name: name,
        symbol: symbol,
        image: image,
        geckoID: geckoID,
        assetId: assetId,
        mintDecimals: mintDecimals,
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
      caipReference: json['caipReference'],
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
  // Relay chain parent — supplies ss58Prefix, path, payScheme, caipRef, default_
  final relayParent = getPolkadoBlockChains().first;

  if (enableTestNet) {
    return [
      PolkadotFungibleCoin.fromParent(
        parent: relayParent,
        name: 'USDC (Devnet)',
        symbol: 'USDC',
        image: 'assets/wusd.png',
        geckoID: 'usd-coin',
        assetId: 31337,
        mintDecimals: 6,
      ),
    ];
  }

  return [
    PolkadotFungibleCoin.fromParent(
      parent: relayParent,
      name: 'Tether USD',
      symbol: 'USDT',
      image: 'assets/usdt.png',
      geckoID: 'tether',
      assetId: 1984,
      mintDecimals: 6,
    ),
    PolkadotFungibleCoin.fromParent(
      parent: relayParent,
      name: 'USD Coin',
      symbol: 'USDC',
      image: 'assets/wusd.png',
      geckoID: 'usd-coin',
      assetId: 1337,
      mintDecimals: 6,
    ),
  ];
}
