//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_multisig_list_response.g.dart';

/// APIV1POSTMultisigListResponse is the response to `POST /v1/multisig/list` friendly:ListMultisigResponse
///
/// Properties:
/// * [addresses] 
/// * [error] 
/// * [message] 
abstract class APIV1POSTMultisigListResponse implements Built<APIV1POSTMultisigListResponse, APIV1POSTMultisigListResponseBuilder> {
    @BuiltValueField(wireName: r'addresses')
    BuiltList<String>? get addresses;

    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTMultisigListResponse._();

    static void _initializeBuilder(APIV1POSTMultisigListResponseBuilder b) => b;

    factory APIV1POSTMultisigListResponse([void updates(APIV1POSTMultisigListResponseBuilder b)]) = _$APIV1POSTMultisigListResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMultisigListResponse> get serializer => _$APIV1POSTMultisigListResponseSerializer();
}

class _$APIV1POSTMultisigListResponseSerializer implements StructuredSerializer<APIV1POSTMultisigListResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMultisigListResponse, _$APIV1POSTMultisigListResponse];

    @override
    final String wireName = r'APIV1POSTMultisigListResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMultisigListResponse object,
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
    APIV1POSTMultisigListResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMultisigListResponseBuilder();

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

