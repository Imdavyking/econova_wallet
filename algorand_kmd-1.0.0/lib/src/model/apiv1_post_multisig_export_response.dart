//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_multisig_export_response.g.dart';

/// APIV1POSTMultisigExportResponse is the response to `POST /v1/multisig/export` friendly:ExportMultisigResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [multisigVersion] 
/// * [pks] 
/// * [threshold] 
abstract class APIV1POSTMultisigExportResponse implements Built<APIV1POSTMultisigExportResponse, APIV1POSTMultisigExportResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'multisig_version')
    int? get multisigVersion;

    @BuiltValueField(wireName: r'pks')
    BuiltList<BuiltList<int>>? get pks;

    @BuiltValueField(wireName: r'threshold')
    int? get threshold;

    APIV1POSTMultisigExportResponse._();

    static void _initializeBuilder(APIV1POSTMultisigExportResponseBuilder b) => b;

    factory APIV1POSTMultisigExportResponse([void updates(APIV1POSTMultisigExportResponseBuilder b)]) = _$APIV1POSTMultisigExportResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMultisigExportResponse> get serializer => _$APIV1POSTMultisigExportResponseSerializer();
}

class _$APIV1POSTMultisigExportResponseSerializer implements StructuredSerializer<APIV1POSTMultisigExportResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMultisigExportResponse, _$APIV1POSTMultisigExportResponse];

    @override
    final String wireName = r'APIV1POSTMultisigExportResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMultisigExportResponse object,
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
        return result;
    }

    @override
    APIV1POSTMultisigExportResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMultisigExportResponseBuilder();

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
            }
        }
        return result.build();
    }
}

