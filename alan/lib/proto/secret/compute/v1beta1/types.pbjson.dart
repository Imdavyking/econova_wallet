///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use accessTypeDescriptor instead')
const AccessType$json = const {
  '1': 'AccessType',
  '2': const [
    const {'1': 'UNDEFINED', '2': 0, '3': const {}},
    const {'1': 'NOBODY', '2': 1, '3': const {}},
    const {'1': 'ONLY_ADDRESS', '2': 2, '3': const {}},
    const {'1': 'EVERYBODY', '2': 3, '3': const {}},
  ],
  '3': const {},
};

/// Descriptor for `AccessType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List accessTypeDescriptor = $convert.base64Decode('CgpBY2Nlc3NUeXBlEiYKCVVOREVGSU5FRBAAGheKnSATQWNjZXNzVHlwZVVuZGVmaW5lZBIgCgZOT0JPRFkQARoUip0gEEFjY2Vzc1R5cGVOb2JvZHkSKwoMT05MWV9BRERSRVNTEAIaGYqdIBVBY2Nlc3NUeXBlT25seUFkZHJlc3MSJgoJRVZFUllCT0RZEAMaF4qdIBNBY2Nlc3NUeXBlRXZlcnlib2R5GgiIox4AqKQeAA==');
@$core.Deprecated('Use accessTypeParamDescriptor instead')
const AccessTypeParam$json = const {
  '1': 'AccessTypeParam',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 14, '6': '.secret.compute.v1beta1.AccessType', '8': const {}, '10': 'value'},
  ],
  '7': const {},
};

/// Descriptor for `AccessTypeParam`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessTypeParamDescriptor = $convert.base64Decode('Cg9BY2Nlc3NUeXBlUGFyYW0SSgoFdmFsdWUYASABKA4yIi5zZWNyZXQuY29tcHV0ZS52MWJldGExLkFjY2Vzc1R5cGVCEPLeHwx5YW1sOiJ2YWx1ZSJSBXZhbHVlOgSYoB8B');
@$core.Deprecated('Use codeInfoDescriptor instead')
const CodeInfo$json = const {
  '1': 'CodeInfo',
  '2': const [
    const {'1': 'code_hash', '3': 1, '4': 1, '5': 12, '10': 'codeHash'},
    const {'1': 'creator', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'creator'},
    const {'1': 'source', '3': 3, '4': 1, '5': 9, '10': 'source'},
    const {'1': 'builder', '3': 4, '4': 1, '5': 9, '10': 'builder'},
  ],
};

/// Descriptor for `CodeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codeInfoDescriptor = $convert.base64Decode('CghDb2RlSW5mbxIbCgljb2RlX2hhc2gYASABKAxSCGNvZGVIYXNoEksKB2NyZWF0b3IYAiABKAxCMfreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSB2NyZWF0b3ISFgoGc291cmNlGAMgASgJUgZzb3VyY2USGAoHYnVpbGRlchgEIAEoCVIHYnVpbGRlcg==');
@$core.Deprecated('Use contractCustomInfoDescriptor instead')
const ContractCustomInfo$json = const {
  '1': 'ContractCustomInfo',
  '2': const [
    const {'1': 'enclave_key', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'enclaveKey'},
    const {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ContractCustomInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contractCustomInfoDescriptor = $convert.base64Decode('ChJDb250cmFjdEN1c3RvbUluZm8SLwoLZW5jbGF2ZV9rZXkYASABKAxCDuLeHwpFbmNsYXZlS2V5UgplbmNsYXZlS2V5EhQKBWxhYmVsGAIgASgJUgVsYWJlbA==');
@$core.Deprecated('Use contractInfoDescriptor instead')
const ContractInfo$json = const {
  '1': 'ContractInfo',
  '2': const [
    const {'1': 'code_id', '3': 1, '4': 1, '5': 4, '8': const {}, '10': 'codeId'},
    const {'1': 'creator', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'creator'},
    const {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
    const {'1': 'created', '3': 5, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.AbsoluteTxPosition', '10': 'created'},
  ],
};

/// Descriptor for `ContractInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contractInfoDescriptor = $convert.base64Decode('CgxDb250cmFjdEluZm8SIwoHY29kZV9pZBgBIAEoBEIK4t4fBkNvZGVJRFIGY29kZUlkEksKB2NyZWF0b3IYAiABKAxCMfreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSB2NyZWF0b3ISFAoFbGFiZWwYBCABKAlSBWxhYmVsEkQKB2NyZWF0ZWQYBSABKAsyKi5zZWNyZXQuY29tcHV0ZS52MWJldGExLkFic29sdXRlVHhQb3NpdGlvblIHY3JlYXRlZA==');
@$core.Deprecated('Use absoluteTxPositionDescriptor instead')
const AbsoluteTxPosition$json = const {
  '1': 'AbsoluteTxPosition',
  '2': const [
    const {'1': 'block_height', '3': 1, '4': 1, '5': 3, '10': 'blockHeight'},
    const {'1': 'tx_index', '3': 2, '4': 1, '5': 4, '10': 'txIndex'},
  ],
};

/// Descriptor for `AbsoluteTxPosition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List absoluteTxPositionDescriptor = $convert.base64Decode('ChJBYnNvbHV0ZVR4UG9zaXRpb24SIQoMYmxvY2tfaGVpZ2h0GAEgASgDUgtibG9ja0hlaWdodBIZCgh0eF9pbmRleBgCIAEoBFIHdHhJbmRleA==');
@$core.Deprecated('Use modelDescriptor instead')
const Model$json = const {
  '1': 'Model',
  '2': const [
    const {'1': 'Key', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'Key'},
    const {'1': 'Value', '3': 2, '4': 1, '5': 12, '10': 'Value'},
  ],
};

/// Descriptor for `Model`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modelDescriptor = $convert.base64Decode('CgVNb2RlbBJKCgNLZXkYASABKAxCOPreHzRnaXRodWIuY29tL3RlbmRlcm1pbnQvdGVuZGVybWludC9saWJzL2J5dGVzLkhleEJ5dGVzUgNLZXkSFAoFVmFsdWUYAiABKAxSBVZhbHVl');
