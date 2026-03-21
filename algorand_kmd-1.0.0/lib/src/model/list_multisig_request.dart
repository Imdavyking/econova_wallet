//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_multisig_request.g.dart';

/// APIV1POSTMultisigListRequest is the request for `POST /v1/multisig/list`
///
/// Properties:
/// * [walletHandleToken] 
abstract class ListMultisigRequest implements Built<ListMultisigRequest, ListMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ListMultisigRequest._();

    static void _initializeBuilder(ListMultisigRequestBuilder b) => b;

    factory ListMultisigRequest([void updates(ListMultisigRequestBuilder b)]) = _$ListMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ListMultisigRequest> get serializer => _$ListMultisigRequestSerializer();
}

class _$ListMultisigRequestSerializer implements StructuredSerializer<ListMultisigRequest> {
    @override
    final Iterable<Type> types = const [ListMultisigRequest, _$ListMultisigRequest];

    @override
    final String wireName = r'ListMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ListMultisigRequest object,
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
    ListMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ListMultisigRequestBuilder();

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

