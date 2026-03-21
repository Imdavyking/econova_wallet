//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'renew_wallet_handle_token_request.g.dart';

/// APIV1POSTWalletRenewRequest is the request for `POST /v1/wallet/renew`
///
/// Properties:
/// * [walletHandleToken] 
abstract class RenewWalletHandleTokenRequest implements Built<RenewWalletHandleTokenRequest, RenewWalletHandleTokenRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    RenewWalletHandleTokenRequest._();

    static void _initializeBuilder(RenewWalletHandleTokenRequestBuilder b) => b;

    factory RenewWalletHandleTokenRequest([void updates(RenewWalletHandleTokenRequestBuilder b)]) = _$RenewWalletHandleTokenRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<RenewWalletHandleTokenRequest> get serializer => _$RenewWalletHandleTokenRequestSerializer();
}

class _$RenewWalletHandleTokenRequestSerializer implements StructuredSerializer<RenewWalletHandleTokenRequest> {
    @override
    final Iterable<Type> types = const [RenewWalletHandleTokenRequest, _$RenewWalletHandleTokenRequest];

    @override
    final String wireName = r'RenewWalletHandleTokenRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, RenewWalletHandleTokenRequest object,
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
    RenewWalletHandleTokenRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = RenewWalletHandleTokenRequestBuilder();

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

