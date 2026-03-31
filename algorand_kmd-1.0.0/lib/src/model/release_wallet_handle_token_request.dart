//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'release_wallet_handle_token_request.g.dart';

/// APIV1POSTWalletReleaseRequest is the request for `POST /v1/wallet/release`
///
/// Properties:
/// * [walletHandleToken] 
abstract class ReleaseWalletHandleTokenRequest implements Built<ReleaseWalletHandleTokenRequest, ReleaseWalletHandleTokenRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ReleaseWalletHandleTokenRequest._();

    static void _initializeBuilder(ReleaseWalletHandleTokenRequestBuilder b) => b;

    factory ReleaseWalletHandleTokenRequest([void updates(ReleaseWalletHandleTokenRequestBuilder b)]) = _$ReleaseWalletHandleTokenRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ReleaseWalletHandleTokenRequest> get serializer => _$ReleaseWalletHandleTokenRequestSerializer();
}

class _$ReleaseWalletHandleTokenRequestSerializer implements StructuredSerializer<ReleaseWalletHandleTokenRequest> {
    @override
    final Iterable<Type> types = const [ReleaseWalletHandleTokenRequest, _$ReleaseWalletHandleTokenRequest];

    @override
    final String wireName = r'ReleaseWalletHandleTokenRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ReleaseWalletHandleTokenRequest object,
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
    ReleaseWalletHandleTokenRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ReleaseWalletHandleTokenRequestBuilder();

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

