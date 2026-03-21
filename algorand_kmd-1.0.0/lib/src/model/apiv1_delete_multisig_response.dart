//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_delete_multisig_response.g.dart';

/// APIV1DELETEMultisigResponse is the response to POST /v1/multisig/delete` friendly:DeleteMultisigResponse
///
/// Properties:
/// * [error] 
/// * [message] 
abstract class APIV1DELETEMultisigResponse implements Built<APIV1DELETEMultisigResponse, APIV1DELETEMultisigResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1DELETEMultisigResponse._();

    static void _initializeBuilder(APIV1DELETEMultisigResponseBuilder b) => b;

    factory APIV1DELETEMultisigResponse([void updates(APIV1DELETEMultisigResponseBuilder b)]) = _$APIV1DELETEMultisigResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1DELETEMultisigResponse> get serializer => _$APIV1DELETEMultisigResponseSerializer();
}

class _$APIV1DELETEMultisigResponseSerializer implements StructuredSerializer<APIV1DELETEMultisigResponse> {
    @override
    final Iterable<Type> types = const [APIV1DELETEMultisigResponse, _$APIV1DELETEMultisigResponse];

    @override
    final String wireName = r'APIV1DELETEMultisigResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1DELETEMultisigResponse object,
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
    APIV1DELETEMultisigResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1DELETEMultisigResponseBuilder();

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

