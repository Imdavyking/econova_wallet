//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_key_response.g.dart';

/// APIV1POSTKeyResponse is the response to `POST /v1/key` friendly:GenerateKeyResponse
///
/// Properties:
/// * [address] 
/// * [error] 
/// * [message] 
abstract class APIV1POSTKeyResponse implements Built<APIV1POSTKeyResponse, APIV1POSTKeyResponseBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTKeyResponse._();

    static void _initializeBuilder(APIV1POSTKeyResponseBuilder b) => b;

    factory APIV1POSTKeyResponse([void updates(APIV1POSTKeyResponseBuilder b)]) = _$APIV1POSTKeyResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTKeyResponse> get serializer => _$APIV1POSTKeyResponseSerializer();
}

class _$APIV1POSTKeyResponseSerializer implements StructuredSerializer<APIV1POSTKeyResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTKeyResponse, _$APIV1POSTKeyResponse];

    @override
    final String wireName = r'APIV1POSTKeyResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTKeyResponse object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.address != null) {
            result
                ..add(r'address')
                ..add(serializers.serialize(object.address,
                    specifiedType: const FullType(String)));
        }
        if (object.error != null) {
            result
                ..add(r'error')
                ..add(serializers.serialize(object.error,
                    specifiedType: const FullType(bool)));
        }
        if (object.message != null) {
            result
                ..add(r'message')
                ..add(serializers.serialize(object.message,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTKeyResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTKeyResponseBuilder();

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
                case r'error':
                    result.error = serializers.deserialize(value,
                        specifiedType: const FullType(bool)) as bool;
                    break;
                case r'message':
                    result.message = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

