//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_multisig_request.g.dart';

/// APIV1DELETEMultisigRequest is the request for `DELETE /v1/multisig`
///
/// Properties:
/// * [address] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class DeleteMultisigRequest implements Built<DeleteMultisigRequest, DeleteMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    DeleteMultisigRequest._();

    static void _initializeBuilder(DeleteMultisigRequestBuilder b) => b;

    factory DeleteMultisigRequest([void updates(DeleteMultisigRequestBuilder b)]) = _$DeleteMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<DeleteMultisigRequest> get serializer => _$DeleteMultisigRequestSerializer();
}

class _$DeleteMultisigRequestSerializer implements StructuredSerializer<DeleteMultisigRequest> {
    @override
    final Iterable<Type> types = const [DeleteMultisigRequest, _$DeleteMultisigRequest];

    @override
    final String wireName = r'DeleteMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, DeleteMultisigRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.address != null) {
            result
                ..add(r'address')
                ..add(serializers.serialize(object.address,
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
    DeleteMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = DeleteMultisigRequestBuilder();

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

