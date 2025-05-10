///
//  Generated code. Do not modify.
//  source: ethermint/feemarket/v1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
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
    const {'1': 'params', '3': 1, '4': 1, '5': 11, '6': '.ethermint.feemarket.v1.Params', '8': const {}, '10': 'params'},
  ],
};

/// Descriptor for `QueryParamsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryParamsResponseDescriptor = $convert.base64Decode('ChNRdWVyeVBhcmFtc1Jlc3BvbnNlEjwKBnBhcmFtcxgBIAEoCzIeLmV0aGVybWludC5mZWVtYXJrZXQudjEuUGFyYW1zQgTI3h8AUgZwYXJhbXM=');
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
@$core.Deprecated('Use queryBlockGasRequestDescriptor instead')
const QueryBlockGasRequest$json = const {
  '1': 'QueryBlockGasRequest',
};

/// Descriptor for `QueryBlockGasRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBlockGasRequestDescriptor = $convert.base64Decode('ChRRdWVyeUJsb2NrR2FzUmVxdWVzdA==');
@$core.Deprecated('Use queryBlockGasResponseDescriptor instead')
const QueryBlockGasResponse$json = const {
  '1': 'QueryBlockGasResponse',
  '2': const [
    const {'1': 'gas', '3': 1, '4': 1, '5': 3, '10': 'gas'},
  ],
};

/// Descriptor for `QueryBlockGasResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List queryBlockGasResponseDescriptor = $convert.base64Decode('ChVRdWVyeUJsb2NrR2FzUmVzcG9uc2USEAoDZ2FzGAEgASgDUgNnYXM=');
