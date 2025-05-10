///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use queryAccountRequestDescriptor instead')
const QueryAccountRequest$json = const {
  '1': 'QueryAccountRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
  '7': const {},
};

/// Descriptor for `QueryAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryAccountRequestDescriptor = $convert.base64Decode('ChNRdWVyeUFjY291bnRSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M6CIigHwDooB8A');
@$core.Deprecated('Use queryAccountResponseDescriptor instead')
const QueryAccountResponse$json = const {
  '1': 'QueryAccountResponse',
  '2': const [
    const {'1': 'balance', '3': 1, '4': 1, '5': 9, '10': 'balance'},
    const {'1': 'code_hash', '3': 2, '4': 1, '5': 9, '10': 'codeHash'},
    const {'1': 'nonce', '3': 3, '4': 1, '5': 4, '10': 'nonce'},
  ],
};

/// Descriptor for `QueryAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryAccountResponseDescriptor = $convert.base64Decode('ChRRdWVyeUFjY291bnRSZXNwb25zZRIYCgdiYWxhbmNlGAEgASgJUgdiYWxhbmNlEhsKCWNvZGVfaGFzaBgCIAEoCVIIY29kZUhhc2gSFAoFbm9uY2UYAyABKARSBW5vbmNl');
@$core.Deprecated('Use queryCosmosAccountRequestDescriptor instead')
const QueryCosmosAccountRequest$json = const {
  '1': 'QueryCosmosAccountRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
  '7': const {},
};

/// Descriptor for `QueryCosmosAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCosmosAccountRequestDescriptor = $convert.base64Decode('ChlRdWVyeUNvc21vc0FjY291bnRSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M6CIigHwDooB8A');
@$core.Deprecated('Use queryCosmosAccountResponseDescriptor instead')
const QueryCosmosAccountResponse$json = const {
  '1': 'QueryCosmosAccountResponse',
  '2': const [
    const {'1': 'cosmos_address', '3': 1, '4': 1, '5': 9, '10': 'cosmosAddress'},
    const {'1': 'sequence', '3': 2, '4': 1, '5': 4, '10': 'sequence'},
    const {'1': 'account_number', '3': 3, '4': 1, '5': 4, '10': 'accountNumber'},
  ],
};

/// Descriptor for `QueryCosmosAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCosmosAccountResponseDescriptor = $convert.base64Decode('ChpRdWVyeUNvc21vc0FjY291bnRSZXNwb25zZRIlCg5jb3Ntb3NfYWRkcmVzcxgBIAEoCVINY29zbW9zQWRkcmVzcxIaCghzZXF1ZW5jZRgCIAEoBFIIc2VxdWVuY2USJQoOYWNjb3VudF9udW1iZXIYAyABKARSDWFjY291bnROdW1iZXI=');
@$core.Deprecated('Use queryValidatorAccountRequestDescriptor instead')
const QueryValidatorAccountRequest$json = const {
  '1': 'QueryValidatorAccountRequest',
  '2': const [
    const {'1': 'cons_address', '3': 1, '4': 1, '5': 9, '10': 'consAddress'},
  ],
  '7': const {},
};

/// Descriptor for `QueryValidatorAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryValidatorAccountRequestDescriptor = $convert.base64Decode('ChxRdWVyeVZhbGlkYXRvckFjY291bnRSZXF1ZXN0EiEKDGNvbnNfYWRkcmVzcxgBIAEoCVILY29uc0FkZHJlc3M6CIigHwDooB8A');
@$core.Deprecated('Use queryValidatorAccountResponseDescriptor instead')
const QueryValidatorAccountResponse$json = const {
  '1': 'QueryValidatorAccountResponse',
  '2': const [
    const {'1': 'account_address', '3': 1, '4': 1, '5': 9, '10': 'accountAddress'},
    const {'1': 'sequence', '3': 2, '4': 1, '5': 4, '10': 'sequence'},
    const {'1': 'account_number', '3': 3, '4': 1, '5': 4, '10': 'accountNumber'},
  ],
};

/// Descriptor for `QueryValidatorAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryValidatorAccountResponseDescriptor = $convert.base64Decode('Ch1RdWVyeVZhbGlkYXRvckFjY291bnRSZXNwb25zZRInCg9hY2NvdW50X2FkZHJlc3MYASABKAlSDmFjY291bnRBZGRyZXNzEhoKCHNlcXVlbmNlGAIgASgEUghzZXF1ZW5jZRIlCg5hY2NvdW50X251bWJlchgDIAEoBFINYWNjb3VudE51bWJlcg==');
@$core.Deprecated('Use queryBalanceRequestDescriptor instead')
const QueryBalanceRequest$json = const {
  '1': 'QueryBalanceRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
  '7': const {},
};

/// Descriptor for `QueryBalanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBalanceRequestDescriptor = $convert.base64Decode('ChNRdWVyeUJhbGFuY2VSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M6CIigHwDooB8A');
@$core.Deprecated('Use queryBalanceResponseDescriptor instead')
const QueryBalanceResponse$json = const {
  '1': 'QueryBalanceResponse',
  '2': const [
    const {'1': 'balance', '3': 1, '4': 1, '5': 9, '10': 'balance'},
  ],
};

/// Descriptor for `QueryBalanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBalanceResponseDescriptor = $convert.base64Decode('ChRRdWVyeUJhbGFuY2VSZXNwb25zZRIYCgdiYWxhbmNlGAEgASgJUgdiYWxhbmNl');
@$core.Deprecated('Use queryStorageRequestDescriptor instead')
const QueryStorageRequest$json = const {
  '1': 'QueryStorageRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    const {'1': 'key', '3': 2, '4': 1, '5': 9, '10': 'key'},
  ],
  '7': const {},
};

/// Descriptor for `QueryStorageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryStorageRequestDescriptor = $convert.base64Decode('ChNRdWVyeVN0b3JhZ2VSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSEAoDa2V5GAIgASgJUgNrZXk6CIigHwDooB8A');
@$core.Deprecated('Use queryStorageResponseDescriptor instead')
const QueryStorageResponse$json = const {
  '1': 'QueryStorageResponse',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `QueryStorageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryStorageResponseDescriptor = $convert.base64Decode('ChRRdWVyeVN0b3JhZ2VSZXNwb25zZRIUCgV2YWx1ZRgBIAEoCVIFdmFsdWU=');
@$core.Deprecated('Use queryCodeRequestDescriptor instead')
const QueryCodeRequest$json = const {
  '1': 'QueryCodeRequest',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
  '7': const {},
};

/// Descriptor for `QueryCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCodeRequestDescriptor = $convert.base64Decode('ChBRdWVyeUNvZGVSZXF1ZXN0EhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3M6CIigHwDooB8A');
@$core.Deprecated('Use queryCodeResponseDescriptor instead')
const QueryCodeResponse$json = const {
  '1': 'QueryCodeResponse',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 12, '10': 'code'},
  ],
};

/// Descriptor for `QueryCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryCodeResponseDescriptor = $convert.base64Decode('ChFRdWVyeUNvZGVSZXNwb25zZRISCgRjb2RlGAEgASgMUgRjb2Rl');
@$core.Deprecated('Use queryTxLogsRequestDescriptor instead')
const QueryTxLogsRequest$json = const {
  '1': 'QueryTxLogsRequest',
  '2': const [
    const {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    const {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.cosmos.base.query.v1beta1.PageRequest', '10': 'pagination'},
  ],
  '7': const {},
};

/// Descriptor for `QueryTxLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTxLogsRequestDescriptor = $convert.base64Decode('ChJRdWVyeVR4TG9nc1JlcXVlc3QSEgoEaGFzaBgBIAEoCVIEaGFzaBJGCgpwYWdpbmF0aW9uGAIgASgLMiYuY29zbW9zLmJhc2UucXVlcnkudjFiZXRhMS5QYWdlUmVxdWVzdFIKcGFnaW5hdGlvbjoIiKAfAOigHwA=');
@$core.Deprecated('Use queryTxLogsResponseDescriptor instead')
const QueryTxLogsResponse$json = const {
  '1': 'QueryTxLogsResponse',
  '2': const [
    const {'1': 'logs', '3': 1, '4': 3, '5': 11, '6': '.ethermint.evm.v1.Log', '10': 'logs'},
    const {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.cosmos.base.query.v1beta1.PageResponse', '10': 'pagination'},
  ],
};

/// Descriptor for `QueryTxLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTxLogsResponseDescriptor = $convert.base64Decode('ChNRdWVyeVR4TG9nc1Jlc3BvbnNlEikKBGxvZ3MYASADKAsyFS5ldGhlcm1pbnQuZXZtLnYxLkxvZ1IEbG9ncxJHCgpwYWdpbmF0aW9uGAIgASgLMicuY29zbW9zLmJhc2UucXVlcnkudjFiZXRhMS5QYWdlUmVzcG9uc2VSCnBhZ2luYXRpb24=');
@$core.Deprecated('Use queryParamsRequestDescriptor instead')
const QueryParamsRequest$json = const {
  '1': 'QueryParamsRequest',
};

/// Descriptor for `QueryParamsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryParamsRequestDescriptor = $convert.base64Decode('ChJRdWVyeVBhcmFtc1JlcXVlc3Q=');
@$core.Deprecated('Use queryParamsResponseDescriptor instead')
const QueryParamsResponse$json = const {
  '1': 'QueryParamsResponse',
  '2': const [
    const {'1': 'params', '3': 1, '4': 1, '5': 11, '6': '.ethermint.evm.v1.Params', '8': const {}, '10': 'params'},
  ],
};

/// Descriptor for `QueryParamsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryParamsResponseDescriptor = $convert.base64Decode('ChNRdWVyeVBhcmFtc1Jlc3BvbnNlEjYKBnBhcmFtcxgBIAEoCzIYLmV0aGVybWludC5ldm0udjEuUGFyYW1zQgTI3h8AUgZwYXJhbXM=');
@$core.Deprecated('Use ethCallRequestDescriptor instead')
const EthCallRequest$json = const {
  '1': 'EthCallRequest',
  '2': const [
    const {'1': 'args', '3': 1, '4': 1, '5': 12, '10': 'args'},
    const {'1': 'gas_cap', '3': 2, '4': 1, '5': 4, '10': 'gasCap'},
  ],
};

/// Descriptor for `EthCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ethCallRequestDescriptor = $convert.base64Decode('Cg5FdGhDYWxsUmVxdWVzdBISCgRhcmdzGAEgASgMUgRhcmdzEhcKB2dhc19jYXAYAiABKARSBmdhc0NhcA==');
@$core.Deprecated('Use estimateGasResponseDescriptor instead')
const EstimateGasResponse$json = const {
  '1': 'EstimateGasResponse',
  '2': const [
    const {'1': 'gas', '3': 1, '4': 1, '5': 4, '10': 'gas'},
  ],
};

/// Descriptor for `EstimateGasResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateGasResponseDescriptor = $convert.base64Decode('ChNFc3RpbWF0ZUdhc1Jlc3BvbnNlEhAKA2dhcxgBIAEoBFIDZ2Fz');
@$core.Deprecated('Use queryTraceTxRequestDescriptor instead')
const QueryTraceTxRequest$json = const {
  '1': 'QueryTraceTxRequest',
  '2': const [
    const {'1': 'msg', '3': 1, '4': 1, '5': 11, '6': '.ethermint.evm.v1.MsgEthereumTx', '10': 'msg'},
    const {'1': 'trace_config', '3': 3, '4': 1, '5': 11, '6': '.ethermint.evm.v1.TraceConfig', '10': 'traceConfig'},
    const {'1': 'predecessors', '3': 4, '4': 3, '5': 11, '6': '.ethermint.evm.v1.MsgEthereumTx', '10': 'predecessors'},
    const {'1': 'block_number', '3': 5, '4': 1, '5': 3, '10': 'blockNumber'},
    const {'1': 'block_hash', '3': 6, '4': 1, '5': 9, '10': 'blockHash'},
    const {'1': 'block_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '8': const {}, '10': 'blockTime'},
  ],
  '9': const [
    const {'1': 2, '2': 3},
  ],
  '10': const ['tx_index'],
};

/// Descriptor for `QueryTraceTxRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTraceTxRequestDescriptor = $convert.base64Decode('ChNRdWVyeVRyYWNlVHhSZXF1ZXN0EjEKA21zZxgBIAEoCzIfLmV0aGVybWludC5ldm0udjEuTXNnRXRoZXJldW1UeFIDbXNnEkAKDHRyYWNlX2NvbmZpZxgDIAEoCzIdLmV0aGVybWludC5ldm0udjEuVHJhY2VDb25maWdSC3RyYWNlQ29uZmlnEkMKDHByZWRlY2Vzc29ycxgEIAMoCzIfLmV0aGVybWludC5ldm0udjEuTXNnRXRoZXJldW1UeFIMcHJlZGVjZXNzb3JzEiEKDGJsb2NrX251bWJlchgFIAEoA1ILYmxvY2tOdW1iZXISHQoKYmxvY2tfaGFzaBgGIAEoCVIJYmxvY2tIYXNoEkMKCmJsb2NrX3RpbWUYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wQgjI3h8AkN8fAVIJYmxvY2tUaW1lSgQIAhADUgh0eF9pbmRleA==');
@$core.Deprecated('Use queryTraceTxResponseDescriptor instead')
const QueryTraceTxResponse$json = const {
  '1': 'QueryTraceTxResponse',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `QueryTraceTxResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTraceTxResponseDescriptor = $convert.base64Decode('ChRRdWVyeVRyYWNlVHhSZXNwb25zZRISCgRkYXRhGAEgASgMUgRkYXRh');
@$core.Deprecated('Use queryTraceBlockRequestDescriptor instead')
const QueryTraceBlockRequest$json = const {
  '1': 'QueryTraceBlockRequest',
  '2': const [
    const {'1': 'txs', '3': 1, '4': 3, '5': 11, '6': '.ethermint.evm.v1.MsgEthereumTx', '10': 'txs'},
    const {'1': 'trace_config', '3': 3, '4': 1, '5': 11, '6': '.ethermint.evm.v1.TraceConfig', '10': 'traceConfig'},
    const {'1': 'block_number', '3': 5, '4': 1, '5': 3, '10': 'blockNumber'},
    const {'1': 'block_hash', '3': 6, '4': 1, '5': 9, '10': 'blockHash'},
    const {'1': 'block_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '8': const {}, '10': 'blockTime'},
  ],
};

/// Descriptor for `QueryTraceBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTraceBlockRequestDescriptor = $convert.base64Decode('ChZRdWVyeVRyYWNlQmxvY2tSZXF1ZXN0EjEKA3R4cxgBIAMoCzIfLmV0aGVybWludC5ldm0udjEuTXNnRXRoZXJldW1UeFIDdHhzEkAKDHRyYWNlX2NvbmZpZxgDIAEoCzIdLmV0aGVybWludC5ldm0udjEuVHJhY2VDb25maWdSC3RyYWNlQ29uZmlnEiEKDGJsb2NrX251bWJlchgFIAEoA1ILYmxvY2tOdW1iZXISHQoKYmxvY2tfaGFzaBgGIAEoCVIJYmxvY2tIYXNoEkMKCmJsb2NrX3RpbWUYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wQgjI3h8AkN8fAVIJYmxvY2tUaW1l');
@$core.Deprecated('Use queryTraceBlockResponseDescriptor instead')
const QueryTraceBlockResponse$json = const {
  '1': 'QueryTraceBlockResponse',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `QueryTraceBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryTraceBlockResponseDescriptor = $convert.base64Decode('ChdRdWVyeVRyYWNlQmxvY2tSZXNwb25zZRISCgRkYXRhGAEgASgMUgRkYXRh');
@$core.Deprecated('Use queryBaseFeeRequestDescriptor instead')
const QueryBaseFeeRequest$json = const {
  '1': 'QueryBaseFeeRequest',
};

/// Descriptor for `QueryBaseFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBaseFeeRequestDescriptor = $convert.base64Decode('ChNRdWVyeUJhc2VGZWVSZXF1ZXN0');
@$core.Deprecated('Use queryBaseFeeResponseDescriptor instead')
const QueryBaseFeeResponse$json = const {
  '1': 'QueryBaseFeeResponse',
  '2': const [
    const {'1': 'base_fee', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'baseFee'},
  ],
};

/// Descriptor for `QueryBaseFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBaseFeeResponseDescriptor = $convert.base64Decode('ChRRdWVyeUJhc2VGZWVSZXNwb25zZRJFCghiYXNlX2ZlZRgBIAEoCUIq2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW50UgdiYXNlRmVl');
