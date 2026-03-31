import 'package:test/test.dart';
import 'package:algorand_kmd/algorand_kmd.dart';

// tests for SignTransactionRequest
void main() {
  final instance = SignTransactionRequestBuilder();
  // TODO add properties to the builder and call build()

  group(SignTransactionRequest, () {
    // BuiltList<int> publicKey
    test('to test the property `publicKey`', () async {
      // TODO
    });

    // Base64 encoding of msgpack encoding of a `Transaction` object Note: SDK and goal usually generate `SignedTxn` objects in that case, the field `txn` / `Transaction` of the generated `SignedTxn` object needs to be used
    // String transaction
    test('to test the property `transaction`', () async {
      // TODO
    });

    // String walletHandleToken
    test('to test the property `walletHandleToken`', () async {
      // TODO
    });

    // String walletPassword
    test('to test the property `walletPassword`', () async {
      // TODO
    });

  });
}
