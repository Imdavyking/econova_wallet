//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/apiv1_wallet.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_wallet_handle.g.dart';

/// APIV1WalletHandle includes the wallet the handle corresponds to and the number of number of seconds to expiration
///
/// Properties:
/// * [expiresSeconds] 
/// * [wallet] 
abstract class APIV1WalletHandle implements Built<APIV1WalletHandle, APIV1WalletHandleBuilder> {
    @BuiltValueField(wireName: r'expires_seconds')
    int? get expiresSeconds;

    @BuiltValueField(wireName: r'wallet')
    APIV1Wallet? get wallet;

    APIV1WalletHandle._();

    static void _initializeBuilder(APIV1WalletHandleBuilder b) => b;

    factory APIV1WalletHandle([void updates(APIV1WalletHandleBuilder b)]) = _$APIV1WalletHandle;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1WalletHandle> get serializer => _$APIV1WalletHandleSerializer();
}

class _$APIV1WalletHandleSerializer implements StructuredSerializer<APIV1WalletHandle> {
    @override
    final Iterable<Type> types = const [APIV1WalletHandle, _$APIV1WalletHandle];

    @override
    final String wireName = r'APIV1WalletHandle';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1WalletHandle object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.expiresSeconds != null) {
            result
                ..add(r'expires_seconds')
                ..add(serializers.serialize(object.expiresSeconds,
                    specifiedType: const FullType(int)));
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
    APIV1WalletHandle deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1WalletHandleBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'expires_seconds':
                    result.expiresSeconds = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
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

