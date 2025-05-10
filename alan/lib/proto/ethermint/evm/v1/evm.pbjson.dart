///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/evm.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use paramsDescriptor instead')
const Params$json = const {
  '1': 'Params',
  '2': const [
    const {'1': 'evm_denom', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'evmDenom'},
    const {'1': 'enable_create', '3': 2, '4': 1, '5': 8, '8': const {}, '10': 'enableCreate'},
    const {'1': 'enable_call', '3': 3, '4': 1, '5': 8, '8': const {}, '10': 'enableCall'},
    const {'1': 'extra_eips', '3': 4, '4': 3, '5': 3, '8': const {}, '10': 'extraEips'},
    const {'1': 'chain_config', '3': 5, '4': 1, '5': 11, '6': '.ethermint.evm.v1.ChainConfig', '8': const {}, '10': 'chainConfig'},
    const {'1': 'allow_unprotected_txs', '3': 6, '4': 1, '5': 8, '10': 'allowUnprotectedTxs'},
  ],
};

/// Descriptor for `Params`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paramsDescriptor = $convert.base64Decode('CgZQYXJhbXMSMQoJZXZtX2Rlbm9tGAEgASgJQhTy3h8QeWFtbDoiZXZtX2Rlbm9tIlIIZXZtRGVub20SPQoNZW5hYmxlX2NyZWF0ZRgCIAEoCEIY8t4fFHlhbWw6ImVuYWJsZV9jcmVhdGUiUgxlbmFibGVDcmVhdGUSNwoLZW5hYmxlX2NhbGwYAyABKAhCFvLeHxJ5YW1sOiJlbmFibGVfY2FsbCJSCmVuYWJsZUNhbGwSQQoKZXh0cmFfZWlwcxgEIAMoA0Ii4t4fCUV4dHJhRUlQc/LeHxF5YW1sOiJleHRyYV9laXBzIlIJZXh0cmFFaXBzEl0KDGNoYWluX2NvbmZpZxgFIAEoCzIdLmV0aGVybWludC5ldm0udjEuQ2hhaW5Db25maWdCG8jeHwDy3h8TeWFtbDoiY2hhaW5fY29uZmlnIlILY2hhaW5Db25maWcSMgoVYWxsb3dfdW5wcm90ZWN0ZWRfdHhzGAYgASgIUhNhbGxvd1VucHJvdGVjdGVkVHhz');
@$core.Deprecated('Use chainConfigDescriptor instead')
const ChainConfig$json = const {
  '1': 'ChainConfig',
  '2': const [
    const {'1': 'homestead_block', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'homesteadBlock'},
    const {'1': 'dao_fork_block', '3': 2, '4': 1, '5': 9, '8': const {}, '10': 'daoForkBlock'},
    const {'1': 'dao_fork_support', '3': 3, '4': 1, '5': 8, '8': const {}, '10': 'daoForkSupport'},
    const {'1': 'eip150_block', '3': 4, '4': 1, '5': 9, '8': const {}, '10': 'eip150Block'},
    const {'1': 'eip150_hash', '3': 5, '4': 1, '5': 9, '8': const {}, '10': 'eip150Hash'},
    const {'1': 'eip155_block', '3': 6, '4': 1, '5': 9, '8': const {}, '10': 'eip155Block'},
    const {'1': 'eip158_block', '3': 7, '4': 1, '5': 9, '8': const {}, '10': 'eip158Block'},
    const {'1': 'byzantium_block', '3': 8, '4': 1, '5': 9, '8': const {}, '10': 'byzantiumBlock'},
    const {'1': 'constantinople_block', '3': 9, '4': 1, '5': 9, '8': const {}, '10': 'constantinopleBlock'},
    const {'1': 'petersburg_block', '3': 10, '4': 1, '5': 9, '8': const {}, '10': 'petersburgBlock'},
    const {'1': 'istanbul_block', '3': 11, '4': 1, '5': 9, '8': const {}, '10': 'istanbulBlock'},
    const {'1': 'muir_glacier_block', '3': 12, '4': 1, '5': 9, '8': const {}, '10': 'muirGlacierBlock'},
    const {'1': 'berlin_block', '3': 13, '4': 1, '5': 9, '8': const {}, '10': 'berlinBlock'},
    const {'1': 'london_block', '3': 17, '4': 1, '5': 9, '8': const {}, '10': 'londonBlock'},
    const {'1': 'arrow_glacier_block', '3': 18, '4': 1, '5': 9, '8': const {}, '10': 'arrowGlacierBlock'},
    const {'1': 'gray_glacier_block', '3': 20, '4': 1, '5': 9, '8': const {}, '10': 'grayGlacierBlock'},
    const {'1': 'merge_netsplit_block', '3': 21, '4': 1, '5': 9, '8': const {}, '10': 'mergeNetsplitBlock'},
  ],
  '9': const [
    const {'1': 14, '2': 15},
    const {'1': 15, '2': 16},
    const {'1': 16, '2': 17},
    const {'1': 19, '2': 20},
  ],
  '10': const ['yolo_v3_block', 'ewasm_block', 'catalyst_block', 'merge_fork_block'],
};

/// Descriptor for `ChainConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chainConfigDescriptor = $convert.base64Decode('CgtDaGFpbkNvbmZpZxJtCg9ob21lc3RlYWRfYmxvY2sYASABKAlCRNreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludPLeHxZ5YW1sOiJob21lc3RlYWRfYmxvY2siUg5ob21lc3RlYWRCbG9jaxJ5Cg5kYW9fZm9ya19ibG9jaxgCIAEoCUJT2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW504t4fDERBT0ZvcmtCbG9ja/LeHxV5YW1sOiJkYW9fZm9ya19ibG9jayJSDGRhb0ZvcmtCbG9jaxJXChBkYW9fZm9ya19zdXBwb3J0GAMgASgIQi3i3h8OREFPRm9ya1N1cHBvcnTy3h8XeWFtbDoiZGFvX2Zvcmtfc3VwcG9ydCJSDmRhb0ZvcmtTdXBwb3J0EnMKDGVpcDE1MF9ibG9jaxgEIAEoCUJQ2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW504t4fC0VJUDE1MEJsb2Nr8t4fE3lhbWw6ImVpcDE1MF9ibG9jayJSC2VpcDE1MEJsb2NrEkkKC2VpcDE1MF9oYXNoGAUgASgJQiji3h8KRUlQMTUwSGFzaPLeHxZ5YW1sOiJieXphbnRpdW1fYmxvY2siUgplaXAxNTBIYXNoEnMKDGVpcDE1NV9ibG9jaxgGIAEoCUJQ2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW504t4fC0VJUDE1NUJsb2Nr8t4fE3lhbWw6ImVpcDE1NV9ibG9jayJSC2VpcDE1NUJsb2NrEnMKDGVpcDE1OF9ibG9jaxgHIAEoCUJQ2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW504t4fC0VJUDE1OEJsb2Nr8t4fE3lhbWw6ImVpcDE1OF9ibG9jayJSC2VpcDE1OEJsb2NrEm0KD2J5emFudGl1bV9ibG9jaxgIIAEoCUJE2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW508t4fFnlhbWw6ImJ5emFudGl1bV9ibG9jayJSDmJ5emFudGl1bUJsb2NrEnwKFGNvbnN0YW50aW5vcGxlX2Jsb2NrGAkgASgJQkna3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTy3h8beWFtbDoiY29uc3RhbnRpbm9wbGVfYmxvY2siUhNjb25zdGFudGlub3BsZUJsb2NrEnAKEHBldGVyc2J1cmdfYmxvY2sYCiABKAlCRdreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludPLeHxd5YW1sOiJwZXRlcnNidXJnX2Jsb2NrIlIPcGV0ZXJzYnVyZ0Jsb2NrEmoKDmlzdGFuYnVsX2Jsb2NrGAsgASgJQkPa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTy3h8VeWFtbDoiaXN0YW5idWxfYmxvY2siUg1pc3RhbmJ1bEJsb2NrEnUKEm11aXJfZ2xhY2llcl9ibG9jaxgMIAEoCUJH2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW508t4fGXlhbWw6Im11aXJfZ2xhY2llcl9ibG9jayJSEG11aXJHbGFjaWVyQmxvY2sSZAoMYmVybGluX2Jsb2NrGA0gASgJQkHa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTy3h8TeWFtbDoiYmVybGluX2Jsb2NrIlILYmVybGluQmxvY2sSZAoMbG9uZG9uX2Jsb2NrGBEgASgJQkHa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTy3h8TeWFtbDoibG9uZG9uX2Jsb2NrIlILbG9uZG9uQmxvY2sSeAoTYXJyb3dfZ2xhY2llcl9ibG9jaxgSIAEoCUJI2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW508t4fGnlhbWw6ImFycm93X2dsYWNpZXJfYmxvY2siUhFhcnJvd0dsYWNpZXJCbG9jaxJ1ChJncmF5X2dsYWNpZXJfYmxvY2sYFCABKAlCR9reHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludPLeHxl5YW1sOiJncmF5X2dsYWNpZXJfYmxvY2siUhBncmF5R2xhY2llckJsb2NrEnsKFG1lcmdlX25ldHNwbGl0X2Jsb2NrGBUgASgJQkna3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTy3h8beWFtbDoibWVyZ2VfbmV0c3BsaXRfYmxvY2siUhJtZXJnZU5ldHNwbGl0QmxvY2tKBAgOEA9KBAgPEBBKBAgQEBFKBAgTEBRSDXlvbG9fdjNfYmxvY2tSC2V3YXNtX2Jsb2NrUg5jYXRhbHlzdF9ibG9ja1IQbWVyZ2VfZm9ya19ibG9jaw==');
@$core.Deprecated('Use stateDescriptor instead')
const State$json = const {
  '1': 'State',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `State`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stateDescriptor = $convert.base64Decode('CgVTdGF0ZRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU=');
@$core.Deprecated('Use transactionLogsDescriptor instead')
const TransactionLogs$json = const {
  '1': 'TransactionLogs',
  '2': const [
    const {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    const {'1': 'logs', '3': 2, '4': 3, '5': 11, '6': '.ethermint.evm.v1.Log', '10': 'logs'},
  ],
};

/// Descriptor for `TransactionLogs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionLogsDescriptor = $convert.base64Decode('Cg9UcmFuc2FjdGlvbkxvZ3MSEgoEaGFzaBgBIAEoCVIEaGFzaBIpCgRsb2dzGAIgAygLMhUuZXRoZXJtaW50LmV2bS52MS5Mb2dSBGxvZ3M=');
@$core.Deprecated('Use logDescriptor instead')
const Log$json = const {
  '1': 'Log',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    const {'1': 'topics', '3': 2, '4': 3, '5': 9, '10': 'topics'},
    const {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
    const {'1': 'block_number', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'blockNumber'},
    const {'1': 'tx_hash', '3': 5, '4': 1, '5': 9, '8': const {}, '10': 'txHash'},
    const {'1': 'tx_index', '3': 6, '4': 1, '5': 4, '8': const {}, '10': 'txIndex'},
    const {'1': 'block_hash', '3': 7, '4': 1, '5': 9, '8': const {}, '10': 'blockHash'},
    const {'1': 'index', '3': 8, '4': 1, '5': 4, '8': const {}, '10': 'index'},
    const {'1': 'removed', '3': 9, '4': 1, '5': 8, '10': 'removed'},
  ],
};

/// Descriptor for `Log`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logDescriptor = $convert.base64Decode('CgNMb2cSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIWCgZ0b3BpY3MYAiADKAlSBnRvcGljcxISCgRkYXRhGAMgASgMUgRkYXRhEjIKDGJsb2NrX251bWJlchgEIAEoBEIP6t4fC2Jsb2NrTnVtYmVyUgtibG9ja051bWJlchIsCgd0eF9oYXNoGAUgASgJQhPq3h8PdHJhbnNhY3Rpb25IYXNoUgZ0eEhhc2gSLwoIdHhfaW5kZXgYBiABKARCFOreHxB0cmFuc2FjdGlvbkluZGV4Ugd0eEluZGV4EiwKCmJsb2NrX2hhc2gYByABKAlCDereHwlibG9ja0hhc2hSCWJsb2NrSGFzaBIiCgVpbmRleBgIIAEoBEIM6t4fCGxvZ0luZGV4UgVpbmRleBIYCgdyZW1vdmVkGAkgASgIUgdyZW1vdmVk');
@$core.Deprecated('Use txResultDescriptor instead')
const TxResult$json = const {
  '1': 'TxResult',
  '2': const [
    const {'1': 'contract_address', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'contractAddress'},
    const {'1': 'bloom', '3': 2, '4': 1, '5': 12, '10': 'bloom'},
    const {'1': 'tx_logs', '3': 3, '4': 1, '5': 11, '6': '.ethermint.evm.v1.TransactionLogs', '8': const {}, '10': 'txLogs'},
    const {'1': 'ret', '3': 4, '4': 1, '5': 12, '10': 'ret'},
    const {'1': 'reverted', '3': 5, '4': 1, '5': 8, '10': 'reverted'},
    const {'1': 'gas_used', '3': 6, '4': 1, '5': 4, '10': 'gasUsed'},
  ],
  '7': const {},
};

/// Descriptor for `TxResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txResultDescriptor = $convert.base64Decode('CghUeFJlc3VsdBJGChBjb250cmFjdF9hZGRyZXNzGAEgASgJQhvy3h8XeWFtbDoiY29udHJhY3RfYWRkcmVzcyJSD2NvbnRyYWN0QWRkcmVzcxIUCgVibG9vbRgCIAEoDFIFYmxvb20SUgoHdHhfbG9ncxgDIAEoCzIhLmV0aGVybWludC5ldm0udjEuVHJhbnNhY3Rpb25Mb2dzQhbI3h8A8t4fDnlhbWw6InR4X2xvZ3MiUgZ0eExvZ3MSEAoDcmV0GAQgASgMUgNyZXQSGgoIcmV2ZXJ0ZWQYBSABKAhSCHJldmVydGVkEhkKCGdhc191c2VkGAYgASgEUgdnYXNVc2VkOgSIoB8A');
@$core.Deprecated('Use accessTupleDescriptor instead')
const AccessTuple$json = const {
  '1': 'AccessTuple',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    const {'1': 'storage_keys', '3': 2, '4': 3, '5': 9, '8': const {}, '10': 'storageKeys'},
  ],
  '7': const {},
};

/// Descriptor for `AccessTuple`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessTupleDescriptor = $convert.base64Decode('CgtBY2Nlc3NUdXBsZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEjIKDHN0b3JhZ2Vfa2V5cxgCIAMoCUIP6t4fC3N0b3JhZ2VLZXlzUgtzdG9yYWdlS2V5czoEiKAfAA==');
@$core.Deprecated('Use traceConfigDescriptor instead')
const TraceConfig$json = const {
  '1': 'TraceConfig',
  '2': const [
    const {'1': 'tracer', '3': 1, '4': 1, '5': 9, '10': 'tracer'},
    const {'1': 'timeout', '3': 2, '4': 1, '5': 9, '10': 'timeout'},
    const {'1': 'reexec', '3': 3, '4': 1, '5': 4, '10': 'reexec'},
    const {'1': 'disable_stack', '3': 5, '4': 1, '5': 8, '8': const {}, '10': 'disableStack'},
    const {'1': 'disable_storage', '3': 6, '4': 1, '5': 8, '8': const {}, '10': 'disableStorage'},
    const {'1': 'debug', '3': 8, '4': 1, '5': 8, '10': 'debug'},
    const {'1': 'limit', '3': 9, '4': 1, '5': 5, '10': 'limit'},
    const {'1': 'overrides', '3': 10, '4': 1, '5': 11, '6': '.ethermint.evm.v1.ChainConfig', '10': 'overrides'},
    const {'1': 'enable_memory', '3': 11, '4': 1, '5': 8, '8': const {}, '10': 'enableMemory'},
    const {'1': 'enable_return_data', '3': 12, '4': 1, '5': 8, '8': const {}, '10': 'enableReturnData'},
  ],
  '9': const [
    const {'1': 4, '2': 5},
    const {'1': 7, '2': 8},
  ],
  '10': const ['disable_memory', 'disable_return_data'],
};

/// Descriptor for `TraceConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List traceConfigDescriptor = $convert.base64Decode('CgtUcmFjZUNvbmZpZxIWCgZ0cmFjZXIYASABKAlSBnRyYWNlchIYCgd0aW1lb3V0GAIgASgJUgd0aW1lb3V0EhYKBnJlZXhlYxgDIAEoBFIGcmVleGVjEjUKDWRpc2FibGVfc3RhY2sYBSABKAhCEOreHwxkaXNhYmxlU3RhY2tSDGRpc2FibGVTdGFjaxI7Cg9kaXNhYmxlX3N0b3JhZ2UYBiABKAhCEureHw5kaXNhYmxlU3RvcmFnZVIOZGlzYWJsZVN0b3JhZ2USFAoFZGVidWcYCCABKAhSBWRlYnVnEhQKBWxpbWl0GAkgASgFUgVsaW1pdBI7CglvdmVycmlkZXMYCiABKAsyHS5ldGhlcm1pbnQuZXZtLnYxLkNoYWluQ29uZmlnUglvdmVycmlkZXMSNQoNZW5hYmxlX21lbW9yeRgLIAEoCEIQ6t4fDGVuYWJsZU1lbW9yeVIMZW5hYmxlTWVtb3J5EkIKEmVuYWJsZV9yZXR1cm5fZGF0YRgMIAEoCEIU6t4fEGVuYWJsZVJldHVybkRhdGFSEGVuYWJsZVJldHVybkRhdGFKBAgEEAVKBAgHEAhSDmRpc2FibGVfbWVtb3J5UhNkaXNhYmxlX3JldHVybl9kYXRh');
