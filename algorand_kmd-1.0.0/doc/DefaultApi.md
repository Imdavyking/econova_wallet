# algorand_kmd.api.DefaultApi

## Load the API package
```dart
import 'package:algorand_kmd/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createWallet**](DefaultApi.md#createwallet) | **POST** /v1/wallet | Create a wallet
[**deleteKey**](DefaultApi.md#deletekey) | **DELETE** /v1/key | Delete a key
[**deleteMultisig**](DefaultApi.md#deletemultisig) | **DELETE** /v1/multisig | Delete a multisig
[**exportKey**](DefaultApi.md#exportkey) | **POST** /v1/key/export | Export a key
[**exportMasterKey**](DefaultApi.md#exportmasterkey) | **POST** /v1/master-key/export | Export the master derivation key from a wallet
[**exportMultisig**](DefaultApi.md#exportmultisig) | **POST** /v1/multisig/export | Export multisig address metadata
[**generateKey**](DefaultApi.md#generatekey) | **POST** /v1/key | Generate a key
[**getVersion**](DefaultApi.md#getversion) | **GET** /versions | Retrieves the current version
[**getWalletInfo**](DefaultApi.md#getwalletinfo) | **POST** /v1/wallet/info | Get wallet info
[**importKey**](DefaultApi.md#importkey) | **POST** /v1/key/import | Import a key
[**importMultisig**](DefaultApi.md#importmultisig) | **POST** /v1/multisig/import | Import a multisig account
[**initWalletHandleToken**](DefaultApi.md#initwallethandletoken) | **POST** /v1/wallet/init | Initialize a wallet handle token
[**listKeysInWallet**](DefaultApi.md#listkeysinwallet) | **POST** /v1/key/list | List keys in wallet
[**listMultisg**](DefaultApi.md#listmultisg) | **POST** /v1/multisig/list | List multisig accounts
[**listWallets**](DefaultApi.md#listwallets) | **GET** /v1/wallets | List wallets
[**releaseWalletHandleToken**](DefaultApi.md#releasewallethandletoken) | **POST** /v1/wallet/release | Release a wallet handle token
[**renameWallet**](DefaultApi.md#renamewallet) | **POST** /v1/wallet/rename | Rename a wallet
[**renewWalletHandleToken**](DefaultApi.md#renewwallethandletoken) | **POST** /v1/wallet/renew | Renew a wallet handle token
[**signMultisigProgram**](DefaultApi.md#signmultisigprogram) | **POST** /v1/multisig/signprogram | Sign a program for a multisig account
[**signMultisigTransaction**](DefaultApi.md#signmultisigtransaction) | **POST** /v1/multisig/sign | Sign a multisig transaction
[**signProgram**](DefaultApi.md#signprogram) | **POST** /v1/program/sign | Sign program
[**signTransaction**](DefaultApi.md#signtransaction) | **POST** /v1/transaction/sign | Sign a transaction
[**swaggerHandler**](DefaultApi.md#swaggerhandler) | **GET** /swagger.json | Gets the current swagger spec.


# **createWallet**
> APIV1POSTWalletResponse createWallet(createWalletRequest)

Create a wallet

Create a new wallet (collection of keys) with the given parameters.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final CreateWalletRequest createWalletRequest = ; // CreateWalletRequest | 

try { 
    final response = api.createWallet(createWalletRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->createWallet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createWalletRequest** | [**CreateWalletRequest**](CreateWalletRequest.md)|  | 

### Return type

[**APIV1POSTWalletResponse**](APIV1POSTWalletResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteKey**
> APIV1DELETEKeyResponse deleteKey(deleteKeyRequest)

Delete a key

Deletes the key with the passed public key from the wallet.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final DeleteKeyRequest deleteKeyRequest = ; // DeleteKeyRequest | 

try { 
    final response = api.deleteKey(deleteKeyRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->deleteKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteKeyRequest** | [**DeleteKeyRequest**](DeleteKeyRequest.md)|  | 

### Return type

[**APIV1DELETEKeyResponse**](APIV1DELETEKeyResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMultisig**
> APIV1DELETEMultisigResponse deleteMultisig(deleteMultisigRequest)

Delete a multisig

Deletes multisig preimage information for the passed address from the wallet. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final DeleteMultisigRequest deleteMultisigRequest = ; // DeleteMultisigRequest | 

try { 
    final response = api.deleteMultisig(deleteMultisigRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->deleteMultisig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteMultisigRequest** | [**DeleteMultisigRequest**](DeleteMultisigRequest.md)|  | 

### Return type

[**APIV1DELETEMultisigResponse**](APIV1DELETEMultisigResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportKey**
> APIV1POSTKeyExportResponse exportKey(exportKeyRequest)

Export a key

Export the secret key associated with the passed public key.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ExportKeyRequest exportKeyRequest = ; // ExportKeyRequest | 

try { 
    final response = api.exportKey(exportKeyRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->exportKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exportKeyRequest** | [**ExportKeyRequest**](ExportKeyRequest.md)|  | 

### Return type

[**APIV1POSTKeyExportResponse**](APIV1POSTKeyExportResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportMasterKey**
> APIV1POSTMasterKeyExportResponse exportMasterKey(exportMasterKeyRequest)

Export the master derivation key from a wallet

Export the master derivation key from the wallet. This key is a master \"backup\" key for the underlying wallet. With it, you can regenerate all of the wallets that have been generated with this wallet's `POST /v1/key` endpoint. This key will not allow you to recover keys imported from other wallets, however. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ExportMasterKeyRequest exportMasterKeyRequest = ; // ExportMasterKeyRequest | 

try { 
    final response = api.exportMasterKey(exportMasterKeyRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->exportMasterKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exportMasterKeyRequest** | [**ExportMasterKeyRequest**](ExportMasterKeyRequest.md)|  | 

### Return type

[**APIV1POSTMasterKeyExportResponse**](APIV1POSTMasterKeyExportResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportMultisig**
> APIV1POSTMultisigExportResponse exportMultisig(exportMultisigRequest)

Export multisig address metadata

Given a multisig address whose preimage this wallet stores, returns the information used to generate the address, including public keys, threshold, and multisig version. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ExportMultisigRequest exportMultisigRequest = ; // ExportMultisigRequest | 

try { 
    final response = api.exportMultisig(exportMultisigRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->exportMultisig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exportMultisigRequest** | [**ExportMultisigRequest**](ExportMultisigRequest.md)|  | 

### Return type

[**APIV1POSTMultisigExportResponse**](APIV1POSTMultisigExportResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **generateKey**
> APIV1POSTKeyResponse generateKey(generateKeyRequest)

Generate a key

Generates the next key in the deterministic key sequence (as determined by the master derivation key) and adds it to the wallet, returning the public key. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final GenerateKeyRequest generateKeyRequest = ; // GenerateKeyRequest | 

try { 
    final response = api.generateKey(generateKeyRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->generateKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **generateKeyRequest** | [**GenerateKeyRequest**](GenerateKeyRequest.md)|  | 

### Return type

[**APIV1POSTKeyResponse**](APIV1POSTKeyResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVersion**
> VersionsResponse getVersion(versionsRequest)

Retrieves the current version

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final JsonObject versionsRequest = Object; // JsonObject | 

try { 
    final response = api.getVersion(versionsRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->getVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **versionsRequest** | **JsonObject**|  | [optional] 

### Return type

[**VersionsResponse**](VersionsResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWalletInfo**
> APIV1POSTWalletInfoResponse getWalletInfo(getWalletInfoRequest)

Get wallet info

Returns information about the wallet associated with the passed wallet handle token. Additionally returns expiration information about the token itself. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final WalletInfoRequest getWalletInfoRequest = ; // WalletInfoRequest | 

try { 
    final response = api.getWalletInfo(getWalletInfoRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->getWalletInfo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **getWalletInfoRequest** | [**WalletInfoRequest**](WalletInfoRequest.md)|  | 

### Return type

[**APIV1POSTWalletInfoResponse**](APIV1POSTWalletInfoResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importKey**
> APIV1POSTKeyImportResponse importKey(importKeyRequest)

Import a key

Import an externally generated key into the wallet. Note that if you wish to back up the imported key, you must do so by backing up the entire wallet database, because imported keys were not derived from the wallet's master derivation key. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ImportKeyRequest importKeyRequest = ; // ImportKeyRequest | 

try { 
    final response = api.importKey(importKeyRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->importKey: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **importKeyRequest** | [**ImportKeyRequest**](ImportKeyRequest.md)|  | 

### Return type

[**APIV1POSTKeyImportResponse**](APIV1POSTKeyImportResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importMultisig**
> APIV1POSTMultisigImportResponse importMultisig(importMultisigRequest)

Import a multisig account

Generates a multisig account from the passed public keys array and multisig metadata, and stores all of this in the wallet. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ImportMultisigRequest importMultisigRequest = ; // ImportMultisigRequest | 

try { 
    final response = api.importMultisig(importMultisigRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->importMultisig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **importMultisigRequest** | [**ImportMultisigRequest**](ImportMultisigRequest.md)|  | 

### Return type

[**APIV1POSTMultisigImportResponse**](APIV1POSTMultisigImportResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **initWalletHandleToken**
> APIV1POSTWalletInitResponse initWalletHandleToken(initializeWalletHandleTokenRequest)

Initialize a wallet handle token

Unlock the wallet and return a wallet handle token that can be used for subsequent operations. These tokens expire periodically and must be renewed. You can `POST` the token to `/v1/wallet/info` to see how much time remains until expiration, and renew it with `/v1/wallet/renew`. When you're done, you can invalidate the token with `/v1/wallet/release`. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final InitWalletHandleTokenRequest initializeWalletHandleTokenRequest = ; // InitWalletHandleTokenRequest | 

try { 
    final response = api.initWalletHandleToken(initializeWalletHandleTokenRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->initWalletHandleToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **initializeWalletHandleTokenRequest** | [**InitWalletHandleTokenRequest**](InitWalletHandleTokenRequest.md)|  | 

### Return type

[**APIV1POSTWalletInitResponse**](APIV1POSTWalletInitResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listKeysInWallet**
> APIV1POSTKeyListResponse listKeysInWallet(listKeysRequest)

List keys in wallet

Lists all of the public keys in this wallet. All of them have a stored private key.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ListKeysRequest listKeysRequest = ; // ListKeysRequest | 

try { 
    final response = api.listKeysInWallet(listKeysRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->listKeysInWallet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listKeysRequest** | [**ListKeysRequest**](ListKeysRequest.md)|  | 

### Return type

[**APIV1POSTKeyListResponse**](APIV1POSTKeyListResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMultisg**
> APIV1POSTMultisigListResponse listMultisg(listMultisigRequest)

List multisig accounts

Lists all of the multisig accounts whose preimages this wallet stores

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ListMultisigRequest listMultisigRequest = ; // ListMultisigRequest | 

try { 
    final response = api.listMultisg(listMultisigRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->listMultisg: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listMultisigRequest** | [**ListMultisigRequest**](ListMultisigRequest.md)|  | 

### Return type

[**APIV1POSTMultisigListResponse**](APIV1POSTMultisigListResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listWallets**
> APIV1GETWalletsResponse listWallets(listWalletRequest)

List wallets

Lists all of the wallets that kmd is aware of.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final JsonObject listWalletRequest = Object; // JsonObject | 

try { 
    final response = api.listWallets(listWalletRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->listWallets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listWalletRequest** | **JsonObject**|  | [optional] 

### Return type

[**APIV1GETWalletsResponse**](APIV1GETWalletsResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **releaseWalletHandleToken**
> APIV1POSTWalletReleaseResponse releaseWalletHandleToken(releaseWalletHandleTokenRequest)

Release a wallet handle token

Invalidate the passed wallet handle token, making it invalid for use in subsequent requests.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final ReleaseWalletHandleTokenRequest releaseWalletHandleTokenRequest = ; // ReleaseWalletHandleTokenRequest | 

try { 
    final response = api.releaseWalletHandleToken(releaseWalletHandleTokenRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->releaseWalletHandleToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **releaseWalletHandleTokenRequest** | [**ReleaseWalletHandleTokenRequest**](ReleaseWalletHandleTokenRequest.md)|  | 

### Return type

[**APIV1POSTWalletReleaseResponse**](APIV1POSTWalletReleaseResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **renameWallet**
> APIV1POSTWalletRenameResponse renameWallet(renameWalletRequest)

Rename a wallet

Rename the underlying wallet to something else

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final RenameWalletRequest renameWalletRequest = ; // RenameWalletRequest | 

try { 
    final response = api.renameWallet(renameWalletRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->renameWallet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **renameWalletRequest** | [**RenameWalletRequest**](RenameWalletRequest.md)|  | 

### Return type

[**APIV1POSTWalletRenameResponse**](APIV1POSTWalletRenameResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **renewWalletHandleToken**
> APIV1POSTWalletRenewResponse renewWalletHandleToken(renewWalletHandleTokenRequest)

Renew a wallet handle token

Renew a wallet handle token, increasing its expiration duration to its initial value

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final RenewWalletHandleTokenRequest renewWalletHandleTokenRequest = ; // RenewWalletHandleTokenRequest | 

try { 
    final response = api.renewWalletHandleToken(renewWalletHandleTokenRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->renewWalletHandleToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **renewWalletHandleTokenRequest** | [**RenewWalletHandleTokenRequest**](RenewWalletHandleTokenRequest.md)|  | 

### Return type

[**APIV1POSTWalletRenewResponse**](APIV1POSTWalletRenewResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signMultisigProgram**
> APIV1POSTMultisigProgramSignResponse signMultisigProgram(signMultisigProgramRequest)

Sign a program for a multisig account

Start a multisig signature, or add a signature to a partially completed multisig signature object. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final SignProgramMultisigRequest signMultisigProgramRequest = ; // SignProgramMultisigRequest | 

try { 
    final response = api.signMultisigProgram(signMultisigProgramRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->signMultisigProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signMultisigProgramRequest** | [**SignProgramMultisigRequest**](SignProgramMultisigRequest.md)|  | 

### Return type

[**APIV1POSTMultisigProgramSignResponse**](APIV1POSTMultisigProgramSignResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signMultisigTransaction**
> APIV1POSTMultisigTransactionSignResponse signMultisigTransaction(signMultisigTransactionRequest)

Sign a multisig transaction

Start a multisig signature, or add a signature to a partially completed multisig signature object. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final SignMultisigRequest signMultisigTransactionRequest = ; // SignMultisigRequest | 

try { 
    final response = api.signMultisigTransaction(signMultisigTransactionRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->signMultisigTransaction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signMultisigTransactionRequest** | [**SignMultisigRequest**](SignMultisigRequest.md)|  | 

### Return type

[**APIV1POSTMultisigTransactionSignResponse**](APIV1POSTMultisigTransactionSignResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signProgram**
> APIV1POSTProgramSignResponse signProgram(signProgramRequest)

Sign program

Signs the passed program with a key from the wallet, determined by the account named in the request. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final SignProgramRequest signProgramRequest = ; // SignProgramRequest | 

try { 
    final response = api.signProgram(signProgramRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->signProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signProgramRequest** | [**SignProgramRequest**](SignProgramRequest.md)|  | 

### Return type

[**APIV1POSTProgramSignResponse**](APIV1POSTProgramSignResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signTransaction**
> APIV1POSTTransactionSignResponse signTransaction(signTransactionRequest)

Sign a transaction

Signs the passed transaction with a key from the wallet, determined by the sender encoded in the transaction. 

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();
final SignTransactionRequest signTransactionRequest = ; // SignTransactionRequest | 

try { 
    final response = api.signTransaction(signTransactionRequest);
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->signTransaction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **signTransactionRequest** | [**SignTransactionRequest**](SignTransactionRequest.md)|  | 

### Return type

[**APIV1POSTTransactionSignResponse**](APIV1POSTTransactionSignResponse.md)

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **swaggerHandler**
> String swaggerHandler()

Gets the current swagger spec.

Returns the entire swagger spec in json.

### Example 
```dart
import 'package:algorand_kmd/api.dart';
// TODO Configure API key authorization: api_key
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('api_key').apiKeyPrefix = 'Bearer';

final api = AlgorandKmd().getDefaultApi();

try { 
    final response = api.swaggerHandler();
    print(response);
} catch on DioError (e) {
    print('Exception when calling DefaultApi->swaggerHandler: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

[api_key](../README.md#api_key)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

