//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_program_sign_response.g.dart';

/// APIV1POSTProgramSignResponse is the response to `POST /v1/data/sign` friendly:SignProgramResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [sig] 
abstract class APIV1POSTProgramSignResponse implements Built<APIV1POSTProgramSignResponse, APIV1POSTProgramSignResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'sig')
    String? get sig;

    APIV1POSTProgramSignResponse._();

    static void _initializeBuilder(APIV1POSTProgramSignResponseBuilder b) => b;

    factory APIV1POSTProgramSignResponse([void updates(APIV1POSTProgramSignResponseBuilder b)]) = _$APIV1POSTProgramSignResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTProgramSignResponse> get serializer => _$APIV1POSTProgramSignResponseSerializer();
}

class _$APIV1POSTProgramSignResponseSerializer implements StructuredSerializer<APIV1POSTProgramSignResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTProgramSignResponse, _$APIV1POSTProgramSignResponse];

    @override
    final String wireName = r'APIV1POSTProgramSignResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTProgramSignResponse object,
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
        if (object.sig != null) {
            result
                ..add(r'sig')
                ..add(serializers.serialize(object.sig,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTProgramSignResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTProgramSignResponseBuilder();

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
                case r'sig':
                    result.sig = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

