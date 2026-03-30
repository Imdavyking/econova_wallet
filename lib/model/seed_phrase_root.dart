import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:web3dart/crypto.dart';

class SeedPhraseRoot {
  late Uint8List seed;
  late bip32.BIP32 root;
  SeedPhraseRoot(this.seed, this.root);
}

Future<SeedPhraseRoot> seedFromMnemonic(String phraseOrBipSeedHex) async {
  final isValid = await compute(bip39.validateMnemonic, phraseOrBipSeedHex);
  Uint8List seed = Uint8List.fromList([]);
  if (isValid) {
    seed = bip39.mnemonicToSeed(phraseOrBipSeedHex);
  } else {
    seed = HEX.decode(strip0x(phraseOrBipSeedHex)) as Uint8List;
  }
  bip32.BIP32 root = bip32.BIP32.fromSeed(seed);

  return SeedPhraseRoot(seed, root);
}
