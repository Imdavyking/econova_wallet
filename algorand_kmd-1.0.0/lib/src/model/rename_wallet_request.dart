//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rename_wallet_request.g.dart';

/// APIV1POSTWalletRenameRequest is the request for `POST /v1/wallet/rename`
///
/// Properties:
/// * [walletId] 
/// * [walletName] 
/// * [walletPassword] 
abstract class RenameWalletRequest implements Built<RenameWalletRequest, RenameWalletRequestBuilder> {
    @BuiltValueField(wireName: r'wallet_id')
    String? get walletId;

    @BuiltValueField(wireName: r'wallet_name')
    String? get walletName;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    RenameWalletRequest._();

    static void _initializeBuilder(RenameWalletRequestBuilder b) => b;

    factory RenameWalletRequest([void updates(RenameWalletRequestBuilder b)]) = _$RenameWalletRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<RenameWalletRequest> get serializer => _$RenameWalletRequestSerializer();
}

class _$RenameWalletRequestSerializer implements StructuredSerializer<RenameWalletRequest> {
    @override
    final Iterable<Type> types = const [RenameWalletRequest, _$RenameWalletRequest];

    @override
    final String wireName = r'RenameWalletRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, RenameWalletRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.walletId != null) {
            result
                ..add(r'wallet_id')
                ..add(serializers.serialize(object.walletId,
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
    RenameWalletRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = RenameWalletRequestBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'wallet_id':
                    result.walletId = serializers.deserialize(value,
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

