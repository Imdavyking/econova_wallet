//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_master_key_request.g.dart';

/// APIV1POSTMasterKeyExportRequest is the request for `POST /v1/master-key/export`
///
/// Properties:
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class ExportMasterKeyRequest implements Built<ExportMasterKeyRequest, ExportMasterKeyRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    ExportMasterKeyRequest._();

    static void _initializeBuilder(ExportMasterKeyRequestBuilder b) => b;

    factory ExportMasterKeyRequest([void updates(ExportMasterKeyRequestBuilder b)]) = _$ExportMasterKeyRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ExportMasterKeyRequest> get serializer => _$ExportMasterKeyRequestSerializer();
}

class _$ExportMasterKeyRequestSerializer implements StructuredSerializer<ExportMasterKeyRequest> {
    @override
    final Iterable<Type> types = const [ExportMasterKeyRequest, _$ExportMasterKeyRequest];

    @override
    final String wireName = r'ExportMasterKeyRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ExportMasterKeyRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
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
    ExportMasterKeyRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ExportMasterKeyRequestBuilder();

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
                case r'wallet_password':
                    result.walletPassword = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

