import 'package:flutter/foundation.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/model/seed_phrase_root.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:web3dart/crypto.dart';

enum WalletImportError { invalidMnemonic, duplicate, unknown }

class WalletImportResult {
  final bool success;
  final WalletImportError? error;

  const WalletImportResult._({required this.success, this.error});

  factory WalletImportResult.ok() => const WalletImportResult._(success: true);
  factory WalletImportResult.fail(WalletImportError error) =>
      WalletImportResult._(success: false, error: error);
}

class WalletImportService {
  WalletImportService._();

  static String getNextWalletName() {
    final count =
        WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex).length;
    return 'Wallet ${count + 1}';
  }

  /// Validates → deduplicates → seeds → sets active key → imports all chains.
  ///
  /// Returns [WalletImportResult.ok()] on success or a typed error.
  static Future<WalletImportResult> importFromMnemonic({
    required String mnemonicOrBip39SeedHex,
    required String walletName,
  }) async {
    try {
      mnemonicOrBip39SeedHex = strip0x(mnemonicOrBip39SeedHex);
      // 1. BIP-39 validation (off main thread)
      final isValid =
          await compute(bip39.validateMnemonic, mnemonicOrBip39SeedHex);

      Uint8List seed = Uint8List.fromList([]);
      if (!isValid) {
        seed = HEX.decode(mnemonicOrBip39SeedHex) as Uint8List;
        if (seed.isEmpty) {
          return WalletImportResult.fail(WalletImportError.invalidMnemonic);
        }
      }

      // 2. Duplicate check
      final existing =
          WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex);
      final phraseData = BIP39PhraseOrSeedHEXParams(
          data: mnemonicOrBip39SeedHex, name: walletName);
      if (existing
          .any((p) => p?.data.toLowerCase() == phraseData.data.toLowerCase())) {
        return WalletImportResult.fail(WalletImportError.duplicate);
      }

      seedPhraseRoot = await compute(seedFromMnemonic, phraseData.data);
      await WalletService.setActiveKey(
          WalletType.bip39PhraseOrSeedHex, phraseData);
      await importAllKeys(phraseData.data);
    } catch (e, st) {
      debugPrint('WalletImportService error: $e\n$st');
      return WalletImportResult.fail(WalletImportError.unknown);
    }

    return WalletImportResult.ok();
  }
}
