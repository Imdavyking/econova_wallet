//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_delete_key_response.g.dart';

/// APIV1DELETEKeyResponse is the response to `DELETE /v1/key` friendly:DeleteKeyResponse
///
/// Properties:
/// * [error] 
/// * [message] 
abstract class APIV1DELETEKeyResponse implements Built<APIV1DELETEKeyResponse, APIV1DELETEKeyResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1DELETEKeyResponse._();

    static void _initializeBuilder(APIV1DELETEKeyResponseBuilder b) => b;

    factory APIV1DELETEKeyResponse([void updates(APIV1DELETEKeyResponseBuilder b)]) = _$APIV1DELETEKeyResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1DELETEKeyResponse> get serializer => _$APIV1DELETEKeyResponseSerializer();
}

class _$APIV1DELETEKeyResponseSerializer implements StructuredSerializer<APIV1DELETEKeyResponse> {
    @override
    final Iterable<Type> types = const [APIV1DELETEKeyResponse, _$APIV1DELETEKeyResponse];

    @override
    final String wireName = r'APIV1DELETEKeyResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1DELETEKeyResponse object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
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
    APIV1DELETEKeyResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1DELETEKeyResponseBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
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

