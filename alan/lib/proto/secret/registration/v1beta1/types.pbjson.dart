///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use seedConfigDescriptor instead')
const SeedConfig$json = const {
  '1': 'SeedConfig',
  '2': const [
    const {'1': 'master_cert', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'masterCert'},
    const {'1': 'encrypted_key', '3': 2, '4': 1, '5': 9, '8': const {}, '10': 'encryptedKey'},
  ],
};

/// Descriptor for `SeedConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seedConfigDescriptor = $convert.base64Decode('CgpTZWVkQ29uZmlnEicKC21hc3Rlcl9jZXJ0GAEgASgJQgbq3h8CcGtSCm1hc3RlckNlcnQSLwoNZW5jcnlwdGVkX2tleRgCIAEoCUIK6t4fBmVuY0tleVIMZW5jcnlwdGVkS2V5');
@$core.Deprecated('Use registrationNodeInfoDescriptor instead')
const RegistrationNodeInfo$json = const {
  '1': 'RegistrationNodeInfo',
  '2': const [
    const {'1': 'certificate', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'certificate'},
    const {'1': 'encrypted_seed', '3': 2, '4': 1, '5': 12, '10': 'encryptedSeed'},
  ],
};

/// Descriptor for `RegistrationNodeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationNodeInfoDescriptor = $convert.base64Decode('ChRSZWdpc3RyYXRpb25Ob2RlSW5mbxJ2CgtjZXJ0aWZpY2F0ZRgBIAEoDEJU+t4fUGdpdGh1Yi5jb20vZW5pZ21hbXBjL1NlY3JldE5ldHdvcmsveC9yZWdpc3RyYXRpb24vcmVtb3RlX2F0dGVzdGF0aW9uLkNlcnRpZmljYXRlUgtjZXJ0aWZpY2F0ZRIlCg5lbmNyeXB0ZWRfc2VlZBgCIAEoDFINZW5jcnlwdGVkU2VlZA==');
