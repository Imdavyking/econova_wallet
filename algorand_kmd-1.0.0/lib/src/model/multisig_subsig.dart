//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'multisig_subsig.g.dart';

/// MultisigSubsig is a struct that holds a pair of public key and signatures signatures may be empty
///
/// Properties:
/// * [key] 
/// * [sig] 
abstract class MultisigSubsig implements Built<MultisigSubsig, MultisigSubsigBuilder> {
    @BuiltValueField(wireName: r'Key')
    BuiltList<int>? get key;

    @BuiltValueField(wireName: r'Sig')
    BuiltList<int>? get sig;

    MultisigSubsig._();

    static void _initializeBuilder(MultisigSubsigBuilder b) => b;

    factory MultisigSubsig([void updates(MultisigSubsigBuilder b)]) = _$MultisigSubsig;

    @BuiltValueSerializer(custom: true)
    static Serializer<MultisigSubsig> get serializer => _$MultisigSubsigSerializer();
}

class _$MultisigSubsigSerializer implements StructuredSerializer<MultisigSubsig> {
    @override
    final Iterable<Type> types = const [MultisigSubsig, _$MultisigSubsig];

    @override
    final String wireName = r'MultisigSubsig';

    @override
    Iterable<Object?> serialize(Serializers serializers, MultisigSubsig object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.key != null) {
            result
                ..add(r'Key')
                ..add(serializers.serialize(object.key,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        if (object.sig != null) {
            result
                ..add(r'Sig')
                ..add(serializers.serialize(object.sig,
                    specifiedType: const FullType(BuiltList, [FullType(int)])));
        }
        return result;
    }

    @override
    MultisigSubsig deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = MultisigSubsigBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'Key':
                    result.key.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
                case r'Sig':
                    result.sig.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(int)])) as BuiltList<int>);
                    break;
            }
        }
        return result.build();
    }
}

