///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/genesis.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use genesisStateDescriptor instead')
const GenesisState$json = const {
  '1': 'GenesisState',
  '2': const [
    const {'1': 'codes', '3': 2, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.Code', '8': const {}, '10': 'codes'},
    const {'1': 'contracts', '3': 3, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.Contract', '8': const {}, '10': 'contracts'},
    const {'1': 'sequences', '3': 4, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.Sequence', '8': const {}, '10': 'sequences'},
  ],
};

/// Descriptor for `GenesisState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List genesisStateDescriptor = $convert.base64Decode('CgxHZW5lc2lzU3RhdGUSSwoFY29kZXMYAiADKAsyHC5zZWNyZXQuY29tcHV0ZS52MWJldGExLkNvZGVCF8jeHwDq3h8PY29kZXMsb21pdGVtcHR5UgVjb2RlcxJbCgljb250cmFjdHMYAyADKAsyIC5zZWNyZXQuY29tcHV0ZS52MWJldGExLkNvbnRyYWN0QhvI3h8A6t4fE2NvbnRyYWN0cyxvbWl0ZW1wdHlSCWNvbnRyYWN0cxJbCglzZXF1ZW5jZXMYBCADKAsyIC5zZWNyZXQuY29tcHV0ZS52MWJldGExLlNlcXVlbmNlQhvI3h8A6t4fE3NlcXVlbmNlcyxvbWl0ZW1wdHlSCXNlcXVlbmNlcw==');
@$core.Deprecated('Use codeDescriptor instead')
const Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'code_id', '3': 1, '4': 1, '5': 4, '8': const {}, '10': 'codeId'},
    const {'1': 'code_info', '3': 2, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.CodeInfo', '8': const {}, '10': 'codeInfo'},
    const {'1': 'code_bytes', '3': 3, '4': 1, '5': 12, '10': 'codeBytes'},
  ],
};

/// Descriptor for `Code`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codeDescriptor = $convert.base64Decode('CgRDb2RlEiMKB2NvZGVfaWQYASABKARCCuLeHwZDb2RlSURSBmNvZGVJZBJDCgljb2RlX2luZm8YAiABKAsyIC5zZWNyZXQuY29tcHV0ZS52MWJldGExLkNvZGVJbmZvQgTI3h8AUghjb2RlSW5mbxIdCgpjb2RlX2J5dGVzGAMgASgMUgljb2RlQnl0ZXM=');
@$core.Deprecated('Use contractDescriptor instead')
const Contract$json = const {
  '1': 'Contract',
  '2': const [
    const {'1': 'contract_address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'contractAddress'},
    const {'1': 'contract_info', '3': 2, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.ContractInfo', '8': const {}, '10': 'contractInfo'},
    const {'1': 'contract_state', '3': 3, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.Model', '8': const {}, '10': 'contractState'},
    const {'1': 'contract_custom_info', '3': 4, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.ContractCustomInfo', '10': 'contractCustomInfo'},
  ],
};

/// Descriptor for `Contract`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contractDescriptor = $convert.base64Decode('CghDb250cmFjdBJcChBjb250cmFjdF9hZGRyZXNzGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUg9jb250cmFjdEFkZHJlc3MSTwoNY29udHJhY3RfaW5mbxgCIAEoCzIkLnNlY3JldC5jb21wdXRlLnYxYmV0YTEuQ29udHJhY3RJbmZvQgTI3h8AUgxjb250cmFjdEluZm8SSgoOY29udHJhY3Rfc3RhdGUYAyADKAsyHS5zZWNyZXQuY29tcHV0ZS52MWJldGExLk1vZGVsQgTI3h8AUg1jb250cmFjdFN0YXRlElwKFGNvbnRyYWN0X2N1c3RvbV9pbmZvGAQgASgLMiouc2VjcmV0LmNvbXB1dGUudjFiZXRhMS5Db250cmFjdEN1c3RvbUluZm9SEmNvbnRyYWN0Q3VzdG9tSW5mbw==');
@$core.Deprecated('Use sequenceDescriptor instead')
const Sequence$json = const {
  '1': 'Sequence',
  '2': const [
    const {'1': 'id_key', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'idKey'},
    const {'1': 'value', '3': 2, '4': 1, '5': 4, '10': 'value'},
  ],
};

/// Descriptor for `Sequence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sequenceDescriptor = $convert.base64Decode('CghTZXF1ZW5jZRIgCgZpZF9rZXkYASABKAxCCeLeHwVJREtleVIFaWRLZXkSFAoFdmFsdWUYAiABKARSBXZhbHVl');
