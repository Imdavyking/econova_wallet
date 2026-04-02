// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:web3dart/crypto.dart';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:wallet_app/coins/fungible_tokens/polkadot_ft_coin.dart';
import 'package:bip39/bip39.dart';
import 'package:bs58check/bs58check.dart' hide getAddress;
import '../utils/blake2bhash.dart';
import '../utils/sign_ed25519.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart';
import 'package:polkadart_scale_codec/polkadart_scale_codec.dart';
import 'package:substrate_metadata/core/metadata_decoder.dart';
import 'package:substrate_metadata/models/models.dart';
import 'package:xxh64/xxh64.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

final systemAccount = '0x${xxhashAsHex('System')}${xxhashAsHex('Account')}';

class PolkadotCoin extends Coin {
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String api;
  int coinDecimals;
  List? rpcMethods;
  Map? runTimeResult;
  String? genesisHash;
  int ss58Prefix;
  String path;
  String geckoID;
  String rampID;
  String payScheme;
  String caipReference;

  @override
  String getExplorer() => blockExplorer;

  @override
  String getDefault() => default_;

  @override
  String getImage() => image;

  @override
  String getName() => name;

  @override
  String getSymbol() => symbol;

  @override
  int decimals() => coinDecimals;

  @override
  String get caip2Namespace => 'polkadot';
  @override
  String get caip2Reference => caipReference;

  @override
  bool get supportPrivateKey => true;

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey =
        'polkadotDetailsPrivate${walletImportType.name}$ss58Prefix';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final keys = await _PolkadotDerive.fromPrivateKey(
      privateKey: HEX.decode(privateKey),
      ss58Prefix: ss58Prefix,
    );

    privateKeyMap[privateKey] = keys.toJson();
    await pref.put(saveKey, jsonEncode(privateKeyMap));
    return keys;
  }

  @override
  bool get supportBip39Seed => true;

// ── Top-level address encoder (mirrors _PolkadotDerive but without async) ──
  String encodePolkadotAddress(Uint8List publicKey, int ss58Prefix) {
    // For multi-byte ss58 prefixes this would need the canary encoding,
    // but all current chains use single-byte prefixes (0-63).
    List<int> prefix = [ss58Prefix, ...publicKey.sublist(1)]; // ← skips byte 0

    return base58.encode(
      Uint8List.fromList([
        ...prefix,
        ...sshash(Uint8List.fromList(prefix)).sublist(
          0,
          [32, 33].contains(publicKey.length) ? 2 : 1,
        ),
      ]),
    );
  }
  // ── In PolkadotCoin ──────────────────────────────────────────────────────────

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey:
            'polkadotDetails${path.replaceAll("/", "_")}${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculatePolkadotKey,
          PolkadotArgs(seedRoot: seedPhraseRoot, path: path),
        ),
        postProcess: (cached) {
          final publicKey =
              Uint8List.fromList(HEX.decode(cached['publicKey'] as String));
          cached['address'] = encodePolkadotAddress(publicKey, ss58Prefix);
          return cached;
        },
      );
  @override
  String savedTransKey() => '$default_$api Details';

  Future<int> getNonce() async {
    const nonce = 0;
    try {
      if (rpcMethods == null) {
        final result = await queryRpc('rpc_methods', []);
        rpcMethods = result!['result']['methods'];
      }
      String? getHead =
          rpcMethods!.firstWhere((element) => element == 'chain_getHead');
      getHead ??=
          rpcMethods!.firstWhere((element) => element == 'chain_getBlockHash');
      final blockHashRes = await queryRpc(getHead!, []);
      final String address = await getAddress();
      final decodedAddr = decodeDOTAddress(address);
      final storageName = blake2_128_concat(decodedAddr);
      final storageKey = '$systemAccount${HEX.encode(storageName)}';

      String? getStorageAt =
          rpcMethods!.firstWhere((element) => element == 'state_getStorageAt');
      getStorageAt ??=
          rpcMethods!.firstWhere((element) => element == 'state_getStorage');

      final storageResult =
          await queryRpc(getStorageAt!, [storageKey, blockHashRes!['result']]);
      String storageData = storageResult!['result'];
      storageData = storageData.replaceFirst('0x', '');
      final input = Input.fromHex(storageData.substring(0, 8));
      return U32Codec.codec.decode(input);
    } catch (_) {
      return nonce;
    }
  }

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
    final String addr = await getAddress();
    final decodedAddr = decodeDOTAddress(addr);
    final storageName = blake2_128_concat(decodedAddr);
    final storageKey = '$systemAccount${HEX.encode(storageName)}';

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
    String storageData = storageResult!['result'];
    storageData = storageData.replaceFirst('0x', '');

    final input = Input.fromHex(storageData.substring(32, 32 + 48));
    final BigInt balanceBigInt = U128Codec.codec.decode(input);
    final base = BigInt.from(10);
    return balanceBigInt / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'polkadotAddressBalance$address$api$ss58Prefix';

    final storedBalance = pref.get(key);
    double savedBalance = 0;
    if (storedBalance != null) savedBalance = storedBalance;
    if (useCache) return savedBalance;

    try {
      double userBal = await getUserBalance(address: address);
      await pref.put(key, userBal);
      return userBal;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  List<Coin> get networkTokens => getPolkadotFungibleCoins();

  @override
  Future<double> getTransactionFee(String amount, String to) async => 0;

  PolkadotCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.coinDecimals,
    required this.ss58Prefix,
    required this.path,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.caipReference,
  });

  factory PolkadotCoin.fromJson(Map<String, dynamic> json) {
    return PolkadotCoin(
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      api: json['api'],
      coinDecimals: json['coinDecimals'],
      ss58Prefix: json['ss58Prefix'],
      path: json['path'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      caipReference: json['caipReference'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'default': default_,
      'symbol': symbol,
      'name': name,
      'blockExplorer': blockExplorer,
      'image': image,
      'api': api,
      'coinDecimals': coinDecimals,
      'ss58Prefix': ss58Prefix,
      'path': path,
      'geckoID': geckoID,
      'rampID': rampID,
      'payScheme': payScheme,
      'caipReference': caipReference,
    };
  }

  Future<Map?> queryRpc(String rpcMethod, List params) async {
    try {
      final body = json.encode({
        "jsonrpc": "2.0",
        "id": "1",
        "method": rpcMethod,
        "params": params,
      });
      final response = await post(
        Uri.parse(api),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final responseBody = response.body;
      if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
        throw Exception(responseBody);
      }
      return jsonDecode(responseBody);
    } catch (e) {
      return null;
    }
  }

  ChainInfo decodeMetadataCompute(DecodedMetadata metadata) {
    return ChainInfo.fromMetadata(metadata);
  }

  Uint8List signEd25519Compute(PolkadotEDSignature signature) {
    final signing = signature.signaturePayload.replaceFirst('0x', '');
    return signEd25519(
      message: HEX.decode(signing) as Uint8List,
      privateKey: signature.privatekey,
    );
  }

  /// Builds and submits a signed extrinsic. Shared by native + FT transfers.
  Future<({String txHash, String? txRaw})?> buildAndSubmitExtrinsic({
    required String encodedCall,
    required ChainInfo chainInfo,
    required int nonce,
  }) async {
    final data_service = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data_service);
    final privatekey = HEX.decode(response.privateKey!) as Uint8List;
    final registry = chainInfo.scaleCodec.registry;
    final signables = registry.signedExtensions;
    final checkMetaHash = signables.containsKey('CheckMetadataHash');
    final hasAssetTxPayment = signables.containsKey('ChargeAssetTxPayment');

    final signaturePayload = await buildSignaturePayload(
      PolkadotSigParams(
        call: encodedCall,
        nonce: nonce,
        registry: registry,
      ),
    );

    final publicKey = HEX.decode(response.publicKey!);
    final signature = await compute(
      signEd25519Compute,
      PolkadotEDSignature(
        privatekey: privatekey,
        signaturePayload: signaturePayload,
      ),
    );

    String txSubmission = '84';
    txSubmission += HEX.encode(publicKey);
    txSubmission += '00'; // Ed25519 sig type
    txSubmission += HEX.encode(signature);
    txSubmission += '00'; // era (immortal)
    txSubmission += HEX.encode(CompactCodec.codec.encode(nonce));
    txSubmission += '00'; // tip
    if (hasAssetTxPayment) txSubmission += '00'; // Option<AssetId> = None
    if (checkMetaHash) {
      txSubmission +=
          HEX.encode(signables['CheckMetadataHash']!.encode('Disabled'));
    }
    txSubmission += encodedCall;

    int txLength = HEX.decode(txSubmission).length;
    txSubmission =
        HEX.encode(CompactCodec.codec.encode(txLength)) + txSubmission;

    final submitResult =
        await queryRpc('author_submitExtrinsic', ['0x$txSubmission']);

    return (
      txHash: submitResult!['result'] as String,
      txRaw: null,
    );
  }

  Future<String> buildSignaturePayload(PolkadotSigParams param) async {
    final signables = param.registry.signedExtensions;
    final checkMetaHash = signables.containsKey('CheckMetadataHash');
    final hasAssetTxPayment = signables.containsKey('ChargeAssetTxPayment');

    if (runTimeResult == null) {
      final runTimeVersion = await queryRpc('chain_getRuntimeVersion', []);
      runTimeResult = runTimeVersion!['result'];
    }

    if (genesisHash == null) {
      final genesisHashRes = await queryRpc('chain_getBlockHash', [0]);
      genesisHash = genesisHashRes!['result'];
    }

    String payload = '0x${param.call}';
    payload += '00'; // era (immortal)
    payload += HEX.encode(CompactCodec.codec.encode(param.nonce));
    payload += '00'; // tip
    if (hasAssetTxPayment) payload += '00'; // Option<AssetId> = None
    if (checkMetaHash) {
      payload += HEX.encode(signables['CheckMetadataHash']!.encode('Disabled'));
    }
    payload += HEX.encode(U32Codec.codec.encode(runTimeResult!['specVersion']));
    payload +=
        HEX.encode(U32Codec.codec.encode(runTimeResult!['transactionVersion']));
    payload += genesisHash!.replaceFirst('0x', '');
    payload += genesisHash!.replaceFirst('0x', '');
    if (checkMetaHash) payload += '00';

    final hexPayload = HEX.decode(strip0x(payload));
    if (hexPayload.length > 256) {
      return HEX.encode(blake2bHash256(hexPayload));
    }
    return payload;
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final planck = amount.toBigIntDec(decimals());
    final decodedAddr = decodeDOTAddress(to);
    final nonce = await getNonce();

    final metaData = await queryRpc('state_getMetadata', []);
    final decoded = MetadataDecoder.instance.decode(metaData!['result']);
    final chainInfo = await compute(decodeMetadataCompute, decoded);

    final transferArgument = MapEntry(
      'Balances',
      MapEntry(
        'transfer_keep_alive',
        {
          'dest': MapEntry('Id', Uint8List.fromList(decodedAddr)),
          'value': planck,
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

  @override
  validateAddress(String address) => decodeDOTAddress(address);

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/extrinsic/', '/account/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

// ── Shared data classes ───────────────────────────────────────────────────────

class PolkadotEDSignature {
  final String signaturePayload;
  final Uint8List privatekey;
  const PolkadotEDSignature({
    required this.privatekey,
    required this.signaturePayload,
  });
}

class PolkadotSigParams {
  final String call;
  final int nonce;
  final Registry registry;
  const PolkadotSigParams({
    required this.call,
    required this.nonce,
    required this.registry,
  });
}

// ── Top-level helpers ─────────────────────────────────────────────────────────

List _polkaChecksum(Uint8List decoded) {
  final ss58Length = (decoded[0] & 64) != 0 ? 2 : 1;
  final ss58Decoded = ss58Length == 1
      ? decoded[0]
      : ((decoded[0] & 63) << 2) | (decoded[1] >> 6) | ((decoded[1] & 63) << 8);
  final isPublicKey =
      [34 + ss58Length, 35 + ss58Length].contains(decoded.length);
  final length = decoded.length - (isPublicKey ? 2 : 1);
  final hash = sshash(Uint8List.fromList(decoded.sublist(0, length)));
  final isValid = (decoded[0] & 128) == 0 &&
      ![46, 47].contains(decoded[0]) &&
      (isPublicKey
          ? decoded[decoded.length - 2] == hash[0] &&
              decoded[decoded.length - 1] == hash[1]
          : decoded[decoded.length - 1] == hash[0]);
  return [isValid, length, ss58Length, ss58Decoded];
}

Uint8List decodeDOTAddress(String address) {
  final decoded = base58.decode(address);
  final checksum = _polkaChecksum(decoded);
  final bool isValid = checksum[0];
  final int endPos = checksum[1];
  final int ss58Length = checksum[2];
  if (!isValid) throw Exception('Invalid decoded address checksum');
  return decoded.sublist(ss58Length, endPos);
}

Future<List<int>> bip39ToMiniSeed(mnemonic) async {
  final entropy = HEX.decode(mnemonicToEntropy(mnemonic));
  final salt = StrCodec.codec.encode('mnemonic').sublist(1);
  final pdkd = Pbkdf2(
    macAlgorithm: Hmac.sha512(),
    iterations: 2048,
    bits: 256,
  );
  final keys = await pdkd.deriveKey(secretKey: SecretKey(entropy), nonce: salt);
  return await keys.extractBytes();
}

List<int> sshash(Uint8List bytes) {
  const SS58_PREFIX = [83, 83, 53, 56, 80, 82, 69];
  return blake2bHash(
    Uint8List.fromList([...SS58_PREFIX, ...bytes]),
    digestSize: 64,
  );
}

String xxhashAsHex(String data) {
  return HEX.encode(xxh128(data).toList());
}

List<int> blake2_128_concat(List<int> data) {
  return blake2bHash(data, digestSize: 16) + data;
}

Uint8List xxh128(String data) {
  List<int> storage_key1 = XXH64
      .digest(data: data, seed: BigInt.from(0))
      .toUint8List()
      .reversed
      .toList();
  List<int> storage_key2 = XXH64
      .digest(data: data, seed: BigInt.from(1))
      .toUint8List()
      .reversed
      .toList();
  return Uint8List.fromList(storage_key1 + storage_key2);
}

class PolkadotArgs {
  final SeedPhraseRoot seedRoot;
  final String path;
  const PolkadotArgs({
    required this.seedRoot,
    required this.path,
  });
}

class _PolkadotDerive {
  static Future<AccountData> fromPrivateKey({
    required List<int> privateKey,
    required int ss58Prefix,
  }) async {
    final publicKey = await ED25519_HD_KEY.getPublicKey(privateKey);
    List<int> prefix = [ss58Prefix, ...publicKey.sublist(1)];
    final address = base58.encode(
      Uint8List.fromList([
        ...prefix,
        ...sshash(Uint8List.fromList(prefix))
            .sublist(0, [32, 33].contains(publicKey.length) ? 2 : 1),
      ]),
    );
    return AccountData(
      address: address,
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
    );
  }
}

Future<Map<String, String>> calculatePolkadotKey(PolkadotArgs config) async {
  final derivedKey = await ED25519_HD_KEY.derivePath(
    config.path,
    config.seedRoot.seed,
  );
  final publicKey = await ED25519_HD_KEY.getPublicKey(derivedKey.key);
  return {
    'privateKey': HEX.encode(derivedKey.key),
    'publicKey': HEX.encode(publicKey),
  };
}
// ── Chain registry ────────────────────────────────────────────────────────────

List<PolkadotCoin> getPolkadoBlockChains() {
  List<PolkadotCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      PolkadotCoin(
        blockExplorer:
            'https://westend.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'WND',
        name: 'Westend',
        default_: 'WND',
        image: 'assets/polkadot.png',
        api: 'https://westend-rpc.polkadot.io',
        coinDecimals: 12,
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
        caipReference: 'e143f23803ac50e8f6f8e62695d1ce9e',
      ),
      PolkadotCoin(
        blockExplorer:
            'https://assethub-westend.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'WND',
        name: 'Asset Hub Westend',
        default_: 'WND',
        image: 'assets/polkadot.png',
        api: 'https://westend-asset-hub-rpc.polkadot.io',
        coinDecimals: 12,
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
        caipReference: 'e143f23803ac50e8f6f8e62695d1ce9e',
      ),
      PolkadotCoin(
        blockExplorer:
            'https://paseo.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'PAS',
        name: 'Paseo(Testnet)',
        default_: 'PAS',
        image: 'assets/paseo.png',
        api: 'https://paseo.rpc.amforc.com',
        coinDecimals: 10,
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: '',
        payScheme: '',
        rampID: '',
        caipReference: '77afd6190f1554ad45fd0d31aee62aac', // Paseo genesis
      ),
    ]);
  } else {
    blockChains.addAll([
      PolkadotCoin(
        blockExplorer:
            'https://polkadot.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'DOT',
        name: 'Polkadot',
        default_: 'DOT',
        image: 'assets/polkadot.png',
        api: 'https://rpc.polkadot.io/',
        coinDecimals: 10,
        ss58Prefix: 0,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
        caipReference: '91b171bb158e2d3848fa23a9f1c25182',
      ),
      PolkadotCoin(
        blockExplorer:
            'https://assethub-polkadot.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'DOT',
        name: 'Asset Hub Polkadot',
        default_: 'DOT',
        image: 'assets/polkadot.png',
        api: 'https://asset-hub-polkadot-rpc.dwellir.com',
        coinDecimals: 10,
        ss58Prefix: 0,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
        caipReference:
            '68d56f15f85d3136970ec16946040bc1', // Asset Hub Polkadot genesis
      ),
      PolkadotCoin(
        blockExplorer:
            'https://kusama.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'KSM',
        name: 'Kusama',
        default_: 'KSM',
        image: 'assets/kusama.png',
        api: 'https://kusama-rpc.polkadot.io/',
        coinDecimals: 12,
        ss58Prefix: 2,
        path: "m/44'/434'/0'/0'/0'",
        geckoID: 'kusama',
        payScheme: 'kusama',
        rampID: 'KUSAMA_KSM',
        caipReference: 'b0a8d493285c2df73290dfb7e61f870f',
      ),
      PolkadotCoin(
        blockExplorer:
            'https://acala.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'ACA',
        name: 'Acala',
        default_: 'ACA',
        image: 'assets/acala.png',
        api: 'https://acala-rpc.dwellir.com',
        coinDecimals: 12,
        ss58Prefix: 10,
        path: "m/44'/787'/0'/0'/0'",
        geckoID: 'acala',
        payScheme: 'acala',
        rampID: '',
        caipReference: 'fc41b9bd8ef8fe53d58c7ea67c794c7e',
      ),
    ]);
  }

  return blockChains;
}
