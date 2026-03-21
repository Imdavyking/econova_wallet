//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sign_program_request.g.dart';

/// APIV1POSTProgramSignRequest is the request for `POST /v1/program/sign`
///
/// Properties:
/// * [address] 
/// * [data] 
/// * [walletHandleToken] 
/// * [walletPassword] 
abstract class SignProgramRequest implements Built<SignProgramRequest, SignProgramRequestBuilder> {
    @BuiltValueField(wireName: r'address')
    String? get address;

    @BuiltValueField(wireName: r'data')
    String? get data;

    @BuiltValueField(wireName: r'wallet_handle_token')
    String? get walletHandleToken;

    @BuiltValueField(wireName: r'wallet_password')
    String? get walletPassword;

    SignProgramRequest._();

    static void _initializeBuilder(SignProgramRequestBuilder b) => b;

    factory SignProgramRequest([void updates(SignProgramRequestBuilder b)]) = _$SignProgramRequest;

    @BuiltValueSerializer(custom: true)
    static Serializer<SignProgramRequest> get serializer => _$SignProgramRequestSerializer();
}

class _$SignProgramRequestSerializer implements StructuredSerializer<SignProgramRequest> {
    @override
    final Iterable<Type> types = const [SignProgramRequest, _$SignProgramRequest];

    @override
    final String wireName = r'SignProgramRequest';

    @override
    Iterable<Object?> serialize(Serializers serializers, SignProgramRequest object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.address != null) {
            result
                ..add(r'address')
                ..add(serializers.serialize(object.address,
                    specifiedType: const FullType(String)));
        }
        if (object.data != null) {
            result
                ..add(r'data')
                ..add(serializers.serialize(object.data,
                    specifiedType: const FullType(String)));
        }
        if (object.walletHandleToken != null) {
            result
                ..add(r'wallet_handle_token')
                ..add(serializers.serialize(object.walletHandleToken,
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
    SignProgramRequest deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = SignProgramRequestBuilder();

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
                case r'data':
                    result.data = serializers.deserialize(value,
                        specifiedType: const FullType(String)) as String;
                    break;
                case r'wallet_handle_token':
                    result.walletHandleToken = serializers.deserialize(value,
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

