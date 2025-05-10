///
//  Generated code. Do not modify.
//  source: amino/amino.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Amino {
  static final name = $pb.Extension<$core.String>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.MessageOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name', 11110001, $pb.PbFieldType.OS);
  static final messageEncoding = $pb.Extension<$core.String>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.MessageOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'messageEncoding', 11110002, $pb.PbFieldType.OS);
  static final encoding = $pb.Extension<$core.String>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.FieldOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'encoding', 11110003, $pb.PbFieldType.OS);
  static final fieldName = $pb.Extension<$core.String>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.FieldOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fieldName', 11110004, $pb.PbFieldType.OS);
  static final dontOmitempty = $pb.Extension<$core.bool>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.FieldOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dontOmitempty', 11110005, $pb.PbFieldType.OB);
  static final oneofName = $pb.Extension<$core.String>(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'google.protobuf.FieldOptions', const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'oneofName', 11110006, $pb.PbFieldType.OS);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(name);
    registry.add(messageEncoding);
    registry.add(encoding);
    registry.add(fieldName);
    registry.add(dontOmitempty);
    registry.add(oneofName);
  }
}

