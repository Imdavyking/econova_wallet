//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_wallet_request.g.dart';

/// APIV1POSTWalletRequest is the request for `POST /v1/wallet`
///
/// Properties:
/// * [masterDerivationKey] - MasterDerivationKey is used to derive ed25519 keys for use in wallets
/// * [walletDriverName] 
/// * [walletName] 
/// * [walletPassword] 
abstract class CreateWalletRequest implements Built<CreateWalletRequest, CreateWalletRequestBuilder> {
    /// MasterDerivationKey is used to derive ed25519 keys for use in wallets
    @BuiltValueField(wireName: r'master_derivation_key')
    BuiltList<int>? get masterDerivationKey;

    @BuiltValueField(wireName: r'wallet_driver_name')
    String? get walletDriverName;

    @BuiltValueField(wireName: r'wallet_name')
    String? get walletName;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    CreateWalletRequest._();

    static void _initializeBuilder(CreateWalletRequestBuilder b) => b;

    factory CreateWalletRequest([void updates(CreateWalletRequestBuilder b)]) = _$CreateWalletRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<CreateWalletRequest> get serializer => _$CreateWalletRequestSerializer();
}

class _$CreateWalletRequestSerializer implements StructuredSerializer<CreateWalletRequest> {
    @override
    final Iterable<Type> types = const [CreateWalletRequest, _$CreateWalletRequest];

    @override
    final String wireName = r'CreateWalletRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, CreateWalletRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.masterDerivationKey != null) {
            result
                ..add(r'master_derivation_key')
                ..add(serializers.serialize(object.masterDerivationKey,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        if (object.walletDriverName != null) {
            result
                ..add(r'wallet_driver_name')
                ..add(serializers.serialize(object.walletDriverName,
                    specifiedType: const FullType(String)));
        }
        if (object.walletName != null) {
            result
                ..add(r'wallet_name')
                ..add(serializers.serialize(object.walletName,
                    specifiedType: const FullType(String)));
        }
        if (object.walletPassword != null) {
            result
                ..add(r'wallet_password')
                ..add(serializers.serialize(object.walletPassword,
                    specifiedType: const FullType(String)));
        }
        return result;
    }

    @override
    CreateWalletRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = CreateWalletRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'master_derivation_key':
                    result.masterDerivationKey.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
                case r'wallet_driver_name':
                    result.walletDriverName = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_name':
                    result.walletName = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_password':
                    result.walletPassword = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
            }
        }
        return result.build();
    }
}

