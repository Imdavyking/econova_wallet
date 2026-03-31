//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:algorand_kmd/src/model/multisig_sig.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sign_program_multisig_request.g.dart';

/// APIV1POSTMultisigProgramSignRequest is the request for `POST /v1/multisig/signprogram`
///
/// Properties:
/// * [address] 
/// * [data] 
/// * [partialMultisig] 
/// * [publicKey] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class SignProgramMultisigRequest implements Built<SignProgramMultisigRequest, SignProgramMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'data')
    String? get data;

    @BuiltValueField(wireName: r'partial_multisig')
    MultisigSig? get partialMultisig;

    @BuiltValueField(wireName: r'public_key')
    BuiltList<int>? get publicKey;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    SignProgramMultisigRequest._();

    static void _initializeBuilder(SignProgramMultisigRequestBuilder b) => b;

    factory SignProgramMultisigRequest([void updates(SignProgramMultisigRequestBuilder b)]) = _$SignProgramMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<SignProgramMultisigRequest> get serializer => _$SignProgramMultisigRequestSerializer();
}

class _$SignProgramMultisigRequestSerializer implements StructuredSerializer<SignProgramMultisigRequest> {
    @override
    final Iterable<Type> types = const [SignProgramMultisigRequest, _$SignProgramMultisigRequest];

    @override
    final String wireName = r'SignProgramMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, SignProgramMultisigRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.address != null) {
            result
                ..add(r'address')
                ..add(serializers.serialize(object.address,
                    specifiedType: const FullType(String)));
        }
        if (object.data != null) {
            result
                ..add(r'data')
                ..add(serializers.serialize(object.data,
                    specifiedType: const FullType(String)));
        }
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
    SignProgramMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = SignProgramMultisigRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'address':
                    result.address = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'data':
                    result.data = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'partial_multisig':
                    result.partialMultisig.replace(serializers.deserialize(value,
                        specifiedType: const FullType(MultisigSig)) as MultisigSig);
                    break;
                case r'public_key':
                    result.publicKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
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

