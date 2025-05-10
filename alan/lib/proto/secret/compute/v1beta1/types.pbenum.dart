///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class AccessType extends $pb.ProtobufEnum {
  static const AccessType UNDEFINED = AccessType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'UNDEFINED');
  static const AccessType NOBODY = AccessType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'NOBODY');
  static const AccessType ONLY_ADDRESS = AccessType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ONLY_ADDRESS');
  static const AccessType EVERYBODY = AccessType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EVERYBODY');

  static const $core.List<AccessType> values = <AccessType> [
    UNDEFINED,
    NOBODY,
    ONLY_ADDRESS,
    EVERYBODY,
  ];

  static final $core.Map<$core.int, AccessType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AccessType? valueOf($core.int value) => _byValue[value];

  const AccessType._($core.int v, $core.String n) : super(v, n);
}

