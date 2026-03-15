// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import '../service/x402_service.dart';
import 'package:wallet_app/screens/view_erc_nfts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../interface/coin.dart';
import '../main.dart';
import '../model/seed_phrase_root.dart';
import '../utils/alt_ens.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

const etherDecimals = 18;

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

  // ── x402 support ────────────────────────────────────────────────────────────

  @override
  bool get supportsX402 => true;

  @override
  Future<String?> signX402Payment(X402PaymentOption option) async {
    try {
      final walletData = WalletService.getActiveKey(walletImportType)!.data;
      final accountData = await importData(walletData);
      final privateKeyBytes = hexToBytes(accountData.privateKey!);
      final fromAddress = accountData.address;

      final value = BigInt.parse(option.maxAmountRequired);
      final validAfter = BigInt.zero;
      final validBefore = BigInt.from(
        DateTime.now()
                .add(const Duration(minutes: 5))
                .millisecondsSinceEpoch ~/
            1000,
      );
      final nonce = _randomNonce();
      final contractVersion = option.extra?['version'] as String? ?? '2';

      final signature = _signEIP3009(
        from: fromAddress,
        to: option.payTo,
        value: value,
        validAfter: validAfter,
        validBefore: validBefore,
        nonce: nonce,
        contractAddress: option.asset,
        chainId: _chainIdForNetwork(option.network),
        contractVersion: contractVersion,
        privateKey: privateKeyBytes,
      );

      final payload = {
        'x402Version': 1,
        'scheme': option.scheme,
        'network': option.network,
        'payload': {
          'signature': signature,
          'authorization': {
            'from': fromAddress,
            'to': option.payTo,
            'value': value.toString(),
            'validAfter': validAfter.toString(),
            'validBefore': validBefore.toString(),
            'nonce': nonce,
          },
        },
      };

      return base64Encode(utf8.encode(jsonEncode(payload)));
    } catch (e) {
      debugPrint('x402 sign error: $e');
      return null;
    }
  }

  // ── EIP-3009 signing ─────────────────────────────────────────────────────────

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
  }) {
    const domainTypeHash =
        'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)';

    final typeHash =
        keccak256(Uint8List.fromList(utf8.encode(domainTypeHash)));
    final nameHash =
        keccak256(Uint8List.fromList(utf8.encode('USD Coin')));
    final versionHash =
        keccak256(Uint8List.fromList(utf8.encode(version)));

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

  int _chainIdForNetwork(String network) {
    switch (network) {
      case 'base-mainnet':
        return 8453;
      case 'base-sepolia':
        return 84532;
      case 'ethereum-mainnet':
        return 1;
      case 'ethereum-sepolia':
        return 11155111;
      default:
        return chainId; // fall back to this coin's own chainId
    }
  }

  // ── Standard EthereumCoin methods ────────────────────────────────────────────

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
    String saveKey = 'ethereumDetailsPrivate$coinType${walletImportType.name}';
    Map<String, dynamic> privateKeyMap = {};

    if (pref.containsKey(saveKey)) {
      privateKeyMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (privateKeyMap.containsKey(privateKey)) {
        return AccountData.fromJson(privateKeyMap[privateKey]);
      }
    }

    final address = await etherPrivateKeyToAddress(privateKey);
    final keys = AccountData(address: address, privateKey: privateKey);
    privateKeyMap[privateKey] = keys.toJson();
    await pref.put(saveKey, jsonEncode(privateKeyMap));
    return keys;
  }

  @override
  Future<AccountData> fromMnemonic({required String mnemonic}) async {
    String saveKey = 'ethereumDetails$coinType${walletImportType.name}';
    Map<String, dynamic> mnemonicMap = {};

    if (pref.containsKey(saveKey)) {
      mnemonicMap = Map<String, dynamic>.from(jsonDecode(pref.get(saveKey)));
      if (mnemonicMap.containsKey(mnemonic)) {
        return AccountData.fromJson(mnemonicMap[mnemonic]);
      }
    }

    final args = EthereumDeriveArgs(
      seedRoot: seedPhraseRoot,
      coinType: coinType,
    );

    final keys = await compute(calculateEthereumKey, args);
    mnemonicMap[mnemonic] = keys;
    await pref.put(saveKey, jsonEncode(mnemonicMap));
    return AccountData.fromJson(keys);
  }

  @override
  Future<String> addressExplorer() async {
    final address = await getAddress();
    return blockExplorer
        .replaceFirst('/tx/', '/address/')
        .replaceFirst(blockExplorerPlaceholder, address);
  }

  @override
  Future<String?> resolveAddress(String address) async {
    Map resolver = await ensToAddr(domainName: address);
    if (resolver['success']) return resolver['msg'];

    resolver = await udResolver(
      domainName: address,
      currency: getDefault(),
    );
    if (resolver['success']) return resolver['msg'];
    return null;
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
  Future<String?> transferToken(String amount, String to,
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

    return await client.sendRawTransaction(trans);
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
        geckoID: "binancecoin",
        payScheme: 'smartchain',
        rampID: 'BSC_BNB',
      ),
      EthereumCoin(
        name: 'Ethereum(Sepolia)',
        rpc: 'https://sepolia.infura.io/v3/$infuraApiKey',
        chainId: 5,
        blockExplorer:
            'https://sepolia.etherscan.io/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/ethereum_logo.png',
        coinType: 60,
        geckoID: "ethereum",
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
        geckoID: "celo",
        payScheme: 'celo',
        rampID: 'CELO_CELO',
      ),
      EthereumCoin(
        name: 'Polygon (Amoy)',
        rpc: "https://rpc-amoy.polygon.technology",
        chainId: 80002,
        blockExplorer:
            "https://amoy.polygonscan.com/tx/$blockExplorerPlaceholder",
        symbol: 'POL',
        default_: 'POL',
        image: "assets/polygon.png",
        coinType: 60,
        geckoID: "polygon-ecosystem-token",
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
        geckoID: "ethereum",
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
        geckoID: "binancecoin",
        payScheme: 'smartchain',
        rampID: 'BSC_BNB',
      ),
      EthereumCoin(
        name: 'Base Chain',
        rpc: 'https://mainnet.base.org',
        chainId: 8453,
        blockExplorer:
            'https://explorer.base.org/tx/$blockExplorerPlaceholder',
        symbol: 'ETH',
        default_: 'ETH',
        image: 'assets/basechain.jpeg',
        coinType: 60,
        geckoID: "ethereum",
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
        geckoID: "polygon-ecosystem-token",
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
        geckoID: "avalanche-2",
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
        geckoID: "fantom",
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
        geckoID: "ethereum",
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
        geckoID: "ethereum",
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
        geckoID: "ethereum-classic",
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
        geckoID: "crypto-com-chain",
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
        geckoID: "huobi-token",
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
        geckoID: "kucoin-shares",
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
        geckoID: "elastos",
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
        geckoID: "xdai",
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
        geckoID: "ubiq",
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
        geckoID: "celo",
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
        geckoID: "ethereum",
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
        geckoID: "thunder-token",
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
        geckoID: "gochain",
        payScheme: 'gochain',
        rampID: '',
      ),
    ]);
  }

  final prefCoin = pref.get(newEVMChainKey);
  if (prefCoin != null && WalletService.isPharseKey()) {
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

  final etherValue = value != null
      ? EtherAmount.inWei(BigInt.from(value))
      : null;

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

Future<Map> calculateEthereumKey(EthereumDeriveArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final path = "m/44'/${config.coinType}'/0'/0/0";
  final node = seedRoot_.root.derivePath(path);
  final privateKey = HEX.encode(node.privateKey!);
  final privatekeyStr = "0x$privateKey";
  final address = await etherPrivateKeyToAddress(privatekeyStr);
  return {'address': address, 'privateKey': privatekeyStr};
}

Future<String> etherPrivateKeyToAddress(String privateKey) async {
  EthPrivateKey ethereumPrivateKey = EthPrivateKey.fromHex(privateKey);
  final uncheckedAddr = ethereumPrivateKey.address;
  return EthereumAddress.fromHex('$uncheckedAddr').hexEip55;
}

String roninAddrToEth(String address) => address.replaceFirst('ronin:', '0x');
String ethAddrToRonin(String address) => address.replaceFirst('0x', 'ronin:');