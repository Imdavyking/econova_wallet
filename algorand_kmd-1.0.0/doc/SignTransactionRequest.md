# algorand_kmd.model.SignTransactionRequest

## Load the model package
```dart
import 'package:algorand_kmd/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**publicKey** | **BuiltList&lt;int&gt;** |  | [optional] 
**transaction** | **String** | Base64 encoding of msgpack encoding of a `Transaction` object Note: SDK and goal usually generate `SignedTxn` objects in that case, the field `txn` / `Transaction` of the generated `SignedTxn` object needs to be used | [optional] 
**walletHandleToken** | **String** |  | [optional] 
**walletPassword** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


