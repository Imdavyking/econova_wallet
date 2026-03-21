//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_multisig_program_sign_response.g.dart';

/// APIV1POSTMultisigProgramSignResponse is the response to `POST /v1/multisig/signdata` friendly:SignProgramMultisigResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [multisig] 
abstract class APIV1POSTMultisigProgramSignResponse implements Built<APIV1POSTMultisigProgramSignResponse, APIV1POSTMultisigProgramSignResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'multisig')
    String? get multisig;

    APIV1POSTMultisigProgramSignResponse._();

    static void _initializeBuilder(APIV1POSTMultisigProgramSignResponseBuilder b) => b;

    factory APIV1POSTMultisigProgramSignResponse([void updates(APIV1POSTMultisigProgramSignResponseBuilder b)]) = _$APIV1POSTMultisigProgramSignResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMultisigProgramSignResponse> get serializer => _$APIV1POSTMultisigProgramSignResponseSerializer();
}

class _$APIV1POSTMultisigProgramSignResponseSerializer implements StructuredSerializer<APIV1POSTMultisigProgramSignResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMultisigProgramSignResponse, _$APIV1POSTMultisigProgramSignResponse];

    @override
    final String wireName = r'APIV1POSTMultisigProgramSignResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMultisigProgramSignResponse object,
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
        if (object.multisig != null) {
            result
                ..add(r'multisig')
                ..add(serializers.serialize(object.multisig,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTMultisigProgramSignResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMultisigProgramSignResponseBuilder();

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
                case r'multisig':
                    result.multisig = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

