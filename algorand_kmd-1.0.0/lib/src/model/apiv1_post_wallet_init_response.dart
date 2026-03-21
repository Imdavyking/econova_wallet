//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_wallet_init_response.g.dart';

/// APIV1POSTWalletInitResponse is the response to `POST /v1/wallet/init` friendly:InitWalletHandleTokenResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [walletHandleToken] 
abstract class APIV1POSTWalletInitResponse implements Built<APIV1POSTWalletInitResponse, APIV1POSTWalletInitResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    APIV1POSTWalletInitResponse._();

    static void _initializeBuilder(APIV1POSTWalletInitResponseBuilder b) => b;

    factory APIV1POSTWalletInitResponse([void updates(APIV1POSTWalletInitResponseBuilder b)]) = _$APIV1POSTWalletInitResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTWalletInitResponse> get serializer => _$APIV1POSTWalletInitResponseSerializer();
}

class _$APIV1POSTWalletInitResponseSerializer implements StructuredSerializer<APIV1POSTWalletInitResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTWalletInitResponse, _$APIV1POSTWalletInitResponse];

    @override
    final String wireName = r'APIV1POSTWalletInitResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTWalletInitResponse object,
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
        if (object.walletHandleToken != null) {
            result
                ..add(r'wallet_handle_token')
                ..add(serializers.serialize(object.walletHandleToken,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTWalletInitResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTWalletInitResponseBuilder();

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
                case r'wallet_handle_token':
                    result.walletHandleToken = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

