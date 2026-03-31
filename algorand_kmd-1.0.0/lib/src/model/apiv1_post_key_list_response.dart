//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_key_list_response.g.dart';

/// APIV1POSTKeyListResponse is the response to `POST /v1/key/list` friendly:ListKeysResponse
///
/// Properties:
/// * [addresses] 
/// * [error] 
/// * [message] 
abstract class APIV1POSTKeyListResponse implements Built<APIV1POSTKeyListResponse, APIV1POSTKeyListResponseBuilder> {
    @BuiltValueField(wireName: r'addresses')
    BuiltList<String>? get addresses;

    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTKeyListResponse._();

    static void _initializeBuilder(APIV1POSTKeyListResponseBuilder b) => b;

    factory APIV1POSTKeyListResponse([void updates(APIV1POSTKeyListResponseBuilder b)]) = _$APIV1POSTKeyListResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTKeyListResponse> get serializer => _$APIV1POSTKeyListResponseSerializer();
}

class _$APIV1POSTKeyListResponseSerializer implements StructuredSerializer<APIV1POSTKeyListResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTKeyListResponse, _$APIV1POSTKeyListResponse];

    @override
    final String wireName = r'APIV1POSTKeyListResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTKeyListResponse object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.addresses != null) {
            result
                ..add(r'addresses')
                ..add(serializers.serialize(object.addresses,
                    specifiedType: const FullType(BuiltList, [FullType(String)])));
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
    APIV1POSTKeyListResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTKeyListResponseBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'addresses':
                    result.addresses.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(String)])) as BuiltList<String>);
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

