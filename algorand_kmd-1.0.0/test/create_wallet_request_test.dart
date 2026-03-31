import 'package:test/test.dart';
import 'package:algorand_kmd/algorand_kmd.dart';

// tests for CreateWalletRequest
void main() {
  final instance = CreateWalletRequestBuilder();
  // TODO add properties to the builder and call build()

  group(CreateWalletRequest, () {
    // MasterDerivationKey is used to derive ed25519 keys for use in wallets
    // BuiltList<int> masterDerivationKey
    test('to test the property `masterDerivationKey`', () async {
      // TODO
    });

    // String walletDriverName
    test('to test the property `walletDriverName`', () async {
      // TODO
    });

    // String walletName
    test('to test the property `walletName`', () async {
      // TODO
    });

    // String walletPassword
    test('to test the property `walletPassword`', () async {
      // TODO
    });

  });
}
