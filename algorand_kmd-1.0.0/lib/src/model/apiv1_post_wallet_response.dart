//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/apiv1_wallet.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_wallet_response.g.dart';

/// APIV1POSTWalletResponse is the response to `POST /v1/wallet` friendly:CreateWalletResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [wallet] 
abstract class APIV1POSTWalletResponse implements Built<APIV1POSTWalletResponse, APIV1POSTWalletResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'wallet')
    APIV1Wallet? get wallet;

    APIV1POSTWalletResponse._();

    static void _initializeBuilder(APIV1POSTWalletResponseBuilder b) => b;

    factory APIV1POSTWalletResponse([void updates(APIV1POSTWalletResponseBuilder b)]) = _$APIV1POSTWalletResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTWalletResponse> get serializer => _$APIV1POSTWalletResponseSerializer();
}

class _$APIV1POSTWalletResponseSerializer implements StructuredSerializer<APIV1POSTWalletResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTWalletResponse, _$APIV1POSTWalletResponse];

    @override
    final String wireName = r'APIV1POSTWalletResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTWalletResponse object,
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
        if (object.wallet != null) {
            result
                ..add(r'wallet')
                ..add(serializers.serialize(object.wallet,
                    specifiedType: const FullType(APIV1Wallet)));
        }
        return result;
    }

    @override
    APIV1POSTWalletResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTWalletResponseBuilder();

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
                case r'wallet':
                    result.wallet.replace(serializers.deserialize(value,
                        specifiedType: const FullType(APIV1Wallet)) as APIV1Wallet);
                    break;
            }
        }
        return result.build();
    }
}

