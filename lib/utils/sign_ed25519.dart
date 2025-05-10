import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';

Uint8List signEd25519(
    {required Uint8List message, required Uint8List privateKey}) {
  SolanaSigner signer = SolanaSigner.fromKeyBytes(privateKey);
  return Uint8List.fromList(signer.sign(message));
}
