// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:wallet_app/coins/fungible_tokens/tron_fungible_coin.dart';
import 'package:wallet_app/extensions/big_int_ext.dart';
import 'package:http/http.dart' as http;
import 'package:on_chain/tron/tron.dart';
import 'package:wallet_app/model/token_approvals.dart';
import '../service/wallet_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/crypto.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const TRX_FEE_LIMIT = 150000000;
const TRX_ADDRESS_PREFIX = '41';
const TRX_MESSAGE_HEADER = '\x19TRON Signed Message:\n32';

const tronDecimals = 6;

class TronCoin extends Coin {
  String api;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;
  String caipReference;

  @override
  bool get supportKeystore => true;
  @override
  bool requireMemo() => true;
  @override
  bool get supportPrivateKey => true;

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
  String get caip2Namespace => 'tron';
  @override
  String get caip2Reference => caipReference;

  TronCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.name,
    required this.api,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
    required this.caipReference,
  });

  factory TronCoin.fromJson(Map<String, dynamic> json) {
    return TronCoin(
      api: json['api'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
      caipReference: json['caipReference'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api'] = api;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    data['image'] = image;
    data['caipReference'] = caipReference;

    return data;
  }

  @override
  List<Coin> get networkTokens => getTronFungibleCoins();

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey = 'tronDetailsPrivate${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final address = tronPrivateKeyToAddress(privateKey);

    final keys = AccountData(
      address: address,
      privateKey: privateKey,
    );

    privateKeyMap[privateKey] = keys.toJson();

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return keys;
  }

  String tronPrivateKeyToAddress(String privateKey) {
    final walletInfo = wallet.PrivateKey(BigInt.parse(privateKey, radix: 16));
    final publicKey = wallet.tron.createPublicKey(walletInfo);
    final address = wallet.tron.createAddress(publicKey);
    return address;
  }

  @override
  bool get supportBip39Seed => true;

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'tronDetails${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateTronKey,
          TronArgs(seedRoot: seedPhraseRoot),
        ),
      );

  Future<String> get _canTransferKey async =>
      'tronAddressCanTransfer${await getAddress()}$api';

  @override
  Future<bool> get canTransfer async =>
      pref.get(await _canTransferKey, defaultValue: true);
  @override
  Future<double> getUserBalance({required String address}) async {
    final request = await get(
      Uri.parse('$api/v1/accounts/$address'),
      headers: {
        'TRON-PRO-API-KEY': tronGridApiKey,
        'Content-Type': 'application/json'
      },
    );

    if (request.statusCode ~/ 100 == 4 || request.statusCode ~/ 100 == 5) {
      throw Exception('Request failed');
    }

    Map<String, dynamic> decodedData = jsonDecode(request.body);
    final List? result = decodedData['data'];

    if (result == null || result.isEmpty) {
      await pref.put(await _canTransferKey, true);
      throw Exception('Account not found');
    }

    final data = result[0];

    final int? balance = data['balance'];
    if (balance == null) throw Exception('Account not found');

    final base = BigInt.from(10);
    final permission =
        AccountPermissionModel.fromJson(data['owner_permission']);
    await pref.put(
      await _canTransferKey,
      _canTransfer(permission, address),
    );
    return BigInt.from(balance) / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    final address = await getAddress();
    final key = 'tronAddressBalance$address$api';

    final storedBalance = pref.get(key);

    double savedBalance = 0;

    if (storedBalance != null) {
      savedBalance = storedBalance;
    }

    if (useCache) return savedBalance;

    try {
      double balTron = await getUserBalance(address: address);

      await pref.put(key, balTron);

      return balTron;
    } catch (_) {
      return savedBalance;
    }
  }

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final tronDetails = await importData(data);

    final ownerAddress = TronAddress(tronDetails.address);
    final rpc = TronProvider(TronHTTPProvider(url: api));
    final block = await rpc.request(TronRequestGetNowBlock());
    final toAddress = TronAddress(to);
    final contract = TransferContract(
      ownerAddress: ownerAddress,
      toAddress: toAddress,
      amount: TronHelper.toSun(amount),
    );
    const expSeconds = 60 * 6 * 60;

    final any = Any(typeUrl: contract.typeURL, value: contract);
    final transactionContract =
        TransactionContract(type: contract.contractType, parameter: any);

    final rawTr = TransactionRaw(
      refBlockBytes: block.blockHeader.rawData.refBlockBytes,
      refBlockHash: block.blockHeader.rawData.refBlockHash,
      expiration: block.blockHeader.rawData.timestamp + BigInt.from(expSeconds),
      contract: [transactionContract],
      timestamp: block.blockHeader.rawData.timestamp,
      feeLimit: BigInt.parse("10"),
      data: memo != null ? utf8.encode(memo) : null,
    );

    Uint8List privateKey =
        Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
    Uint8List txID = Uint8List.fromList(HEX.decode(rawTr.txID));
    final signatureEC = sign(txID, privateKey);
    final recid = signatureEC.v - 27;
    final signature = '${HEX.encode([
          ...signatureEC.r.toUint8List(),
          ...signatureEC.s.toUint8List(),
        ])}0$recid';

    final transaction =
        Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);

    final raw = BytesUtils.toHexString(transaction.toBuffer());

    final result = await rpc.request(TronRequestBroadcastHex(transaction: raw));

    if (result.isSuccess) {
      return (txHash: result.txId!, txRaw: raw);
    }

    debugPrint(result.toString());
    throw Exception('sending failed');
  }

  @override
  bool get haveTestAppproval => true;
  @override
  Future<String?> testCreateApproval() async {
    try {
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final tronDetails = await importData(data);
      final ownerAddress = TronAddress(tronDetails.address);
      final rpcProvider = TronProvider(TronHTTPProvider(url: api));
      final block = await rpcProvider.request(TronRequestGetNowBlock());

      const testTokenAddress =
          'TTFd5kQ8r34XPtUjK3Lk5Eh8rLBjynsX1k'; // PRIME TRC20

      const testSpender = 'TXF1xDbVGdxFGbovmmmXvBGu8ZiE3Lq4mR';
      final testAmount = BigInt.from(1000000);

      final spenderHex = tronAddressToHex(testSpender)
          .toLowerCase()
          .replaceFirst('41', '')
          .padLeft(64, '0');
      final amountHex = testAmount.toRadixString(16).padLeft(64, '0');
      final callData = '095ea7b3$spenderHex$amountHex';

      final contract = TriggerSmartContract(
        ownerAddress: ownerAddress,
        contractAddress: TronAddress(testTokenAddress),
        data: BytesUtils.fromHexString(callData),
        callValue: BigInt.zero,
      );

      final any = Any(typeUrl: contract.typeURL, value: contract);
      final transactionContract =
          TransactionContract(type: contract.contractType, parameter: any);

      final rawTr = TransactionRaw(
        refBlockBytes: block.blockHeader.rawData.refBlockBytes,
        refBlockHash: block.blockHeader.rawData.refBlockHash,
        expiration:
            block.blockHeader.rawData.timestamp + BigInt.from(60 * 6 * 60),
        contract: [transactionContract],
        timestamp: block.blockHeader.rawData.timestamp,
        feeLimit: BigInt.from(TRX_FEE_LIMIT),
      );

      final privateKey =
          Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
      final txID = Uint8List.fromList(HEX.decode(rawTr.txID));
      final sig = sign(txID, privateKey);
      final recid = sig.v - 27;
      final signature = '${HEX.encode([
            ...sig.r.toUint8List(),
            ...sig.s.toUint8List(),
          ])}0$recid';

      final transaction =
          Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);
      final raw = BytesUtils.toHexString(transaction.toBuffer());
      final result =
          await rpcProvider.request(TronRequestBroadcastHex(transaction: raw));

      return result.txId;
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Future<({String key, String timeKey})?> approvalCacheKeys() async {
    final address = await getAddress();
    final key = 'tron_approvals_${address}_$api';
    return (key: key, timeKey: '${key}_time');
  }

  @override
  Future<List<TokenApproval>>? getApprovals() {
    return _fetchTronApprovalsWithCache();
  }

  Future<List<TokenApproval>> _fetchTronApprovalsWithCache() async {
    final address = await getAddress();
    final keys = await approvalCacheKeys();
    if (keys == null) return [];

    final String? cached = pref.get(keys.key) as String?;
    final String? cachedTime = pref.get(keys.timeKey) as String?;

    if (cached != null && cachedTime != null) {
      final age = DateTime.now().difference(DateTime.parse(cachedTime));
      if (age.inSeconds < 10) {
        try {
          final list = jsonDecode(cached) as List;
          if (list.isNotEmpty) {
            return list
                .map((e) => TokenApproval.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }
    }

    try {
      final approvals = await _fetchTronApprovals(address);
      await pref.put(
          keys.key, jsonEncode(approvals.map((a) => a.toJson()).toList()));
      await pref.put(keys.timeKey, DateTime.now().toIso8601String());
      return approvals;
    } catch (e) {
      debugPrint('TronCoin.getApprovals error: $e');
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List;
          return list.map((e) => TokenApproval.fromJson(e)).toList();
        } catch (_) {}
      }
      return [];
    }
  }

  Future<List<TokenApproval>> _fetchTronApprovals(String address) async {
    final response = await http.get(
      Uri.parse(
        '$api/v1/accounts/$address/transactions/trc20'
        '?limit=200&only_confirmed=true&order_by=block_timestamp,desc', // ← sort desc
      ),
      headers: {
        'TRON-PRO-API-KEY': tronGridApiKey,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('TronGrid error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final txList = data['data'] as List? ?? [];

    // Sort by block_timestamp descending — latest first
    final sorted = List.from(txList)
      ..sort((a, b) {
        final aTime = a['block_timestamp'] as int? ?? 0;
        final bTime = b['block_timestamp'] as int? ?? 0;
        return bTime.compareTo(aTime); // desc
      });

    // Track latest allowance per (token, spender) pair
    // Since sorted latest first, first seen = most recent state
    final seen = <String>{};
    final approvalMap = <String, TokenApproval>{};

    for (final tx in sorted) {
      final type = tx['type'] as String?;
      if (type != 'Approval') continue;

      final tokenAddress = (tx['token_info']?['address'] as String? ?? '');
      final spender = tx['to'] as String? ?? '';
      if (spender.isEmpty || tokenAddress.isEmpty) continue;

      final pairKey = '${tokenAddress}_$spender';

      // Already seen a more recent tx for this pair — skip
      if (seen.contains(pairKey)) continue;
      seen.add(pairKey);

      final tokenSymbol = tx['token_info']?['symbol'] as String? ?? '?';
      final tokenName = tx['token_info']?['name'] as String? ?? tokenSymbol;
      final value = tx['value'] as String? ?? '0';
      final blockTimestamp = tx['block_timestamp'] as int?;

      BigInt allowance;
      try {
        allowance = BigInt.parse(value);
      } catch (_) {
        allowance = BigInt.zero;
      }

      // Most recent tx for this pair is a revoke — skip
      if (allowance == BigInt.zero) continue;

      approvalMap[pairKey] = TokenApproval(
        tokenAddress: tokenAddress,
        tokenSymbol: tokenSymbol,
        tokenName: tokenName,
        spenderAddress: spender,
        spenderName: _resolveSpenderName(spender),
        allowance: allowance,
        contractDecimals: tx['token_info']?['decimals'] as int? ?? 6,
        lastUpdated: blockTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(blockTimestamp)
            : null,
      );
    }

    return approvalMap.values.toList()
      ..sort((a, b) {
        if (a.isDangerous && !b.isDangerous) return -1;
        if (!a.isDangerous && b.isDangerous) return 1;
        return 0;
      });
  }

  @override
  Future<bool>? revokeApproval(TokenApproval approval) async {
    try {
      final keys = await approvalCacheKeys();
      if (keys == null) return false;
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final tronDetails = await importData(data);
      final ownerAddress = TronAddress(tronDetails.address);
      final rpc = TronProvider(TronHTTPProvider(url: api));
      final block = await rpc.request(TronRequestGetNowBlock());

      // TRC20 approve(spender, 0) — same as ERC20
      // Function selector: 0x095ea7b3
      final spenderHex = tronAddressToHex(approval.spenderAddress)
          .toLowerCase()
          .replaceFirst('41', '')
          .padLeft(64, '0');
      final amountHex = '0' * 64; // amount = 0
      final data_ = '095ea7b3$spenderHex$amountHex';

      final contract = TriggerSmartContract(
        ownerAddress: ownerAddress,
        contractAddress: TronAddress(approval.tokenAddress),
        data: BytesUtils.fromHexString(data_),
        callValue: BigInt.zero,
      );

      final any = Any(typeUrl: contract.typeURL, value: contract);
      final transactionContract =
          TransactionContract(type: contract.contractType, parameter: any);

      final rawTr = TransactionRaw(
        refBlockBytes: block.blockHeader.rawData.refBlockBytes,
        refBlockHash: block.blockHeader.rawData.refBlockHash,
        expiration:
            block.blockHeader.rawData.timestamp + BigInt.from(60 * 6 * 60),
        contract: [transactionContract],
        timestamp: block.blockHeader.rawData.timestamp,
        feeLimit: BigInt.from(TRX_FEE_LIMIT),
      );

      final privateKey =
          Uint8List.fromList(HEX.decode(tronDetails.privateKey!));
      final txID = Uint8List.fromList(HEX.decode(rawTr.txID));
      final sig = sign(txID, privateKey);
      final recid = sig.v - 27;
      final signature = '${HEX.encode([
            ...sig.r.toUint8List(),
            ...sig.s.toUint8List(),
          ])}0$recid';

      final transaction =
          Transaction(rawData: rawTr, signature: [HEX.decode(signature)]);
      final raw = BytesUtils.toHexString(transaction.toBuffer());
      final result =
          await rpc.request(TronRequestBroadcastHex(transaction: raw));

      if (!result.isSuccess) {
        throw Exception('Revoke failed: ${result.error}');
      }

      await pref.delete(keys.key);
      await pref.delete(keys.timeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  static const _knownTronSpenders = <String, String>{
    'TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax': 'SunSwap V2',
    'TFVisXFaijZfeyeSjCEVkHfex7HGdTxzS9': 'JustLend',
    'TXF1xDbVGdxFGbovmmmXvBGu8ZiE3Lq4mR': 'Sun.io',
  };

  String _resolveSpenderName(String address) {
    return _knownTronSpenders[address] ?? _shortAddr(address);
  }

  String _shortAddr(String addr) => addr.length > 10
      ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}'
      : addr;

  @override
  validateAddress(String address) {
    if (!wallet.isValidTronAddress(address)) {
      throw Exception('Invalid $default_ address');
    }
  }

  @override
  int decimals() {
    return tronDecimals;
  }

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    return 0;
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/transaction/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  Widget getExplorerIdenticon(String address, {double size = 40}) {
    return Jazzicon.getIconWidget(
      Jazzicon.getJazziconData(size, address: address),
    );
  }

  bool _canTransfer(
    AccountPermissionModel permission,
    String address,
  ) {
    BigInt userWeight = BigInt.zero;
    for (PermissionKeysModel key in permission.keys) {
      if (key.address == address) {
        userWeight += key.weight;
        if (userWeight >= permission.threshold) {
          return true;
        }
      }
    }

    return userWeight >= permission.threshold;
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;
  @override
  String getRampID() => rampID;
}

List<TronCoin> getTronBlockchains() {
  List<TronCoin> blockChains = [];

  if (enableTestNet) {
    blockChains.add(
      TronCoin(
        blockExplorer:
            'https://shasta.tronscan.org/#/transaction/$blockExplorerPlaceholder',
        symbol: 'TRX',
        default_: 'TRX',
        name: 'Tron(Testnet Shasta)',
        image: 'assets/tron.png',
        api: 'https://api.shasta.trongrid.io',
        geckoID: "tron",
        payScheme: "tron",
        rampID: '',
        caipReference: '0x94a9059e',
      ),
    );
  } else {
    blockChains.addAll([
      TronCoin(
        blockExplorer:
            'https://tronscan.org/#/transaction/$blockExplorerPlaceholder',
        symbol: 'TRX',
        name: 'Tron',
        default_: 'TRX',
        image: 'assets/tron.png',
        api: 'https://api.trongrid.io',
        geckoID: "tron",
        payScheme: "tron",
        rampID: '',
        caipReference: '0x2b6653dc',
      ),
    ]);
  }

  return blockChains;
}

String tronAddressToHex(String address) {
  if (isHexString(address)) {
    return address.replaceFirst('0x', TRX_ADDRESS_PREFIX).toUpperCase();
  }
  return HEX.encode(bs58check.decode(address)).toUpperCase();
}

class TronArgs {
  final SeedPhraseRoot seedRoot;

  const TronArgs({
    required this.seedRoot,
  });
}

Future<Map<String, dynamic>> calculateTronKey(TronArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final master = wallet.ExtendedPrivateKey.master(seedRoot_.seed, wallet.xprv);
  final root = master.forPath("m/44'/195'/0'/0/0");

  final privateKey = wallet.PrivateKey((root as wallet.ExtendedPrivateKey).key);
  final publicKey = wallet.tron.createPublicKey(privateKey);
  final address = wallet.tron.createAddress(publicKey);

  return {
    'privateKey': HEX.encode(privateKey.value.toUint8List()),
    'address': address,
  };
}

class TronHTTPProvider implements TronServiceProvider {
  TronHTTPProvider(
      {required this.url,
      http.Client? client,
      this.defaultRequestTimeout = const Duration(seconds: 30)})
      : client = client ?? http.Client();

  final String url;
  final http.Client client;
  final Duration defaultRequestTimeout;

  @override
  Future<TronServiceResponse<T>> doRequest<T>(TronRequestDetails params,
      {Duration? timeout}) async {
    if (params.type.isPostRequest) {
      final response = await client
          .post(params.toUri(url), headers: params.headers, body: params.body())
          .timeout(timeout ?? defaultRequestTimeout);
      return params.toResponse(response.bodyBytes, response.statusCode);
    }
    final response = await client
        .get(params.toUri(url), headers: params.headers)
        .timeout(timeout ?? defaultRequestTimeout);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
