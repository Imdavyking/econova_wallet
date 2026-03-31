//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'wallet_info_request.g.dart';

/// APIV1POSTWalletInfoRequest is the request for `POST /v1/wallet/info`
///
/// Properties:
/// * [walletHandleToken] 
abstract class WalletInfoRequest implements Built<WalletInfoRequest, WalletInfoRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    WalletInfoRequest._();

    static void _initializeBuilder(WalletInfoRequestBuilder b) => b;

    factory WalletInfoRequest([void updates(WalletInfoRequestBuilder b)]) = _$WalletInfoRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<WalletInfoRequest> get serializer => _$WalletInfoRequestSerializer();
}

class _$WalletInfoRequestSerializer implements StructuredSerializer<WalletInfoRequest> {
    @override
    final Iterable<Type> types = const [WalletInfoRequest, _$WalletInfoRequest];

    @override
    final String wireName = r'WalletInfoRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, WalletInfoRequest object,
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
    WalletInfoRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = WalletInfoRequestBuilder();

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

