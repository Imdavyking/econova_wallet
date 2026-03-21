//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_wallet_release_response.g.dart';

/// APIV1POSTWalletReleaseResponse is the response to `POST /v1/wallet/release` friendly:ReleaseWalletHandleTokenResponse
///
/// Properties:
/// * [error] 
/// * [message] 
abstract class APIV1POSTWalletReleaseResponse implements Built<APIV1POSTWalletReleaseResponse, APIV1POSTWalletReleaseResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTWalletReleaseResponse._();

    static void _initializeBuilder(APIV1POSTWalletReleaseResponseBuilder b) => b;

    factory APIV1POSTWalletReleaseResponse([void updates(APIV1POSTWalletReleaseResponseBuilder b)]) = _$APIV1POSTWalletReleaseResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTWalletReleaseResponse> get serializer => _$APIV1POSTWalletReleaseResponseSerializer();
}

class _$APIV1POSTWalletReleaseResponseSerializer implements StructuredSerializer<APIV1POSTWalletReleaseResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTWalletReleaseResponse, _$APIV1POSTWalletReleaseResponse];

    @override
    final String wireName = r'APIV1POSTWalletReleaseResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTWalletReleaseResponse object,
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
        return result;
    }

    @override
    APIV1POSTWalletReleaseResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTWalletReleaseResponseBuilder();

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
            }
        }
        return result.build();
    }
}

