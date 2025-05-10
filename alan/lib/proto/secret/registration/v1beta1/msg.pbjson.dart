///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/msg.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use raAuthenticateDescriptor instead')
const RaAuthenticate$json = const {
  '1': 'RaAuthenticate',
  '2': const [
    const {'1': 'sender', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'sender'},
    const {'1': 'certificate', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'certificate'},
  ],
};

/// Descriptor for `RaAuthenticate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List raAuthenticateDescriptor = $convert.base64Decode('Cg5SYUF1dGhlbnRpY2F0ZRJJCgZzZW5kZXIYASABKAxCMfreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSBnNlbmRlchKBAQoLY2VydGlmaWNhdGUYAiABKAxCX+reHwdyYV9jZXJ0+t4fUGdpdGh1Yi5jb20vZW5pZ21hbXBjL1NlY3JldE5ldHdvcmsveC9yZWdpc3RyYXRpb24vcmVtb3RlX2F0dGVzdGF0aW9uLkNlcnRpZmljYXRlUgtjZXJ0aWZpY2F0ZQ==');
@$core.Deprecated('Use masterCertificateDescriptor instead')
const MasterCertificate$json = const {
  '1': 'MasterCertificate',
  '2': const [
    const {'1': 'bytes', '3': 1, '4': 1, '5': 12, '10': 'bytes'},
  ],
};

/// Descriptor for `MasterCertificate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List masterCertificateDescriptor = $convert.base64Decode('ChFNYXN0ZXJDZXJ0aWZpY2F0ZRIUCgVieXRlcxgBIAEoDFIFYnl0ZXM=');
@$core.Deprecated('Use keyDescriptor instead')
const Key$json = const {
  '1': 'Key',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'key'},
  ],
};

/// Descriptor for `Key`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyDescriptor = $convert.base64Decode('CgNLZXkSGQoDa2V5GAEgASgMQgfq3h8Da2V5UgNrZXk=');
