//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/apiv1_wallet.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_post_wallet_rename_response.g.dart';

/// APIV1POSTWalletRenameResponse is the response to `POST /v1/wallet/rename` friendly:RenameWalletResponse
///
/// Properties:
/// * [error] 
/// * [message] 
/// * [wallet] 
abstract class APIV1POSTWalletRenameResponse implements Built<APIV1POSTWalletRenameResponse, APIV1POSTWalletRenameResponseBuilder> {
    @BuiltValueField(wireName: r'error')
    bool? get error;

    @BuiltValueField(wireName: r'message')
    String? get message;

    @BuiltValueField(wireName: r'wallet')
    APIV1Wallet? get wallet;

    APIV1POSTWalletRenameResponse._();

    static void _initializeBuilder(APIV1POSTWalletRenameResponseBuilder b) => b;

    factory APIV1POSTWalletRenameResponse([void updates(APIV1POSTWalletRenameResponseBuilder b)]) = _$APIV1POSTWalletRenameResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1POSTWalletRenameResponse> get serializer => _$APIV1POSTWalletRenameResponseSerializer();
}

class _$APIV1POSTWalletRenameResponseSerializer implements StructuredSerializer<APIV1POSTWalletRenameResponse> {
    @override
    final Iterable<Type> types = const [APIV1POSTWalletRenameResponse, _$APIV1POSTWalletRenameResponse];

    @override
    final String wireName = r'APIV1POSTWalletRenameResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1POSTWalletRenameResponse object,
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
        if (object.wallet != null) {
            result
                ..add(r'wallet')
                ..add(serializers.serialize(object.wallet,
                    specifiedType: const FullType(APIV1Wallet)));
        }
        return result;
    }

    @override
    APIV1POSTWalletRenameResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1POSTWalletRenameResponseBuilder();

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
                case r'wallet':
                    result.wallet.replace(serializers.deserialize(value,
                        specifiedType: const FullType(APIV1Wallet)) as APIV1Wallet);
                    break;
            }
        }
        return result.build();
    }
}

