// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import '../extensions/big_int_ext.dart';
import '../service/wallet_service.dart';
import 'package:cryptowallet/screens/view_erc_nfts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';
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

    final keys = AccountData(
      address: address,
      privateKey: privateKey,
    ).toJson();

    privateKeyMap[privateKey] = keys;

    await pref.put(saveKey, jsonEncode(privateKeyMap));

    return AccountData.fromJson(keys);
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
    Map resolver = await ensToAddr(
      domainName: address,
    );

    if (resolver['success']) {
      return resolver['msg'];
    }

    resolver = await udResolver(
      domainName: address,
      currency: getDefault(),
    );

    if (resolver['success']) {
      return resolver['msg'];
    }
    return null;
  }

  @override
  Future<double> getBalance(bool skipNetworkRequest) async {
    String address = roninAddrToEth(await getAddress());
    final tokenKey = '$rpc$address/balance';
    final storedBalance = pref.get(tokenKey);

    double savedBalance = 0;

    if (storedBalance != null) savedBalance = storedBalance;

    if (skipNetworkRequest) return savedBalance;

    try {
      final ethClient = Web3Client(rpc, Client());

      final userAddress = EthereumAddress.fromHex(address);

      final etherAmount = await ethClient.getBalance(userAddress);

      final base = BigInt.from(10);

      double ethBalance = etherAmount.getInWei / base.pow(decimals());

      await pref.put(tokenKey, ethBalance);
      await ethClient.dispose();
      return ethBalance;
    } catch (e) {
      return savedBalance;
    }
  }

  @override
  String savedTransKey() {
    return '$default_$rpc Details';
  }

  @override
  Future<String?> transferToken(String amount, String to,
      {String? memo}) async {
    final client = Web3Client(
      rpc,
      Client(),
    );
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final response = await importData(data);

    final credentials = EthPrivateKey.fromHex(
      response.privateKey!,
    );
    final gasPrice = await client.getGasPrice();
    final wei = amount.toBigIntDec(decimals());

    final trans = await client.signTransaction(
      credentials,
      Transaction(
        from: credentials.address,
        to: EthereumAddress.fromHex(roninAddrToEth(to)),
        value: EtherAmount.inWei(
          wei,
        ),
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
  int decimals() {
    return etherDecimals;
  }

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
        name: 'Ethereum(Goerli)',
        rpc: 'https://goerli.infura.io/v3/$infuraApiKey',
        chainId: 5,
        blockExplorer:
            'https://goerli.etherscan.io/tx/$blockExplorerPlaceholder',
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
        symbol: "MATIC",
        default_: "MATIC",
        image: "assets/polygon.png",
        coinType: 60,
        geckoID: "matic-network",
        payScheme: 'polygon',
        rampID: 'MATIC_MATIC',
      )
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
        blockExplorer: 'https://explorer.base.org/tx/$blockExplorerPlaceholder',
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
        symbol: 'MATIC',
        default_: 'MATIC',
        image: 'assets/polygon.png',
        coinType: 60,
        geckoID: "matic-network",
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
      // EthereumCoin(
      //   name: 'Fuse',
      //   rpc: 'https://rpc.fuse.io',
      //   chainId: 122,
      //   blockExplorer: 'https://explorer.fuse.io/tx/$blockExplorerPlaceholder',
      //   symbol: 'FUSE',
      //   default_: 'FUSE',
      //   image: 'assets/fuse.png',
      //   coinType: 60,
      //   geckoID: "fuse-network-token",
      //   payScheme: 'fuse',
      //   rampID: '',
      // ),
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
  final client = Web3Client(
    rpc,
    Client(),
  );

  final etherValue = value != null
      ? EtherAmount.inWei(
          BigInt.from(value),
        )
      : null;

  if (gasPrice == null || gasPrice.getInWei == BigInt.from(0)) {
    gasPrice = await client.getGasPrice();
  }

  BigInt? gasUnit;

  try {
    gasUnit = await client.estimateGas(
      sender: sender,
      to: to,
      data: data,
      value: etherValue,
    );
  } catch (_) {}

  if (gasUnit == null) {
    try {
      gasUnit = await client.estimateGas(
        sender: EthereumAddress.fromHex(zeroAddress),
        to: to,
        data: data,
        value: etherValue,
      );
    } catch (_) {}
  }

  if (gasUnit == null) {
    try {
      gasUnit = await client.estimateGas(
        sender: EthereumAddress.fromHex(deadAddress),
        to: to,
        data: data,
        value: etherValue,
      );
    } catch (e) {
      gasUnit = BigInt.from(0);
    }
  }

  return gasPrice.getInWei.toDouble() * gasUnit.toDouble();
}

class EthereumDeriveArgs {
  final SeedPhraseRoot seedRoot;
  final int coinType;

  const EthereumDeriveArgs({
    required this.seedRoot,
    required this.coinType,
  });
}

Future<Map> calculateEthereumKey(EthereumDeriveArgs config) async {
  SeedPhraseRoot seedRoot_ = config.seedRoot;
  final path = "m/44'/${config.coinType}'/0'/0/0";
  final node = seedRoot_.root.derivePath(path);
  final privateKey = HEX.encode(node.privateKey!);
  final privatekeyStr = "0x$privateKey";
  final address = await etherPrivateKeyToAddress(privatekeyStr);

  return {
    'address': address,
    'privateKey': privatekeyStr,
  };
}

Future<String> etherPrivateKeyToAddress(String privateKey) async {
  EthPrivateKey ethereumPrivateKey = EthPrivateKey.fromHex(privateKey);
  final uncheckedAddr = ethereumPrivateKey.address;
  return EthereumAddress.fromHex('$uncheckedAddr').hexEip55;
}

String roninAddrToEth(String address) {
  return address.replaceFirst('ronin:', '0x');
}

String ethAddrToRonin(String address) {
  return address.replaceFirst('0x', 'ronin:');
}
