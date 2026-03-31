//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'apiv1_wallet.g.dart';

/// APIV1Wallet is the API's representation of a wallet
///
/// Properties:
/// * [driverName] 
/// * [driverVersion] 
/// * [id] 
/// * [mnemonicUx] 
/// * [name] 
/// * [supportedTxs] 
abstract class APIV1Wallet implements Built<APIV1Wallet, APIV1WalletBuilder> {
    @BuiltValueField(wireName: r'driver_name')
    String? get driverName;

    @BuiltValueField(wireName: r'driver_version')
    int? get driverVersion;

    @BuiltValueField(wireName: r'id')
    String? get id;

    @BuiltValueField(wireName: r'mnemonic_ux')
    bool? get mnemonicUx;

    @BuiltValueField(wireName: r'name')
    String? get name;

    @BuiltValueField(wireName: r'supported_txs')
    BuiltList<String>? get supportedTxs;

    APIV1Wallet._();

    static void _initializeBuilder(APIV1WalletBuilder b) => b;

    factory APIV1Wallet([void updates(APIV1WalletBuilder b)]) = _$APIV1Wallet;

    @BuiltValueSerializer(custom: true)
    static Serializer<APIV1Wallet> get serializer => _$APIV1WalletSerializer();
}

class _$APIV1WalletSerializer implements StructuredSerializer<APIV1Wallet> {
    @override
    final Iterable<Type> types = const [APIV1Wallet, _$APIV1Wallet];

    @override
    final String wireName = r'APIV1Wallet';

    @override
    Iterable<Object?> serialize(Serializers serializers, APIV1Wallet object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.driverName != null) {
            result
                ..add(r'driver_name')
                ..add(serializers.serialize(object.driverName,
                    specifiedType: const FullType(String)));
        }
        if (object.driverVersion != null) {
            result
                ..add(r'driver_version')
                ..add(serializers.serialize(object.driverVersion,
                    specifiedType: const FullType(int)));
        }
        if (object.id != null) {
            result
                ..add(r'id')
                ..add(serializers.serialize(object.id,
                    specifiedType: const FullType(String)));
        }
        if (object.mnemonicUx != null) {
            result
                ..add(r'mnemonic_ux')
                ..add(serializers.serialize(object.mnemonicUx,
                    specifiedType: const FullType(bool)));
        }
        if (object.name != null) {
            result
                ..add(r'name')
                ..add(serializers.serialize(object.name,
                    specifiedType: const FullType(String)));
        }
        if (object.supportedTxs != null) {
            result
                ..add(r'supported_txs')
                ..add(serializers.serialize(object.supportedTxs,
                    specifiedType: const FullType(BuiltList, [FullType(String)])));
        }
        return result;
    }

    @override
    APIV1Wallet deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = APIV1WalletBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'driver_name':
                    result.driverName = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'driver_version':
                    result.driverVersion = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
                    break;
                case r'id':
                    result.id = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'mnemonic_ux':
                    result.mnemonicUx = serializers.deserialize(value,
                        specifiedType: const FullType(bool)) as bool;
                    break;
                case r'name':
                    result.name = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'supported_txs':
                    result.supportedTxs.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(String)])) as BuiltList<String>);
                    break;
            }
        }
        return result.build();
    }
}

