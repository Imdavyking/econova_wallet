import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/web_home/econova_web.dart';
import 'dart:convert';

import '../coins/ethereum_coin.dart';

// ── App identity ──────────────────────────────────────────────────────────────

const walletAbbr = 'ECA';
const walletName = 'Econova';
const walletURL = 'https://econova.vercel.app';
const walletIconURL = '$walletURL/img/logo.png';
const blockExplorerPlaceholder = '{{TransactionHash}}';

final base64Logo = base64Encode(logoBytes.buffer.asUint8List());

final browserUrl = Uri.dataFromString(
  walletHomePage,
  mimeType: 'text/html',
  encoding: Encoding.getByName('utf-8'),
).toString();

// ── Network toggle ────────────────────────────────────────────────────────────

/// Flip this to switch the entire app between mainnet and testnet.
/// Use [enableTestNet.value] to read, [enableTestNet.value = x] to write.
///
/// Example:
///   enableTestNet.value = true;  // → all chains switch to testnet
///   enableTestNet.value = false; // → all chains switch to mainnet
final _testNetNotifier = ValueNotifier<bool>(true);

// Public notifier for ValueListenableBuilder
ValueNotifier<bool> get testNetNotifier => _testNetNotifier;

// Bool getter/setter — use exactly like before
bool get enableTestNet => _testNetNotifier.value;
set enableTestNet(bool value) =>
    _testNetNotifier.value = value; // writes to notifier

// After
final coinListener = ValueNotifier<List<Coin>>([]);
final supportedChains = coinListener.value;
set supportedChains(List<Coin> value) =>
    coinListener.value = value; // writes to notifier

// ── API keys (loaded from .env) ───────────────────────────────────────────────

String get covalApiKey => dotenv.env['COVAL_API_KEY'] ?? '';
String get alchemyEthMainnetApiKey => dotenv.env['ALCHEMY_ETH_MAINNET'] ?? '';
String get alchemyEthGoerliApiKey => dotenv.env['ALCHEMY_ETH_GOERLI'] ?? '';
String get alchemyStarknetApiKey => dotenv.env['ALCHEMY_STRK_KEY'] ?? '';
String get alchemyArbitriumApiKey => dotenv.env['ALCHEMY_ARBITRUM'] ?? '';
String get alchemyMumbaiApiKey => dotenv.env['ALCHEMY_MUMBAI'] ?? '';
String get alchemyPolygonApiKey => dotenv.env['ALCHEMY_POLYGON'] ?? '';
String get rampApiKey => dotenv.env['RAMP_API_KEY'] ?? '';
String get bscApiKey => dotenv.env['BSC_API_KEY'] ?? '';
String get tronGridApiKey => dotenv.env['TRON_GRID_API_KEY'] ?? '';
String get infuraApiKey => dotenv.env['INFURA_API_KEY'] ?? '';
String get walletConnectKey => dotenv.env['WALLET_CONNECT_KEY'] ?? '';
String get coinMarketCapApiKey => dotenv.env['COIN_MARKET_CAP_KEY'] ?? '';
String get blastApiProjectId => dotenv.env['BLAST_API_PROJECT_ID'] ?? '';
String get utxoApiKey => dotenv.env['UTXO_API_KEY'] ?? '';
String get pureStakeApiKey => dotenv.env['PURE_STAKE_API_KEY'] ?? '';
String get nanoApiKey => dotenv.env['NANO_API_KEY'] ?? '';
String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

// ── External links ────────────────────────────────────────────────────────────

const fiatDexProviderUrl = 'https://buy.moonpay.com/?currencyCode=stx';
const walletDexProviderUrl =
    'https://app.alexlab.co/swap?base=token-wstx&quote=token-wusdc';
const stakeDexProviderUrl = 'https://app.alexlab.co/stake';

// dapp links
const blogUrl = 'https://www.stacks.co/blog';
const marketPlaceUrl = 'https://gamma.io/';
const stacksMarketUrl = 'http://localhost:3000/api/market';

// social media
const telegramLink = '';
const twitterLink = 'https://x.com/econova/';
const mediumLink = '';
const discordLink = '';
const instagramLink =
    'https://www.instagram.com/econova?igsh=ZTJidG9kNTQwemp1&utm_source=qr';

// ── Colors ────────────────────────────────────────────────────────────────────

const appPrimaryColor = Color.fromARGB(255, 43, 249, 215);
const appBackgroundblue = appPrimaryColor;
const appBackgroundblueDim = Color.fromARGB(140, 233, 185, 9);
const settingIconColor = Colors.white;
const dividerColor = Color(0xffE6E6E3);
const red = Color(0xffeb6a61);
const green = Color(0xff01aa78);
const grey = Colors.grey;
const colorForAddress = Color(0xffEBF3FF);
const portfolioCardColor = Color(0xFF4B4B4B);
const portfolioCardColorLowerSection = Color.fromARGB(255, 39, 39, 39);
const orangTxt = Colors.orange;
const orange1 = Color.fromARGB(255, 233, 183, 9);

const primaryMaterialColor = MaterialColor(
  0xff2469E9,
  <int, Color>{
    50: appPrimaryColor,
    100: appPrimaryColor,
    200: appPrimaryColor,
    300: appPrimaryColor,
    400: appPrimaryColor,
    500: appPrimaryColor,
    600: appPrimaryColor,
    700: appPrimaryColor,
    800: appPrimaryColor,
    900: appPrimaryColor,
  },
);

const alterPrimaryColor = MaterialColor(
  0xff2469E9,
  <int, Color>{
    50: appPrimaryColor,
    100: appPrimaryColor,
    200: appPrimaryColor,
    300: appPrimaryColor,
    400: appPrimaryColor,
    500: appPrimaryColor,
    600: appPrimaryColor,
    700: appPrimaryColor,
    800: appPrimaryColor,
    900: appPrimaryColor,
  },
);

// ── Security / storage keys ───────────────────────────────────────────────────

const secureStorageKey = 'box28aldk3qka';
const biometricsKey = 's3ialdkal3aksleidla83aidildilsiei83019';
const userUnlockPasscodeKey = 'userUnlockPasscode';
const languageKey = 'languageksks38q830qialdkjd';
const useBlockiesKey = 'skkeiealdkalD88Ad2204AD54B417e8a0CCs3eiasl';
const darkModekey = 'userTheme';
const hideBalanceKey = 'hideUserBalance';
const dappChainIdKey = 'dappBrowserChainIdKey';
const userSignInDataKey = 'user-sign-in-data';
const currentUserWalletNameKey = 'current__walletNameKey';
const coinGeckoCryptoPriceKey = 'cryptoPricesKey';
const bookMarkKey = 'bookMarks';
const historyKey = 'broswer_kehsi_history';
const newEVMChainKey = '5500a-8077-420a-a1cf-9aa7';
const appUnlockTime = 'applockksksietimeal382';
const supportedCurrencyKey = 'supportedCurrencies';
const defaultCurrencyKey = 'defaultCurrency';
const deadSwitchSaveKey = '9c840bf-95d0-8331-8148-eded0b9';

// ── Sign types ────────────────────────────────────────────────────────────────

const eIP681ProcessingErrorMsg =
    'Ethereum request format not supported or Network Time Out';
const personalSignKey = 'Personal';
const normalSignKey = 'Normal Sign';
const typedMessageSignKey = 'Typed Message';
const fallbackMessage =
    'Unspecified error message. This is a bug, please report it.';

// ── App limits ────────────────────────────────────────────────────────────────

const userPinTrials = 3;
const pinLength = 6;
const faLength = 6;
const maximumTransactionToSave = 30;
const maximumBrowserHistoryToSave = 20;
const swapSlippage = 10;

// ── Encryption ────────────────────────────────────────────────────────────────

final iv = encrypt.IV.fromLength(16);

// ── NFT helpers ───────────────────────────────────────────────────────────────

List getAlchemyNFTs(EthereumCoin ethCoin) {
  final allowedNFTNames = enableTestNet
      ? ['Polygon (Mumbai)', 'Ethereum(Goerli)']
      : ['Ethereum', 'Polygon Matic'];

  if (allowedNFTNames.contains(ethCoin.name)) return [ethCoin.name];
  return [];
}

// ── Theme ─────────────────────────────────────────────────────────────────────

final darkTheme = ThemeData(
  useMaterial3: true,
  dialogBackgroundColor: const Color.fromARGB(255, 26, 26, 26),
  fontFamily: 'Roboto',
  primaryColor: appPrimaryColor,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    unselectedItemColor: Colors.white,
    backgroundColor: Color.fromARGB(255, 47, 47, 47),
    selectedItemColor: appPrimaryColor,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 26, 26, 26),
  cardColor: const Color.fromARGB(255, 47, 47, 47),
  dividerColor: const Color.fromARGB(255, 57, 57, 57),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color.fromARGB(255, 26, 26, 26),
  ),
  cardTheme: const CardTheme(
    color: Color.fromARGB(255, 47, 47, 47),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color.fromARGB(255, 47, 47, 47),
    filled: true,
    iconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    prefixIconColor: Colors.grey,
    hintStyle: TextStyle(color: Colors.grey),
    labelStyle: TextStyle(color: Colors.grey),
    helperStyle: TextStyle(color: Colors.grey),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 47, 47, 47),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStateProperty.all(Colors.white),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
      .copyWith(
        secondary: Colors.white,
        brightness: Brightness.dark,
        surface: const Color.fromARGB(255, 47, 47, 47),
        onSurface: Colors.white,
      )
      .copyWith(surface: const Color.fromARGB(255, 26, 26, 26)),
);
