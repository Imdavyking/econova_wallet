import 'dart:convert' hide Encoding;
import 'dart:io';
import 'package:eth_sig_util/util/utils.dart' hide hexToBytes, bytesToHex;
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/network_guard.dart';
import 'package:blockchain_utils/blockchain_utils.dart' hide AES;
import 'package:on_chain/on_chain.dart' hide Permission;
import '../service/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:http/http.dart';
import 'package:validators/validators.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';
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

const Duration networkTimeOutDuration = Duration(seconds: 20);
const Duration httpPollingDelay = Duration(seconds: 20);

late SeedPhraseRoot seedPhraseRoot;

const zeroAddress = '0x0000000000000000000000000000000000000000';
const deadAddress = '0x000000000000000000000000000000000000dEaD';
const nativeTokenAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
const ensInterfaceAddress = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e';
const coinGeckoBaseurl = 'https://api.coingecko.com/api/v3';
const coinGeckoSupportedCurrencies =
    '$coinGeckoBaseurl/simple/supported_vs_currencies';

// ─── Result types ─────────────────────────────────────────────────────────────

/// Generic success/failure wrapper. Prefer domain-specific subtypes below
/// when the payload shape is known at compile time.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}

extension ResultX<T> on Result<T> {
  bool get isOk => this is Ok<T>;
  T get value => (this as Ok<T>).value;
  String get error => (this as Err<T>).message;
  T? get valueOrNull => isOk ? value : null;
}

// ─── Domain result types ──────────────────────────────────────────────────────

class EnsAddressResult {
  final String address; // EIP-55 checksummed
  const EnsAddressResult({required this.address});
}

class EnsContentResult {
  /// Resolved URL — either https://ipfs.io/ipfs/… or bzz://…
  final String url;
  const EnsContentResult({required this.url});
}

class UDResult {
  final String address;
  const UDResult({required this.address});
}

class NFTResult {
  final List<dynamic> items;
  const NFTResult({required this.items});
}

class ERC20NFTResult {
  final Map<String, dynamic> data;
  const ERC20NFTResult({required this.data});
}

// ─── ABI helpers ──────────────────────────────────────────────────────────────

solidityFunctionSig(String methodId) {
  return '0x${solidityKeccak256(methodId).substring(0, 8)}';
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

class Erc8117 {
  final String str;
  final String? unicode;
  final String? ascii;

  const Erc8117({
    required this.str,
    required this.unicode,
    required this.ascii,
  });

  static const _sub = {
    '0': '₀',
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

  static String _toSubscript(int n) =>
      n.toString().split('').map((c) => _sub[c]!).join();

  static Erc8117 fromAddress(String address) {
    final trimmed = address.trim();
    if (!trimmed.startsWith('0x') && !trimmed.startsWith('0X')) {
      return Erc8117(str: trimmed, unicode: null, ascii: null);
    }
    final body = trimmed.substring(2).toLowerCase();
    int n = 0;
    while (n < body.length && body[n] == '0') {
      n++;
    }
    if (n <= 4) return Erc8117(str: trimmed, unicode: null, ascii: null);
    final rest = body.substring(n);
    return Erc8117(
      str: trimmed,
      unicode: '0x0${_toSubscript(n)}$rest',
      ascii: '0x0($n)$rest',
    );
  }

  static Erc8117 fromTokenPrice(String price) {
    final trimmed = price.trim();
    if (!trimmed.startsWith('0.')) {
      return Erc8117(str: trimmed, unicode: null, ascii: null);
    }
    final afterDot = trimmed.substring(2);
    int n = 0;
    while (n < afterDot.length && afterDot[n] == '0') {
      n++;
    }
    if (n <= 4) return Erc8117(str: trimmed, unicode: null, ascii: null);
    final significant = afterDot.substring(n);
    if (significant.isEmpty) {
      return Erc8117(str: trimmed, unicode: null, ascii: null);
    }
    return Erc8117(
      str: trimmed,
      unicode: '0.0${_toSubscript(n)}$significant',
      ascii: '0.0($n)$significant',
    );
  }
}

String ellipsify({required String str, int? maxLength}) {
  maxLength ??= 10;
  if (maxLength % 2 != 0) maxLength++;
  if (str.length <= maxLength) return str;
  if (str.startsWith('0x')) {
    final eipData = Erc8117.fromAddress(str);
    if (eipData.unicode != null) return eipData.unicode!;
    if (eipData.ascii != null) return eipData.ascii!;
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
      now.difference(MyApp.lastCoinGeckoData).inSeconds;
  final bool useCached = secondsSinceLastFetch < secondsToResendRequest;

  final String defaultCurrency = pref.get(defaultCurrencyKey) ?? 'usd';
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
    final String vsCurrencies = pref.get(supportedCurrencyKey) ?? 'usd';

    final Uri apiUrl = Uri.parse(
      '$coinGeckoBaseurl/simple/price?ids=$allCrypto'
      '&vs_currencies=$vsCurrencies'
      '&include_24hr_change=true',
    );
    final response = await get(apiUrl).timeout(networkTimeOutDuration);

    if (response.statusCode >= 400) {
      throw Exception('CoinGecko Error: ${response.statusCode}');
    }

    MyApp.getCoinGeckoData = false;
    MyApp.lastCoinGeckoData = now;
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

Future<Result<EnsContentResult>> ensToContentHashAndIPFS({
  required String cryptoDomainName,
}) async {
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
        return Ok(EnsContentResult(
          url: ipfsTohttp(
            'ipfs://${bs58check.base58.encode(HEX.decode(match.group(1)!) as Uint8List)}',
          ),
        ));
      }
      return const Err('Invalid IPFS checksum');
    }

    if (swarmMatch != null) {
      if (swarmMatch.group(1)!.length == 32 * 2) {
        return Ok(EnsContentResult(url: 'bzz://${swarmMatch.group(2)!}'));
      }
      return const Err('Invalid SWARM checksum');
    }

    return const Err('Unrecognised ENS content hash format');
  } catch (e) {
    debugPrint('ensToContentHashAndIPFS: $e');
    return Err('Error resolving ENS content hash: $e');
  }
}

Future<Result<EnsAddressResult>> ensToAddr({
  required String domainName,
}) async {
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
    return Ok(EnsAddressResult(
      address: web3.EthereumAddress.fromHex(userAddress.toString()).hexEip55,
    ));
  } catch (e) {
    debugPrint('ensToAddr: $e');
    return Err('Error resolving ENS address: $e');
  }
}

// ─── NFTs ─────────────────────────────────────────────────────────────────────

Future<Result<NFTResult>> multivrNFT(
  String address, {
  required String multiversxApi,
  required bool useCache,
}) async {
  final tokenListKey = 'multiversnListKey_$address$multiversxApi';
  final tokenList = pref.get(tokenListKey);

  Result<NFTResult>? cached;
  if (tokenList != null) {
    cached = Ok(NFTResult(items: json.decode(tokenList) as List));
  }

  if (useCache) return cached ?? const Err('No cached NFT data');

  try {
    final response =
        await get(Uri.parse('$multiversxApi/accounts/$address/nfts'));
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception('HTTP ${response.statusCode}');
    }
    await pref.put(tokenListKey, response.body);
    return Ok(NFTResult(items: json.decode(response.body) as List));
  } catch (e) {
    debugPrint('multivrNFT: $e');
    return cached ?? Err('Failed to fetch MultiversX NFTs: $e');
  }
}

Future<Result<ERC20NFTResult>> erc20NFTs(
  int chainId,
  String address, {
  required bool useCache,
}) async {
  final tokenListKey = 'tokenListKey_$chainId-$address/__';
  final tokenList = pref.get(tokenListKey);

  Result<ERC20NFTResult>? cached;
  if (tokenList != null) {
    cached = Ok(
        ERC20NFTResult(data: json.decode(tokenList) as Map<String, dynamic>));
  }

  if (useCache) return cached ?? const Err('No cached ERC20 NFT data');

  final _alchemyBaseUrls = {
    1: 'https://eth-mainnet.g.alchemy.com/v2/$alchemyEthMainnetApiKey',
    5: 'https://eth-goerli.g.alchemy.com/v2/$alchemyEthGoerliApiKey',
    137: 'https://polygon-mainnet.g.alchemy.com/v2/$alchemyPolygonApiKey',
    80001: 'https://polygon-mumbai.g.alchemy.com/v2/$alchemyMumbaiApiKey',
    42161: 'https://arb-mainnet.g.alchemy.com/v2/$alchemyArbitriumApiKey',
  };

  final baseUrl = _alchemyBaseUrls[chainId];
  if (baseUrl == null) return Err('Unsupported chain ID: $chainId');

  try {
    final response = await get(Uri.parse('$baseUrl/getNFTs?owner=$address'));
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception('HTTP ${response.statusCode}');
    }
    await pref.put(tokenListKey, response.body);
    return Ok(ERC20NFTResult(
        data: json.decode(response.body) as Map<String, dynamic>));
  } catch (e) {
    debugPrint('erc20NFTs: $e');
    return cached ?? Err('Failed to fetch ERC20 NFTs: $e');
  }
}

Future<Map> get1InchUrlList(int chainId) async {
  final response = await http
      .get(Uri.parse('https://tokens.1inch.io/v1.1/$chainId'))
      .timeout(networkTimeOutDuration);
  return Map.from(json.decode(response.body));
}

// ─── WalletConnect ────────────────────────────────────────────────────────────

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

// ─── CryptoPrice ─────────────────────────────────────────────────────────────

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
