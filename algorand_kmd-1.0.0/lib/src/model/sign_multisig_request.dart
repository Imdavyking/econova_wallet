//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:algorand_kmd/src/model/multisig_sig.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sign_multisig_request.g.dart';

/// APIV1POSTMultisigTransactionSignRequest is the request for `POST /v1/multisig/sign`
///
/// Properties:
/// * [partialMultisig] 
/// * [publicKey] 
/// * [signer] 
/// * [transaction] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class SignMultisigRequest implements Built<SignMultisigRequest, SignMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'partial_multisig')
    MultisigSig? get partialMultisig;

    @BuiltValueField(wireName: r'public_key')
    BuiltList<int>? get publicKey;

    @BuiltValueField(wireName: r'signer')
    BuiltList<int>? get signer;

    @BuiltValueField(wireName: r'transaction')
    String? get transaction;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    SignMultisigRequest._();

    static void _initializeBuilder(SignMultisigRequestBuilder b) => b;

    factory SignMultisigRequest([void updates(SignMultisigRequestBuilder b)]) = _$SignMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<SignMultisigRequest> get serializer => _$SignMultisigRequestSerializer();
}

class _$SignMultisigRequestSerializer implements StructuredSerializer<SignMultisigRequest> {
    @override
    final Iterable<Type> types = const [SignMultisigRequest, _$SignMultisigRequest];

    @override
    final String wireName = r'SignMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, SignMultisigRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.partialMultisig != null) {
            result
                ..add(r'partial_multisig')
                ..add(serializers.serialize(object.partialMultisig,
                    specifiedType: const FullType(MultisigSig)));
        }
        if (object.publicKey != null) {
            result
                ..add(r'public_key')
                ..add(serializers.serialize(object.publicKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        if (object.signer != null) {
            result
                ..add(r'signer')
                ..add(serializers.serialize(object.signer,
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
    SignMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = SignMultisigRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'partial_multisig':
                    result.partialMultisig.replace(serializers.deserialize(value,
                        specifiedType: const FullType(MultisigSig)) as MultisigSig);
                    break;
                case r'public_key':
                    result.publicKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
                case r'signer':
                    result.signer.replace(serializers.deserialize(value,
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

