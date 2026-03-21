//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_multisig_transaction_sign_response.g.dart';

/// APIV1POSTMultisigTransactionSignResponse is the response to `POST /v1/multisig/sign` friendly:SignMultisigResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [multisig] 
abstract class APIV1POSTMultisigTransactionSignResponse implements Built<APIV1POSTMultisigTransactionSignResponse, APIV1POSTMultisigTransactionSignResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'multisig')
    String? get multisig;

    APIV1POSTMultisigTransactionSignResponse._();

    static void _initializeBuilder(APIV1POSTMultisigTransactionSignResponseBuilder b) => b;

    factory APIV1POSTMultisigTransactionSignResponse([void updates(APIV1POSTMultisigTransactionSignResponseBuilder b)]) = _$APIV1POSTMultisigTransactionSignResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTMultisigTransactionSignResponse> get serializer => _$APIV1POSTMultisigTransactionSignResponseSerializer();
}

class _$APIV1POSTMultisigTransactionSignResponseSerializer implements StructuredSerializer<APIV1POSTMultisigTransactionSignResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTMultisigTransactionSignResponse, _$APIV1POSTMultisigTransactionSignResponse];

    @override
    final String wireName = r'APIV1POSTMultisigTransactionSignResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTMultisigTransactionSignResponse object,
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
        if (object.multisig != null) {
            result
                ..add(r'multisig')
                ..add(serializers.serialize(object.multisig,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTMultisigTransactionSignResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTMultisigTransactionSignResponseBuilder();

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
                case r'multisig':
                    result.multisig = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

