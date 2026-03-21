//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_multisig_request.g.dart';

/// APIV1POSTMultisigExportRequest is the request for `POST /v1/multisig/export`
///
/// Properties:
/// * [address] 
/// * [walletHandleToken] 
abstract class ExportMultisigRequest implements Built<ExportMultisigRequest, ExportMultisigRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ExportMultisigRequest._();

    static void _initializeBuilder(ExportMultisigRequestBuilder b) => b;

    factory ExportMultisigRequest([void updates(ExportMultisigRequestBuilder b)]) = _$ExportMultisigRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ExportMultisigRequest> get serializer => _$ExportMultisigRequestSerializer();
}

class _$ExportMultisigRequestSerializer implements StructuredSerializer<ExportMultisigRequest> {
    @override
    final Iterable<Type> types = const [ExportMultisigRequest, _$ExportMultisigRequest];

    @override
    final String wireName = r'ExportMultisigRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ExportMultisigRequest object,
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
        return result;
    }

    @override
    ExportMultisigRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ExportMultisigRequestBuilder();

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
            }
        }
        return result.build();
    }
}

