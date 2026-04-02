// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:hex/hex.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:wallet_app/model/token_approvals.dart';
import 'package:wallet_app/screens/view_nft_screens.dart';
import 'package:wallet_app/utils/blockie_widget.dart';

import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import '../service/x402_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet_app/coins/fungible_tokens/erc_fungible_coin.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/alt_ens.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const etherDecimals = 18;

const _usdcDomainNameByVersion = {
  0: 'USDC',
  1: 'USD Coin',
  2: 'USD Coin',
};

class EthereumCoin extends Coin {
  int coinType;
  int chainId;
  String rpc;
  String blockExplorer;
  String symbol;
  String default_;
  String image;
  String name;
  String geckoID;
  String rampID;
  String payScheme;

  EthereumCoin({
    required this.blockExplorer,
    required this.symbol,
    required this.default_,
    required this.image,
    required this.coinType,
    required this.rpc,
    required this.chainId,
    required this.name,
    required this.geckoID,
    required this.rampID,
    required this.payScheme,
  });

  @override
  bool get supportKeystore => true;
  @override
  bool get supportPrivateKey => true;

  @override
  Widget? getNFTPage() => ViewErcNFTs(ethCoin: this);

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
  String get caip2Namespace => 'eip155';
  @override
  String get caip2Reference => '$chainId';

  @override
  List<Coin> get networkTokens => getERC20Coins();

  @override
  String? getSwapDappUrl() => 'https://app.uniswap.org/swap';

  @override
  String? getStakeDappUrl() => 'https://lido.fi';

  @override
  Widget getExplorerIdenticon(String address, {double size = 40}) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(75)),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: BlockieWidget(
          size: .6,
          data: address,
        ),
      ),
    );
  }

  // ── x402 ─────────────────────────────────────────────────────────────────

  @override
  bool get supportsX402 => true;

  @override
  Future<String?> signX402Payment(
    X402PaymentOption option, {
    int version = 1,
  }) async {
    try {
      final payTo = option.payTo;
      if (payTo.isEmpty) {
        debugPrint(
            'EthereumCoin x402: payTo is missing — cannot sign EVM payment');
        return null;
      }

      final walletData = WalletService.getActiveKey(walletImportType)!.data;
      final accountData = await importData(walletData);
      final privateKeyBytes = hexToBytes(accountData.privateKey!);
      final fromAddress = accountData.address;

      final resolvedChainId = _chainIdForNetwork(option.network);
      final isNativeEth = _isNativeEth(option.asset);

      if (version >= 2 && isNativeEth) {
        return _signNativeEthPayment(
          from: fromAddress,
          option: option,
          payTo: payTo,
          chainId: resolvedChainId,
          privateKey: privateKeyBytes,
          version: version,
        );
      }

      final value = BigInt.parse(option.maxAmountRequired);
      final validAfter = BigInt.zero;
      final validBefore = BigInt.from(
        DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/
            1000,
      );
      final nonce = _randomNonce();
      final contractVersion = option.extra?['version'] as String? ?? '2';
      final domainName = _usdcDomainNameByVersion[version] ?? 'USD Coin';

      final signature = _signEIP3009(
        from: fromAddress,
        to: payTo,
        value: value,
        validAfter: validAfter,
        validBefore: validBefore,
        nonce: nonce,
        contractAddress: option.asset,
        chainId: resolvedChainId,
        contractVersion: contractVersion,
        domainName: domainName,
        privateKey: privateKeyBytes,
      );

      final payload = _buildPayload(
        version: version,
        option: option,
        payTo: payTo,
        from: fromAddress,
        value: value,
        validAfter: validAfter,
        validBefore: validBefore,
        nonce: nonce,
        signature: signature,
      );

      return base64Encode(utf8.encode(jsonEncode(payload)));
    } catch (e) {
      debugPrint('x402 sign error (v$version): $e');
      return null;
    }
  }

  Map<String, dynamic> _buildPayload({
    required int version,
    required X402PaymentOption option,
    required String payTo,
    required String from,
    required BigInt value,
    required BigInt validAfter,
    required BigInt validBefore,
    required String nonce,
    required String signature,
  }) {
    final authorization = {
      'from': from,
      'to': payTo,
      'value': value.toString(),
      'validAfter': validAfter.toString(),
      'validBefore': validBefore.toString(),
      'nonce': nonce,
    };

    if (version == 0) {
      return {
        'version': 0,
        'scheme': option.scheme,
        'network': option.network,
        'payload': {
          'signature': signature,
          'authorization': authorization,
        },
      };
    }

    final payload = <String, dynamic>{
      'x402Version': version,
      'scheme': option.scheme,
      'network': option.network,
      'payload': {
        'signature': signature,
        'authorization': authorization,
      },
    };

    if (version >= 2 && option.extra != null) {
      payload['extra'] = option.extra;
    }

    return payload;
  }

  Future<String?> _signNativeEthPayment({
    required String from,
    required X402PaymentOption option,
    required String payTo,
    required int chainId,
    required Uint8List privateKey,
    required int version,
  }) async {
    final validBefore =
        DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/
            1000;
    final nonce = _randomNonce();

    final commitment =
        'x402:eth:${option.network}:$payTo:${option.maxAmountRequired}:$validBefore:$nonce';

    final msgBytes = utf8.encode(commitment);
    final prefixed =
        '\x19Ethereum Signed Message:\n${msgBytes.length}$commitment';
    final digest = keccak256(Uint8List.fromList(utf8.encode(prefixed)));

    final sig = sign(digest, privateKey);
    final v = (sig.v + 27).toRadixString(16).padLeft(2, '0');
    final r = sig.r.toRadixString(16).padLeft(64, '0');
    final s = sig.s.toRadixString(16).padLeft(64, '0');
    final signature = '0x$r$s$v';

    final payload = {
      'x402Version': version,
      'scheme': option.scheme,
      'network': option.network,
      'payload': {
        'type': 'personal_sign',
        'signature': signature,
        'commitment': commitment,
        'from': from,
        'validBefore': validBefore.toString(),
        'nonce': nonce,
      },
    };

    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  String _signEIP3009({
    required String from,
    required String to,
    required BigInt value,
    required BigInt validAfter,
    required BigInt validBefore,
    required String nonce,
    required String contractAddress,
    required int chainId,
    required String contractVersion,
    required String domainName,
    required Uint8List privateKey,
  }) {
    const transferTypeHash =
        'TransferWithAuthorization(address from,address to,uint256 value,'
        'uint256 validAfter,uint256 validBefore,bytes32 nonce)';

    final typeHashBytes =
        keccak256(Uint8List.fromList(utf8.encode(transferTypeHash)));

    final structHash = keccak256(_abiEncode([
      typeHashBytes,
      _addressToBytes32(from),
      _addressToBytes32(to),
      _uint256ToBytes(value),
      _uint256ToBytes(validAfter),
      _uint256ToBytes(validBefore),
      hexToBytes(nonce.replaceFirst('0x', '')),
    ]));

    final domainSeparator = _buildDomainSeparator(
      contractAddress: contractAddress,
      chainId: chainId,
      version: contractVersion,
      name: domainName,
    );

    final digest = keccak256(
      Uint8List.fromList([0x19, 0x01, ...domainSeparator, ...structHash]),
    );

    final sig = sign(digest, privateKey);
    final v = (sig.v + 27).toRadixString(16).padLeft(2, '0');
    final r = sig.r.toRadixString(16).padLeft(64, '0');
    final s = sig.s.toRadixString(16).padLeft(64, '0');

    return '0x$r$s$v';
  }

  Uint8List _buildDomainSeparator({
    required String contractAddress,
    required int chainId,
    required String version,
    required String name,
  }) {
    const domainTypeHash =
        'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)';

    final typeHash = keccak256(Uint8List.fromList(utf8.encode(domainTypeHash)));
    final nameHash = keccak256(Uint8List.fromList(utf8.encode(name)));
    final versionHash = keccak256(Uint8List.fromList(utf8.encode(version)));

    return keccak256(_abiEncode([
      typeHash,
      nameHash,
      versionHash,
      _uint256ToBytes(BigInt.from(chainId)),
      _addressToBytes32(contractAddress),
    ]));
  }

  Uint8List _abiEncode(List<Uint8List> parts) {
    final result = <int>[];
    for (final part in parts) {
      if (part.length <= 32) {
        result.addAll(List.filled(32 - part.length, 0));
        result.addAll(part);
      } else {
        result.addAll(part.sublist(part.length - 32));
      }
    }
    return Uint8List.fromList(result);
  }

  Uint8List _uint256ToBytes(BigInt value) =>
      hexToBytes(value.toRadixString(16).padLeft(64, '0'));

  Uint8List _addressToBytes32(String address) => hexToBytes(
        address.toLowerCase().replaceFirst('0x', '').padLeft(64, '0'),
      );

  String _randomNonce() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  bool _isNativeEth(String asset) {
    final lower = asset.toLowerCase();
    return lower == 'eth' ||
        lower == '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' ||
        lower == 'native';
  }

  @override
  bool get haveTestAppproval => true;
  @override
  Future<String?>? testCreateApproval() async {
    const sepoliaChainId = 11155111;
    if (chainId != sepoliaChainId) return null;
    try {
      final client = Web3Client(rpc, Client());
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final response = await importData(data);
      final credentials = EthPrivateKey.fromHex(response.privateKey!);
      final gasPrice = await client.getGasPrice();

      // Your existing Sepolia USDC
      const testTokenAddress = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238';

      // Any address as spender — using Uniswap V2 router for test
      const testSpender = '0x7a250d5630b4cf539739df2c5dacb4c659f2488d';

      // Approve 100 USDC (6 decimals)
      final testAmount = BigInt.from(100) * BigInt.from(10).pow(6);

      final approveData = _encodeApprove(
        spender: testSpender,
        amount: testAmount,
      );

      final tx = Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(testTokenAddress),
        data: approveData,
        gasPrice: gasPrice,
      );

      final signed = await client.signTransaction(
        credentials,
        tx,
        chainId: chainId,
      );

      final txHash = await client.sendRawTransaction(signed);
      await client.dispose();
      debugPrint('ETH test approval tx: $txHash');
      return txHash;
    } catch (e) {
      return 'Error: $e';
    }
  }

  int _chainIdForNetwork(String network) {
    return switch (network) {
      'base-mainnet' => 8453,
      'base-sepolia' => 84532,
      'ethereum-mainnet' => 1,
      'ethereum-sepolia' => 11155111,
      'optimism-mainnet' => 10,
      'optimism-sepolia' => 11155420,
      'arbitrum-mainnet' => 42161,
      'arbitrum-sepolia' => 421614,
      'polygon-mainnet' => 137,
      'polygon-amoy' => 80002,
      _ => chainId,
    };
  }

  @override
  Future<({String key, String timeKey})?> approvalCacheKeys() async {
    final address = await getAddress();
    final key = 'token_approvals_${chainId}_$address';
    return (key: key, timeKey: '${key}_time');
  }

  // ── Token approvals ───────────────────────────────────────────────────────
  @override
  Future<List<TokenApproval>>? getApprovals() {
    return _fetchEthApprovals();
  }

  Future<List<TokenApproval>> _fetchEthApprovals() async {
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
      final fetcher = TokenApprovalFetcherFactory.forChain(chainId: chainId);
      final approvals = await fetcher.fetchApprovals(address);
      if (approvals != null) {
        await pref.put(
            keys.key, jsonEncode(approvals.map((a) => a.toJson()).toList()));
        await pref.put(keys.timeKey, DateTime.now().toIso8601String());
        return approvals;
      }
      return [];
    } catch (e) {
      debugPrint('EthereumCoin.getApprovals error: $e');
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List;
          return list
              .map((e) => TokenApproval.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      }
      return [];
    }
  }

  @override
  Future<bool>? revokeApproval(TokenApproval approval) async {
    try {
      final keys = await approvalCacheKeys();
      if (keys == null) return false;
      final client = Web3Client(rpc, Client());
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final response = await importData(data);
      final credentials = EthPrivateKey.fromHex(response.privateKey!);
      final gasPrice = await client.getGasPrice();

      // approve(spender, 0) — revoke
      final approveData = _encodeApprove(
        spender: approval.spenderAddress,
        amount: BigInt.zero,
      );

      final tx = Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(approval.tokenAddress),
        data: approveData,
        gasPrice: gasPrice,
      );

      final signed = await client.signTransaction(
        credentials,
        tx,
        chainId: chainId,
      );

      await client.sendRawTransaction(signed);
      await client.dispose();

      await pref.delete(keys.key);
      await pref.delete(keys.timeKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Uint8List _encodeApprove({
    required String spender,
    required BigInt amount,
  }) {
    // approve(address,uint256) selector = 0x095ea7b3
    const selector = '095ea7b3';
    final paddedSpender =
        spender.toLowerCase().replaceFirst('0x', '').padLeft(64, '0');
    final paddedAmount = amount.toRadixString(16).padLeft(64, '0');
    return hexToBytes('$selector$paddedSpender$paddedAmount');
  }

  // ── Standard methods ──────────────────────────────────────────────────────

  factory EthereumCoin.fromJson(Map<String, dynamic> json) {
    return EthereumCoin(
      chainId: json['chainId'],
      rpc: json['rpc'],
      coinType: json['coinType'],
      blockExplorer: json['blockExplorer'],
      default_: json['default'],
      symbol: json['symbol'],
      image: json['image'],
      name: json['name'],
      geckoID: json['geckoID'],
      rampID: json['rampID'],
      payScheme: json['payScheme'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chainId'] = chainId;
    data['rpc'] = rpc;
    data['default'] = default_;
    data['symbol'] = symbol;
    data['name'] = name;
    data['blockExplorer'] = blockExplorer;
    data['coinType'] = coinType;
    data['image'] = image;
    data['geckoID'] = geckoID;
    data['rampID'] = rampID;
    data['payScheme'] = payScheme;
    return data;
  }

  @override
  Future<AccountData> fromPrivateKey(String privateKey) async {
    String saveKey =
        'ethereumDetailsPrivateV1$coinType${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final account = await deriveEthereumAccount(privateKey);
    final keys = AccountData(
      address: account.address,
      privateKey: privateKey,
      publicKey: account.publicKey,
    );
    privateKeyMap[privateKey] = keys.toJson();
    await pref.put(saveKey, jsonEncode(privateKeyMap));
    return keys;
  }

  @override
  bool get supportBip39Seed => true;

  @override
  Future<AccountData> fromBip39PhraseOrSeed(
          {required String bip39PhraseOrSeedHex}) =>
      Coin.fromBip39PhraseOrSeedCached(
        cacheKey: 'ethereumDetailsV4$coinType${walletImportType.name}',
        bip39PhraseOrSeedHex: bip39PhraseOrSeedHex,
        derive: () => compute(
          calculateEthereumKey,
          EthereumDeriveArgs(seedRoot: seedPhraseRoot, coinType: coinType),
        ),
      );
  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  Future<String?> resolveAddress(String address) async {
    final ens = await ensToAddr(domainName: address);
    if (ens.isOk) return ens.value.address;

    final ud = await udResolver(domainName: address, currency: default_);
    return ud.valueOrNull?.address;
  }

// ─────────────────────────────────────────────────────────────────────────────
// ADD these three overrides inside EthereumCoin (e.g. after getRampID())
// ─────────────────────────────────────────────────────────────────────────────

  @override
  bool get canAddCustomToken => true;

  @override
  Future<CustomTokenMeta?> fetchCustomToken(String contractAddress) async {
    try {
      final coin = ERCFungibleCoin(
        contractAddress_: contractAddress,
        geckoID: '',
        rpc: rpc,
        blockExplorer: blockExplorer,
        image: image,
        chainId: chainId,
        coinType: coinType,
        default_: default_,
        mintDecimals: 18,
        name: '',
        symbol: '',
      );
      final meta = await coin.getERC20Meta();
      if (meta == null) return null;
      return CustomTokenMeta(
        name: meta.name,
        symbol: meta.symbol,
        decimals: meta.decimals,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Coin?> addCustomToken(
    CustomTokenMeta meta,
    String contractAddress,
  ) async {
    // Duplicate check
    final alreadyExists = getChains<ERCFungibleCoin>().any((c) =>
        c.tokenAddress().toLowerCase() == contractAddress.toLowerCase() &&
        c.chainId == chainId);
    if (alreadyExists) return null;

    final token = ERCFungibleCoin(
      contractAddress_: contractAddress,
      name: meta.name,
      geckoID: '',
      symbol: meta.symbol,
      mintDecimals: meta.decimals,
      chainId: chainId,
      rpc: rpc,
      blockExplorer: blockExplorer,
      coinType: coinType,
      default_: default_,
      image: meta.iconUrl ?? 'assets/ethereum-2.png',
    );

    final added = await token.addCoinToStore();
    return added ? token : null;
  }

  @override
  Future<double> getUserBalance({required String address}) async {
    final ethClient = Web3Client(rpc, Client());
    final userAddress = EthereumAddress.fromHex(address);
    final etherAmount = await ethClient.getBalance(userAddress);
    final base = BigInt.from(10);
    await ethClient.dispose();
    return etherAmount.getInWei / base.pow(decimals());
  }

  @override
  Future<double> getBalance(bool useCache) async {
    String address = roninAddrToEth(await getAddress());
    final tokenKey = '$rpc$address/balance';
    final storedBalance = pref.get(tokenKey);
    double savedBalance = 0;
    if (storedBalance != null) savedBalance = storedBalance;
    if (useCache) return savedBalance;
    try {
      double ethBalance = await getUserBalance(address: address);
      await pref.put(tokenKey, ethBalance);
      return ethBalance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  String savedTransKey() => '$default_$rpc Details';

  @override
  Future<({String txHash, String? txRaw})?> transferToken(
      String amount, String to,
      {String? memo}) async {
    final client = Web3Client(rpc, Client());
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final credentials = EthPrivateKey.fromHex(response.privateKey!);
    final gasPrice = await client.getGasPrice();
    final wei = amount.toBigIntDec(decimals());

    final trans = await client.signTransaction(
      credentials,
      Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(roninAddrToEth(to)),
        value: EtherAmount.inWei(wei),
        gasPrice: gasPrice,
      ),
      chainId: chainId,
    );

    final txHash = await client.sendRawTransaction(trans);
    return (
      txHash: txHash,
      txRaw: HEX.encode(trans),
    );
  }

  @override
  validateAddress(String address) {
    EthereumAddress.fromHex(address);
  }

  @override
  int decimals() => etherDecimals;

  @override
  Future<double> getTransactionFee(String amount, String to) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);
    final transactionFee = await getEtherTransactionFee(
      rpc,
      null,
      EthereumAddress.fromHex(roninAddrToEth(response.address)),
      EthereumAddress.fromHex(roninAddrToEth(to)),
    );
    return transactionFee / pow(10, decimals());
  }

  @override
  String getGeckoId() => geckoID;

  @override
  String getPayScheme() => payScheme;

  @override
  String getRampID() => rampID;
}

// ── Blockchain list ────────────────────────────────────────────────────────────

List<EthereumCoin> getEVMBlockchains() {
  List<EthereumCoin> blockChains = [];
  if (enableTestNet) {
    blockChains.addAll([
      EthereumCoin(
        name: 'Smart Chain(Testnet)',
        rpc: 'https://data-seed-prebsc-2-s3.binance.org:8545/',
        chainId: 97,
        blockExplorer:
            'https://testnet.bscscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'BNB',
        default_: 'BNB',
        image: 'assets/smartchain.png',
        coinType: 60,
        geckoID: 'binancecoin',
        payScheme: 'smartchain',
        rampID: 'BSC_BNB',
      ),
      EthereumCoin(
        name: 'Ethereum(Sepolia)',
        rpc: 'https://sepolia.infura.io/v3/$infuraApiKey',
        chainId: 11155111,
        blockExplorer:
            'https://sepolia.etherscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/ethereum_logo.png',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'ethereum',
        rampID: 'ETH_ETH',
      ),
      EthereumCoin(
        name: 'Celo (Alfajores)',
        rpc: 'https://alfajores-forno.celo-testnet.org',
        chainId: 44787,
        blockExplorer:
            'https://explorer.celo.org/alfajores/tx/$blockExplorerPlaceholder',
        symbol: 'CELO',
        default_: 'CELO',
        image: 'assets/celo.png',
        coinType: 60,
        geckoID: 'celo',
        payScheme: 'celo',
        rampID: 'CELO_CELO',
      ),
      EthereumCoin(
        name: 'Polygon (Amoy)',
        rpc: 'https://rpc-amoy.polygon.technology',
        chainId: 80002,
        blockExplorer:
            'https://amoy.polygonscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'POL',
        default_: 'POL',
        image: 'assets/polygon.png',
        coinType: 60,
        geckoID: 'polygon-ecosystem-token',
        payScheme: 'polygon',
        rampID: 'MATIC_MATIC',
      ),
    ]);
  } else {
    blockChains.addAll([
      EthereumCoin(
        rpc: 'https://mainnet.infura.io/v3/$infuraApiKey',
        chainId: 1,
        blockExplorer: 'https://etherscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        name: 'Ethereum',
        image: 'assets/ethereum_logo.png',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'ethereum',
        rampID: 'ETH_ETH',
      ),
      EthereumCoin(
        name: 'Smart Chain',
        rpc: 'https://bsc-dataseed.binance.org/',
        chainId: 56,
        blockExplorer: 'https://bscscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'BNB',
        default_: 'BNB',
        image: 'assets/smartchain.png',
        coinType: 60,
        geckoID: 'binancecoin',
        payScheme: 'smartchain',
        rampID: 'BSC_BNB',
      ),
      EthereumCoin(
        name: 'Base Chain',
        rpc: 'https://mainnet.base.org',
        chainId: 8453,
        blockExplorer: 'https://explorer.base.org/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/basechain.jpeg',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'base',
        rampID: 'BASE_ETH',
      ),
      EthereumCoin(
        name: 'Polygon Matic',
        rpc: 'https://polygon-rpc.com',
        chainId: 137,
        blockExplorer: 'https://polygonscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'POL',
        default_: 'POL',
        image: 'assets/polygon.png',
        coinType: 60,
        geckoID: 'polygon-ecosystem-token',
        payScheme: 'polygon',
        rampID: 'MATIC_MATIC',
      ),
      EthereumCoin(
        name: 'Avalanche',
        rpc: 'https://api.avax.network/ext/bc/C/rpc',
        chainId: 43114,
        blockExplorer: 'https://snowtrace.io/tx/$blockExplorerPlaceholder',
        symbol: 'AVAX',
        default_: 'AVAX',
        image: 'assets/avalanche.png',
        coinType: 60,
        geckoID: 'avalanche-2',
        payScheme: 'avalanchec',
        rampID: 'AVAX_AVAX',
      ),
      EthereumCoin(
        name: 'Fantom',
        rpc: 'https://rpc.ftm.tools/',
        chainId: 250,
        blockExplorer: 'https://ftmscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'FTM',
        default_: 'FTM',
        image: 'assets/fantom.png',
        coinType: 60,
        geckoID: 'fantom',
        payScheme: 'fantom',
        rampID: 'FANTOM_FTM',
      ),
      EthereumCoin(
        name: 'Arbitrum',
        rpc: 'https://arb1.arbitrum.io/rpc',
        chainId: 42161,
        blockExplorer: 'https://arbiscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/arbitrum.jpg',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'arbitrum',
        rampID: 'ARBITRUM_ETH',
      ),
      EthereumCoin(
        name: 'Optimism',
        rpc: 'https://mainnet.optimism.io',
        chainId: 10,
        blockExplorer:
            'https://optimistic.etherscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/optimism.png',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'optimism',
        rampID: 'OPTIMISM_ETH',
      ),
      EthereumCoin(
        name: 'Ethereum Classic',
        symbol: 'ETC',
        default_: 'ETC',
        blockExplorer:
            'https://blockscout.com/etc/mainnet/tx/$blockExplorerPlaceholder',
        rpc: 'https://www.ethercluster.com/etc',
        chainId: 61,
        image: 'assets/ethereum-classic.png',
        coinType: 61,
        geckoID: 'ethereum-classic',
        payScheme: 'classic',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Cronos',
        rpc: 'https://evm.cronos.org',
        chainId: 25,
        blockExplorer: 'https://cronoscan.com/tx/$blockExplorerPlaceholder',
        symbol: 'CRO',
        default_: 'CRO',
        image: 'assets/cronos.png',
        coinType: 60,
        geckoID: 'crypto-com-chain',
        payScheme: 'cronos',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Milkomeda Cardano',
        rpc: 'https://rpc-mainnet-cardano-evm.c1.milkomeda.com',
        chainId: 2001,
        blockExplorer:
            'https://explorer-mainnet-cardano-evm.c1.milkomeda.com/tx/$blockExplorerPlaceholder',
        symbol: 'MilkADA',
        default_: 'MilkADA',
        image: 'assets/milko-cardano.jpeg',
        coinType: 60,
        geckoID: 'cardano',
        payScheme: 'cardano',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Huobi Chain',
        rpc: 'https://http-mainnet-node.huobichain.com/',
        chainId: 128,
        blockExplorer: 'https://hecoinfo.com/tx/$blockExplorerPlaceholder',
        symbol: 'HT',
        default_: 'HT',
        image: 'assets/huobi.png',
        coinType: 60,
        geckoID: 'huobi-token',
        payScheme: 'heco',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Kucoin Chain',
        rpc: 'https://rpc-mainnet.kcc.network',
        chainId: 321,
        blockExplorer: 'https://explorer.kcc.io/tx/$blockExplorerPlaceholder',
        symbol: 'KCS',
        default_: 'KCS',
        image: 'assets/kucoin.jpeg',
        coinType: 60,
        geckoID: 'kucoin-shares',
        payScheme: 'kcc',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Elastos',
        rpc: 'https://api.elastos.io/eth',
        chainId: 20,
        blockExplorer:
            'https://explorer.elaeth.io/tx/$blockExplorerPlaceholder',
        symbol: 'ELA',
        default_: 'ELA',
        image: 'assets/elastos.png',
        coinType: 60,
        geckoID: 'elastos',
        payScheme: 'elastos',
        rampID: '',
      ),
      EthereumCoin(
        name: 'XDAI',
        rpc: 'https://rpc.xdaichain.com/',
        chainId: 100,
        blockExplorer:
            'https://blockscout.com/xdai/mainnet/tx/$blockExplorerPlaceholder',
        symbol: 'XDAI',
        default_: 'XDAI',
        image: 'assets/xdai.jpg',
        geckoID: 'xdai',
        coinType: 60,
        payScheme: 'xdai',
        rampID: 'XDAI_XDAI',
      ),
      EthereumCoin(
        name: 'Ubiq',
        rpc: 'https://rpc.octano.dev/',
        chainId: 8,
        blockExplorer: 'https://ubiqscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'UBQ',
        default_: 'UBQ',
        image: 'assets/ubiq.png',
        coinType: 60,
        geckoID: 'ubiq',
        payScheme: '',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Celo',
        rpc: 'https://rpc.ankr.com/celo',
        chainId: 42220,
        blockExplorer: 'https://explorer.celo.org/tx/$blockExplorerPlaceholder',
        symbol: 'CELO',
        default_: 'CELO',
        image: 'assets/celo.png',
        coinType: 60,
        geckoID: 'celo',
        payScheme: 'celo',
        rampID: 'CELO_CELO',
      ),
      EthereumCoin(
        name: 'Aurora',
        rpc: 'https://mainnet.aurora.dev',
        chainId: 1313161554,
        blockExplorer: 'https://aurorascan.dev/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/aurora.png',
        coinType: 60,
        geckoID: 'ethereum',
        payScheme: 'aurora',
        rampID: '',
      ),
      EthereumCoin(
        name: 'Thunder Token',
        rpc: 'https://mainnet-rpc.thundercore.com',
        chainId: 108,
        blockExplorer:
            'https://viewblock.io/thundercore/tx/$blockExplorerPlaceholder',
        symbol: 'TT',
        default_: 'TT',
        image: 'assets/thunder-token.jpeg',
        coinType: 1001,
        geckoID: 'thunder-token',
        payScheme: 'thundertoken',
        rampID: '',
      ),
      EthereumCoin(
        name: 'GoChain',
        rpc: 'https://rpc.gochain.io',
        chainId: 60,
        blockExplorer:
            'https://explorer.gochain.io/tx/$blockExplorerPlaceholder',
        symbol: 'GO',
        default_: 'GO',
        image: 'assets/go-chain.png',
        coinType: 6060,
        geckoID: 'gochain',
        payScheme: 'gochain',
        rampID: '',
      ),
    ]);
  }

  final prefCoin = pref.get(newEVMChainKey);
  if (prefCoin != null && WalletService.isBip39PhraseOrSeedHexKey()) {
    final tokenList = Map.from(jsonDecode(prefCoin))
        .values
        .map((e) => EthereumCoin.fromJson(e));
    blockChains.addAll([...tokenList]);
  }

  return blockChains;
}

Future<double> getEtherTransactionFee(
  String rpc,
  Uint8List? data,
  EthereumAddress sender,
  EthereumAddress? to, {
  double? value,
  EtherAmount? gasPrice,
}) async {
  final client = Web3Client(rpc, Client());

  final etherValue =
      value != null ? EtherAmount.inWei(BigInt.from(value)) : null;

  if (gasPrice == null || gasPrice.getInWei == BigInt.from(0)) {
    gasPrice = await client.getGasPrice();
  }

  BigInt? gasUnit;
  try {
    gasUnit = await client.estimateGas(
        sender: sender, to: to, data: data, value: etherValue);
  } catch (_) {}

  if (gasUnit == null) {
    try {
      gasUnit = await client.estimateGas(
          sender: EthereumAddress.fromHex(zeroAddress),
          to: to,
          data: data,
          value: etherValue);
    } catch (_) {}
  }

  if (gasUnit == null) {
    try {
      gasUnit = await client.estimateGas(
          sender: EthereumAddress.fromHex(deadAddress),
          to: to,
          data: data,
          value: etherValue);
    } catch (e) {
      gasUnit = BigInt.from(0);
    }
  }

  return gasPrice.getInWei.toDouble() * gasUnit.toDouble();
}

class EthereumDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final int coinType;
  const EthereumDeriveArgs({required this.seedRoot, required this.coinType});
}

Future<Map<String, dynamic>> calculateEthereumKey(
  EthereumDeriveArgs config,
) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final path = "m/44'/${config.coinType}'/0'/0/0";
  final node = seedRoot_.root.derivePath(path);
  final privateKey = HEX.encode(node.privateKey!);
  final privatekeyStr = '0x$privateKey';
  final account = await deriveEthereumAccount(privatekeyStr);
  return {
    'address': account.address,
    'privateKey': privatekeyStr,
    'publicKey': account.publicKey
  };
}

Future<({String address, String publicKey})> deriveEthereumAccount(
    String privateKey) async {
  final ethPrivKey = EthPrivateKey.fromHex(privateKey);

  // compressed = true (default) → 33 bytes, starts with 02 or 03
  final pubKeyBytes = ethPrivKey.publicKey.getEncoded();
  final compressedPubKey = HEX.encode(pubKeyBytes);

  final address = EthereumAddress.fromHex('${ethPrivKey.address}').hexEip55;

  return (address: address, publicKey: compressedPubKey);
}

String roninAddrToEth(String address) => address.replaceFirst('ronin:', '0x');
String ethAddrToRonin(String address) => address.replaceFirst('0x', 'ronin:');

String publicKeyToAddress(String compressedPubKeyHex) {
  final domain = ECDomainParameters('secp256k1');
  final pubKeyBytes = HEX.decode(compressedPubKeyHex.replaceFirst('0x', ''));

  // Decompress to 64-byte uncompressed form (strip the 04 prefix)
  final point = domain.curve.decodePoint(pubKeyBytes)!;
  final uncompressed = point.getEncoded(false); // 65 bytes with 04 prefix
  final pubKeyOnly = uncompressed.sublist(1); // drop 04 prefix → 64 bytes

  // keccak256 → take last 20 bytes → EIP-55 checksum
  final hash = keccak256(pubKeyOnly);
  final addressHex =
      hash.sublist(12).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return EthereumAddress.fromHex('0x$addressHex').hexEip55;
}
