//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_transaction_sign_response.g.dart';

/// APIV1POSTTransactionSignResponse is the response to `POST /v1/transaction/sign` friendly:SignTransactionResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [signedTransaction] 
abstract class APIV1POSTTransactionSignResponse implements Built<APIV1POSTTransactionSignResponse, APIV1POSTTransactionSignResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'signed_transaction')
    String? get signedTransaction;

    APIV1POSTTransactionSignResponse._();

    static void _initializeBuilder(APIV1POSTTransactionSignResponseBuilder b) => b;

    factory APIV1POSTTransactionSignResponse([void updates(APIV1POSTTransactionSignResponseBuilder b)]) = _$APIV1POSTTransactionSignResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTTransactionSignResponse> get serializer => _$APIV1POSTTransactionSignResponseSerializer();
}

class _$APIV1POSTTransactionSignResponseSerializer implements StructuredSerializer<APIV1POSTTransactionSignResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTTransactionSignResponse, _$APIV1POSTTransactionSignResponse];

    @override
    final String wireName = r'APIV1POSTTransactionSignResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTTransactionSignResponse object,
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
        if (object.signedTransaction != null) {
            result
                ..add(r'signed_transaction')
                ..add(serializers.serialize(object.signedTransaction,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    APIV1POSTTransactionSignResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTTransactionSignResponseBuilder();

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
                case r'signed_transaction':
                    result.signedTransaction = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

