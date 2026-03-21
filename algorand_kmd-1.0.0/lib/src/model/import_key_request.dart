//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_key_request.g.dart';

/// APIV1POSTKeyImportRequest is the request for `POST /v1/key/import`
///
/// Properties:
/// * [privateKey] 
/// * [walletHandleToken] 
abstract class ImportKeyRequest implements Built<ImportKeyRequest, ImportKeyRequestBuilder> {
    @BuiltValueField(wireName: r'private_key')
    BuiltList<int>? get privateKey;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    ImportKeyRequest._();

    static void _initializeBuilder(ImportKeyRequestBuilder b) => b;

    factory ImportKeyRequest([void updates(ImportKeyRequestBuilder b)]) = _$ImportKeyRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<ImportKeyRequest> get serializer => _$ImportKeyRequestSerializer();
}

class _$ImportKeyRequestSerializer implements StructuredSerializer<ImportKeyRequest> {
    @override
    final Iterable<Type> types = const [ImportKeyRequest, _$ImportKeyRequest];

    @override
    final String wireName = r'ImportKeyRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, ImportKeyRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.privateKey != null) {
            result
                ..add(r'private_key')
                ..add(serializers.serialize(object.privateKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
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
    ImportKeyRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = ImportKeyRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'private_key':
                    result.privateKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
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

