//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sign_transaction_request.g.dart';

/// APIV1POSTTransactionSignRequest is the request for `POST /v1/transaction/sign`
///
/// Properties:
/// * [publicKey] 
/// * [transaction] - Base64 encoding of msgpack encoding of a `Transaction` object Note: SDK and goal usually generate `SignedTxn` objects in that case, the field `txn` / `Transaction` of the generated `SignedTxn` object needs to be used
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class SignTransactionRequest implements Built<SignTransactionRequest, SignTransactionRequestBuilder> {
    @BuiltValueField(wireName: r'public_key')
    BuiltList<int>? get publicKey;

    /// Base64 encoding of msgpack encoding of a `Transaction` object Note: SDK and goal usually generate `SignedTxn` objects in that case, the field `txn` / `Transaction` of the generated `SignedTxn` object needs to be used
    @BuiltValueField(wireName: r'transaction')
    String? get transaction;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    SignTransactionRequest._();

    static void _initializeBuilder(SignTransactionRequestBuilder b) => b;

    factory SignTransactionRequest([void updates(SignTransactionRequestBuilder b)]) = _$SignTransactionRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<SignTransactionRequest> get serializer => _$SignTransactionRequestSerializer();
}

class _$SignTransactionRequestSerializer implements StructuredSerializer<SignTransactionRequest> {
    @override
    final Iterable<Type> types = const [SignTransactionRequest, _$SignTransactionRequest];

    @override
    final String wireName = r'SignTransactionRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, SignTransactionRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.publicKey != null) {
            result
                ..add(r'public_key')
                ..add(serializers.serialize(object.publicKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        if (object.transaction != null) {
            result
                ..add(r'transaction')
                ..add(serializers.serialize(object.transaction,
                    specifiedType: const FullType(String)));
        }
        if (object.walletHandleToken != null) {
            result
                ..add(r'wallet_handle_token')
                ..add(serializers.serialize(object.walletHandleToken,
                    specifiedType: const FullType(String)));
        }
        if (object.walletPassword != null) {
            result
                ..add(r'wallet_password')
                ..add(serializers.serialize(object.walletPassword,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    SignTransactionRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = SignTransactionRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'public_key':
                    result.publicKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
                case r'transaction':
                    result.transaction = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_handle_token':
                    result.walletHandleToken = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_password':
                    result.walletPassword = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

