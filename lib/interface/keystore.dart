import 'dart:convert';
import 'dart:typed_data';

import 'package:web3dart/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart' as pbkdf2;
import 'package:pointycastle/key_derivators/scrypt.dart' as scrypt;
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/stream/ctr.dart';

class KeyStoreParams {
  String keystore;
  String password;
  KeyStoreParams({
    required this.keystore,
    required this.password,
  });
}

class KeyStore {
  static Uint8List fromKeystore(KeyStoreParams params) {
    final data = json.decode(params.keystore);

    // Ensure version is 3, only version that we support at the moment
    final version = data['version'];
    if (version != 3) {
      throw ArgumentError.value(
        version,
        'version',
        'Library only supports '
            'version 3 of wallet files at the moment. However, the following value'
            ' has been given:',
      );
    }

    final crypto = data['crypto'] ?? data['Crypto'];

    final kdf = crypto['kdf'] as String;
    _KeyDerivator derivator;

    switch (kdf) {
      case 'pbkdf2':
        final derParams = crypto['kdfparams'] as Map<String, dynamic>;

        if (derParams['prf'] != 'hmac-sha256') {
          throw ArgumentError(
            'Invalid prf supplied with the pdf: was ${derParams["prf"]}, expected hmac-sha256',
          );
        }

        derivator = _PBDKDF2KeyDerivator(
          derParams['c'] as int,
          Uint8List.fromList(hexToBytes(derParams['salt'] as String)),
          derParams['dklen'] as int,
        );

        break;
      case 'scrypt':
        final derParams = crypto['kdfparams'] as Map<String, dynamic>;
        derivator = _ScryptKeyDerivator(
          derParams['dklen'] as int,
          derParams['n'] as int,
          derParams['r'] as int,
          derParams['p'] as int,
          Uint8List.fromList(hexToBytes(derParams['salt'] as String)),
        );
        break;
      default:
        throw ArgumentError(
          'Wallet file uses $kdf as key derivation function, which is not supported.',
        );
    }

    // Now that we have the derivator, let's obtain the aes key:
    final encodedPassword = Uint8List.fromList(utf8.encode(params.password));
    final derivedKey = derivator.deriveKey(encodedPassword);
    final aesKey = Uint8List.fromList(derivedKey.sublist(0, 16));

    final encryptedPrivateKey = hexToBytes(crypto['ciphertext'] as String);

    //Validate the derived key with the mac provided
    final derivedMac = _generateMac(derivedKey, encryptedPrivateKey);
    if (derivedMac != crypto['mac']) {
      throw ArgumentError(
        'Could not unlock wallet file. You either supplied the wrong password or the file is corrupted',
      );
    }

    // We only support this mode at the moment
    if (crypto['cipher'] != 'aes-128-ctr') {
      throw ArgumentError(
        'Wallet file uses ${crypto["cipher"]} as cipher, but only aes-128-ctr is supported.',
      );
    }
    final iv =
        Uint8List.fromList(hexToBytes(crypto['cipherparams']['iv'] as String));

    // Decrypt the private key

    final aes = _initCipher(false, aesKey, iv);

    final privateKey = aes.process(Uint8List.fromList(encryptedPrivateKey));
    return privateKey;
  }

  static CTRStreamCipher _initCipher(
    bool forEncryption,
    Uint8List key,
    Uint8List iv,
  ) {
    return CTRStreamCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));
  }

  static String _generateMac(List<int> dk, List<int> ciphertext) {
    final macBody = <int>[...dk.sublist(16, 32), ...ciphertext];

    return bytesToHex(keccak256(uint8ListFromList(macBody)));
  }
}

Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}

abstract class _KeyDerivator {
  Uint8List deriveKey(Uint8List password);

  String get name;
  Map<String, dynamic> encode();
}

class _PBDKDF2KeyDerivator extends _KeyDerivator {
  _PBDKDF2KeyDerivator(this.iterations, this.salt, this.dklen);
  final int iterations;
  final Uint8List salt;
  final int dklen;

  // The docs (https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition)
  // say that HMAC with SHA-256 is the only mac supported at the moment
  static final Mac mac = HMac(SHA256Digest(), 64);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = pbkdf2.PBKDF2KeyDerivator(mac)
      ..init(Pbkdf2Parameters(salt, iterations, dklen));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'c': iterations,
      'dklen': dklen,
      'prf': 'hmac-sha256',
      'salt': bytesToHex(salt)
    };
  }

  @override
  final String name = 'pbkdf2';
}

class _ScryptKeyDerivator extends _KeyDerivator {
  _ScryptKeyDerivator(this.dklen, this.n, this.r, this.p, this.salt);
  final int dklen;
  final int n;
  final int r;
  final int p;
  final Uint8List salt;

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = scrypt.Scrypt()..init(ScryptParameters(n, r, p, dklen, salt));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'dklen': dklen,
      'n': n,
      'r': r,
      'p': p,
      'salt': bytesToHex(salt),
    };
  }

  @override
  final String name = 'scrypt';
}
