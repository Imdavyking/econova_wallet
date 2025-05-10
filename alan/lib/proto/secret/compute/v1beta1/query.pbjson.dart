///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use queryContractInfoRequestDescriptor instead')
const QueryContractInfoRequest$json = const {
  '1': 'QueryContractInfoRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
  ],
};

/// Descriptor for `QueryContractInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractInfoRequestDescriptor = $convert.base64Decode('ChhRdWVyeUNvbnRyYWN0SW5mb1JlcXVlc3QSSwoHYWRkcmVzcxgBIAEoDEIx+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IHYWRkcmVzcw==');
@$core.Deprecated('Use queryContractInfoResponseDescriptor instead')
const QueryContractInfoResponse$json = const {
  '1': 'QueryContractInfoResponse',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
    const {'1': 'ContractInfo', '3': 2, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.ContractInfo', '8': const {}, '10': 'ContractInfo'},
  ],
};

/// Descriptor for `QueryContractInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractInfoResponseDescriptor = $convert.base64Decode('ChlRdWVyeUNvbnRyYWN0SW5mb1Jlc3BvbnNlEksKB2FkZHJlc3MYASABKAxCMfreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSB2FkZHJlc3MSUgoMQ29udHJhY3RJbmZvGAIgASgLMiQuc2VjcmV0LmNvbXB1dGUudjFiZXRhMS5Db250cmFjdEluZm9CCNDeHwHq3h8AUgxDb250cmFjdEluZm8=');
@$core.Deprecated('Use queryContractHistoryRequestDescriptor instead')
const QueryContractHistoryRequest$json = const {
  '1': 'QueryContractHistoryRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
  ],
};

/// Descriptor for `QueryContractHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractHistoryRequestDescriptor = $convert.base64Decode('ChtRdWVyeUNvbnRyYWN0SGlzdG9yeVJlcXVlc3QSSwoHYWRkcmVzcxgBIAEoDEIx+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IHYWRkcmVzcw==');
@$core.Deprecated('Use queryContractsByCodeRequestDescriptor instead')
const QueryContractsByCodeRequest$json = const {
  '1': 'QueryContractsByCodeRequest',
  '2': const [
    const {'1': 'code_id', '3': 1, '4': 1, '5': 4, '10': 'codeId'},
  ],
};

/// Descriptor for `QueryContractsByCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractsByCodeRequestDescriptor = $convert.base64Decode('ChtRdWVyeUNvbnRyYWN0c0J5Q29kZVJlcXVlc3QSFwoHY29kZV9pZBgBIAEoBFIGY29kZUlk');
@$core.Deprecated('Use contractInfoWithAddressDescriptor instead')
const ContractInfoWithAddress$json = const {
  '1': 'ContractInfoWithAddress',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
    const {'1': 'ContractInfo', '3': 2, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.ContractInfo', '8': const {}, '10': 'ContractInfo'},
  ],
};

/// Descriptor for `ContractInfoWithAddress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contractInfoWithAddressDescriptor = $convert.base64Decode('ChdDb250cmFjdEluZm9XaXRoQWRkcmVzcxJLCgdhZGRyZXNzGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgdhZGRyZXNzElIKDENvbnRyYWN0SW5mbxgCIAEoCzIkLnNlY3JldC5jb21wdXRlLnYxYmV0YTEuQ29udHJhY3RJbmZvQgjQ3h8B6t4fAFIMQ29udHJhY3RJbmZv');
@$core.Deprecated('Use queryContractsByCodeResponseDescriptor instead')
const QueryContractsByCodeResponse$json = const {
  '1': 'QueryContractsByCodeResponse',
  '2': const [
    const {'1': 'contract_infos', '3': 1, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.ContractInfoWithAddress', '8': const {}, '10': 'contractInfos'},
  ],
};

/// Descriptor for `QueryContractsByCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractsByCodeResponseDescriptor = $convert.base64Decode('ChxRdWVyeUNvbnRyYWN0c0J5Q29kZVJlc3BvbnNlElwKDmNvbnRyYWN0X2luZm9zGAEgAygLMi8uc2VjcmV0LmNvbXB1dGUudjFiZXRhMS5Db250cmFjdEluZm9XaXRoQWRkcmVzc0IEyN4fAFINY29udHJhY3RJbmZvcw==');
@$core.Deprecated('Use querySmartContractStateRequestDescriptor instead')
const QuerySmartContractStateRequest$json = const {
  '1': 'QuerySmartContractStateRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
    const {'1': 'query_data', '3': 2, '4': 1, '5': 12, '10': 'queryData'},
  ],
};

/// Descriptor for `QuerySmartContractStateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List querySmartContractStateRequestDescriptor = $convert.base64Decode('Ch5RdWVyeVNtYXJ0Q29udHJhY3RTdGF0ZVJlcXVlc3QSSwoHYWRkcmVzcxgBIAEoDEIx+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IHYWRkcmVzcxIdCgpxdWVyeV9kYXRhGAIgASgMUglxdWVyeURhdGE=');
@$core.Deprecated('Use queryContractAddressByLabelRequestDescriptor instead')
const QueryContractAddressByLabelRequest$json = const {
  '1': 'QueryContractAddressByLabelRequest',
  '2': const [
    const {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `QueryContractAddressByLabelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractAddressByLabelRequestDescriptor = $convert.base64Decode('CiJRdWVyeUNvbnRyYWN0QWRkcmVzc0J5TGFiZWxSZXF1ZXN0EhQKBWxhYmVsGAEgASgJUgVsYWJlbA==');
@$core.Deprecated('Use queryContractKeyRequestDescriptor instead')
const QueryContractKeyRequest$json = const {
  '1': 'QueryContractKeyRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
  ],
};

/// Descriptor for `QueryContractKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractKeyRequestDescriptor = $convert.base64Decode('ChdRdWVyeUNvbnRyYWN0S2V5UmVxdWVzdBJLCgdhZGRyZXNzGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgdhZGRyZXNz');
@$core.Deprecated('Use queryContractHashRequestDescriptor instead')
const QueryContractHashRequest$json = const {
  '1': 'QueryContractHashRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
  ],
};

/// Descriptor for `QueryContractHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractHashRequestDescriptor = $convert.base64Decode('ChhRdWVyeUNvbnRyYWN0SGFzaFJlcXVlc3QSSwoHYWRkcmVzcxgBIAEoDEIx+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IHYWRkcmVzcw==');
@$core.Deprecated('Use querySmartContractStateResponseDescriptor instead')
const QuerySmartContractStateResponse$json = const {
  '1': 'QuerySmartContractStateResponse',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `QuerySmartContractStateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List querySmartContractStateResponseDescriptor = $convert.base64Decode('Ch9RdWVyeVNtYXJ0Q29udHJhY3RTdGF0ZVJlc3BvbnNlEhIKBGRhdGEYASABKAxSBGRhdGE=');
@$core.Deprecated('Use queryCodeRequestDescriptor instead')
const QueryCodeRequest$json = const {
  '1': 'QueryCodeRequest',
  '2': const [
    const {'1': 'code_id', '3': 1, '4': 1, '5': 4, '10': 'codeId'},
  ],
};

/// Descriptor for `QueryCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCodeRequestDescriptor = $convert.base64Decode('ChBRdWVyeUNvZGVSZXF1ZXN0EhcKB2NvZGVfaWQYASABKARSBmNvZGVJZA==');
@$core.Deprecated('Use codeInfoResponseDescriptor instead')
const CodeInfoResponse$json = const {
  '1': 'CodeInfoResponse',
  '2': const [
    const {'1': 'code_id', '3': 1, '4': 1, '5': 4, '8': const {}, '10': 'codeId'},
    const {'1': 'creator', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'creator'},
    const {'1': 'data_hash', '3': 3, '4': 1, '5': 12, '8': const {}, '10': 'dataHash'},
    const {'1': 'source', '3': 4, '4': 1, '5': 9, '10': 'source'},
    const {'1': 'builder', '3': 5, '4': 1, '5': 9, '10': 'builder'},
  ],
};

/// Descriptor for `CodeInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codeInfoResponseDescriptor = $convert.base64Decode('ChBDb2RlSW5mb1Jlc3BvbnNlEikKB2NvZGVfaWQYASABKARCEOLeHwZDb2RlSUTq3h8CaWRSBmNvZGVJZBJLCgdjcmVhdG9yGAIgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgdjcmVhdG9yElUKCWRhdGFfaGFzaBgDIAEoDEI4+t4fNGdpdGh1Yi5jb20vdGVuZGVybWludC90ZW5kZXJtaW50L2xpYnMvYnl0ZXMuSGV4Qnl0ZXNSCGRhdGFIYXNoEhYKBnNvdXJjZRgEIAEoCVIGc291cmNlEhgKB2J1aWxkZXIYBSABKAlSB2J1aWxkZXI=');
@$core.Deprecated('Use queryCodeResponseDescriptor instead')
const QueryCodeResponse$json = const {
  '1': 'QueryCodeResponse',
  '2': const [
    const {'1': 'code_info', '3': 1, '4': 1, '5': 11, '6': '.secret.compute.v1beta1.CodeInfoResponse', '8': const {}, '10': 'codeInfo'},
    const {'1': 'data', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'data'},
  ],
};

/// Descriptor for `QueryCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCodeResponseDescriptor = $convert.base64Decode('ChFRdWVyeUNvZGVSZXNwb25zZRJPCgljb2RlX2luZm8YASABKAsyKC5zZWNyZXQuY29tcHV0ZS52MWJldGExLkNvZGVJbmZvUmVzcG9uc2VCCNDeHwHq3h8AUghjb2RlSW5mbxIcCgRkYXRhGAIgASgMQgjq3h8EZGF0YVIEZGF0YQ==');
@$core.Deprecated('Use queryCodesResponseDescriptor instead')
const QueryCodesResponse$json = const {
  '1': 'QueryCodesResponse',
  '2': const [
    const {'1': 'code_infos', '3': 1, '4': 3, '5': 11, '6': '.secret.compute.v1beta1.CodeInfoResponse', '8': const {}, '10': 'codeInfos'},
  ],
};

/// Descriptor for `QueryCodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCodesResponseDescriptor = $convert.base64Decode('ChJRdWVyeUNvZGVzUmVzcG9uc2USTQoKY29kZV9pbmZvcxgBIAMoCzIoLnNlY3JldC5jb21wdXRlLnYxYmV0YTEuQ29kZUluZm9SZXNwb25zZUIEyN4fAFIJY29kZUluZm9z');
@$core.Deprecated('Use queryContractAddressByLabelResponseDescriptor instead')
const QueryContractAddressByLabelResponse$json = const {
  '1': 'QueryContractAddressByLabelResponse',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'address'},
  ],
};

/// Descriptor for `QueryContractAddressByLabelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractAddressByLabelResponseDescriptor = $convert.base64Decode('CiNRdWVyeUNvbnRyYWN0QWRkcmVzc0J5TGFiZWxSZXNwb25zZRJLCgdhZGRyZXNzGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgdhZGRyZXNz');
@$core.Deprecated('Use queryContractKeyResponseDescriptor instead')
const QueryContractKeyResponse$json = const {
  '1': 'QueryContractKeyResponse',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'key'},
  ],
};

/// Descriptor for `QueryContractKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractKeyResponseDescriptor = $convert.base64Decode('ChhRdWVyeUNvbnRyYWN0S2V5UmVzcG9uc2USSgoDa2V5GAEgASgMQjj63h80Z2l0aHViLmNvbS90ZW5kZXJtaW50L3RlbmRlcm1pbnQvbGlicy9ieXRlcy5IZXhCeXRlc1IDa2V5');
@$core.Deprecated('Use queryContractHashResponseDescriptor instead')
const QueryContractHashResponse$json = const {
  '1': 'QueryContractHashResponse',
  '2': const [
    const {'1': 'code_hash', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'codeHash'},
  ],
};

/// Descriptor for `QueryContractHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryContractHashResponseDescriptor = $convert.base64Decode('ChlRdWVyeUNvbnRyYWN0SGFzaFJlc3BvbnNlElUKCWNvZGVfaGFzaBgBIAEoDEI4+t4fNGdpdGh1Yi5jb20vdGVuZGVybWludC90ZW5kZXJtaW50L2xpYnMvYnl0ZXMuSGV4Qnl0ZXNSCGNvZGVIYXNo');
@$core.Deprecated('Use decryptedAnswerDescriptor instead')
const DecryptedAnswer$json = const {
  '1': 'DecryptedAnswer',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'input', '3': 2, '4': 1, '5': 9, '10': 'input'},
    const {'1': 'output_data', '3': 3, '4': 1, '5': 9, '10': 'outputData'},
    const {'1': 'output_data_as_string', '3': 4, '4': 1, '5': 9, '10': 'outputDataAsString'},
    const {'1': 'output_logs', '3': 5, '4': 3, '5': 11, '6': '.cosmos.base.abci.v1beta1.StringEvent', '8': const {}, '10': 'outputLogs'},
    const {'1': 'output_error', '3': 6, '4': 1, '5': 12, '8': const {}, '10': 'outputError'},
    const {'1': 'plaintext_error', '3': 7, '4': 1, '5': 9, '10': 'plaintextError'},
  ],
  '7': const {},
};

/// Descriptor for `DecryptedAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decryptedAnswerDescriptor = $convert.base64Decode('Cg9EZWNyeXB0ZWRBbnN3ZXISEgoEdHlwZRgBIAEoCVIEdHlwZRIUCgVpbnB1dBgCIAEoCVIFaW5wdXQSHwoLb3V0cHV0X2RhdGEYAyABKAlSCm91dHB1dERhdGESMQoVb3V0cHV0X2RhdGFfYXNfc3RyaW5nGAQgASgJUhJvdXRwdXREYXRhQXNTdHJpbmcSTAoLb3V0cHV0X2xvZ3MYBSADKAsyJS5jb3Ntb3MuYmFzZS5hYmNpLnYxYmV0YTEuU3RyaW5nRXZlbnRCBMjeHwBSCm91dHB1dExvZ3MSPwoMb3V0cHV0X2Vycm9yGAYgASgMQhz63h8YZW5jb2RpbmcvanNvbi5SYXdNZXNzYWdlUgtvdXRwdXRFcnJvchInCg9wbGFpbnRleHRfZXJyb3IYByABKAlSDnBsYWludGV4dEVycm9yOgTooB8A');
