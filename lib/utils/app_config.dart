import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import '../coins/ethereum_coin.dart';

const walletAbbr = 'ECA';
const walletName = 'Econova';
const walletURL = "https://econova.vercel.app";
const walletIconURL = "$walletURL/img/logo.png";
const walletDexProviderUrl =
    'https://app.ekubo.org/?inputCurrency=USDC&outputCurrency=ETH&amount=-1';
const String fallbackMessage =
    "Unspecified error message. This is a bug, please report it.";
const stakeDexProviderUrl =
    'https://app.ekubo.org/?inputCurrency=USDC&outputCurrency=ETH&amount=-1';
const fiatDexProviderUrl = 'https://paxful.com/';
// const browserUrl = 'http://10.0.2.2:5500/lib/screens/demo.html';
const browserUrl =
    'https://sepolia.voyager.online/contract/0x07134aad6969880f11b2d50e57c6e8d38ceef3a6b02bd9ea44837bd257023f6b#readContract';
// const browserUrl = 'https://duckduckgo.com/';
const oneInchApi = "https://api.1inch.dev";
const oneInceApiKey = 'cc7YbgSI5NA9t5KGLa00uNdklhGFxJhi';

// dapp links
const blogUrl = "https://www.starknet.io/blog/";
const marketPlaceUrl = 'https://unframed.co/';

// social media links
const telegramLink = '';
const twitterLink = 'https://x.com/econova/';
const mediumLink = '';
const discordLink = '';
const instagramLink =
    'https://www.instagram.com/econova?igsh=ZTJidG9kNTQwemp1&utm_source=qr';

// color
const settingIconColor = Colors.white;
const dividerColor = Color(0xffE6E6E3);
const appPrimaryColor = Color.fromARGB(255, 43, 249, 215);
const red = Color(0xffeb6a61);
const green = Color(0xff01aa78);
const grey = Colors.grey;
const colorForAddress = Color(0xffEBF3FF);
const appBackgroundblue = appPrimaryColor;
const appBackgroundblueDim = Color.fromARGB(140, 233, 185, 9);
const portfolioCardColor = Color(0xFF4B4B4B);
const portfolioCardColorLowerSection = Color.fromARGB(255, 39, 39, 39);
const orangTxt = Colors.orange;

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

// security
const secureStorageKey = 'box28aldk3qka';
const alchemyEthMainnetApiKey = 'DyEtOvLwpEw43cr-lTgQWre7HfjPeUlq';
const alchemyEthGoerliApiKey = 's00aWtjDOmCnUYS7cFBFIL3fbVCzsc8Z';
const alchemyArbitriumApiKey = 'T2_T1IKID7xte8PYAhLK2FyCAu2lIcq-';
const alchemyMumbaiApiKey = 'gpR0c9Le2dR45Fqit9OXTz6dtpf1HPfa';
const alchemyPolygonApiKey = 'DtU0__wTk6KUpZElU8pYQRpaHK0b8mip';
const rampApiKey = '9842oj9c45xuzc93bm7zd7z4rn8cub3fs45decqh';
const bscApiKey = '2WQ9Q2TTNSMD5DJ7GJR8F7TAEMZUCNCI5B';
const tronGridApiKey = 'e09b6df9-0abc-4463-a623-43eaf291ef22';

List getAlchemyNFTs(EthereumCoin ethCoin) {
  List allowedNFTNames = [];

  if (enableTestNet) {
    allowedNFTNames.addAll([
      'Polygon (Mumbai)',
      'Ethereum(Goerli)',
    ]);
  } else {
    allowedNFTNames.addAll([
      'Ethereum',
      'Polygon Matic',
    ]);
  }

  if (allowedNFTNames.contains(ethCoin.name)) return [ethCoin.name];
  return [];
}

const infuraApiKey = '53163c736f1d4ba78f0a39ffda8d87b4';
const pureStakeApiKey = 'G322hXkYM4749xUANJXm02d6M98WvYjtaWeAgJ4m';
const walletConnectKey = "73801621aec60dfaa2197c7640c15858";

// settings key...not to be edited

final iv = encrypt.IV.fromLength(16);
const biometricsKey = 's3ialdkal3aksleidla83aidildilsiei83019';
const userUnlockPasscodeKey = 'userUnlockPasscode';
const languageKey = 'languageksks38q830qialdkjd';
const useBlockiesKey = 'skkeiealdkalD88Ad2204AD54B417e8a0CCs3eiasl';
const darkModekey = 'userTheme';
const hideBalanceKey = 'hideUserBalance';
const dappChainIdKey = 'dappBrowserChainIdKey';
const eIP681ProcessingErrorMsg =
    'Ethereum request format not supported or Network Time Out';
const personalSignKey = 'Personal';
const normalSignKey = 'Normal Sign';
const typedMessageSignKey = "Typed Message";
const userSignInDataKey = 'user-sign-in-data';
const currentUserWalletNameKey = 'current__walletNameKey';
const coinGeckoCryptoPriceKey = 'cryptoPricesKey';
const bookMarkKey = 'bookMarks';
const historyKey = 'broswer_kehsi_history';
const coinMarketCapApiKey = "c354e715-9e18-4fee-806d-ae32d38d5d5c";
const newEVMChainKey = '5500a-8077-420a-a1cf-9aa7';
const blastApiProjectId = '2f6ccf07-7b89-4bf4-be14-7a26f2eae72d';
const appUnlockTime = 'applockksksietimeal382';
// template tags
const blockExplorerPlaceholder = '{{TransactionHash}}';

// enable
bool enableTestNet = true;
const orange1 = Color.fromARGB(255, 233, 183, 9);

// app theme
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
  // cardColor: const Color.fromARGB(255, 26, 26, 26),
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
    // systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarBrightness: Brightness.dark,
    // ),
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

// final lightTheme = ThemeData(
//   useMaterial3: true,
//   appBarTheme: const AppBarTheme(
//     systemOverlayStyle: SystemUiOverlayStyle(
//       statusBarBrightness: Brightness.light,
//     ),
//   ),
//   fontFamily: 'Roboto',
//   primaryColor: Colors.white,
//   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//     type: BottomNavigationBarType.fixed,
//     backgroundColor: Color(0xffEBF3FF),
//     unselectedItemColor: Colors.grey,
//   ),
//   checkboxTheme: CheckboxThemeData(
//     fillColor: WidgetStateProperty.all(appPrimaryColor),
//     checkColor: WidgetStateProperty.all(appPrimaryColor),
//     overlayColor: WidgetStateProperty.all(appPrimaryColor),
//   ),
//   dividerColor: dividerColor,
//   colorScheme: ColorScheme.fromSwatch(
//     primarySwatch: alterPrimaryColor,
//   )
//       .copyWith(
//         secondary: Colors.black,
//         brightness: Brightness.light,
//       )
//       .copyWith(surface: const Color(0xFFE5E5E5)),
// );

// preferences keys and app data
const userPinTrials = 3;
const pinLength = 6;
const faLength = 6;
const maximumTransactionToSave = 30;
const maximumBrowserHistoryToSave = 20;
const swapSlippage = 10;

const oneInchHeaders = {
  'accept': 'application/json',
  'Authorization': 'Bearer $oneInceApiKey',
};
