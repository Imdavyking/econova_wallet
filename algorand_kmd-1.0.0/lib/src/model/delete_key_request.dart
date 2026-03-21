//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_key_request.g.dart';

/// APIV1DELETEKeyRequest is the request for `DELETE /v1/key`
///
/// Properties:
/// * [address] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class DeleteKeyRequest implements Built<DeleteKeyRequest, DeleteKeyRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    DeleteKeyRequest._();

    static void _initializeBuilder(DeleteKeyRequestBuilder b) => b;

    factory DeleteKeyRequest([void updates(DeleteKeyRequestBuilder b)]) = _$DeleteKeyRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<DeleteKeyRequest> get serializer => _$DeleteKeyRequestSerializer();
}

class _$DeleteKeyRequestSerializer implements StructuredSerializer<DeleteKeyRequest> {
    @override
    final Iterable<Type> types = const [DeleteKeyRequest, _$DeleteKeyRequest];

    @override
    final String wireName = r'DeleteKeyRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, DeleteKeyRequest object,
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
    DeleteKeyRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = DeleteKeyRequestBuilder();

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

