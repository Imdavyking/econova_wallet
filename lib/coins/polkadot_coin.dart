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
  String getExplorer() {
    return blockExplorer;
  }

  @override
  String getDefault() {
    return default_;
  }

  @override
  String getImage() {
    return image;
  }

  @override
  String getName() {
    return name;
  }

  @override
  String getSymbol() {
    return symbol;
  }

  @override
  int decimals() {
    return coinDecimals;
  }

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

    final results = await _PolkadotDerive.fromPrivateKey(
      privateKey: HEX.decode(privateKey),
      ss58Prefix: ss58Prefix,
    );

    final keys = results.toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
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
  String savedTransKey() {
    return '$default_$api Details';
  }

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

      String? getStorageAt =
          rpcMethods!.firstWhere((element) => element == 'state_getStorageAt');

      getStorageAt ??=
          rpcMethods!.firstWhere((element) => element == 'state_getStorage');

      final storageResult =
          await _queryRpc(getStorageAt!, [storageKey, blockHashRes!['result']]);
      String storageData = storageResult!['result'];
      storageData = storageData.replaceFirst('0x', '');

      final input = Input.fromHex(storageData.substring(0, 0 + 4));

      return U16Codec.codec.decode(input);
    } catch (_) {
      return nonce;
    }
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    final address = await getAddress();
    final key = 'polkadotAddressBalance$address$api$ss58Prefix';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (skipNetworkRequest) return savedBalance;

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

      String? getStorageAt = rpcMethods!.firstWhere(
        (element) => element == 'state_getStorageAt',
      );

      getStorageAt ??= rpcMethods!.firstWhere(
        (element) => element == 'state_getStorage',
      );

      final storageResult = await _queryRpc(
        getStorageAt!,
        [
          storageKey,
          blockHashRes!['result'],
        ],
      );
      String storageData = storageResult!['result'];

      storageData = storageData.replaceFirst('0x', '');

      final input = Input.fromHex(storageData.substring(32, 32 + 48));

      final BigInt balanceBigInt = U128Codec.codec.decode(input);

      final base = BigInt.from(10);

      double userBal = balanceBigInt / base.pow(decimals());

      await pref.put(key, userBal);
      return userBal;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
  }

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
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['image'] = image;
    data['api'] = api;
    data['coinDecimals'] = coinDecimals;
    data['ss58Prefix'] = ss58Prefix;
    data['path'] = path;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;

    return data;
  }

  Future<Map?> _queryRpc(String rpcMethod, List params) async {
    try {
      final body = json.encode(
          {"jsonrpc": "2.0", "id": "1", "method": rpcMethod, "params": params});
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
    DecodedMetadata data = MetadataDecoder.instance.decode(metaData!['result']);

    final chainInfo = await compute(_decodeMetadata, data);

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

    final data_service = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data_service);
    final privatekey = HEX.decode(response.privateKey!);
    final registry = chainInfo.scaleCodec.registry;
    final signables = registry.signedExtensions;
    final checkMetaHash = signables.containsKey('CheckMetadataHash');
    final signaturePayload = await _signaturePayload(
      _SigParams(
        call: encodedData,
        nonce: nonce,
        registry: registry,
      ),
    );

    final publicKey = HEX.decode(response.publicKey!);
    final signature = await compute(
      _signEd25519,
      EDSignature(
        privatekey: privatekey as Uint8List,
        signaturePayload: signaturePayload,
      ),
    );

    String txSubmission = '84';
    txSubmission += HEX.encode(publicKey);

    txSubmission += '00';
    txSubmission += HEX.encode(signature);

    txSubmission += '00';
    txSubmission += HEX.encode(CompactCodec.codec.encode(nonce));
    if (checkMetaHash) {
      txSubmission += HEX.encode(
        signables['CheckMetadataHash']!.encode('Disabled'),
      );
    }
    txSubmission += '00';
    txSubmission += encodedData;

    int txLength = HEX.decode(txSubmission).length;

    txSubmission =
        HEX.encode(CompactCodec.codec.encode(txLength)) + txSubmission;

    final submitResult =
        await _queryRpc('author_submitExtrinsic', ['0x$txSubmission']);

    return submitResult!['result'];
  }

  Future<String> _signaturePayload(_SigParams param) async {
    final signables = param.registry.signedExtensions;
    final checkMetaHash = signables.containsKey('CheckMetadataHash');
    if (runTimeResult == null) {
      final runTimeVersion = await _queryRpc('chain_getRuntimeVersion', []);
      runTimeResult = runTimeVersion!['result'];
    }

    if (genesisHash == null) {
      final genesisHashRes = await _queryRpc('chain_getBlockHash', [0]);
      genesisHash = genesisHashRes!['result'];
    }

    String payload = '0x${param.call}';

    payload += '00';
    payload += HEX.encode(CompactCodec.codec.encode(param.nonce));

    if (checkMetaHash) {
      final mode = signables['CheckMetadataHash']!.encode('Disabled');
      payload += HEX.encode(mode);
    }

    payload += '00';
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
        rampID: "POLKADOT_DOT",
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
        rampID: "",
      )
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
        rampID: "POLKADOT_DOT",
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
        geckoID: "kusama",
        payScheme: "kusama",
        rampID: "KUSAMA_KSM",
      ),
      PolkadotCoin(
        blockExplorer:
            'https://acala.subscan.io/extrinsic/$blockExplorerPlaceholder',
        symbol: 'ACA',
        name: 'Acala',
        default_: 'ACA',
        image: 'assets/acala.png',
        api: "https://acala-rpc.dwellir.com",
        coinDecimals: 12,
        ss58Prefix: 10,
        path: "m/44'/787'/0'/0'/0'",
        geckoID: "acala",
        payScheme: "acala",
        rampID: "",
      )
    ]);
  }

  return blockChains;
}

Uint8List decodeDOTAddress(String address) {
  final decoded = base58.decode(address);
  final checksum = _polkaChecksum(decoded);
  final bool isValid = checksum[0];
  final int endPos = checksum[1];
  final int ss58Length = checksum[2];

  if (!isValid) {
    throw Exception('Invalid decoded address checksum');
  }
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
      Uint8List.fromList(
        [
          ...prefix,
          ...sshash(Uint8List.fromList(prefix))
              .sublist(0, [32, 33].contains(publicKey.length) ? 2 : 1)
        ],
      ),
    );
    return AccountData(
      address: address,
      privateKey: HEX.encode(privateKey),
      publicKey: HEX.encode(publicKey),
    );
  }
}

calculatePolkadotKey(PolkadotArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final derivedKey =
      await ED25519_HD_KEY.derivePath(config.path, seedRoot_.seed);
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
