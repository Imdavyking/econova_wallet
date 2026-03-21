//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_key_request.g.dart';

/// APIV1POSTKeyExportRequest is the request for `POST /v1/key/export`
///
/// Properties:
/// * [address] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class ExportKeyRequest implements Built<ExportKeyRequest, ExportKeyRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    ExportKeyRequest._();

    static void _initializeBuilder(ExportKeyRequestBuilder b) => b;

    factory ExportKeyRequest([void updates(ExportKeyRequestBuilder b)]) = _$ExportKeyRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ExportKeyRequest> get serializer => _$ExportKeyRequestSerializer();
}

class _$ExportKeyRequestSerializer implements StructuredSerializer<ExportKeyRequest> {
    @override
    final Iterable<Type> types = const [ExportKeyRequest, _$ExportKeyRequest];

    @override
    final String wireName = r'ExportKeyRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ExportKeyRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.address != null) {
            result
                ..add(r'address')
                ..add(serializers.serialize(object.address,
                    specifiedType: const FullType(String)));
        }
        if (object.walletHandleToken != null) {
            result
                ..add(r'wallet_handle_token')
                ..add(serializers.serialize(object.walletHandleToken,
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
    ExportKeyRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ExportKeyRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'address':
                    result.address = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_handle_token':
                    result.walletHandleToken = serializers.deserialize(value,
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

