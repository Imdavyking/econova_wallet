import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

/// Extension on `SignedTx` to allow resigning a transaction with a new signature.
///
/// This is particularly useful when you need to re-sign a transaction
/// using a new recent blockhash or keypair without rebuilding the whole transaction manually.
extension SignedTxResign on SignedTx {
  /// Re-signs the current transaction with the specified `wallet` keypair.
  ///
  /// - If `blockhash` is provided (not empty), the transaction will be signed
  ///   with the updated recent blockhash. If omitted, the original blockhash is used.
  /// - Replaces only the signature matching the public key of `wallet`.
  ///
  /// Returns a new `SignedTx` instance with updated signatures and message.
  Future<SignedTx> resign({
    required Ed25519HDKeyPair wallet,
    String blockhash = '',
  }) async {
    final CompiledMessage newCompiledMessage = blockhash.isEmpty
        ? compiledMessage
        : compiledMessage.copyWith(recentBlockhash: blockhash);

    final signature = await wallet.sign(newCompiledMessage.toByteArray());

    return SignedTx(
      signatures: signatures
          .map(
            (e) => e.publicKey == wallet.publicKey ? signature : e,
          )
          .toList(),
      compiledMessage: newCompiledMessage,
    );
  }
}
