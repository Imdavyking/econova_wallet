//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'generate_key_request.g.dart';

/// APIV1POSTKeyRequest is the request for `POST /v1/key`
///
/// Properties:
/// * [displayMnemonic] 
/// * [walletHandleToken] 
abstract class GenerateKeyRequest implements Built<GenerateKeyRequest, GenerateKeyRequestBuilder> {
    @BuiltValueField(wireName: r'display_mnemonic')
    bool? get displayMnemonic;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    GenerateKeyRequest._();

    static void _initializeBuilder(GenerateKeyRequestBuilder b) => b;

    factory GenerateKeyRequest([void updates(GenerateKeyRequestBuilder b)]) = _$GenerateKeyRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<GenerateKeyRequest> get serializer => _$GenerateKeyRequestSerializer();
}

class _$GenerateKeyRequestSerializer implements StructuredSerializer<GenerateKeyRequest> {
    @override
    final Iterable<Type> types = const [GenerateKeyRequest, _$GenerateKeyRequest];

    @override
    final String wireName = r'GenerateKeyRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, GenerateKeyRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.displayMnemonic != null) {
            result
                ..add(r'display_mnemonic')
                ..add(serializers.serialize(object.displayMnemonic,
                    specifiedType: const FullType(bool)));
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
    GenerateKeyRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = GenerateKeyRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'display_mnemonic':
                    result.displayMnemonic = serializers.deserialize(value,
                        specifiedType: const FullType(bool)) as bool;
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

