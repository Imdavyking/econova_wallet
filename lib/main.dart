// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_device/safe_device.dart';
import 'package:wallet_app/coins/aptos_coin.dart';
import 'package:wallet_app/coins/cardano_coin.dart';
import 'package:wallet_app/coins/legacy_utxo_coin.dart';
import 'package:wallet_app/coins/nano_coin.dart';
import 'package:wallet_app/coins/tezos_coin.dart';
import 'package:wallet_app/coins/algorand_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/cosmos_fungible_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/erc_fungible_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/fuse_4337_ft.dart';
import 'package:wallet_app/coins/fungible_tokens/stack_ft_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/starknet_fungible_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/polkadot_ft_coin.dart';
import 'package:wallet_app/coins/fuse_4337_coin.dart';
import 'package:wallet_app/coins/segwit_coin.dart';
import 'package:wallet_app/coins/stack_coin.dart';
import 'package:wallet_app/coins/icp_coin.dart';
import 'package:wallet_app/coins/icon_coin.dart';
import 'package:wallet_app/coins/starknet_coin.dart';
import 'package:wallet_app/coins/wave_coin.dart';
import 'package:wallet_app/coins/ontology_coin.dart';
import 'package:wallet_app/coins/polkadot_coin.dart';
import 'package:wallet_app/coins/cosmos_coin.dart';
import 'package:wallet_app/coins/xrp_coin.dart';
import 'package:wallet_app/coins/tron_coin.dart';
import 'package:wallet_app/coins/filecoin_coin.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/wordlist.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../service/wallet_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:wallet_app/screens/navigator_service.dart';
import 'package:wallet_app/screens/open_app_pin_failed.dart';
import 'package:wallet_app/screens/security.dart';
import 'package:wallet_app/screens/wallet.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/web_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'coins/fungible_tokens/esdt_ft_coin.dart';
import 'coins/fungible_tokens/ton_fungible_coins.dart';
import 'coins/fungible_tokens/tron_fungible_coin.dart';
import 'coins/evmhrp_coin.dart';
import 'coins/multiversx_coin.dart';
import 'coins/fungible_tokens/near_fungible_coin.dart';
import 'coins/ronin_coin.dart';
import 'coins/fungible_tokens/spl_token_coin.dart';
import 'coins/sui_coin.dart';
import 'coins/ton_coin.dart';
import 'coins/zilliqa_coin.dart';
import 'data_structures/trie.dart';
import 'interface/coin.dart';
import 'screens/main_screen.dart';
import '../coins/ethereum_coin.dart';
import '../coins/near_coin.dart';
import '../coins/solana_coin.dart';
import '../coins/stellar_coin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late String currencyJson;
late String currencyJsonSearch;
late String trustWalletProvider;
late String leatherWalletProvider;
late String nightly;
late String webNotifer;
List<T> getChains<T extends Coin>() {
  List<Coin> all = [
    ...getNanoBlockChains(),
    ...getWavesBlockChains(),
    ...getOntologyBlockChains(),
    ...getESDTCoins(),
    ...getIconBlockChains(),
    ...getPolkadotFungibleCoins(),
    ...getTonFungibleCoins(),
    ...getCardanoBlockChains(),
    ...getTonBlockChains(),
    ...getEVMBlockchains(),
    ...getNearBlockChains(),
    ...getTronBlockchains(),
    ...getSolanaBlockChains(),
    ...getEGLDBlockchains(),
    ...getCosmosFungibleCoins(),
    ...getNearFungibles(),
    ...getICPBlockchains(),
    ...getFUSEBlockchains(),
    ...getZilliqaBlockChains(),
    ...getEVMHrpBlockchains(),
    ...getStellarBlockChains(),
    ...getSuiBlockChains(),
    ...getRoninBlockchains(),
    ...getTezosBlockchains(),
    ...getAlgorandBlockchains(),
    ...getFUSEFTBlockchains(),
    ...getLegacyUtxoCoins(),
    ...getSplTokens(),
    ...getERC20Coins(),
    ...getCosmosBlockChains(),
    ...getFilecoinBlockChains(),
    ...getStarknetBlockchains(),
    ...getXRPBlockChains(),
    ...getPolkadoBlockChains(),
    ...getAptosBlockchain(),
    ...getStarknetFungibleCoins(),
    ...getTronFungibleCoins(),
    ...getStacksBlockchains(),
    ...getSIP010Coins(),
    ...getSegwitCoins(),
  ];

  return (T == Coin ? all : all.whereType<T>().toList()) as List<T>;
}

Future<List<T>> getChainsSortedByBalance<T extends Coin>() async {
  final coins = getChains<T>();
  final cryptoPrice = await getCryptoPrice(useCache: true);

  final balances = await Future.wait(
    coins.map((coin) async {
      final balance = await coin.getBalance(true);
      final price = cryptoPrice.getPrice(coin.getGeckoId()) ?? 0;
      return MapEntry(coin, balance * price);
    }),
    eagerError: false,
  );

  balances.sort((a, b) => b.value.compareTo(a.value));

  return balances.map((e) => e.key).toList();
}

late Box pref;
final mnemonicSuggester = Trie();
late WalletType walletImportType;
late ByteData logoBytes;

// DO NOT USE (public)
const testMnemonic2 =
    'express crane road good warm suggest genre organ cradle tuition strike manual'; // do not use it in production
const testMnemonic1 =
    'test test test test test test test test test test test junk'; // do not use it in production
const bip39SeedHex1 =
    '9dfc3c64c2f8bede1533b6a79f8570e5943e0b8fd1cf77107adf7b72cef42185d564a3aee24cab43f80e3c4538087d70fc824eabbad596a23c97b6ee8322ccc0';
const bip39SeedHex2 =
    '7e9f86e818b5b872612d4efe76b8c4232cede988846533e10d883e661217d2766ec04e05e3a4585eceacbf7e6f29a5bf7481f03c94e54a553602ac8d003889f2';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Hive.initFlutter();
  await dotenv.load();
  FocusManager.instance.primaryFocus?.unfocus();
  // make app always in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      return Container();
    }
    return Container(
      color: Colors.red,
      child: Center(
        child: Text(
          details.exceptionAsString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  };

  const secureEncryptionKey = 'b6f71-9b6df9-0abc-4463-a623-43eaf2';

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  var containsEncryptionKey =
      await secureStorage.containsKey(key: secureEncryptionKey);

  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(
      key: secureEncryptionKey,
      value: base64UrlEncode(key),
    );
  }

  final result = await secureStorage.read(key: secureEncryptionKey);

  var encryptionKey = base64Url.decode(result!);
  pref = await Hive.openBox(
    secureStorageKey,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  walletImportType = WalletService.getType();

  trustWalletProvider = await rootBundle.loadString('js/trust.min.js');
  leatherWalletProvider = await rootBundle.loadString('js/leather.stx.min.js');
  nightly = await rootBundle.loadString('js/nightly.min.js');
  webNotifer = await rootBundle.loadString('js/web_notification.js');
  currencyJson = await rootBundle.loadString('json/currency_symbol.json');
  currencyJsonSearch = await rootBundle.loadString('json/currencies.json');
  await WebNotificationPermissionDb.loadSavedPermissions();
  if (WalletService.isBip39PhraseOrSeedHexKey()) {
    await reInstianteSeedRoot();
    debugPrint('Reinstantiated seed root');
  }
  supportedChains = await getChainsSortedByBalance();
  testNetNotifier.addListener(() async {
    debugPrint('enableTestNet = $enableTestNet — reloading chains');
    supportedChains = await getChainsSortedByBalance();
  });

  for (int i = 0; i < wordList.length; i++) {
    mnemonicSuggester.insert(wordList[i]);
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  await DeadManSwitchService.checkOnAppOpen();
  cacheSupportedCurrencies();
  logoBytes = await rootBundle.load('assets/logo.png');
  runApp(ProviderScope(
    child: MyApp(
      userDarkMode: pref.get(darkModekey, defaultValue: true),
      locale: Locale.fromSubtags(
        languageCode: pref.get(languageKey, defaultValue: 'en'),
      ),
    ),
  ));
}

// Call this once at app startup or first launch
Future<void> cacheSupportedCurrencies() async {
  if (pref.get(supportedCurrencyKey) != null) return; // already cached

  final supported = jsonDecode(
    (await http.get(Uri.parse(coinGeckoSupportedCurrencies))).body,
  ) as List;

  await pref.put(supportedCurrencyKey, supported.join(','));
}

int uint8ListToNumber(Uint8List bytes, {Endian endian = Endian.little}) {
  if (endian == Endian.big) {
    return bytes.fold(0, (result, byte) => (result << 8) + byte);
  } else {
    return bytes.reversed.fold(0, (result, byte) => (result << 8) + byte);
  }
}

class MyApp extends StatefulWidget {
  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static bool getCoinGeckoData = true;
  static DateTime lastcoinGeckoData = DateTime.now();

  final bool userDarkMode;
  final Locale locale;

  const MyApp({super.key, required this.userDarkMode, required this.locale});
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  initState() {
    super.initState();
    _locale = widget.locale;
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    MyApp.themeNotifier.value =
        widget.userDarkMode ? ThemeMode.dark : ThemeMode.light;

    return ValueListenableBuilder(
      valueListenable: MyApp.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarBrightness: currentMode == ThemeMode.light
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.black,
          ),
        );
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey, // set property
          debugShowCheckedModeBanner: false,
          locale: _locale,
          theme: darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          darkTheme: darkTheme,
          themeMode: currentMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<bool> _detectDanger() async {
  if (kDebugMode) {
    return false;
  }
  bool isJailBroken = false;
  bool isRealDevice = true;
  try {
    isJailBroken = await SafeDevice.isJailBroken;
    isRealDevice = await SafeDevice.isRealDevice;
  } catch (e) {
    isJailBroken = true;
  }
  if (isJailBroken || !isRealDevice) {
    if (kDebugMode) {
      print('Device is jailbroken or not a real device');
    }
    return true;
  }
  return false;
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen.withScreenFunction(
        curve: Curves.linear,
        splashIconSize: 100,
        duration: 1000,
        backgroundColor: Theme.of(context).colorScheme.surface,
        disableNavigation: true,
        splash: 'assets/logo.png',
        screenFunction: () async {
          final bool hasWallet =
              WalletService.getActiveKey(walletImportType) != null;

          final bool hasPasscode = pref.get(userUnlockPasscodeKey) != null;
          final int hasUnlockTime = pref.get(appUnlockTime, defaultValue: 1);
          bool isAuthenticated = false;

          if (hasUnlockTime > 1) {
            return OpenAppPinFailed(remainSec: hasUnlockTime);
          }

          if (hasWallet) {
            isAuthenticated = await authenticate(context);
          }

          bool isDangerous = await _detectDanger();

          if (isDangerous) {
            return const Text(
              'Device is jailbroken or not real can not use app',
            );
          }

          if (hasWallet && !isAuthenticated) return const OpenAppPinFailed();

          if (hasWallet) return const Wallet();

          if (hasPasscode) return const MainScreen();

          return const Security();
        },
        pageTransitionType: PageTransitionType.rightToLeft,
      ),
    );
  }
}
