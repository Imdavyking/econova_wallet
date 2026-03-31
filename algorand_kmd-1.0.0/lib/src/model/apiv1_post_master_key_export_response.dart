//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_master_key_export_response.g.dart';

/// APIV1POSTMasterKeyExportResponse is the response to `POST /v1/master-key/export` friendly:ExportMasterKeyResponse
///
/// Properties:
/// * [error] 
/// * [masterDerivationKey] - MasterDerivationKey is used to derive ed25519 keys for use in wallets
/// * [message] 
abstract class APIV1POSTMasterKeyExportResponse implements Built<APIV1POSTMasterKeyExportResponse, APIV1POSTMasterKeyExportResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    /// MasterDerivationKey is used to derive ed25519 keys for use in wallets
    @BuiltValueField(wireName: r'master_derivation_key')
    BuiltList<int>? get masterDerivationKey;

    @BuiltValueField(wireName: r'message')
    String? get message;

    APIV1POSTMasterKeyExportResponse._();

    static void _initializeBuilder(APIV1POSTMasterKeyExportResponseBuilder b) => b;

    factory APIV1POSTMasterKeyExportResponse([void updates(APIV1POSTMasterKeyExportResponseBuilder b)]) = _$APIV1POSTMasterKeyExportResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMasterKeyExportResponse> get serializer => _$APIV1POSTMasterKeyExportResponseSerializer();
}

class _$APIV1POSTMasterKeyExportResponseSerializer implements StructuredSerializer<APIV1POSTMasterKeyExportResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMasterKeyExportResponse, _$APIV1POSTMasterKeyExportResponse];

    @override
    final String wireName = r'APIV1POSTMasterKeyExportResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMasterKeyExportResponse object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.error != null) {
            result
                ..add(r'error')
                ..add(serializers.serialize(object.error,
                    specifiedType: const FullType(bool)));
        }
        if (object.masterDerivationKey != null) {
            result
                ..add(r'master_derivation_key')
                ..add(serializers.serialize(object.masterDerivationKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
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
    APIV1POSTMasterKeyExportResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMasterKeyExportResponseBuilder();

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
                case r'master_derivation_key':
                    result.masterDerivationKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
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

