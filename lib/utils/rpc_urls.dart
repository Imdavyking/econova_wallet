// ignore_for_file: unused_local_variable

import 'dart:convert' hide Encoding;
import 'dart:io';
import 'dart:math';
import 'package:wallet_app/utils/network_guard.dart';
import 'package:wallet_app/utils/starknet_call.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:blockchain_utils/blockchain_utils.dart' hide AES;
import 'package:near_api_flutter/near_api_flutter.dart' hide Account;
import 'package:on_chain/on_chain.dart' hide Permission;
import 'package:sui/utils/sha.dart';
import '../coins/near_coin.dart';
// ignore: implementation_imports, unused_import
import 'package:near_api_flutter/src/models/actions/dapp_function.dart'
    as near_borsh_dapp;
import '../model/near_trx_obj.dart' as near_obj;
import '../screens/google_fa/fa_details.dart';
import '../screens/google_fa/google_fa_screen_verify.dart';
import '../service/google_fa.dart';
import '../service/wallet_service.dart';
import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/screens/security.dart';
import 'package:wallet_app/utils/json_viewer.dart';
import 'package:eth_sig_util/util/utils.dart' hide hexToBytes, bytesToHex;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallet_app/utils/slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validators/validators.dart';

import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';

import '../coins/bitcoin_coin.dart';
import '../coins/fungible_tokens/erc_fungible_coin.dart';
import '../coins/ethereum_coin.dart';
import '../coins/multiversx_coin.dart';
import '../components/loader.dart';
import '../interface/coin.dart';
import '../model/seed_phrase_root.dart';
import '../screens/dapp.dart';
import 'abis.dart';
import 'all_coins.dart';
import 'alt_ens.dart';
import 'app_config.dart';

// crypto decimals

const satoshiDustAmount = 546;

// time
const Duration networkTimeOutDuration = Duration(seconds: 15);
const Duration httpPollingDelay = Duration(seconds: 15);

// extra seedValues.
late SeedPhraseRoot seedPhraseRoot;

// useful ether addresses
const zeroAddress = '0x0000000000000000000000000000000000000000';
const deadAddress = '0x000000000000000000000000000000000000dEaD';
const nativeTokenAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
const ensInterfaceAddress = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e';
const coinGeckoBaseurl = 'https://api.coingecko.com/api/v3';

// third party urls
const coinGeckoSupportedCurrencies =
    '$coinGeckoBaseurl/simple/supported_vs_currencies';

// abi's
solidityFunctionSig(String methodId) {
  return '0x${sha3(methodId).substring(0, 8)}';
}

Future<Map> multivrNFT(
  String address, {
  required String multiversxApi,
  required bool useCache,
}) async {
  final tokenListKey = 'multiversnListKey_$address$multiversxApi';

  final tokenList = pref.get(tokenListKey);
  Map userTokens = {
    'msg': 'could not fetch tokens',
    'success': false,
  };
  if (tokenList != null) {
    userTokens = {'msg': json.decode(tokenList) as List, 'success': true};
  }

  if (useCache) return userTokens;

  try {
    final url = '$multiversxApi/accounts/$address/nfts';

    final response = await get(Uri.parse(url));
    final responseBody = response.body;
    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      throw Exception(responseBody);
    }

    await pref.put(tokenListKey, response.body);
    return {'msg': json.decode(response.body), 'success': true};
  } catch (_) {
    if (kDebugMode) {
      print(_);
    }
    return userTokens;
  }
}

Future<Map> erc20NFTs(
  int chainId,
  String address, {
  required bool useCache,
}) async {
  final tokenListKey = 'tokenListKey_$chainId-$address/__';
  final tokenList = pref.get(tokenListKey);
  Map userTokens = {
    'msg': 'could not fetch tokens',
    'success': false,
  };
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
    final response = await get(
      Uri.parse(
        '$baseUrl/getNFTs?owner=$address',
      ),
    );
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
  uri = uri.replace(
    host: Platform.isAndroid ? '10.0.2.2' : '127.0.0.1',
  );
  return uri.toString();
}

Future<bool> authenticateIsAvailable() async {
  final localAuth = LocalAuthentication();
  final isAvailable = await localAuth.canCheckBiometrics;
  final isDeviceSupported = await localAuth.isDeviceSupported();
  return isAvailable && isDeviceSupported;
}

Future<bool> localAuthentication() async {
  if (!pref.get(biometricsKey, defaultValue: true)) {
    return false;
  }
  final localAuth = LocalAuthentication();
  bool didAuthenticate = false;
  if (await authenticateIsAvailable()) {
    didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Your authentication is needed.',
    );
  }

  return didAuthenticate;
}

Future<bool> authenticate(
  BuildContext context, {
  bool? useLocalAuth,
}) async {
  bool? didAuthenticate = false;
  await disEnableScreenShot();

  bool googleAuthEnabled = GoogleFA.haveOTPSecret;

  if (googleAuthEnabled) {
    FADetails faDetails = FADetails(secret: GoogleFA.getOTPSecret()!);
    didAuthenticate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => GoogleFAScreenVerify(faDetails: faDetails),
      ),
    );

    return didAuthenticate ??= false;
  }
  if (useLocalAuth ?? true && didAuthenticate == false) {
    didAuthenticate = await localAuthentication();
  }
  if (!didAuthenticate) {
    didAuthenticate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Security(
          isEnterPin: true,
          useLocalAuth: useLocalAuth,
        ),
      ),
    );
  }

  await enableScreenShot();

  return didAuthenticate ?? false;
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
  'Dec'
];

Future<void> reInstianteSeedRoot() async {
  WalletParams? params = WalletService.getActiveKey(WalletType.secretPhrase);
  if (params == null) return;
  seedPhraseRoot = await compute(seedFromMnemonic, params.data);
}

Future<web3.DeployedContract> getEnsResolverContract(
  String cryptoDomainName,
  web3.Web3Client client,
) async {
  cryptoDomainName = cryptoDomainName.trim();
  final nameHash_ = nameHash(cryptoDomainName);

  web3.DeployedContract ensInterfaceContract = web3.DeployedContract(
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
    final rpcUrl = evmFromChainId(1)!.rpc;
    final client = web3.Web3Client(rpcUrl, Client());
    final nameHash_ = nameHash(cryptoDomainName);
    web3.DeployedContract ensResolverContract =
        await getEnsResolverContract(cryptoDomainName, client);
    List<int> contentHashList = (await client.call(
      contract: ensResolverContract,
      function: ensResolverContract.function('contenthash'),
      params: [hexToBytes(nameHash_)],
    ))
        .first;

    String contentHash = bytesToHex(contentHashList);

    if (!contentHash.startsWith('0x')) {
      contentHash = "0x$contentHash";
    }
    final ipfsCIDRegex = RegExp(
        r'^0xe3010170(([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f]*))$');

    final swarmRegex = RegExp(r'^0xe40101fa011b20([0-9a-f]*)$');

    final match = ipfsCIDRegex.firstMatch(contentHash);
    final swarmMatch = swarmRegex.firstMatch(contentHash);
    if (match != null) {
      final length = int.parse(match.group(3)!, radix: 16);
      if (match.group(4)!.length == length * 2) {
        final decodedHash = match.group(1);
        return {
          'success': true,
          'msg': ipfsTohttp(
            "ipfs://${bs58check.base58.encode(HEX.decode(decodedHash!) as Uint8List)}",
          )
        };
      }
      throw Exception('invalid IPFS checksum');
    } else if (swarmMatch != null) {
      if (swarmMatch.group(1)!.length == (32 * 2)) {
        return {'success': true, 'msg': "bzz://${swarmMatch.group(2)!}"};
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

    final rpcUrl = evmFromChainId(1)!.rpc;
    final client = web3.Web3Client(rpcUrl, Client());
    final nameHash_ = nameHash(domainName);
    web3.DeployedContract ensResolverContract =
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

String _getKeys(String password) {
  final hash = sha256(utf8.encode(password));
  return base64.encode(hash);
}

String encryptText(String plainText, String password) {
  final aesEncrKey = encrypt.Key.fromBase64(_getKeys(password));
  final encrypter = Encrypter(AES(aesEncrKey));

  final encrypted = encrypter.encrypt(plainText, iv: iv);

  return encrypted.base64;
}

String decryptText(String encrypted, String password) {
  final aesEncrKey = encrypt.Key.fromBase64(_getKeys(password));
  final encrypter = Encrypter(AES(aesEncrKey));

  return encrypter.decrypt(Encrypted.fromBase64(encrypted), iv: iv);
}

Future<void> importAllKeys(String mnemonic) async {
  await Future.wait(
    supportedChains.map(
      (blockchain) => blockchain.importData(mnemonic),
    ),
  );
}

String getRampLink(String asset, String userAddress) {
  return 'https://app.ramp.network/?defaultAsset=$asset&fiatCurrency=USD&fiatValue=150.000000&hostApiKey=$rampApiKey&swapAsset=$asset&userAddress=$userAddress';
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

AbiDecodedResult? decodeAbi(String txData) {
  if (kDebugMode) {
    print('using flutter abi decoder');
  }
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
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}

Future<String> getCryptoPrice({bool useCache = false}) async {
  const int secondsToResendRequest = 15;

  final String? savedCryptoPrice = pref.get(coinGeckoCryptoPriceKey);
  final DateTime now = DateTime.now();
  final int secondsSinceLastFetch =
      now.difference(MyApp.lastcoinGeckoData).inSeconds;
  final bool useCached = secondsSinceLastFetch < secondsToResendRequest;

  // Return cached response if within cooldown or skipping network
  if ((useCached || useCache || !NetworkGuard().isConnected) &&
      savedCryptoPrice != null) {
    return json.decode(savedCryptoPrice)['data'];
  }

  try {
    final String defaultCurrency = pref.get('defaultCurrency') ?? "usd";

    if (!MyApp.getCoinGeckoData && savedCryptoPrice != null) {
      return json.decode(savedCryptoPrice)['data'];
    }
    final String allCrypto = coinGeckoIDs.join(',');

    final Uri apiUrl = Uri.parse(
      '$coinGeckoBaseurl/simple/price?ids=$allCrypto&vs_currencies=usd,$defaultCurrency&include_24hr_change=true',
    );

    final response = await get(apiUrl).timeout(networkTimeOutDuration);

    if (response.statusCode >= 400) {
      throw Exception("CoinGecko Error: ${response.statusCode}");
    }

    final responseBody = response.body;

    // Update cache and flags
    MyApp.getCoinGeckoData = false;
    MyApp.lastcoinGeckoData = now;

    await pref.put(
      coinGeckoCryptoPriceKey,
      json.encode({'data': responseBody}),
    );

    return responseBody;
  } catch (e, _) {
    if (savedCryptoPrice != null) {
      return json.decode(savedCryptoPrice)['data'];
    }
    throw Exception('Failed to get data from CoinGecko: $e');
  }
}

Future<String> getCurrencyJson() async {
  return currencyJsonSearch;
}

Future<double> totalCryptoBalance({
  required Map<String, dynamic> allCryptoPrice,
  required String defaultCurrency,
}) async {
  double totalBalance = 0.0;

  for (final coin in supportedChains) {
    try {
      if (WalletService.removeCoin(coin)) continue;
      final balance = await coin.getBalance(true);
      final geckoId = coin.getGeckoId();
      final priceData = allCryptoPrice[geckoId];

      if (priceData == null ||
          priceData[defaultCurrency.toLowerCase()] == null) {
        continue;
      }

      final price =
          (priceData[defaultCurrency.toLowerCase()] as num).toDouble();
      totalBalance += balance * price;
    } catch (e, stack) {
      // You can optionally log or report the error:
      debugPrint('Failed to calculate balance for ${coin.getGeckoId()}: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  return totalBalance;
}

Future<String?> upload(
  File imageFile,
  String imagefileName,
  MediaType imageMediaType,
  String uploadURL,
  Map fieldsMap,
) async {
  try {
    final stream = http.ByteStream(imageFile.openRead())..cast();
    final length = await imageFile.length();

    final uri = Uri.parse(uploadURL);

    final request = http.MultipartRequest("POST", uri);
    for (final key in fieldsMap.keys) {
      request.fields[key] = fieldsMap[key];
    }

    final multipartFile = http.MultipartFile(imagefileName, stream, length,
        filename: basename(imageFile.path), contentType: imageMediaType);

    request.files.add(multipartFile);
    StreamedResponse response = await request.send();
    Uint8List responseData = await response.stream.toBytes();
    String responseBody = String.fromCharCodes(responseData);

    if (response.statusCode ~/ 100 == 4 || response.statusCode ~/ 100 == 5) {
      if (kDebugMode) {
        print(responseBody);
      }
      throw Exception(responseBody);
    }
    return responseBody;
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
    return null;
  }
}

Uri blockChainToHttps(String? value) {
  if (value == null) return Uri.parse(walletURL);

  value = value.trim();

  value = localHostToIpAddress(value);

  if (value.startsWith('ipfs://')) return Uri.parse(ipfsTohttp(value));

  if (isURL(value)) {
    Uri url = Uri.parse(value);
    if (url.scheme.isEmpty) {
      url = url.replace(scheme: 'http');
    }
    return url;
  }

  Uri? url = Uri.tryParse(value);
  if (url != null && isLocalizedContent(url)) {
    return url;
  }
  return Uri.parse('https://www.google.com/search?q=$value');
}

Future<Map> get1InchUrlList(int chainId) async {
  final response = await http
      .get(Uri.parse('https://tokens.1inch.io/v1.1/$chainId'))
      .timeout(networkTimeOutDuration);

  Map jsonResponse = {};

  jsonResponse.addAll(Map.from(json.decode(response.body)));
  return jsonResponse;
}

EthereumCoin? evmFromSymbol(String symbol) {
  List<EthereumCoin> blockChains = getEVMBlockchains();
  for (int i = 0; i < blockChains.length; i++) {
    if (blockChains[i].symbol == symbol) {
      return blockChains[i];
    }
  }
  return null;
}

EthereumCoin? evmFromChainId(int chainId) {
  List<EthereumCoin> blockChains = getEVMBlockchains();
  for (int i = 0; i < blockChains.length; i++) {
    if (blockChains[i].chainId == chainId) {
      return blockChains[i];
    }
  }
  return null;
}

BitcoinCoin? bitcoinFromNetwork(NetworkType network) {
  List blockChains = getBitCoinPOSBlockchains();
  for (int i = 0; i < blockChains.length; i++) {
    if (blockChains[i]['POSNetwork'] == network) {
      return BitcoinCoin.fromJson(blockChains[i]);
    }
  }
  return null;
}

showDialogWithMessage({
  required BuildContext context,
  String? message,
  dynamic Function()? onConfirm,
  dynamic Function()? onCancel,
  Color? btnOkColor,
  Color? btnCancelColor,
}) async {
  final localization = AppLocalizations.of(context)!;
  await AwesomeDialog(
    closeIcon: const Icon(
      Icons.close,
    ),
    buttonsTextStyle: const TextStyle(color: Colors.white),
    context: context,
    btnOkColor: btnOkColor ?? appBackgroundblue,
    dialogType: DialogType.info,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: localization.info,
    desc: message,
    showCloseIcon: true,
    btnCancelColor: btnCancelColor,
    btnOkOnPress: onConfirm ?? () {},
    btnCancelOnPress: onCancel,
  ).show();
}

bool seqEqual(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

Future setupWebViewWalletBridge(
  int chainId,
  String rpc,
) async {
  await pref.put(dappChainIdKey, chainId);
  final data = WalletService.getActiveKey(walletImportType)!.data;
  final coin = evmFromChainId(chainId)!;
  final response = await coin.importData(data);

  final address = response.address;

  String twProvider = """
        (function() {
            const config = {
                ethereum: {
                    chainId: $chainId,
                    rpcUrl: "$rpc",  
                    address: "$address"
                },
                solana: {
                     cluster: "${solanaChains.first.rpc}",
                },
                aptos: {
                   network: "network",
                   chainId: "chainId"
                }
            };

            const strategy = 'CALLBACK';

            try {
                const core = trustwallet.core(strategy, (params) => {
                     // Disabled methods
                    if (params.name === 'wallet_requestPermissions') {
                        core.sendResponse(params.id, null);
                        return;
                    }

                    const interval = setInterval(() => {
                      if (isFlutterInAppWebViewReady) {
                        clearInterval(interval);
                        window.flutter_inappwebview.callHandler(
                          "CryptoHandler",
                          JSON.stringify({ ...params, url: window.location.origin })
                        );
                      }
                    }, 100);
                });

                // Generate instances
                const ethereum = trustwallet.ethereum(config.ethereum);
                const solana = trustwallet.solana(config.solana);
                const cosmos = trustwallet.cosmos();
                const aptos = trustwallet.aptos(config.aptos);
                const ton = trustwallet.ton();

                const walletInfo = {
                  deviceInfo: {
                    platform: 'iphone',
                    appName: 'trustwalletTon',
                    appVersion: "2",
                    maxProtocolVersion: 2,
                    features: [
                      'SendTransaction',
                      {
                        name: 'SendTransaction',
                        maxMessages: 4,
                      },
                    ],
                  },
                  walletInfo: {
                    name: 'Trust',
                    image: 'https://assets-cdn.trustwallet.com/dapps/trust.logo.png',
                    about_url: 'https://trustwallet.com/about-us',
                  },
                  isWalletBrowser: true,
                };

                const tonBridge = trustwallet.tonBridge(walletInfo, ton);

                core.registerProviders([ethereum, solana, cosmos, aptos, ton].map(provider => {
                  provider.sendResponse = core.sendResponse.bind(core);
                  provider.sendError = core.sendError.bind(core);
                  return provider;
                }));

                window.trustwalletTon = { tonconnect: tonBridge, provider: ton };

                // Custom methods
                ethereum.emitChainChanged = (chainId) => {
                  ethereum.setChainId('0x' + parseInt(chainId || '1').toString(16));
                  ethereum.emit('chainChanged', ethereum.getChainId());
                  ethereum.emit('networkChanged', parseInt(chainId || '1'));
                };

                ethereum.setConfig = (config) => {
                  ethereum.setChainId('0x' + parseInt(config.ethereum.chainId || '1').toString(16));
                  ethereum.setAddress(config.ethereum.address);
                    if (config.ethereum.rpcUrl) {
                      ethereum.setRPCUrl(config.ethereum.rpcUrl);
                    }
                };
                // End custom methods

                cosmos.mode = 'extension';
                cosmos.providerNetwork = 'cosmos';
                cosmos.isKeplr = true;
                cosmos.version = "0.12.106";

             

                // Attach to window
                trustwallet.ethereum = ethereum;
                trustwallet.solana = solana;
                trustwallet.cosmos = cosmos;
                trustwallet.TrustCosmos = trustwallet.cosmos;
                trustwallet.aptos = aptos;
                trustwallet.ton = ton;

                window.ethereum = trustwallet.ethereum;
                window.keplr = trustwallet.cosmos;
                window.aptos = trustwallet.aptos;
                window.ton = trustwallet.ton;

                const getDefaultCosmosProvider = (chainId) => {
                  return trustwallet.cosmos.getOfflineSigner(chainId);
                };

                window.getOfflineSigner = getDefaultCosmosProvider;
                window.getOfflineSignerOnlyAmino = getDefaultCosmosProvider;
                window.getOfflineSignerAuto = getDefaultCosmosProvider;

                Object.assign(window.trustwallet, {
                  isTrust: true,
                  isTrustWallet: true,
                  request: ethereum.request.bind(ethereum),
                  send: ethereum.send.bind(ethereum),
                  on: (...params) => ethereum.on(...params),
                  off: (...params) => ethereum.off(...params),
                });

                const provider = ethereum;
                const proxyMethods = ['chainId', 'networkVersion', 'address', 'enable', 'send'];

                // Attach properties to trustwallet object (legacy props)
                const proxy = new Proxy(window.trustwallet, {
                  get(target, prop, receiver) {
                    if (proxyMethods.includes(prop)) {
                      switch (prop) {
                        case 'chainId':
                          return ethereum.getChainId.bind(provider);
                        case 'networkVersion':
                          return ethereum.getNetworkVersion.bind(provider);
                        case 'address':
                          return ethereum.getAddress.bind(provider);
                        case 'enable':
                          return ethereum.enable.bind(provider);
                        case 'send':
                          return ethereum.send.bind(provider);
                      }
                    }

                    return Reflect.get(target, prop, receiver);
                  },
                });

                window.trustwallet = proxy;
                window.trustWallet = proxy;

                const EIP6963Icon =
                'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTgiIGhlaWdodD0iNjUiIHZpZXdCb3g9IjAgMCA1OCA2NSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTAgOS4zODk0OUwyOC44OTA3IDBWNjUuMDA0MkM4LjI1NDUgNTYuMzM2OSAwIDM5LjcyNDggMCAzMC4zMzUzVjkuMzg5NDlaIiBmaWxsPSIjMDUwMEZGIi8+CjxwYXRoIGQ9Ik01Ny43ODIyIDkuMzg5NDlMMjguODkxNSAwVjY1LjAwNDJDNDkuNTI3NyA1Ni4zMzY5IDU3Ljc4MjIgMzkuNzI0OCA1Ny43ODIyIDMwLjMzNTNWOS4zODk0OVoiIGZpbGw9InVybCgjcGFpbnQwX2xpbmVhcl8yMjAxXzY5NDIpIi8+CjxkZWZzPgo8bGluZWFyR3JhZGllbnQgaWQ9InBhaW50MF9saW5lYXJfMjIwMV82OTQyIiB4MT0iNTEuMzYxNSIgeTE9Ii00LjE1MjkzIiB4Mj0iMjkuNTM4NCIgeTI9IjY0LjUxNDciIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agb2Zmc2V0PSIwLjAyMTEyIiBzdG9wLWNvbG9yPSIjMDAwMEZGIi8+CjxzdG9wIG9mZnNldD0iMC4wNzYyNDIzIiBzdG9wLWNvbG9yPSIjMDA5NEZGIi8+CjxzdG9wIG9mZnNldD0iMC4xNjMwODkiIHN0b3AtY29sb3I9IiM0OEZGOTEiLz4KPHN0b3Agb2Zmc2V0PSIwLjQyMDA0OSIgc3RvcC1jb2xvcj0iIzAwOTRGRiIvPgo8c3RvcCBvZmZzZXQ9IjAuNjgyODg2IiBzdG9wLWNvbG9yPSIjMDAzOEZGIi8+CjxzdG9wIG9mZnNldD0iMC45MDI0NjUiIHN0b3AtY29sb3I9IiMwNTAwRkYiLz4KPC9saW5lYXJHcmFkaWVudD4KPC9kZWZzPgo8L3N2Zz4K';

                const info = {
                  uuid: crypto.randomUUID(),
                  name: 'Trust Wallet',
                  icon: EIP6963Icon,
                  rdns: 'com.trustwallet.app',
                };

                const announceEvent = new CustomEvent('eip6963:announceProvider', {
                  detail: Object.freeze({ info, provider: ethereum }),
                });

                window.dispatchEvent(announceEvent);

                window.addEventListener('eip6963:requestProvider', () => {
                   window.dispatchEvent(announceEvent);
                });
            } catch (e) {
              console.error(e)
            }
        })();
        """;

  print(twProvider);

  return '''
   (function() {

    let isFlutterInAppWebViewReady = false;
    window.addEventListener("flutterInAppWebViewPlatformReady", function (event) {
      isFlutterInAppWebViewReady = true;
      console.log("done and ready");
    });
 
   
    $twProvider


    nightly.postMessage = (json) => {
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "NightyHandler",
            JSON.stringify({...json,'url': window.location.origin})
          );
        }
      }, 100);
    }
    
    window.nightly = nightly;
    window.addEventListener("message", function (e) {
    if(e.data.target !== "erdw-inpage") return;
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "Multiversx",
            JSON.stringify({...e.data,'url': e.origin})
          );
        }
      }, 100);
    });
 
    window.elrondWallet = {'extensionId':"dngmlblcodfobpdpecaadgfbcggfjfnm"};
   

 window.starknet = {
  id: "argentX",
  name: "Argent X",
  eventName: "starknet-contentScript",
  icon: "data:image/svg+xml;base64,Cjxzdmcgd2lkdGg9IjQwIiBoZWlnaHQ9IjM2IiB2aWV3Qm94PSIwIDAgNDAgMzYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0yNC43NTgyIC0zLjk3MzY0ZS0wN0gxNC42MjM4QzE0LjI4NTEgLTMuOTczNjRlLTA3IDE0LjAxMzggMC4yODExNzggMTQuMDA2NCAwLjYzMDY4M0MxMy44MDE3IDEwLjQ1NDkgOC44MjIzNCAxOS43NzkyIDAuMjUxODkzIDI2LjM4MzdDLTAuMDIwMjA0NiAyNi41OTMzIC0wLjA4MjE5NDYgMjYuOTg3MiAwLjExNjczNCAyNy4yNzA5TDYuMDQ2MjMgMzUuNzM0QzYuMjQ3OTYgMzYuMDIyIDYuNjQwOTkgMzYuMDg3IDYuOTE3NjYgMzUuODc1NEMxMi4yNzY1IDMxLjc3MjggMTYuNTg2OSAyNi44MjM2IDE5LjY5MSAyMS4zMzhDMjIuNzk1MSAyNi44MjM2IDI3LjEwNTcgMzEuNzcyOCAzMi40NjQ2IDM1Ljg3NTRDMzIuNzQxIDM2LjA4NyAzMy4xMzQxIDM2LjAyMiAzMy4zMzYxIDM1LjczNEwzOS4yNjU2IDI3LjI3MDlDMzkuNDY0MiAyNi45ODcyIDM5LjQwMjIgMjYuNTkzMyAzOS4xMzA0IDI2LjM4MzdDMzAuNTU5NyAxOS43NzkyIDI1LjU4MDQgMTAuNDU0OSAyNS4zNzU5IDAuNjMwNjgzQzI1LjM2ODUgMC4yODExNzggMjUuMDk2OSAtMy45NzM2NGUtMDcgMjQuNzU4MiAtMy45NzM2NGUtMDdaIiBmaWxsPSIjRkY4NzVCIi8+Cjwvc3ZnPgo=",
  request: (args) => {
    const requestId = Math.random().toString(36).substr(2, 9);

    return window.starknet
      .callFlutterHandler({
        type: "request",
        requestId,
        args,
        url: window.location.origin,
      })
      .then(() => {
        return window.starknet.waitForResponse(requestId);
      });
  },

  callFlutterHandler: (payload) => {
    return new Promise((resolve, reject) => {
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          resolve();
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "StarknetHandler",
            JSON.stringify(payload)
          );
        }
      }, 100);
    });
  },

  waitForResponse: (requestId) => {
    console.log("waiting for response", requestId);
    return new Promise((resolve, reject) => {
      const handler = (event) => {
        try {
          const data = event.detail;
          if(typeof data.error !== 'undefined'){
            reject(new Error(data.error));
            return;
          }
          const requestType = data.requestType;
          const chainId = data.chainId;
          const address = data.address;
          switch(requestType){
            case 'wallet_requestAccounts':
              starknet.selectedAddress = address;
              starknet.chainId = data.chainId;
              starknet.isConnected = true;
              resolve([address]);
              break;
            case 'wallet_requestChainId':
              resolve(chainId);
              break;
            case 'wallet_deploymentData':
              resolve(data);
              break;
            case 'wallet_addInvokeTransaction':
              const txHash = data.txHash;
              console.log("txHash", txHash);
              resolve({
                transaction_hash: txHash,
              });
              break;
            case 'wallet_getPermissions':
              const permissions = data.permissions;
              console.log("permissions", permissions);
              resolve(permissions);
              break;
            case 'wallet_supportedSpecs':
              const specs = data.specs;
              console.log("specs", specs);
              resolve(specs);
              break;
            case 'wallet_addDeclareTransaction':
              const declareTx = data.txHash;
              const classHash = data.classHash;
              console.log("declareTx", declareTx);
              resolve({
                transaction_hash: declareTx,
                class_hash: classHash,
              });
              break;
            case 'wallet_signTypedData':
              const signature = data.signature;
              console.log("signature", signature);
              resolve(signature);
              break;
            default:
              reject(new Error("Invalid request type "+ requestType));
              break;
          }
        } catch (err) {
          console.error("error gotten", err);
          reject(new Error(err.toString()));
        } finally {
          window.removeEventListener(requestId, handler);
        }
      };

      window.addEventListener(requestId, handler);
    });
  },

  sendResponse: (requestId, payload) => {
    const customEvent = new CustomEvent(requestId, {
      detail: payload,
    });
    window.dispatchEvent(customEvent);
  },

  enable: () => {
    console.warn(
      "Warning: `enable()` is deprecated and may be removed in future versions. Please use `request({ type: 'wallet_requestAccounts' })` directly."
    );
    return window.starknet.request({
      type: "wallet_requestAccounts", 
    });
  },

  isPreauthorized: () => {
    return false;
  },
  on: (event, handler) => {
    window.starknet.callFlutterHandler({
      type: "on",
      event,
      url: window.location.origin,
    });

    window._starknetHandlers = window._starknetHandlers || {};
    window._starknetHandlers[event] = handler;
  },

  off: (event) => {
    window.starknet.callFlutterHandler({
      type: "off",
      event,
      url: window.location.origin,
    });

    if (window._starknetHandlers) {
      delete window._starknetHandlers[event];
    }
  },
};



 

    window.starknet_argentX = window.starknet;



  })();
''';
}

Future navigateToDappBrowser(
  BuildContext context,
  String data,
) async {
  List<EthereumCoin> evmChains = getEVMBlockchains();

  if (pref.get(dappChainIdKey) == null) {
    await pref.put(
      dappChainIdKey,
      evmChains[0].chainId,
    );
  }

  bool isActive = false;
  int chainId = pref.get(dappChainIdKey);
  for (int i = 0; i < evmChains.length; i++) {
    if (evmChains[i].chainId == chainId) {
      isActive = true;
      break;
    }
  }

  if (!isActive) {
    await pref.put(
      dappChainIdKey,
      evmChains[0].chainId,
    );
  }

  chainId = pref.get(dappChainIdKey);

  final coin = evmFromChainId(chainId)!;

  final init = await setupWebViewWalletBridge(
    chainId,
    coin.rpc,
  );

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Dapp(
        provider: '$provider;$nightly',
        webNotifier: webNotifer,
        init: init,
        data: data,
      ),
    ),
  );
}

Future addEthereumChain({
  context,
  required String jsonObj,
  onConfirm,
  onReject,
}) async {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  final localization = AppLocalizations.of(context)!;
  await slideUpPanel(
    context,
    Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localization.addNetwork,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          JsonViewer(json.decode(jsonObj)),
          const SizedBox(
            height: 20,
          ),
          ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (_, isLoading_, __) {
                if (isLoading_) {
                  return const Row(
                    children: [
                      Loader(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: appBackgroundblue,
                        ),
                        onPressed: () async {
                          if (await authenticate(context)) {
                            isLoading.value = true;
                            try {
                              await onConfirm();
                            } catch (_) {}
                            isLoading.value = false;
                          } else {
                            onReject();
                          }
                        },
                        child: Text(
                          localization.confirm,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: appBackgroundblue,
                        ),
                        onPressed: onReject,
                        child: Text(
                          localization.reject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    ),
    canDismiss: false,
  );
}

switchEthereumChain({
  context,
  EthereumCoin? switchChain,
  EthereumCoin? currentChain,
  onConfirm,
  onReject,
}) async {
  final localization = AppLocalizations.of(context)!;
  await slideUpPanel(
    context,
    Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localization.switchChainRequest,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: AssetImage(
                  currentChain!.getImage(),
                ),
              ),
              const Icon(
                Icons.arrow_right_alt_outlined,
              ),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                backgroundImage: AssetImage(
                  switchChain!.getImage(),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            localization.switchChainIdMessage(
              switchChain.getSymbol(),
              switchChain.chainId,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: appBackgroundblue,
                  ),
                  onPressed: onConfirm,
                  child: Text(
                    localization.confirm,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: appBackgroundblue,
                  ),
                  onPressed: onReject,
                  child: Text(
                    localization.reject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    canDismiss: false,
  );
}

connectWalletModal({
  required BuildContext context,
  String? url,
  String? authToken,
  required Function onConfirm,
  required Function()? onReject,
}) async {
  if (!context.mounted) return;
  final localization = AppLocalizations.of(context)!;
  ValueNotifier<bool> isSigning = ValueNotifier(false);
  await slideUpPanel(
    context,
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, bottom: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.close,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Text(
                    localization.connectedTo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          onReject!();
                        }
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            if (url != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.url,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      url,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            if (authToken != null && authToken.trim() != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.authToken,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      authToken,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ValueListenableBuilder<bool>(
                valueListenable: isSigning,
                builder: (_, isSigning_, __) {
                  if (isSigning_) {
                    return const Row(
                      children: [
                        Loader(),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: appBackgroundblue,
                          ),
                          onPressed: () async {
                            isSigning.value = true;
                            try {
                              await onConfirm();
                            } catch (_) {}
                            isSigning.value = false;
                          },
                          child: Text(
                            localization.confirm,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: appBackgroundblue,
                          ),
                          onPressed: onReject,
                          child: Text(
                            localization.reject,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    ),
    canDismiss: false,
  );
}

signMessage({
  required BuildContext context,
  String? data,
  String? networkIcon,
  String? name,
  required Function onConfirm,
  required Function()? onReject,
  required String messageType,
}) async {
  String? decoded = data;
  if (messageType == personalSignKey && data != null && isHexString(data)) {
    try {
      decoded = ascii.decode(txDataToUintList(data));
    } catch (_) {}
  }
  final localization = AppLocalizations.of(context)!;

  ValueNotifier<bool> isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, bottom: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.close,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Text(
                    localization.signMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          onReject!();
                        }
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            if (networkIcon != null)
              Container(
                height: 50.0,
                width: 50.0,
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CachedNetworkImage(
                  imageUrl: ipfsTohttp(networkIcon),
                  placeholder: (context, url) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Loader(
                          color: appPrimaryColor,
                        ),
                      )
                    ],
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            if (name != null)
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
              ),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    localization.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  children: [
                    if (messageType == typedMessageSignKey)
                      JsonViewer(
                        json.decode(decoded!),
                        fontSize: 16,
                      )
                    else
                      Text(
                        decoded!,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isSigning,
              builder: (_, isSigning_, __) {
                if (isSigning_) {
                  return const Row(
                    children: [
                      Loader(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: appBackgroundblue,
                        ),
                        onPressed: () async {
                          if (await authenticate(context)) {
                            isSigning.value = true;
                            try {
                              await onConfirm();
                            } catch (_) {}
                            isSigning.value = false;
                          } else {
                            onReject!();
                          }
                        },
                        child: Text(
                          localization.confirm,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: appBackgroundblue,
                        ),
                        onPressed: onReject,
                        child: Text(
                          localization.reject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
    canDismiss: false,
  );
}

signMultiversXTransaction({
  required Function()? onReject,
  String? gasPrice,
  String? gasLimit,
  required BuildContext context,
  required Function onConfirm,
  String? value_,
  String? txData,
  String? from,
  String? to,
  String? networkIcon,
  String? name,
  required String symbol,
  String? chainId,
  int? nonce,
}) async {
  List<int> data = [];
  if (txData != null) {
    try {
      data = base64.decode(txData);
    } catch (err) {
      data = txDataToUintList(txData);
    }
    txData = utf8.decode(data);
  }
  final localization = AppLocalizations.of(context)!;
  BigInt deciml = BigInt.from(pow(10, multiversxDecimals));

  double value = value_ == null ? 0 : BigInt.parse(value_) / deciml;

  ValueNotifier<bool> isSigning = ValueNotifier(false);
  bool hasTransaction = gasPrice != null && gasLimit != null;
  double transactionFee = 0;
  Decimal finalVal = Decimal.parse(value.toString());

  if (hasTransaction) {
    transactionFee = double.parse(gasPrice) * double.parse(gasLimit);
    transactionFee /= deciml.toDouble();
  }

  Decimal finalTranFee = Decimal.parse(transactionFee.toString());

  await slideUpPanel(
    context,
    DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Text(
                  localization.signTransaction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        onReject!();
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 50,
            child: TabBar(
              tabs: [
                Tab(
                    icon: Text(
                  "Details",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
                Tab(
                    icon: Text(
                  "Data",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
              ],
            ),
          ),

          // create widgets for each tab bar here
          Expanded(
            child: TabBarView(
              children: [
                // first tab bar view widget
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (networkIcon != null)
                          Container(
                            height: 50.0,
                            width: 50.0,
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CachedNetworkImage(
                              imageUrl: ipfsTohttp(networkIcon),
                              placeholder: (context, url) => const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Loader(
                                      color: appPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (name != null)
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                        if (from != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.from,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  from,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        if (to != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.receipientAddress,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  to,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        if (chainId != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.chainId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  chainId,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        if (nonce != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.nonce,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '$nonce',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.transactionAmount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '${finalVal.toString()} $symbol',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        if (hasTransaction)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.transactionFee,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${finalTranFee.toString()} $symbol',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ValueListenableBuilder<bool>(
                          valueListenable: isSigning,
                          builder: (_, isSigning_, __) {
                            if (isSigning_) {
                              return const Row(
                                children: [
                                  Loader(),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: appBackgroundblue,
                                    ),
                                    onPressed: () async {
                                      if (await authenticate(context)) {
                                        isSigning.value = true;
                                        try {
                                          await onConfirm();
                                        } catch (_) {}
                                        isSigning.value = false;
                                      } else {
                                        onReject!();
                                      }
                                    },
                                    child: Text(
                                      localization.confirm,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: appBackgroundblue,
                                    ),
                                    onPressed: onReject,
                                    child: Text(
                                      localization.reject,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            "Data",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          children: [
                            Text(
                              txData!,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    canDismiss: false,
  );
}

signEVMTransaction({
  required Function()? onReject,
  String? gasPriceInWei_,
  required BuildContext context,
  required Function onConfirm,
  String? valueInWei_,
  String? gasInWei_,
  String? txData,
  required String from,
  String? to,
  String? networkIcon,
  String? name,
  String? symbol,
  String? title,
  required int chainId,
}) async {
  final coin = evmFromChainId(chainId)!;

  final _wcClient = web3.Web3Client(
    coin.rpc,
    Client(),
  );
  final localization = AppLocalizations.of(context)!;
  double value = valueInWei_ == null ? 0 : BigInt.parse(valueInWei_).toDouble();

  double gasPrice =
      gasPriceInWei_ == null ? 0 : BigInt.parse(gasPriceInWei_).toDouble();
  txData ??= '0x';

  double userBalance = 0;

  Uint8List trxDataList = txDataToUintList(txData);
  double transactionFee = 0;
  String message = '';

  final AbiDecodedResult? decodedFunction = decodeAbi(txData);

  final String? decodedName = decodedFunction?.name;

  String info = localization.info;

  ValueNotifier<bool> isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Text(
                  localization.signTransaction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        onReject!();
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 50,
            child: TabBar(
              tabs: [
                Tab(
                  icon: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt,
                    ),
                  ),
                ),
                Tab(
                    icon: Text(
                  "Data",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
                Tab(
                  icon: Text(
                    "Hex",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt),
                  ),
                ),
              ],
            ),
          ),

          // create widgets for each tab bar here
          Expanded(
            child: TabBarView(
              children: [
                // first tab bar view widget
                FutureBuilder(future: () async {
                  final bal =
                      await _wcClient.getBalance(EthereumAddress.fromHex(from));
                  userBalance = bal.getInWei.toDouble();

                  transactionFee = await getEtherTransactionFee(
                    coin.rpc,
                    trxDataList,
                    web3.EthereumAddress.fromHex(from),
                    to == null ? null : web3.EthereumAddress.fromHex(to),
                    value: value,
                    gasPrice: web3.EtherAmount.inWei(
                      BigInt.from(
                        gasPrice,
                      ),
                    ),
                  );
                  if (decodedFunction == null) return true;

                  final List decodedResult = decodedFunction.decodedInputs;

                  if (decodedName == 'safeBatchTransferFrom') {
                    String _sender = '${decodedResult[0]}';
                    String _receiver = '${decodedResult[1]}';

                    List<dynamic> _nftIds = decodedResult[2];
                    List<dynamic> _nftAmounts = decodedResult[3];

                    BigInt totalAmount = BigInt.zero;
                    for (var amount in _nftAmounts) {
                      totalAmount += amount;
                    }

                    String nftOrNfts =
                        totalAmount == BigInt.one ? 'NFT' : 'NFTs';

                    // Prepare token IDs string
                    String tokenIdsString = _nftIds.join(', ');

                    message =
                        "$totalAmount $nftOrNfts (IDs: $tokenIdsString) would be sent from $_sender to $_receiver.";
                  } else if (decodedName == 'safeTransferFrom') {
                    String _sender = '${decodedResult[0]}';
                    String _receiver = '${decodedResult[1]}';
                    String _tokenId = '${decodedResult[2]}';

                    message =
                        "Transfer NFT $_tokenId ($to) from $_sender to $_receiver";
                  } else if (decodedName == 'approve') {
                    String _spender = '${decodedResult[0]}';
                    BigInt _tokenAmt = decodedResult[1];
                    final ftCoin = ERCFungibleCoin(
                      contractAddress_: to!,
                      geckoID: '',
                      rpc: coin.rpc,
                      blockExplorer: coin.blockExplorer,
                      chainId: coin.chainId,
                      coinType: coin.coinType,
                      image: '',
                      default_: coin.default_,
                      mintDecimals: 18,
                      name: '',
                      symbol: '',
                    );
                    final tokenDetails = await ftCoin.getERC20Meta();
                    final decimals = tokenDetails!.decimals;

                    final _amount = _tokenAmt / BigInt.from(pow(10, decimals));

                    message =
                        "Allow $_spender to spend $_amount ${tokenDetails.symbol} ($to)";
                  } else if (decodedName == 'transfer') {
                    String _recipient = '${decodedResult[0]}';
                    BigInt _tokenAmt = decodedResult[1];
                    final ftCoin = ERCFungibleCoin(
                      contractAddress_: to!,
                      rpc: coin.rpc,
                      blockExplorer: coin.blockExplorer,
                      chainId: coin.chainId,
                      coinType: coin.coinType,
                      image: '',
                      default_: coin.default_,
                      mintDecimals: 18,
                      name: '',
                      symbol: '',
                      geckoID: '',
                    );
                    final tokenDetails = await ftCoin.getERC20Meta();
                    final decimals = tokenDetails!.decimals;
                    final amount = _tokenAmt / BigInt.from(pow(10, decimals));
                    message =
                        "Transfer $amount ${tokenDetails.symbol} ($to) to $_recipient";
                  } else if (decodedName == 'transferFrom') {
                    String _sender = '${decodedResult[0]}';
                    String _recipient = '${decodedResult[1]}';
                    BigInt _tokenAmt = decodedResult[2];

                    final ftCoin = ERCFungibleCoin(
                      contractAddress_: to!,
                      geckoID: '',
                      rpc: coin.rpc,
                      blockExplorer: coin.blockExplorer,
                      chainId: coin.chainId,
                      coinType: coin.coinType,
                      image: '',
                      default_: coin.default_,
                      mintDecimals: 18,
                      name: '',
                      symbol: '',
                    );
                    final tokenDetails = await ftCoin.getERC20Meta();
                    final decimals = tokenDetails!.decimals;
                    final amount = _tokenAmt / BigInt.from(pow(10, decimals));
                    message =
                        "Transfer $amount ${tokenDetails.symbol} ($to) from $_sender to $_recipient";
                  }

                  return true;
                }(), builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localization.couldNotFetchData,
                          style: const TextStyle(fontSize: 16.0),
                        )
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Loader(),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25, bottom: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (networkIcon != null)
                            Container(
                              height: 50.0,
                              width: 50.0,
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: ipfsTohttp(networkIcon),
                                placeholder: (context, url) => const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Loader(
                                        color: appPrimaryColor,
                                      ),
                                    )
                                  ],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (name != null)
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          if (message != '')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    message,
                                    style: const TextStyle(fontSize: 16.0),
                                  )
                                ],
                              ),
                            ),
                          if (to != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.receipientAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    to,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.balance,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${userBalance / pow(10, etherDecimals)} $symbol',
                                  style: const TextStyle(fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.transactionAmount,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '${value / pow(10, etherDecimals)} $symbol',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localization.transactionFee,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      '${transactionFee / pow(10, etherDecimals)} $symbol',
                                      style: const TextStyle(fontSize: 16.0),
                                    )
                                  ],
                                ),
                              ),
                              if (transactionFee + value > userBalance)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localization.insufficientBalance,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: red,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: isSigning,
                              builder: (_, isSigning_, __) {
                                if (isSigning_) {
                                  return const Row(
                                    children: [
                                      Loader(),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: appBackgroundblue,
                                        ),
                                        onPressed: () async {
                                          if (await authenticate(context)) {
                                            isSigning.value = true;
                                            try {
                                              await onConfirm();
                                            } catch (_) {}
                                            isSigning.value = false;
                                          } else {
                                            onReject!();
                                          }
                                        },
                                        child: Text(
                                          localization.confirm,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: appBackgroundblue,
                                        ),
                                        onPressed: onReject,
                                        child: Text(
                                          localization.reject,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                  );
                }),

                // second tab bar viiew widget
                if (decodedFunction != null)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25, bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            localization.functionType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            decodedFunction.methodId,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // for (var key in decodedFunction.decodedInputs)
                          //   Column(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         key,
                          //         style: const TextStyle(
                          //           fontSize: 16.0,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 5.0),
                          //       Text(
                          //         '$key',
                          //         style: const TextStyle(
                          //           fontSize: 16.0,
                          //         ),
                          //       ),
                          //       const SizedBox(
                          //         height: 10,
                          //       )
                          //     ],
                          //   ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            "Hex",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          children: [
                            Text(
                              txData,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    canDismiss: false,
  );
}

signStarkNetTransaction({
  required Function()? onReject,
  required BuildContext context,
  required Function onConfirm,
  required String from,
  required List<StarknetCall> dapCalls,
  String? networkIcon,
  String? name,
  String? symbol,
  String? title,
}) async {
  final localization = AppLocalizations.of(context)!;

  String info = localization.info;

  ValueNotifier<bool> isSigning = ValueNotifier(false);

  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Text(
                  localization.signTransaction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        onReject!();
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 50,
            child: TabBar(
              tabs: [
                Tab(
                  icon: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt,
                    ),
                  ),
                ),
                Tab(
                    icon: Text(
                  "Data",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
                Tab(
                  icon: Text(
                    "Hex",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: orangTxt),
                  ),
                ),
              ],
            ),
          ),

          // create widgets for each tab bar here
          Expanded(
            child: TabBarView(
              children: [
                // first tab bar view widget
                FutureBuilder(future: () async {
                  return true;
                }(), builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localization.couldNotFetchData,
                          style: const TextStyle(fontSize: 16.0),
                        )
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Loader(),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25, bottom: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (networkIcon != null)
                            Container(
                              height: 50.0,
                              width: 50.0,
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: ipfsTohttp(networkIcon),
                                placeholder: (context, url) => const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Loader(
                                        color: appPrimaryColor,
                                      ),
                                    )
                                  ],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (name != null)
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 10),
                                child: StarknetCallList(dapCalls: dapCalls),
                              ),
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                              valueListenable: isSigning,
                              builder: (_, isSigning_, __) {
                                if (isSigning_) {
                                  return const Row(
                                    children: [
                                      Loader(),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: appBackgroundblue,
                                        ),
                                        onPressed: () async {
                                          if (await authenticate(context)) {
                                            isSigning.value = true;
                                            try {
                                              await onConfirm();
                                            } catch (_) {}
                                            isSigning.value = false;
                                          } else {
                                            onReject!();
                                          }
                                        },
                                        child: Text(
                                          localization.confirm,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: appBackgroundblue,
                                        ),
                                        onPressed: onReject,
                                        child: Text(
                                          localization.reject,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ],
                      ),
                    ),
                  );
                }),

                // second tab bar viiew widget

                Container(),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            "Hex",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          children: [
                            Text(
                              ' txData',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    canDismiss: false,
  );
}

class _NearUiAmount {
  final BigInt nearAmount;
  final double tokenAmount;
  final String message;
  final String? functionName;
  const _NearUiAmount({
    required this.nearAmount,
    required this.tokenAmount,
    required this.message,
    this.functionName,
  });
}

List<Widget> _buildNearActionUi({
  required near_obj.NearDappTrx txData,
  required AppLocalizations localization,
  required NearCoin coin,
}) {
  return txData.actions.map((near_obj.Action action) {
    final actionType = ActionType.getByValue(action.value);

    return FutureBuilder<_NearUiAmount>(
      future: () async {
        String functionName = '';
        BigInt nearAmout = BigInt.zero;
        double tokenAmount = 0;
        String message = '';
        if (action is near_obj.Transfer) {
          nearAmout = action.deposit;
        } else if (action is near_obj.FunctionCall) {
          nearAmout = action.deposit;
          functionName = '(${action.methodName})';

          if (action.methodName == 'ft_transfer') {
            action.args;

            final functionArgs = json.decode(ascii.decode(action.args));

            final metaData = await coin.getMetaData(txData.receiverId);
            tokenAmount = BigInt.parse(functionArgs['amount']) /
                BigInt.from(10).pow(metaData!.decimals);

            message =
                "Transfer $tokenAmount ${metaData.symbol} (${txData.receiverId}) to ${functionArgs['receiver_id']}";
          }
        } else if (action is near_obj.Stake) {
          nearAmout = action.stake;
        }
        return _NearUiAmount(
          nearAmount: nearAmout,
          tokenAmount: tokenAmount,
          message: message,
          functionName: functionName,
        );
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localization.couldNotFetchData,
                style: const TextStyle(fontSize: 16.0),
              )
            ],
          );
        }
        if (!snapshot.hasData) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loader(),
            ],
          );
        }
        final data = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.action,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${actionType.name} ${data.functionName ?? ''}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                localization.amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${data.nearAmount / BigInt.from(10).pow(nearDecimals)} NEAR',
                style: const TextStyle(fontSize: 16.0),
              ),
              if (action is near_obj.FunctionCall)
                if (action.methodName == 'ft_transfer') ...[
                  const SizedBox(height: 8.0),
                  Text(
                    localization.info,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    data.message,
                    style: const TextStyle(fontSize: 16.0),
                  )
                ],
            ],
          ),
        );
      },
    );
  }).toList();
}

signNearTransaction({
  required Function()? onReject,
  required BuildContext context,
  required Function onConfirm,
  required NearCoin coin,
  required near_obj.NearDappTrx txData,
  required String from,
  String? networkIcon,
  String? name,
  required String symbol,
}) async {
  double userBalance = 0;

  Uint8List trxDataList = Uint8List.fromList([]);
  double transactionFee = 0;

  final localization = AppLocalizations.of(context)!;

  String info = localization.info;

  ValueNotifier<bool> isSigning = ValueNotifier(false);
  slideUpPanel(
    context,
    DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Text(
                  localization.signTransaction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        onReject!();
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 50,
            child: TabBar(
              tabs: [
                Tab(
                    icon: Text(
                  "Details",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
                Tab(
                    icon: Text(
                  "Data",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
                Tab(
                    icon: Text(
                  "Hex",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: orangTxt),
                )),
              ],
            ),
          ),

          // create widgets for each tab bar here
          Expanded(
            child: TabBarView(
              children: [
                // first tab bar view widget
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (networkIcon != null)
                          Container(
                            height: 50.0,
                            width: 50.0,
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CachedNetworkImage(
                              imageUrl: ipfsTohttp(networkIcon),
                              placeholder: (context, url) => const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Loader(
                                      color: appPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (name != null)
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.from,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                txData.signerId,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.receipientAddress,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                txData.receiverId,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.nonce,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '${txData.nonce}',
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        ..._buildNearActionUi(
                          txData: txData,
                          localization: localization,
                          coin: coin,
                        ),
                        ValueListenableBuilder<bool>(
                            valueListenable: isSigning,
                            builder: (_, isSigning_, __) {
                              if (isSigning_) {
                                return const Row(
                                  children: [
                                    Loader(),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: appBackgroundblue,
                                      ),
                                      onPressed: () async {
                                        if (await authenticate(context)) {
                                          isSigning.value = true;
                                          try {
                                            await onConfirm();
                                          } catch (_) {}
                                          isSigning.value = false;
                                        } else {
                                          onReject!();
                                        }
                                      },
                                      child: Text(
                                        localization.confirm,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: appBackgroundblue,
                                      ),
                                      onPressed: onReject,
                                      child: Text(
                                        localization.reject,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                ),

                const SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25, bottom: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25, bottom: 25),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            "Hex",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          children: [
                            Text(
                              txData.encoded != null
                                  ? HEX.encode(txData.encoded!)
                                  : '0x',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    canDismiss: false,
  );
}

class StructReader {
  StructReader(this._buffer) : _offset = 0;

  void skip(int length) => _offset += length;

  String nextString() {
    final length = _buffer.asByteData(_offset, 4).getInt32(0, Endian.little);
    final rawBytes = _buffer.asUint8List(_offset + 4, length);

    _offset += length + 4;
    // It is a zero terminated string a'la C
    final lastZero = rawBytes.indexOf(0);
    if (lastZero == -1) {
      return '';
    }

    return utf8.decode(rawBytes.sublist(0, lastZero));
  }

  Uint8List nextBytes(int length) {
    final bytes = _buffer.asUint8List(_offset, length);
    _offset += length;

    return bytes;
  }

  final ByteBuffer _buffer;
  int _offset;
}

class _SolanaSimuRes {
  final double fee;
  final List<String> result;

  const _SolanaSimuRes({
    required this.fee,
    required this.result,
  });
}

Uint8List txDataToUintList(String txData) {
  return isHexString(txData) ? hexToBytes(txData) : ascii.encode(txData);
}

String ellipsify({required String str, int? maxLength}) {
  maxLength ??= 10;
  if (maxLength % 2 != 0) {
    maxLength++;
  }
  if (str.length <= maxLength) return str;
  // get first four and last four characters
  final first = str.substring(0, maxLength ~/ 2);
  final last = str.substring((str.length - maxLength / 2).toInt(), str.length);
  return '$first...$last';
}

Future<void> enableScreenShot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.clearFlags(
      FlutterWindowManager.FLAG_SECURE,
    );
  }
}

Future<void> disEnableScreenShot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(
      FlutterWindowManager.FLAG_SECURE,
    );
  }
}

selectImage({
  required BuildContext context,
  required Function(XFile) onSelect,
}) {
  final localization = AppLocalizations.of(context)!;
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    closeIcon: const Icon(
      Icons.close,
    ),
    title: localization.chooseImageSource,
    desc: localization.imageSource,
    showCloseIcon: true,
    btnOkText: localization.gallery,
    btnCancelText: localization.camera,
    btnCancelOnPress: () async {
      XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
      if (file == null) return;
      onSelect(file);
    },
    btnCancelColor: Colors.blue,
    btnOkColor: Colors.blue,
    btnOkOnPress: () async {
      XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      onSelect(file);
    },
  ).show();
}

web3.Transaction wcEthTxToWeb3Tx(WCEthereumTransaction ethereumTransaction) {
  return web3.Transaction(
    from: EthereumAddress.fromHex(
      ethereumTransaction.from,
    ),
    to: ethereumTransaction.to == null
        ? null
        : EthereumAddress.fromHex(
            ethereumTransaction.to!,
          ),
    maxGas: ethereumTransaction.gasLimit != null
        ? int.tryParse(
            ethereumTransaction.gasLimit!,
          )
        : null,
    gasPrice: ethereumTransaction.gasPrice != null
        ? EtherAmount.inWei(
            BigInt.parse(
              ethereumTransaction.gasPrice!,
            ),
          )
        : null,
    value: EtherAmount.inWei(
      BigInt.parse(
        ethereumTransaction.value ?? '0',
      ),
    ),
    data: ethereumTransaction.data == null
        ? null
        : hexToBytes(ethereumTransaction.data!),
    nonce: ethereumTransaction.nonce != null
        ? int.tryParse(ethereumTransaction.nonce!)
        : null,
  );
}

bool isLocalizedContent(Uri url) {
  return (url.scheme == "file" ||
      url.scheme == "chrome" ||
      url.scheme == "data" ||
      url.scheme == "javascript" ||
      url.scheme == "about");
}

bool urlIsSecure(Uri url) {
  return (url.scheme == "https") || isLocalizedContent(url);
}

Future<String?> downloadFile(String url, [String? filename]) async {
  var hasStoragePermission = await Permission.storage.isGranted;
  if (!hasStoragePermission) {
    final status = await Permission.storage.request();
    hasStoragePermission = status.isGranted;
  }
  if (hasStoragePermission) {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {},
      savedDir: (await getTemporaryDirectory()).path,
      saveInPublicStorage: true,
      fileName: filename,
    );
    return taskId;
  }
  return null;
}
