import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
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

  static Future<WalletImportResult> importFromMnemonic({
    required String mnemonicOrBip39SeedHex,
    required String walletName,
  }) async {
    try {
      final normalized = await _normalize(mnemonicOrBip39SeedHex);
      if (normalized == null) {
        return WalletImportResult.fail(WalletImportError.invalidMnemonic);
      }

      final existing =
          WalletService.getActiveKeys(WalletType.bip39PhraseOrSeedHex);
      final params =
          BIP39PhraseOrSeedHEXParams(data: normalized, name: walletName);

      if (existing.any(
        (p) => p.data.toLowerCase() == params.data.toLowerCase(),
      )) {
        return WalletImportResult.fail(WalletImportError.duplicate);
      }

      seedPhraseRoot = await compute(seedFromMnemonic, params.data);

      // setActiveKey handles setType internally — no separate call needed.
      await WalletService.setActiveKey(WalletType.bip39PhraseOrSeedHex, params);
      await importAllKeys(params.data);

      return WalletImportResult.ok();
    } catch (e, st) {
      debugPrint('WalletImportService error: $e\n$st');
      return WalletImportResult.fail(WalletImportError.unknown);
    }
  }

  /// Returns the canonical form of the input (mnemonic or seed hex),
  /// or null if the input is neither valid.
  static Future<String?> _normalize(String input) async {
    final trimmed = input.trim();

    if (await compute(bip39.validateMnemonic, trimmed)) return trimmed;

    final hex = strip0x(trimmed);
    try {
      final seed = HEX.decode(hex) as Uint8List;
      if (seed.length == 64) return hex; // BIP-39 seeds are 64 bytes
    } catch (_) {}

    return null;
  }
}
