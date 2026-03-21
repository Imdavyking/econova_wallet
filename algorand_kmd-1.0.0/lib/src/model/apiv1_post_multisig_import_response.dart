//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_multisig_import_response.g.dart';

/// APIV1POSTMultisigImportResponse is the response to `POST /v1/multisig/import` friendly:ImportMultisigResponse
///
/// Properties:
/// * [address] 
/// * [error] 
/// * [message] 
abstract class APIV1POSTMultisigImportResponse implements Built<APIV1POSTMultisigImportResponse, APIV1POSTMultisigImportResponseBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTMultisigImportResponse._();

    static void _initializeBuilder(APIV1POSTMultisigImportResponseBuilder b) => b;

    factory APIV1POSTMultisigImportResponse([void updates(APIV1POSTMultisigImportResponseBuilder b)]) = _$APIV1POSTMultisigImportResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMultisigImportResponse> get serializer => _$APIV1POSTMultisigImportResponseSerializer();
}

class _$APIV1POSTMultisigImportResponseSerializer implements StructuredSerializer<APIV1POSTMultisigImportResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMultisigImportResponse, _$APIV1POSTMultisigImportResponse];

    @override
    final String wireName = r'APIV1POSTMultisigImportResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMultisigImportResponse object,
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
    APIV1POSTMultisigImportResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMultisigImportResponseBuilder();

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

