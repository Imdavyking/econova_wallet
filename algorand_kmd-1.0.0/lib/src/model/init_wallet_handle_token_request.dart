//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'init_wallet_handle_token_request.g.dart';

/// APIV1POSTWalletInitRequest is the request for `POST /v1/wallet/init`
///
/// Properties:
/// * [walletId] 
/// * [walletPassword] 
abstract class InitWalletHandleTokenRequest implements Built<InitWalletHandleTokenRequest, InitWalletHandleTokenRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_id')
    String? get walletId;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    InitWalletHandleTokenRequest._();

    static void _initializeBuilder(InitWalletHandleTokenRequestBuilder b) => b;

    factory InitWalletHandleTokenRequest([void updates(InitWalletHandleTokenRequestBuilder b)]) = _$InitWalletHandleTokenRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<InitWalletHandleTokenRequest> get serializer => _$InitWalletHandleTokenRequestSerializer();
}

class _$InitWalletHandleTokenRequestSerializer implements StructuredSerializer<InitWalletHandleTokenRequest> {
    @override
    final Iterable<Type> types = const [InitWalletHandleTokenRequest, _$InitWalletHandleTokenRequest];

    @override
    final String wireName = r'InitWalletHandleTokenRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, InitWalletHandleTokenRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.walletId != null) {
            result
                ..add(r'wallet_id')
                ..add(serializers.serialize(object.walletId,
                    specifiedType: const FullType(String)));
        }
        if (object.walletPassword != null) {
            result
                ..add(r'wallet_password')
                ..add(serializers.serialize(object.walletPassword,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    InitWalletHandleTokenRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = InitWalletHandleTokenRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'wallet_id':
                    result.walletId = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_password':
                    result.walletPassword = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

