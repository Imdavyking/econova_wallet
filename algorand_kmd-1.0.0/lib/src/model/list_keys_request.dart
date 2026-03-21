//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_keys_request.g.dart';

/// APIV1POSTKeyListRequest is the request for `POST /v1/key/list`
///
/// Properties:
/// * [walletHandleToken] 
abstract class ListKeysRequest implements Built<ListKeysRequest, ListKeysRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ListKeysRequest._();

    static void _initializeBuilder(ListKeysRequestBuilder b) => b;

    factory ListKeysRequest([void updates(ListKeysRequestBuilder b)]) = _$ListKeysRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ListKeysRequest> get serializer => _$ListKeysRequestSerializer();
}

class _$ListKeysRequestSerializer implements StructuredSerializer<ListKeysRequest> {
    @override
    final Iterable<Type> types = const [ListKeysRequest, _$ListKeysRequest];

    @override
    final String wireName = r'ListKeysRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ListKeysRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.walletHandleToken != null) {
            result
                ..add(r'wallet_handle_token')
                ..add(serializers.serialize(object.walletHandleToken,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    ListKeysRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ListKeysRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'wallet_handle_token':
                    result.walletHandleToken = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

