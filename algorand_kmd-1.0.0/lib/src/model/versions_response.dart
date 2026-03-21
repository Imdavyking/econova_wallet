//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'versions_response.g.dart';

/// VersionsResponse is the response to `GET /versions` friendly:VersionsResponse
///
/// Properties:
/// * [versions] 
abstract class VersionsResponse implements Built<VersionsResponse, VersionsResponseBuilder> {
    @BuiltValueField(wireName: r'versions')
    BuiltList<String>? get versions;

    VersionsResponse._();

    static void _initializeBuilder(VersionsResponseBuilder b) => b;

    factory VersionsResponse([void updates(VersionsResponseBuilder b)]) = _$VersionsResponse;

    @BuiltValueSerializer(custom: true)
    static Serializer<VersionsResponse> get serializer => _$VersionsResponseSerializer();
}

class _$VersionsResponseSerializer implements StructuredSerializer<VersionsResponse> {
    @override
    final Iterable<Type> types = const [VersionsResponse, _$VersionsResponse];

    @override
    final String wireName = r'VersionsResponse';

    @override
    Iterable<Object?> serialize(Serializers serializers, VersionsResponse object,
        {FullType specifiedType = FullType.unspecified}) {
        final result = <Object?>[];
        if (object.versions != null) {
            result
                ..add(r'versions')
                ..add(serializers.serialize(object.versions,
                    specifiedType: const FullType(BuiltList, [FullType(String)])));
        }
        return result;
    }

    @override
    VersionsResponse deserialize(Serializers serializers, Iterable<Object?> serialized,
        {FullType specifiedType = FullType.unspecified}) {
        final result = VersionsResponseBuilder();

        final iterator = serialized.iterator;
        while (iterator.moveNext()) {
            final key = iterator.current as String;
            iterator.moveNext();
            final Object? value = iterator.current;
            switch (key) {
                case r'versions':
                    result.versions.replace(serializers.deserialize(value,
                        specifiedType: const FullType(BuiltList, [FullType(String)])) as BuiltList<String>);
                    break;
            }
        }
        return result.build();
    }
}

