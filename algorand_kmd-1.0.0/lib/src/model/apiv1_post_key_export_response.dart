//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_key_export_response.g.dart';

/// APIV1POSTKeyExportResponse is the response to `POST /v1/key/export` friendly:ExportKeyResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [privateKey] 
abstract class APIV1POSTKeyExportResponse implements Built<APIV1POSTKeyExportResponse, APIV1POSTKeyExportResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'private_key')
    BuiltList<int>? get privateKey;

    APIV1POSTKeyExportResponse._();

    static void _initializeBuilder(APIV1POSTKeyExportResponseBuilder b) => b;

    factory APIV1POSTKeyExportResponse([void updates(APIV1POSTKeyExportResponseBuilder b)]) = _$APIV1POSTKeyExportResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTKeyExportResponse> get serializer => _$APIV1POSTKeyExportResponseSerializer();
}

class _$APIV1POSTKeyExportResponseSerializer implements StructuredSerializer<APIV1POSTKeyExportResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTKeyExportResponse, _$APIV1POSTKeyExportResponse];

    @override
    final String wireName = r'APIV1POSTKeyExportResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTKeyExportResponse object,
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
        if (object.privateKey != null) {
            result
                ..add(r'private_key')
                ..add(serializers.serialize(object.privateKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        return result;
    }

    @override
    APIV1POSTKeyExportResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTKeyExportResponseBuilder();

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
                case r'private_key':
                    result.privateKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
            }
        }
        return result.build();
    }
}

