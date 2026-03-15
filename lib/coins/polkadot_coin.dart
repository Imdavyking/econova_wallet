// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:web3dart/crypto.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
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
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    final saveKey = 'polkadotDetails${walletImportType.name}$ss58Prefix';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = PolkadotArgs(
      seedRoot: seedPhraseRoot,
      path: path,
      ss58Prefix: ss58Prefix,
    );
    final keys = await compute(calculatePolkadotKey, args);
    mnemonicMap[mnemonic] = keys;
    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  @override
  String savedTransKey() => '$default_$api Details';

  Future<int> _getNonce() async {
    const nonce = 0;
    try {
      if (rpcMethods == null) {
        final result = await _queryRpc('rpc_methods', []);
        rpcMethods = result!['result']['methods'];
      }

      String? getHead =
          rpcMethods!.firstWhere((element) => element == 'chain_getHead');
      getHead ??=
          rpcMethods!.firstWhere((element) => element == 'chain_getBlockHash');

      final blockHashRes = await _queryRpc(getHead!, []);
      final String address = await getAddress();
      final decodedAddr = decodeDOTAddress(address);
      final storageName = blake2_128_concat(decodedAddr);
      final storageKey = '$systemAccount${HEX.encode(storageName)}';

      String? getStorageAt = rpcMethods!
          .firstWhere((element) => element == 'state_getStorageAt');
      getStorageAt ??=
          rpcMethods!.firstWhere((element) => element == 'state_getStorage');

      final storageResult = await _queryRpc(
          getStorageAt!, [storageKey, blockHashRes!['result']]);
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
      final result = await _queryRpc('rpc_methods', []);
      rpcMethods = result!['result']['methods'];
    }

    String? getHead =
        rpcMethods!.firstWhere((element) => element == 'chain_getHead');
    getHead ??=
        rpcMethods!.firstWhere((element) => element == 'chain_getBlockHash');

    final blockHashRes = await _queryRpc(getHead!, []);
    final String addr = await getAddress();
    final decodedAddr = decodeDOTAddress(addr);
    final storageName = blake2_128_concat(decodedAddr);
    final storageKey = '$systemAccount${HEX.encode(storageName)}';

    String? getStorageAt =
        rpcMethods!.firstWhere((element) => element == 'state_getStorageAt');
    getStorageAt ??=
        rpcMethods!.firstWhere((element) => element == 'state_getStorage');

    final storageResult = await _queryRpc(
        getStorageAt!, [storageKey, blockHashRes!['result']]);
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
    final key = 'polBal$address$api$ss58Prefix';
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
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
      };

  Future<Map?> _queryRpc(String rpcMethod, List params) async {
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
      if (response.statusCode ~/ 100 == 4 ||
          response.statusCode ~/ 100 == 5) {
        throw Exception(responseBody);
      }
      return jsonDecode(responseBody);
    } catch (e) {
      return null;
    }
  }

  ChainInfo _decodeMetadata(DecodedMetadata metadata) {
    return ChainInfo.fromMetadata(metadata);
  }

  Uint8List _signEd25519(EDSignature signature) {
    final signing = signature.signaturePayload.replaceFirst('0x', '');
    return signEd25519(
      message: HEX.decode(signing) as Uint8List,
      privateKey: signature.privatekey,
    );
  }

  @override
  Future<String?> transferToken(
    String amount,
    String to, {
    String? memo,
  }) async {
    final planck = amount.toBigIntDec(decimals());
    final decodedAddr = decodeDOTAddress(to);
    final nonce = await _getNonce();

    final metaData = await _queryRpc('state_getMetadata', []);
    final DecodedMetadata decodedMeta =
        MetadataDecoder.instance.decode(metaData!['result']);
    final chainInfo = await compute(_decodeMetadata, decodedMeta);

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
    final encodedData = HEX.encode(output.toBytes());
    debugPrint('Encoded call: $encodedData');

    final data_service = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data_service);
    final privatekey = HEX.decode(response.privateKey!);
    final registry = chainInfo.scaleCodec.registry;
    final signables = registry.signedExtensions;

    // ── Detect signed extension variants ─────────────────────────────────────
    final checkMetaHash = signables.containsKey('CheckMetadataHash');

    // Asset Hub and other system parachains use ChargeAssetTxPayment instead
    // of ChargeTransactionPayment. This extension encodes an extra
    // Option<AssetId> byte (0x00 = None) after the tip.
    // Sending only the tip byte without this Option byte shifts all subsequent
    // bytes by one, causing the runtime to hit an unreachable branch during
    // transaction validation.
    final chargeAssetTxPayment =
        signables.containsKey('ChargeAssetTxPayment');

    debugPrint(
        'Signed extensions — checkMetaHash: $checkMetaHash, chargeAssetTxPayment: $chargeAssetTxPayment');
    debugPrint('All signed extensions: ${signables.keys.toList()}');

    final signaturePayload = await _signaturePayload(
      _SigParams(
        call: encodedData,
        nonce: nonce,
        registry: registry,
      ),
    );

    // ── Extrinsic version ─────────────────────────────────────────────────────
    // Relay chains (Polkadot, Westend, Kusama) use specVersion < 1_000_000
    // and extrinsic version 4 (0x84).
    // Parachains (Asset Hub, etc.) use specVersion >= 1_000_000
    // and extrinsic version 5 (0x85).
    final int specVersion =
        (runTimeResult?['specVersion'] as int?) ?? 0;
    final int extrinsicVersion = specVersion >= 1000000 ? 5 : 4;
    final String extrinsicVersionHex =
        (0x80 | extrinsicVersion).toRadixString(16).padLeft(2, '0');

    debugPrint(
        'specVersion: $specVersion → extrinsicVersion: $extrinsicVersion (0x$extrinsicVersionHex)');

    final publicKey = HEX.decode(response.publicKey!);
    final signature = await compute(
      _signEd25519,
      EDSignature(
        privatekey: privatekey as Uint8List,
        signaturePayload: signaturePayload,
      ),
    );

    // ── Build extrinsic bytes ─────────────────────────────────────────────────
    // Layout:
    //   <version> | <pubkey> | <sig_type:00=Ed25519> | <sig> |
    //   <era:00=immortal> | <nonce> | <tip:00> |
    //   [asset_id:00 — only if ChargeAssetTxPayment] |
    //   [CheckMetadataHash:00 — only if present] |
    //   <call>
    String txSubmission = extrinsicVersionHex;
    txSubmission += HEX.encode(publicKey);
    txSubmission += '00'; // signature type: Ed25519
    txSubmission += HEX.encode(signature);
    txSubmission += '00'; // era: immortal
    txSubmission += HEX.encode(CompactCodec.codec.encode(nonce));
    txSubmission += '00'; // tip: 0

    if (chargeAssetTxPayment) {
      // Option<AssetId>::None — required by ChargeAssetTxPayment on Asset Hub.
      // Without this byte the transaction bytes are off by one and the runtime
      // panics with an unreachable branch in validate_transaction.
      txSubmission += '00';
    }

    if (checkMetaHash) {
      final encoded = signables['CheckMetadataHash']!.encode('Disabled');
      debugPrint('CheckMetadataHash encoded: ${HEX.encode(encoded)}');
      txSubmission += HEX.encode(encoded);
    }

    txSubmission += encodedData;

    final int txLength = HEX.decode(txSubmission).length;
    txSubmission =
        HEX.encode(CompactCodec.codec.encode(txLength)) + txSubmission;

    debugPrint('tx hex: 0x$txSubmission');

    try {
      final submitResult =
          await _queryRpc('author_submitExtrinsic', ['0x$txSubmission']);
      debugPrint('submit result: $submitResult');
      return submitResult!['result'];
    } catch (e) {
      debugPrint('submit error: $e');
      return null;
    } finally {
      runTimeResult = null;
      genesisHash = null;
      rpcMethods = null;
    }
  }

  Future<String> _signaturePayload(_SigParams param) async {
    final signables = param.registry.signedExtensions;
    final checkMetaHash = signables.containsKey('CheckMetadataHash');
    final chargeAssetTxPayment =
        signables.containsKey('ChargeAssetTxPayment');

    if (runTimeResult == null) {
      final runTimeVersion = await _queryRpc('chain_getRuntimeVersion', []);
      runTimeResult = runTimeVersion!['result'];
    }

    if (genesisHash == null) {
      final genesisHashRes = await _queryRpc('chain_getBlockHash', [0]);
      genesisHash = genesisHashRes!['result'];
    }

    // ── Signature payload layout ──────────────────────────────────────────────
    // call | era | nonce | tip | [asset_id if ChargeAssetTxPayment] |
    // [CheckMetadataHash mode] | specVersion | transactionVersion |
    // genesisHash | blockHash | [CheckMetadataHash extra]
    String payload = '0x${param.call}';
    payload += '00'; // era: immortal
    payload += HEX.encode(CompactCodec.codec.encode(param.nonce));
    payload += '00'; // tip: 0

    if (chargeAssetTxPayment) {
      // Option<AssetId>::None — must mirror the extrinsic encoding exactly
      payload += '00';
    }

    if (checkMetaHash) {
      final mode = signables['CheckMetadataHash']!.encode('Disabled');
      payload += HEX.encode(mode);
    }

    payload +=
        HEX.encode(U32Codec.codec.encode(runTimeResult!['specVersion']));
    payload += HEX.encode(
        U32Codec.codec.encode(runTimeResult!['transactionVersion']));
    payload += genesisHash!.replaceFirst('0x', '');
    payload += genesisHash!
        .replaceFirst('0x', ''); // blockHash = genesisHash for immortal era

    if (checkMetaHash) payload += '00'; // CheckMetadataHash extra: no hash

    final hexPayload = HEX.decode(strip0x(payload));

    if (hexPayload.length > 256) {
      return HEX.encode(blake2bHash256(hexPayload));
    }

    return payload;
  }

  @override
  validateAddress(String address) {
    decodeDOTAddress(address);
  }

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

// ── Checksum ──────────────────────────────────────────────────────────────────

List _polkaChecksum(Uint8List decoded) {
  final ss58Length = (decoded[0] & 64) != 0 ? 2 : 1;
  final ss58Decoded = ss58Length == 1
      ? decoded[0]
      : ((decoded[0] & 63) << 2) |
          (decoded[1] >> 6) |
          ((decoded[1] & 63) << 8);
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

// ── Address decoding ──────────────────────────────────────────────────────────

Uint8List decodeDOTAddress(String address) {
  final decoded = base58.decode(address);
  final checksum = _polkaChecksum(decoded);
  final bool isValid = checksum[0];
  final int endPos = checksum[1];
  final int ss58Length = checksum[2];
  if (!isValid) throw Exception('Invalid decoded address checksum');
  return decoded.sublist(ss58Length, endPos);
}

// ── Seed helpers ──────────────────────────────────────────────────────────────

Future<List<int>> bip39ToMiniSeed(mnemonic) async {
  final entropy = HEX.decode(mnemonicToEntropy(mnemonic));
  final salt = StrCodec.codec.encode('mnemonic').sublist(1);
  final pdkd = Pbkdf2(
    macAlgorithm: Hmac.sha512(),
    iterations: 2048,
    bits: 256,
  );
  final keys =
      await pdkd.deriveKey(secretKey: SecretKey(entropy), nonce: salt);
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

// ── Chain list ────────────────────────────────────────────────────────────────

List<PolkadotCoin> getPolkadoBlockChains() {
  List<PolkadotCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.addAll([
      PolkadotCoin(
        blockExplorer:
            'https://westend.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'DOT',
        name: 'Polkadot(Westend)',
        default_: 'DOT',
        image: 'assets/polkadot.png',
        api: 'https://westend-rpc.polkadot.io',
        coinDecimals: 12,
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
      ),
      PolkadotCoin(
        blockExplorer:
            'https://assethub-westend.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'WND',
        name: 'Westend Asset Hub',
        default_: 'WND',
        image: 'assets/polkadot.png',
        api: 'https://westend-asset-hub-rpc.polkadot.io',
        coinDecimals: 12,
        ss58Prefix: 42,
        path: "m/44'/354'/0'/0'/0'",
        geckoID: 'polkadot',
        payScheme: 'polkadot',
        rampID: 'POLKADOT_DOT',
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
      ),
    ]);
  }

  return blockChains;
}

// ── Key derivation ────────────────────────────────────────────────────────────

class PolkadotArgs {
  final SeedPhraseRoot seedRoot;
  final String path;
  final int ss58Prefix;

  const PolkadotArgs({
    required this.seedRoot,
    required this.path,
    required this.ss58Prefix,
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

calculatePolkadotKey(PolkadotArgs config) async {
  final derivedKey =
      await ED25519_HD_KEY.derivePath(config.path, config.seedRoot.seed);
  final results = await _PolkadotDerive.fromPrivateKey(
    privateKey: derivedKey.key,
    ss58Prefix: config.ss58Prefix,
  );
  return {
    'address': results.address,
    'publicKey': results.publicKey,
    'privateKey': results.privateKey,
  };
}

// ── Supporting classes ────────────────────────────────────────────────────────

class EDSignature {
  final String signaturePayload;
  final Uint8List privatekey;
  const EDSignature({
    required this.privatekey,
    required this.signaturePayload,
  });
}

class _SigParams {
  final String call;
  final int nonce;
  final Registry registry;
  const _SigParams({
    required this.call,
    required this.nonce,
    required this.registry,
  });
}