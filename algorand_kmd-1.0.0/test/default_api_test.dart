import 'package:test/test.dart';
import 'package:algorand_kmd/algorand_kmd.dart';


/// tests for DefaultApi
void main() {
  final instance = AlgorandKmd().getDefaultApi();

  group(DefaultApi, () {
    // Create a wallet
    //
    // Create a new wallet (collection of keys) with the given parameters.
    //
    //Future<APIV1POSTWalletResponse> createWallet(CreateWalletRequest createWalletRequest) async
    test('test createWallet', () async {
      // TODO
    });

    // Delete a key
    //
    // Deletes the key with the passed public key from the wallet.
    //
    //Future<APIV1DELETEKeyResponse> deleteKey(DeleteKeyRequest deleteKeyRequest) async
    test('test deleteKey', () async {
      // TODO
    });

    // Delete a multisig
    //
    // Deletes multisig preimage information for the passed address from the wallet. 
    //
    //Future<APIV1DELETEMultisigResponse> deleteMultisig(DeleteMultisigRequest deleteMultisigRequest) async
    test('test deleteMultisig', () async {
      // TODO
    });

    // Export a key
    //
    // Export the secret key associated with the passed public key.
    //
    //Future<APIV1POSTKeyExportResponse> exportKey(ExportKeyRequest exportKeyRequest) async
    test('test exportKey', () async {
      // TODO
    });

    // Export the master derivation key from a wallet
    //
    // Export the master derivation key from the wallet. This key is a master \"backup\" key for the underlying wallet. With it, you can regenerate all of the wallets that have been generated with this wallet's `POST /v1/key` endpoint. This key will not allow you to recover keys imported from other wallets, however. 
    //
    //Future<APIV1POSTMasterKeyExportResponse> exportMasterKey(ExportMasterKeyRequest exportMasterKeyRequest) async
    test('test exportMasterKey', () async {
      // TODO
    });

    // Export multisig address metadata
    //
    // Given a multisig address whose preimage this wallet stores, returns the information used to generate the address, including public keys, threshold, and multisig version. 
    //
    //Future<APIV1POSTMultisigExportResponse> exportMultisig(ExportMultisigRequest exportMultisigRequest) async
    test('test exportMultisig', () async {
      // TODO
    });

    // Generate a key
    //
    // Generates the next key in the deterministic key sequence (as determined by the master derivation key) and adds it to the wallet, returning the public key. 
    //
    //Future<APIV1POSTKeyResponse> generateKey(GenerateKeyRequest generateKeyRequest) async
    test('test generateKey', () async {
      // TODO
    });

    // Retrieves the current version
    //
    //Future<VersionsResponse> getVersion({ JsonObject versionsRequest }) async
    test('test getVersion', () async {
      // TODO
    });

    // Get wallet info
    //
    // Returns information about the wallet associated with the passed wallet handle token. Additionally returns expiration information about the token itself. 
    //
    //Future<APIV1POSTWalletInfoResponse> getWalletInfo(WalletInfoRequest getWalletInfoRequest) async
    test('test getWalletInfo', () async {
      // TODO
    });

    // Import a key
    //
    // Import an externally generated key into the wallet. Note that if you wish to back up the imported key, you must do so by backing up the entire wallet database, because imported keys were not derived from the wallet's master derivation key. 
    //
    //Future<APIV1POSTKeyImportResponse> importKey(ImportKeyRequest importKeyRequest) async
    test('test importKey', () async {
      // TODO
    });

    // Import a multisig account
    //
    // Generates a multisig account from the passed public keys array and multisig metadata, and stores all of this in the wallet. 
    //
    //Future<APIV1POSTMultisigImportResponse> importMultisig(ImportMultisigRequest importMultisigRequest) async
    test('test importMultisig', () async {
      // TODO
    });

    // Initialize a wallet handle token
    //
    // Unlock the wallet and return a wallet handle token that can be used for subsequent operations. These tokens expire periodically and must be renewed. You can `POST` the token to `/v1/wallet/info` to see how much time remains until expiration, and renew it with `/v1/wallet/renew`. When you're done, you can invalidate the token with `/v1/wallet/release`. 
    //
    //Future<APIV1POSTWalletInitResponse> initWalletHandleToken(InitWalletHandleTokenRequest initializeWalletHandleTokenRequest) async
    test('test initWalletHandleToken', () async {
      // TODO
    });

    // List keys in wallet
    //
    // Lists all of the public keys in this wallet. All of them have a stored private key.
    //
    //Future<APIV1POSTKeyListResponse> listKeysInWallet(ListKeysRequest listKeysRequest) async
    test('test listKeysInWallet', () async {
      // TODO
    });

    // List multisig accounts
    //
    // Lists all of the multisig accounts whose preimages this wallet stores
    //
    //Future<APIV1POSTMultisigListResponse> listMultisg(ListMultisigRequest listMultisigRequest) async
    test('test listMultisg', () async {
      // TODO
    });

    // List wallets
    //
    // Lists all of the wallets that kmd is aware of.
    //
    //Future<APIV1GETWalletsResponse> listWallets({ JsonObject listWalletRequest }) async
    test('test listWallets', () async {
      // TODO
    });

    // Release a wallet handle token
    //
    // Invalidate the passed wallet handle token, making it invalid for use in subsequent requests.
    //
    //Future<APIV1POSTWalletReleaseResponse> releaseWalletHandleToken(ReleaseWalletHandleTokenRequest releaseWalletHandleTokenRequest) async
    test('test releaseWalletHandleToken', () async {
      // TODO
    });

    // Rename a wallet
    //
    // Rename the underlying wallet to something else
    //
    //Future<APIV1POSTWalletRenameResponse> renameWallet(RenameWalletRequest renameWalletRequest) async
    test('test renameWallet', () async {
      // TODO
    });

    // Renew a wallet handle token
    //
    // Renew a wallet handle token, increasing its expiration duration to its initial value
    //
    //Future<APIV1POSTWalletRenewResponse> renewWalletHandleToken(RenewWalletHandleTokenRequest renewWalletHandleTokenRequest) async
    test('test renewWalletHandleToken', () async {
      // TODO
    });

    // Sign a program for a multisig account
    //
    // Start a multisig signature, or add a signature to a partially completed multisig signature object. 
    //
    //Future<APIV1POSTMultisigProgramSignResponse> signMultisigProgram(SignProgramMultisigRequest signMultisigProgramRequest) async
    test('test signMultisigProgram', () async {
      // TODO
    });

    // Sign a multisig transaction
    //
    // Start a multisig signature, or add a signature to a partially completed multisig signature object. 
    //
    //Future<APIV1POSTMultisigTransactionSignResponse> signMultisigTransaction(SignMultisigRequest signMultisigTransactionRequest) async
    test('test signMultisigTransaction', () async {
      // TODO
    });

    // Sign program
    //
    // Signs the passed program with a key from the wallet, determined by the account named in the request. 
    //
    //Future<APIV1POSTProgramSignResponse> signProgram(SignProgramRequest signProgramRequest) async
    test('test signProgram', () async {
      // TODO
    });

    // Sign a transaction
    //
    // Signs the passed transaction with a key from the wallet, determined by the sender encoded in the transaction. 
    //
    //Future<APIV1POSTTransactionSignResponse> signTransaction(SignTransactionRequest signTransactionRequest) async
    test('test signTransaction', () async {
      // TODO
    });

    // Gets the current swagger spec.
    //
    // Returns the entire swagger spec in json.
    //
    //Future<String> swaggerHandler() async
    test('test swaggerHandler', () async {
      // TODO
    });

  });
}
