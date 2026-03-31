//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/apiv1_wallet_handle.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_wallet_renew_response.g.dart';

/// APIV1POSTWalletRenewResponse is the response to `POST /v1/wallet/renew` friendly:RenewWalletHandleTokenResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [walletHandle] 
abstract class APIV1POSTWalletRenewResponse implements Built<APIV1POSTWalletRenewResponse, APIV1POSTWalletRenewResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'wallet_handle')
    APIV1WalletHandle? get walletHandle;

    APIV1POSTWalletRenewResponse._();

    static void _initializeBuilder(APIV1POSTWalletRenewResponseBuilder b) => b;

    factory APIV1POSTWalletRenewResponse([void updates(APIV1POSTWalletRenewResponseBuilder b)]) = _$APIV1POSTWalletRenewResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTWalletRenewResponse> get serializer => _$APIV1POSTWalletRenewResponseSerializer();
}

class _$APIV1POSTWalletRenewResponseSerializer implements StructuredSerializer<APIV1POSTWalletRenewResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTWalletRenewResponse, _$APIV1POSTWalletRenewResponse];

    @override
    final String wireName = r'APIV1POSTWalletRenewResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTWalletRenewResponse object,
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
        if (object.walletHandle != null) {
            result
                ..add(r'wallet_handle')
                ..add(serializers.serialize(object.walletHandle,
                    specifiedType: const FullType(APIV1WalletHandle)));
        }
        return result;
    }

    @override
    APIV1POSTWalletRenewResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTWalletRenewResponseBuilder();

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
                case r'wallet_handle':
                    result.walletHandle.replace(serializers.deserialize(value,
                        specifiedType: const FullType(APIV1WalletHandle)) as APIV1WalletHandle);
                    break;
            }
        }
        return result.build();
    }
}

