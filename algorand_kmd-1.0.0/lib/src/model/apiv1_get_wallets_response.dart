//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/apiv1_wallet.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_get_wallets_response.g.dart';

/// APIV1GETWalletsResponse is the response to `GET /v1/wallets` friendly:ListWalletsResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [wallets] 
abstract class APIV1GETWalletsResponse implements Built<APIV1GETWalletsResponse, APIV1GETWalletsResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'wallets')
    BuiltList<APIV1Wallet>? get wallets;

    APIV1GETWalletsResponse._();

    static void _initializeBuilder(APIV1GETWalletsResponseBuilder b) => b;

    factory APIV1GETWalletsResponse([void updates(APIV1GETWalletsResponseBuilder b)]) = _$APIV1GETWalletsResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1GETWalletsResponse> get serializer => _$APIV1GETWalletsResponseSerializer();
}

class _$APIV1GETWalletsResponseSerializer implements StructuredSerializer<APIV1GETWalletsResponse> {
    @override
    final Iterable<Type> types = const [APIV1GETWalletsResponse, _$APIV1GETWalletsResponse];

    @override
    final String wireName = r'APIV1GETWalletsResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1GETWalletsResponse object,
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
        if (object.wallets != null) {
            result
                ..add(r'wallets')
                ..add(serializers.serialize(object.wallets,
                    specifiedType: const FullType(BuiltList, [FullType(APIV1Wallet)])));
        }
        return result;
    }

    @override
    APIV1GETWalletsResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1GETWalletsResponseBuilder();

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
                case r'wallets':
                    result.wallets.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(APIV1Wallet)])) as BuiltList<APIV1Wallet>);
                    break;
            }
        }
        return result.build();
    }
}

