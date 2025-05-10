///
//  Generated code. Do not modify.
//  source: agoric/swingset/msgs.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use msgDeliverInboundDescriptor instead')
const MsgDeliverInbound$json = const {
  '1': 'MsgDeliverInbound',
  '2': const [
    const {'1': 'messages', '3': 1, '4': 3, '5': 9, '8': const {}, '10': 'messages'},
    const {'1': 'nums', '3': 2, '4': 3, '5': 4, '8': const {}, '10': 'nums'},
    const {'1': 'ack', '3': 3, '4': 1, '5': 4, '8': const {}, '10': 'ack'},
    const {'1': 'submitter', '3': 4, '4': 1, '5': 12, '8': const {}, '10': 'submitter'},
  ],
  '7': const {},
};

/// Descriptor for `MsgDeliverInbound`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgDeliverInboundDescriptor = $convert.base64Decode('ChFNc2dEZWxpdmVySW5ib3VuZBI7CghtZXNzYWdlcxgBIAMoCUIf6t4fCG1lc3NhZ2Vz8t4fD3lhbWw6Im1lc3NhZ2VzIlIIbWVzc2FnZXMSKwoEbnVtcxgCIAMoBEIX6t4fBG51bXPy3h8LeWFtbDoibnVtcyJSBG51bXMSJwoDYWNrGAMgASgEQhXq3h8DYWNr8t4fCnlhbWw6ImFjayJSA2FjaxJwCglzdWJtaXR0ZXIYBCABKAxCUureHwlzdWJtaXR0ZXLy3h8QeWFtbDoic3VibWl0dGVyIvreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSCXN1Ym1pdHRlcjoE6KAfAA==');
@$core.Deprecated('Use msgDeliverInboundResponseDescriptor instead')
const MsgDeliverInboundResponse$json = const {
  '1': 'MsgDeliverInboundResponse',
};

/// Descriptor for `MsgDeliverInboundResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgDeliverInboundResponseDescriptor = $convert.base64Decode('ChlNc2dEZWxpdmVySW5ib3VuZFJlc3BvbnNl');
@$core.Deprecated('Use msgWalletActionDescriptor instead')
const MsgWalletAction$json = const {
  '1': 'MsgWalletAction',
  '2': const [
    const {'1': 'owner', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'owner'},
    const {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
  ],
  '7': const {},
};

/// Descriptor for `MsgWalletAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgWalletActionDescriptor = $convert.base64Decode('Cg9Nc2dXYWxsZXRBY3Rpb24SYAoFb3duZXIYASABKAxCSureHwVvd25lcvLeHwx5YW1sOiJvd25lciL63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgVvd25lchIWCgZhY3Rpb24YAiABKAlSBmFjdGlvbjoE6KAfAA==');
@$core.Deprecated('Use msgWalletActionResponseDescriptor instead')
const MsgWalletActionResponse$json = const {
  '1': 'MsgWalletActionResponse',
};

/// Descriptor for `MsgWalletActionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgWalletActionResponseDescriptor = $convert.base64Decode('ChdNc2dXYWxsZXRBY3Rpb25SZXNwb25zZQ==');
@$core.Deprecated('Use msgWalletSpendActionDescriptor instead')
const MsgWalletSpendAction$json = const {
  '1': 'MsgWalletSpendAction',
  '2': const [
    const {'1': 'owner', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'owner'},
    const {'1': 'spend_action', '3': 2, '4': 1, '5': 9, '10': 'spendAction'},
  ],
  '7': const {},
};

/// Descriptor for `MsgWalletSpendAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgWalletSpendActionDescriptor = $convert.base64Decode('ChRNc2dXYWxsZXRTcGVuZEFjdGlvbhJgCgVvd25lchgBIAEoDEJK6t4fBW93bmVy8t4fDHlhbWw6Im93bmVyIvreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSBW93bmVyEiEKDHNwZW5kX2FjdGlvbhgCIAEoCVILc3BlbmRBY3Rpb246BOigHwA=');
@$core.Deprecated('Use msgWalletSpendActionResponseDescriptor instead')
const MsgWalletSpendActionResponse$json = const {
  '1': 'MsgWalletSpendActionResponse',
};

/// Descriptor for `MsgWalletSpendActionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgWalletSpendActionResponseDescriptor = $convert.base64Decode('ChxNc2dXYWxsZXRTcGVuZEFjdGlvblJlc3BvbnNl');
@$core.Deprecated('Use msgProvisionDescriptor instead')
const MsgProvision$json = const {
  '1': 'MsgProvision',
  '2': const [
    const {'1': 'nickname', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'nickname'},
    const {'1': 'address', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'address'},
    const {'1': 'power_flags', '3': 3, '4': 3, '5': 9, '8': const {}, '10': 'powerFlags'},
    const {'1': 'submitter', '3': 4, '4': 1, '5': 12, '8': const {}, '10': 'submitter'},
  ],
  '7': const {},
};

/// Descriptor for `MsgProvision`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgProvisionDescriptor = $convert.base64Decode('CgxNc2dQcm92aXNpb24SOwoIbmlja25hbWUYASABKAlCH+reHwhuaWNrbmFtZfLeHw95YW1sOiJuaWNrbmFtZSJSCG5pY2tuYW1lEmgKB2FkZHJlc3MYAiABKAxCTureHwdhZGRyZXNz8t4fDnlhbWw6ImFkZHJlc3Mi+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IHYWRkcmVzcxJSCgtwb3dlcl9mbGFncxgDIAMoCUIx4t4fClBvd2VyRmxhZ3Pq3h8KcG93ZXJGbGFnc/LeHxF5YW1sOiJwb3dlckZsYWdzIlIKcG93ZXJGbGFncxJwCglzdWJtaXR0ZXIYBCABKAxCUureHwlzdWJtaXR0ZXLy3h8QeWFtbDoic3VibWl0dGVyIvreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSCXN1Ym1pdHRlcjoE6KAfAA==');
@$core.Deprecated('Use msgProvisionResponseDescriptor instead')
const MsgProvisionResponse$json = const {
  '1': 'MsgProvisionResponse',
};

/// Descriptor for `MsgProvisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgProvisionResponseDescriptor = $convert.base64Decode('ChRNc2dQcm92aXNpb25SZXNwb25zZQ==');
@$core.Deprecated('Use msgInstallBundleDescriptor instead')
const MsgInstallBundle$json = const {
  '1': 'MsgInstallBundle',
  '2': const [
    const {'1': 'bundle', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'bundle'},
    const {'1': 'submitter', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'submitter'},
    const {'1': 'compressed_bundle', '3': 3, '4': 1, '5': 12, '8': const {}, '10': 'compressedBundle'},
    const {'1': 'uncompressed_size', '3': 4, '4': 1, '5': 3, '8': const {}, '10': 'uncompressedSize'},
  ],
};

/// Descriptor for `MsgInstallBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgInstallBundleDescriptor = $convert.base64Decode('ChBNc2dJbnN0YWxsQnVuZGxlEjMKBmJ1bmRsZRgBIAEoCUIb6t4fBmJ1bmRsZfLeHw15YW1sOiJidW5kbGUiUgZidW5kbGUScAoJc3VibWl0dGVyGAIgASgMQlLq3h8Jc3VibWl0dGVy8t4fEHlhbWw6InN1Ym1pdHRlciL63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUglzdWJtaXR0ZXISXAoRY29tcHJlc3NlZF9idW5kbGUYAyABKAxCL+reHxBjb21wcmVzc2VkQnVuZGxl8t4fF3lhbWw6ImNvbXByZXNzZWRCdW5kbGUiUhBjb21wcmVzc2VkQnVuZGxlEkEKEXVuY29tcHJlc3NlZF9zaXplGAQgASgDQhTq3h8QdW5jb21wcmVzc2VkU2l6ZVIQdW5jb21wcmVzc2VkU2l6ZQ==');
@$core.Deprecated('Use msgInstallBundleResponseDescriptor instead')
const MsgInstallBundleResponse$json = const {
  '1': 'MsgInstallBundleResponse',
};

/// Descriptor for `MsgInstallBundleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgInstallBundleResponseDescriptor = $convert.base64Decode('ChhNc2dJbnN0YWxsQnVuZGxlUmVzcG9uc2U=');
