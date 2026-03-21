//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:algorand_kmd/src/model/multisig_subsig.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'multisig_sig.g.dart';

/// MultisigSig is the structure that holds multiple Subsigs
///
/// Properties:
/// * [subsigs] 
/// * [threshold] 
/// * [version] 
abstract class MultisigSig implements Built<MultisigSig, MultisigSigBuilder> {
    @BuiltValueField(wireName: r'Subsigs')
    BuiltList<MultisigSubsig>? get subsigs;

    @BuiltValueField(wireName: r'Threshold')
    int? get threshold;

    @BuiltValueField(wireName: r'Version')
    int? get version;

    MultisigSig._();

    static void _initializeBuilder(MultisigSigBuilder b) => b;

    factory MultisigSig([void updates(MultisigSigBuilder b)]) = _$MultisigSig;

    @BuiltValueSerializer(custom: true)
    static Serializer<MultisigSig> get serializer => _$MultisigSigSerializer();
}

class _$MultisigSigSerializer implements StructuredSerializer<MultisigSig> {
    @override
    final Iterable<Type> types = const [MultisigSig, _$MultisigSig];

    @override
    final String wireName = r'MultisigSig';

    @override
    Iterable<Object?> serialize(Serializers serializers, MultisigSig object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.subsigs != null) {
            result
                ..add(r'Subsigs')
                ..add(serializers.serialize(object.subsigs,
                    specifiedType: const FullType(BuiltList, [FullType(MultisigSubsig)])));
        }
        if (object.threshold != null) {
            result
                ..add(r'Threshold')
                ..add(serializers.serialize(object.threshold,
                    specifiedType: const FullType(int)));
        }
        if (object.version != null) {
            result
                ..add(r'Version')
                ..add(serializers.serialize(object.version,
                    specifiedType: const FullType(int)));
        }
        return result;
    }

    @override
    MultisigSig deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = MultisigSigBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'Subsigs':
                    result.subsigs.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(MultisigSubsig)])) as BuiltList<MultisigSubsig>);
                    break;
                case r'Threshold':
                    result.threshold = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
                    break;
                case r'Version':
                    result.version = serializers.deserialize(value,
                        specifiedType: const FullType(int)) as int;
                    break;
            }
        }
        return result.build();
    }
}

