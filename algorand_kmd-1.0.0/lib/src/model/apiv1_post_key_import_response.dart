//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_key_import_response.g.dart';

/// APIV1POSTKeyImportResponse is the response to `POST /v1/key/import` friendly:ImportKeyResponse
///
/// Properties:
/// * [address] 
/// * [error] 
/// * [message] 
abstract class APIV1POSTKeyImportResponse implements Built<APIV1POSTKeyImportResponse, APIV1POSTKeyImportResponseBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTKeyImportResponse._();

    static void _initializeBuilder(APIV1POSTKeyImportResponseBuilder b) => b;

    factory APIV1POSTKeyImportResponse([void updates(APIV1POSTKeyImportResponseBuilder b)]) = _$APIV1POSTKeyImportResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTKeyImportResponse> get serializer => _$APIV1POSTKeyImportResponseSerializer();
}

class _$APIV1POSTKeyImportResponseSerializer implements StructuredSerializer<APIV1POSTKeyImportResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTKeyImportResponse, _$APIV1POSTKeyImportResponse];

    @override
    final String wireName = r'APIV1POSTKeyImportResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTKeyImportResponse object,
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
    APIV1POSTKeyImportResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTKeyImportResponseBuilder();

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

