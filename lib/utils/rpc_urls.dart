import 'dart:convert' hide Encoding;
import 'dart:io';
import 'package:eth_sig_util/util/utils.dart' hide hexToBytes, bytesToHex;
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/network_guard.dart';
import 'package:blockchain_utils/blockchain_utils.dart' hide AES;
import 'package:on_chain/on_chain.dart' hide Permission;
import '../service/wallet_service.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:validators/validators.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';

import '../coins/utxo_coin.dart';
import '../coins/ethereum_coin.dart';
import '../model/seed_phrase_root.dart';
import 'abis.dart';
import 'coingecko_ids.dart';
import 'alt_ens.dart';
import 'app_config.dart';

export '../modals/connect_wallet_modal.dart';
export '../modals/sign_message_modal.dart';
export '../modals/sign_evm_transaction_modal.dart';
export '../modals/sign_multiversx_transaction_modal.dart';
export '../modals/sign_near_transaction_modal.dart';
export '../modals/sign_starknet_transaction_modal.dart';
export '../modals/ethereum_chain_modals.dart';
export 'crypto_utils.dart';
export 'auth_utils.dart';
export 'file_utils.dart';
export 'web3_bridge.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const satoshiDustAmount = 546;

const Duration networkTimeOutDuration = Duration(seconds: 15);
const Duration httpPollingDelay = Duration(seconds: 15);

late SeedPhraseRoot seedPhraseRoot;

const zeroAddress = '0x0000000000000000000000000000000000000000';
const deadAddress = '0x000000000000000000000000000000000000dEaD';
const nativeTokenAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
const ensInterfaceAddress = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e';
const coinGeckoBaseurl = 'https://api.coingecko.com/api/v3';
const coinGeckoSupportedCurrencies =
    '$coinGeckoBaseurl/simple/supported_vs_currencies';

// ─── ABI helpers ──────────────────────────────────────────────────────────────

solidityFunctionSig(String methodId) {
  return '0x${sha3(methodId).substring(0, 8)}';
}

AbiDecodedResult? decodeAbi(String txData) {
  if (kDebugMode) print('using flutter abi decoder');
  try {
    final contractAbi = ContractABI.fromJson(abisJson);
    final selector =
        BytesUtils.fromHexString(txData).sublist(0, ABIConst.selectorLength);
    final function = contractAbi.functions.lastWhere(
      (element) => BytesUtils.bytesEqual(selector, element.selector),
    );
    final hexStr = BytesUtils.fromHexString(txData);
    final decodedInput = function.decodeInput(hexStr);
    return AbiDecodedResult(
      name: function.name,
      methodId: function.functionName,
      decodedInputs: decodedInput,
      functionInputs: function.inputs,
    );
  } catch (e) {
    if (kDebugMode) print(e);
    return null;
  }
}

class AbiDecodedResult {
  final String methodId;
  final String name;
  final List decodedInputs;
  final List functionInputs;
  const AbiDecodedResult({
    required this.name,
    required this.methodId,
    required this.decodedInputs,
    required this.functionInputs,
  });
}

// ─── Chain lookups ────────────────────────────────────────────────────────────

EthereumCoin? evmFromSymbol(String symbol) {
  for (final c in getEVMBlockchains()) {
    if (c.symbol == symbol) return c;
  }
  return null;
}

EthereumCoin? evmFromChainId(int chainId) {
  for (final c in getEVMBlockchains()) {
    if (c.chainId == chainId) return c;
  }
  return null;
}

UtxoCoin? bitcoinFromNetwork(NetworkType network) {
  for (final c in getUtxoCoins()) {
    if (c.POSNetwork == network) return c;
  }
  return null;
}

// ─── URL / IPFS helpers ───────────────────────────────────────────────────────

String ipfsTohttp(String url) {
  url = url.trim();
  return url.startsWith('ipfs://')
      ? 'https://ipfs.io/ipfs/${url.replaceFirst('ipfs://', '')}'
      : url;
}

String localHostToIpAddress(String url) {
  Uri uri = Uri.parse(url);
  const localhostNames = ['localhost', '127.0.0.1', '[::1]', '10.0.2.2'];
  if (!localhostNames.contains(uri.host)) return url;
  uri = uri.replace(host: Platform.isAndroid ? '10.0.2.2' : '127.0.0.1');
  return uri.toString();
}

Uri blockChainToHttps(String? value) {
  if (value == null) return Uri.parse(walletURL);
  value = value.trim();
  value = localHostToIpAddress(value);
  if (value.startsWith('ipfs://')) return Uri.parse(ipfsTohttp(value));
  if (isURL(value)) {
    Uri url = Uri.parse(value);
    if (url.scheme.isEmpty) url = url.replace(scheme: 'http');
    return url;
  }
  Uri? url = Uri.tryParse(value);
  if (url != null && isLocalizedContent(url)) return url;
  return Uri.parse('https://www.google.com/search?q=$value');
}

bool isLocalizedContent(Uri url) {
  return url.scheme == 'file' ||
      url.scheme == 'chrome' ||
      url.scheme == 'data' ||
      url.scheme == 'javascript' ||
      url.scheme == 'about';
}

bool urlIsSecure(Uri url) => url.scheme == 'https' || isLocalizedContent(url);

// ─── Data helpers ─────────────────────────────────────────────────────────────

Uint8List txDataToUintList(String txData) =>
    isHexString(txData) ? hexToBytes(txData) : ascii.encode(txData);

bool seqEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class Eip1809 {
  final String? ascii;
  final String? brackets;
  final String str;
  const Eip1809({
    required this.ascii,
    required this.brackets,
    required this.str,
  });
}

Eip1809 eipEllipsify({required String str}) {
  if (!str.startsWith('0x')) {
    return Eip1809(str: str, ascii: null, brackets: null);
  } else {
    final strip0x = str.substring(2);
    final cstr = strip0x.split("");
    int totalFirstZero = 0;
    for (String c in cstr) {
      if (c != "0") break;
      totalFirstZero++;
    }
    if (totalFirstZero < 3) {
      return Eip1809(str: str, ascii: null, brackets: null);
    }
    const mapSub = {
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
    };
    final totalString = totalFirstZero.toString().split('');
    for (int i = 0; i < totalString.length; i++) {
      totalString[i] = mapSub[totalString[i]]!;
    }

    return Eip1809(
      str: str,
      ascii: '0x0${totalString.join('')}${strip0x.substring(totalFirstZero)}',
      brackets: '0x0($totalFirstZero)${strip0x.substring(totalFirstZero)}',
    );
  }
}

String ellipsify({required String str, int? maxLength}) {
  maxLength ??= 10;
  if (maxLength % 2 != 0) maxLength++;
  if (str.length <= maxLength) return str;
  if (str.startsWith('0x')) {
    final eipData = eipEllipsify(str: str);
    if (eipData.ascii != null) {
      str = eipData.ascii!;
      maxLength = 20;
    } else if (eipData.brackets != null) {
      str = eipData.brackets!;
      maxLength = 20;
    }
  }
  final first = str.substring(0, maxLength ~/ 2);
  final last = str.substring((str.length - maxLength / 2).toInt(), str.length);
  return '$first...$last';
}

String getRampLink(String asset, String userAddress) {
  return 'https://app.ramp.network/?defaultAsset=$asset&fiatCurrency=USD&fiatValue=150.000000&hostApiKey=$rampApiKey&swapAsset=$asset&userAddress=$userAddress';
}

final List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// ─── Crypto price ─────────────────────────────────────────────────────────────

Future<CryptoPrice> getCryptoPrice({bool useCache = false}) async {
  const int secondsToResendRequest = 15;
  final String? savedCryptoPrice = pref.get(coinGeckoCryptoPriceKey);
  final DateTime now = DateTime.now();
  final int secondsSinceLastFetch =
      now.difference(MyApp.lastcoinGeckoData).inSeconds;
  final bool useCached = secondsSinceLastFetch < secondsToResendRequest;

  final String defaultCurrency = pref.get('defaultCurrency') ?? 'usd';
  final currencyWithSymbol = jsonDecode(currencyJson) as Map;
  final String symbol =
      currencyWithSymbol[defaultCurrency.toUpperCase()]['symbol'];

  Map<String, dynamic> parsedPrices = {};

  if ((useCached || useCache || !NetworkGuard().isConnected) &&
      savedCryptoPrice != null) {
    parsedPrices = jsonDecode(
      jsonDecode(savedCryptoPrice)['data'],
    ) as Map<String, dynamic>;

    return CryptoPrice(
      prices: parsedPrices,
      symbol: symbol,
      defaultCurrency: defaultCurrency,
    );
  }

  try {
    if (!MyApp.getCoinGeckoData && savedCryptoPrice != null) {
      parsedPrices = jsonDecode(
        jsonDecode(savedCryptoPrice)['data'],
      ) as Map<String, dynamic>;

      return CryptoPrice(
        prices: parsedPrices,
        symbol: symbol,
        defaultCurrency: defaultCurrency,
      );
    }

    final String allCrypto = coinGeckoIDs.join(',');
    final Uri apiUrl = Uri.parse(
      '$coinGeckoBaseurl/simple/price?ids=$allCrypto&vs_currencies=usd,$defaultCurrency&include_24hr_change=true',
    );
    final response = await get(apiUrl).timeout(networkTimeOutDuration);

    if (response.statusCode >= 400) {
      throw Exception('CoinGecko Error: ${response.statusCode}');
    }

    MyApp.getCoinGeckoData = false;
    MyApp.lastcoinGeckoData = now;
    await pref.put(
      coinGeckoCryptoPriceKey,
      json.encode({'data': response.body}),
    );

    parsedPrices = jsonDecode(response.body) as Map<String, dynamic>;

    return CryptoPrice(
      prices: parsedPrices,
      symbol: symbol,
      defaultCurrency: defaultCurrency,
    );
  } catch (e) {
    if (savedCryptoPrice != null) {
      parsedPrices = jsonDecode(
        jsonDecode(savedCryptoPrice)['data'],
      ) as Map<String, dynamic>;

      return CryptoPrice(
        prices: parsedPrices,
        symbol: symbol,
        defaultCurrency: defaultCurrency,
      );
    }
    throw Exception('Failed to get data from CoinGecko: $e');
  }
}

Future<String> getCurrencyJson() async => currencyJsonSearch;

Future<double> totalCryptoBalance({
  required CryptoPrice cryptoPrice,
}) async {
  double totalBalance = 0.0;
  for (final coin in supportedChains) {
    try {
      if (WalletService.removeCoin(coin)) continue;
      final balance = await coin.getBalance(true);
      final price = cryptoPrice.getPrice(coin.getGeckoId());
      if (price == null) continue;
      totalBalance += balance * price;
    } catch (e) {
      debugPrint('Failed to calculate balance for ${coin.getGeckoId()}: $e');
    }
  }
  return totalBalance;
}

// ─── ENS ──────────────────────────────────────────────────────────────────────

Future<web3.DeployedContract> getEnsResolverContract(
  String cryptoDomainName,
  web3.Web3Client client,
) async {
  cryptoDomainName = cryptoDomainName.trim();
  final nameHash_ = nameHash(cryptoDomainName);
  final ensInterfaceContract = web3.DeployedContract(
    web3.ContractAbi.fromJson(json.encode(ensInterface), ''),
    web3.EthereumAddress.fromHex(ensInterfaceAddress),
  );
  final resolverAddr = (await client.call(
    contract: ensInterfaceContract,
    function: ensInterfaceContract.function('resolver'),
    params: [hexToBytes(nameHash_)],
  ))
      .first;
  return web3.DeployedContract(
    web3.ContractAbi.fromJson(json.encode(ensResolver), ''),
    resolverAddr,
  );
}

Future<Map> ensToContentHashAndIPFS({required String cryptoDomainName}) async {
  try {
    final client = web3.Web3Client(evmFromChainId(1)!.rpc, Client());
    final nameHash_ = nameHash(cryptoDomainName);
    final ensResolverContract =
        await getEnsResolverContract(cryptoDomainName, client);
    List<int> contentHashList = (await client.call(
      contract: ensResolverContract,
      function: ensResolverContract.function('contenthash'),
      params: [hexToBytes(nameHash_)],
    ))
        .first;
    String contentHash = bytesToHex(contentHashList);
    if (!contentHash.startsWith('0x')) contentHash = '0x$contentHash';

    final ipfsCIDRegex = RegExp(
        r'^0xe3010170(([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f]*))$');
    final swarmRegex = RegExp(r'^0xe40101fa011b20([0-9a-f]*)$');
    final match = ipfsCIDRegex.firstMatch(contentHash);
    final swarmMatch = swarmRegex.firstMatch(contentHash);

    if (match != null) {
      final length = int.parse(match.group(3)!, radix: 16);
      if (match.group(4)!.length == length * 2) {
        return {
          'success': true,
          'msg': ipfsTohttp(
            'ipfs://${bs58check.base58.encode(HEX.decode(match.group(1)!) as Uint8List)}',
          )
        };
      }
      throw Exception('invalid IPFS checksum');
    } else if (swarmMatch != null) {
      if (swarmMatch.group(1)!.length == 32 * 2) {
        return {'success': true, 'msg': 'bzz://${swarmMatch.group(2)!}'};
      }
      throw Exception('invalid SWARM checksum');
    }
    throw Exception('invalid ENS checksum');
  } catch (e) {
    return {'success': false, 'msg': 'Error resolving ens'};
  }
}

Future<Map> ensToAddr({required String domainName}) async {
  try {
    domainName = domainName.toLowerCase().trim();
    final client = web3.Web3Client(evmFromChainId(1)!.rpc, Client());
    final nameHash_ = nameHash(domainName);
    final ensResolverContract =
        await getEnsResolverContract(domainName, client);
    final userAddress = (await client.call(
      contract: ensResolverContract,
      function: ensResolverContract.findFunctionsByName('addr').toList()[0],
      params: [hexToBytes(nameHash_)],
    ))
        .first;
    return {
      'success': true,
      'msg': web3.EthereumAddress.fromHex(userAddress.toString()).hexEip55
    };
  } catch (e) {
    return {'success': false, 'msg': 'Error resolving ens'};
  }
}

// ─── NFTs ─────────────────────────────────────────────────────────────────────

Future<Map> multivrNFT(
  String address, {
  required String multiversxApi,
  required bool useCache,
}) async {
  final tokenListKey = 'multiversnListKey_$address$multiversxApi';
  final tokenList = pref.get(tokenListKey);
  Map userTokens = {'msg': 'could not fetch tokens', 'success': false};
  if (tokenList != null) {
    userTokens = {'msg': json.decode(tokenList) as List, 'success': true};
  }
  if (useCache) return userTokens;
  try {
    final response =
        await get(Uri.parse('$multiversxApi/accounts/$address/nfts'));
    final responseBody = response.body;
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }
    await pref.put(tokenListKey, response.body);
    return {'msg': json.decode(response.body), 'success': true};
  } catch (_) {
    return userTokens;
  }
}

Future<Map> erc20NFTs(int chainId, String address,
    {required bool useCache}) async {
  final tokenListKey = 'tokenListKey_$chainId-$address/__';
  final tokenList = pref.get(tokenListKey);
  Map userTokens = {'msg': 'could not fetch tokens', 'success': false};
  if (tokenList != null) {
    userTokens = {'msg': json.decode(tokenList) as Map, 'success': true};
  }
  if (useCache) return userTokens;
  try {
    String baseUrl = '';
    switch (chainId) {
      case 1:
        baseUrl =
            'https://eth-mainnet.g.alchemy.com/v2/$alchemyEthMainnetApiKey';
        break;
      case 5:
        baseUrl = 'https://eth-goerli.g.alchemy.com/v2/$alchemyEthGoerliApiKey';
        break;
      case 137:
        baseUrl =
            'https://polygon-mainnet.g.alchemy.com/v2/$alchemyPolygonApiKey';
        break;
      case 80001:
        baseUrl =
            'https://polygon-mumbai.g.alchemy.com/v2/$alchemyMumbaiApiKey';
        break;
      case 42161:
        baseUrl =
            'https://arb-mainnet.g.alchemy.com/v2/$alchemyArbitriumApiKey';
        break;
    }
    final response = await get(Uri.parse('$baseUrl/getNFTs?owner=$address'));
    final responseBody = response.body;
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }
    await pref.put(tokenListKey, response.body);
    return {'msg': json.decode(response.body), 'success': true};
  } catch (_) {
    return userTokens;
  }
}

Future<Map> get1InchUrlList(int chainId) async {
  final response = await http
      .get(Uri.parse('https://tokens.1inch.io/v1.1/$chainId'))
      .timeout(networkTimeOutDuration);
  return Map.from(json.decode(response.body));
}

// ─── WalletConnect helper ─────────────────────────────────────────────────────

web3.Transaction wcEthTxToWeb3Tx(WCEthereumTransaction tx) {
  return web3.Transaction(
    from: EthereumAddress.fromHex(tx.from),
    to: tx.to == null ? null : EthereumAddress.fromHex(tx.to!),
    maxGas: tx.gasLimit != null ? int.tryParse(tx.gasLimit!) : null,
    gasPrice: tx.gasPrice != null
        ? EtherAmount.inWei(BigInt.parse(tx.gasPrice!))
        : null,
    value: EtherAmount.inWei(BigInt.parse(tx.value ?? '0')),
    data: tx.data == null ? null : hexToBytes(tx.data!),
    nonce: tx.nonce != null ? int.tryParse(tx.nonce!) : null,
  );
}

class CryptoPrice {
  final Map<String, dynamic> prices;
  final String symbol;
  final String defaultCurrency;

  const CryptoPrice({
    required this.prices,
    required this.symbol,
    required this.defaultCurrency,
  });

  double? getPrice(String geckoId) {
    return (prices[geckoId]?[defaultCurrency.toLowerCase()] as num?)
        ?.toDouble();
  }

  double? getChange(String geckoId) {
    return (prices[geckoId]?['${defaultCurrency.toLowerCase()}_24h_change']
            as num?)
        ?.toDouble();
  }

  Map<String, dynamic>? getMarket(String geckoId) {
    return prices[geckoId] as Map<String, dynamic>?;
  }
}
