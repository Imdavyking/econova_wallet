// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:safe_device/safe_device.dart';
import 'coins/aptos_coin.dart';
import 'data_structures/trie.dart';
import 'interface/coin.dart';
import 'screens/main_screen.dart';
import 'screens/navigator_service.dart';
import 'screens/open_app_pin_failed.dart';
import 'screens/security.dart';
import 'screens/wallet.dart';
import 'service/dead_man_switch_service.dart';
import 'service/transaction_export_service.dart';
import 'service/wallet_service.dart';
import 'utils/app_config.dart';
import 'utils/rpc_urls.dart';
import 'utils/web_notifications.dart';
import 'wordlist.dart';
import 'package:wallet_app/coins/cardano_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/ontology_ft_coin.dart';
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
import 'package:wallet_app/coins/fungible_tokens/esdt_ft_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/ton_fungible_coins.dart';
import 'package:wallet_app/coins/fungible_tokens/tron_fungible_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/near_fungible_coin.dart';
import 'package:wallet_app/coins/fungible_tokens/spl_token_coin.dart';
import 'package:wallet_app/coins/fuse_4337_coin.dart';
import 'package:wallet_app/coins/segwit_coin.dart';
import 'package:wallet_app/coins/stack_coin.dart';
import 'package:wallet_app/coins/nimiq_coin.dart';
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
import 'coins/evmhrp_coin.dart';
import 'coins/multiversx_coin.dart';
import 'coins/ronin_coin.dart';
import 'coins/sui_coin.dart';
import 'coins/ton_coin.dart';
import 'coins/zilliqa_coin.dart';
import '../coins/ethereum_coin.dart';
import '../coins/near_coin.dart';
import '../coins/solana_coin.dart';
import '../coins/stellar_coin.dart';

// ── Globals ───────────────────────────────────────────────────────────────────

late String currencyJson;
late String currencyJsonSearch;
late String trustWalletProvider;
late String leatherWalletProvider;
late String nightly;
late String webNotifer;
late String nimiqSpriteSvg;
late Box pref;
late WalletType walletImportType;
late ByteData logoBytes;

final Map<String, Map<String, dynamic>> decodedCache = {};
final mnemonicSuggester = Trie();

// ── Chain registry ────────────────────────────────────────────────────────────

List<T> getChains<T extends Coin>() {
  List<Coin> all = [
    ...getNimiqBlockchains(),
    ...getNanoBlockChains(),
    ...getWavesBlockChains(),
    ...getOntologyBlockChains(),
    ...getIconBlockChains(),
    ...getCardanoBlockChains(),
    ...getTonBlockChains(),
    ...getEVMBlockchains(),
    ...getNearBlockChains(),
    ...getTronBlockchains(),
    ...getSolanaBlockChains(),
    ...getEGLDBlockchains(),
    ...getICPBlockchains(),
    ...getFUSEBlockchains(),
    ...getZilliqaBlockChains(),
    ...getEVMHrpBlockchains(),
    ...getStellarBlockChains(),
    ...getSuiBlockChains(),
    ...getRoninBlockchains(),
    ...getTezosBlockchains(),
    ...getAlgorandBlockchains(),
    ...getLegacyUtxoCoins(),
    ...getCosmosBlockChains(),
    ...getFilecoinBlockChains(),
    ...getStarknetBlockchains(),
    ...getXRPBlockChains(),
    ...getPolkadoBlockChains(),
    ...getAptosBlockchain(),
    ...getStacksBlockchains(),
    ...getSegwitCoins(),
    ...getSplTokens(),
    ...getESDTCoins(),
    ...getTonFungibleCoins(),
    ...getTronFungibleCoins(),
    ...getNearFungibles(),
    ...getPolkadotFungibleCoins(),
    ...getOntologyFungibleCoins(),
    ...getSIP010Coins(),
    ...getERC20Coins(),
    ...getFUSEFTBlockchains(),
    ...getCosmosFungibleCoins(),
    ...getStarknetFungibleCoins(),
  ];

  return (T == Coin ? all : all.whereType<T>().toList()) as List<T>;
}

List<T> getChainsSortedByName<T extends Coin>() {
  return (getChains<T>()
        ..sort((a, b) => b.getSymbol().compareTo(a.getSymbol())))
      .toList();
}

// ── Entry point ───────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initCore();
  await _initStorage();
  await _loadAssets();
  await _initChains();
  await _initMisc();

  runApp(ProviderScope(
    child: MyApp(
      userDarkMode: pref.get(darkModekey, defaultValue: true),
      locale: Locale.fromSubtags(
        languageCode: pref.get(languageKey, defaultValue: 'en'),
      ),
    ),
  ));
}

Future<void> _initCore() async {
  await Future.wait([
    FlutterDownloader.initialize(),
    Hive.initFlutter(),
    dotenv.load(),
    AppFonts.load(),
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ErrorWidget.builder = (details) => kReleaseMode
      ? const SizedBox.shrink()
      : ColoredBox(
          color: Colors.red,
          child: Center(
            child: Text(details.exceptionAsString(),
                style: const TextStyle(color: Colors.white)),
          ),
        );
}

Future<void> _initStorage() async {
  const secureStorage = FlutterSecureStorage();

  if (!await secureStorage.containsKey(key: secureEncryptionKey)) {
    await secureStorage.write(
      key: secureEncryptionKey,
      value: base64UrlEncode(Hive.generateSecureKey()),
    );
  }

  final encryptionKeyB64 = await secureStorage.read(key: secureEncryptionKey);
  pref = await Hive.openBox(
    secureStorageKey,
    encryptionCipher: HiveAesCipher(base64Url.decode(encryptionKeyB64!)),
  );

  walletImportType = WalletService.getType();
  await WebNotificationPermissionDb.loadSavedPermissions();
}

Future<void> _loadAssets() async {
  final results = await Future.wait([
    rootBundle.loadString('js/trust.min.js'),
    rootBundle.loadString('js/leather.stx.min.js'),
    rootBundle.loadString('js/nightly.min.js'),
    rootBundle.loadString('js/web_notification.js'),
    rootBundle.loadString('json/currency_symbol.json'),
    rootBundle.loadString('json/currencies.json'),
    rootBundle.loadString('assets/identicons.min.svg'),
    rootBundle.load('assets/logo.png'),
  ]);

  trustWalletProvider = results[0] as String;
  leatherWalletProvider = results[1] as String;
  nightly = results[2] as String;
  webNotifer = results[3] as String;
  currencyJson = results[4] as String;
  currencyJsonSearch = results[5] as String;
  nimiqSpriteSvg = results[6] as String;
  logoBytes = results[7] as ByteData;
}

Future<void> _initChains() async {
  if (WalletService.isBip39PhraseOrSeedHexKey()) {
    await reInstianteSeedRoot();
    debugPrint('Reinstantiated seed root');
  }

  supportedChains = getChainsSortedByName();
  testNetNotifier.addListener(() async {
    debugPrint('enableTestNet = $enableTestNet — reloading chains');
    supportedChains = getChainsSortedByName();
  });
}

Future<void> _initMisc() async {
  for (final word in wordList) {
    mnemonicSuggester.insert(word);
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  await DeadManSwitchService.checkOnAppOpen();
  unawaited(cacheSupportedCurrencies()); // intentionally fire-and-forget
}

Future<void> cacheSupportedCurrencies() async {
  if (pref.get(supportedCurrencyKey) != null) return;
  final response = await http.get(Uri.parse(coinGeckoSupportedCurrencies));
  final supported = jsonDecode(response.body) as List;
  await pref.put(supportedCurrencyKey, supported.join(','));
}

// ── Utilities ─────────────────────────────────────────────────────────────────

int uint8ListToNumber(Uint8List bytes, {Endian endian = Endian.little}) =>
    endian == Endian.big
        ? bytes.fold(0, (r, b) => (r << 8) + b)
        : bytes.reversed.fold(0, (r, b) => (r << 8) + b);

/// Returns true if the device is jailbroken or an emulator.
/// Always returns false in debug mode.
Future<bool> _detectDanger() async {
  if (kDebugMode) return false;
  try {
    final jailbroken = await SafeDevice.isJailBroken;
    final realDevice = await SafeDevice.isRealDevice;
    return jailbroken || !realDevice;
  } catch (_) {
    return true; // assume dangerous on error
  }
}

// ── App ───────────────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  static final themeNotifier = ValueNotifier(ThemeMode.dark);
  static bool getCoinGeckoData = true;
  static DateTime lastCoinGeckoData =
      DateTime.now(); // ← restored + fixed casing
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
  void initState() {
    super.initState();
    _locale = widget.locale;
    // Set theme from widget param once — not in build
    MyApp.themeNotifier.value =
        widget.userDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void setLocale(Locale value) => setState(() => _locale = value);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (_, mode, __) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarBrightness:
              mode == ThemeMode.light ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.black,
        ));
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: _locale,
          theme: darkTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyHomePage(),
        );
      },
    );
  }
}

// ── Home / Splash ─────────────────────────────────────────────────────────────

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
        screenFunction: _resolveStartScreen,
        pageTransitionType: PageTransitionType.rightToLeft,
      ),
    );
  }

  Future<Widget> _resolveStartScreen() async {
    // 1. Enforce unlock timeout first — before anything else
    final int unlockTime = pref.get(appUnlockTime, defaultValue: 1);
    if (unlockTime > 1) return OpenAppPinFailed(remainSec: unlockTime);

    // 2. Jailbreak / emulator check
    if (await _detectDanger()) {
      return const Center(
        child: Text('Device is jailbroken or not real — cannot use app'),
      );
    }

    final hasWallet = WalletService.getActiveKey(walletImportType) != null;
    final hasPasscode = pref.get(userUnlockPasscodeKey) != null;

    // 3. Authenticate if wallet exists
    if (hasWallet) {
      // Note: authenticate() needs a BuildContext — keep using navigatorKey
      final authenticated =
          await authenticate(NavigationService.navigatorKey.currentContext!);
      if (!authenticated) return const OpenAppPinFailed();
      return const Wallet();
    }

    if (hasPasscode) return const MainScreen();
    return const Security();
  }
}
