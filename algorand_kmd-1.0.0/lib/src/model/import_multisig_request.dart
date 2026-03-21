//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_multisig_request.g.dart';

/// APIV1POSTMultisigImportRequest is the request for `POST /v1/multisig/import`
///
/// Properties:
/// * [multisigVersion] 
/// * [pks] 
/// * [threshold] 
/// * [walletHandleToken] 
abstract class ImportMultisigRequest implements Built<ImportMultisigRequest, ImportMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'multisig_version')
    int? get multisigVersion;

    @BuiltValueField(wireName: r'pks')
    BuiltList<BuiltList<int>>? get pks;

    @BuiltValueField(wireName: r'threshold')
    int? get threshold;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ImportMultisigRequest._();

    static void _initializeBuilder(ImportMultisigRequestBuilder b) => b;

    factory ImportMultisigRequest([void updates(ImportMultisigRequestBuilder b)]) = _$ImportMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ImportMultisigRequest> get serializer => _$ImportMultisigRequestSerializer();
}

class _$ImportMultisigRequestSerializer implements StructuredSerializer<ImportMultisigRequest> {
    @override
    final Iterable<Type> types = const [ImportMultisigRequest, _$ImportMultisigRequest];

    @override
    final String wireName = r'ImportMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ImportMultisigRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.multisigVersion != null) {
            result
                ..add(r'multisig_version')
                ..add(serializers.serialize(object.multisigVersion,
                    specifiedType: const FullType(int)));
        }
        if (object.pks != null) {
            result
                ..add(r'pks')
                ..add(serializers.serialize(object.pks,
                    specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(int)])])));
        }
        if (object.threshold != null) {
            result
                ..add(r'threshold')
                ..add(serializers.serialize(object.threshold,
                    specifiedType: const FullType(int)));
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
    ImportMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ImportMultisigRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'multisig_version':
                    result.multisigVersion = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
                    break;
                case r'pks':
                    result.pks.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(int)])])) as BuiltList<BuiltList<int>>);
                    break;
                case r'threshold':
                    result.threshold = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
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

