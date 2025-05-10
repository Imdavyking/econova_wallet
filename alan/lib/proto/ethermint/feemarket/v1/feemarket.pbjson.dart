///
//  Generated code. Do not modify.
//  source: ethermint/feemarket/v1/feemarket.proto
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
    const {'1': 'no_base_fee', '3': 1, '4': 1, '5': 8, '10': 'noBaseFee'},
    const {'1': 'base_fee_change_denominator', '3': 2, '4': 1, '5': 13, '10': 'baseFeeChangeDenominator'},
    const {'1': 'elasticity_multiplier', '3': 3, '4': 1, '5': 13, '10': 'elasticityMultiplier'},
    const {'1': 'enable_height', '3': 5, '4': 1, '5': 3, '10': 'enableHeight'},
    const {'1': 'base_fee', '3': 6, '4': 1, '5': 9, '8': const {}, '10': 'baseFee'},
    const {'1': 'min_gas_price', '3': 7, '4': 1, '5': 9, '8': const {}, '10': 'minGasPrice'},
    const {'1': 'min_gas_multiplier', '3': 8, '4': 1, '5': 9, '8': const {}, '10': 'minGasMultiplier'},
  ],
  '9': const [
    const {'1': 4, '2': 5},
  ],
  '10': const ['initial_base_fee'],
};

/// Descriptor for `Params`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paramsDescriptor = $convert.base64Decode('CgZQYXJhbXMSHgoLbm9fYmFzZV9mZWUYASABKAhSCW5vQmFzZUZlZRI9ChtiYXNlX2ZlZV9jaGFuZ2VfZGVub21pbmF0b3IYAiABKA1SGGJhc2VGZWVDaGFuZ2VEZW5vbWluYXRvchIzChVlbGFzdGljaXR5X211bHRpcGxpZXIYAyABKA1SFGVsYXN0aWNpdHlNdWx0aXBsaWVyEiMKDWVuYWJsZV9oZWlnaHQYBSABKANSDGVuYWJsZUhlaWdodBJJCghiYXNlX2ZlZRgGIAEoCUIuyN4fANreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludFIHYmFzZUZlZRJSCg1taW5fZ2FzX3ByaWNlGAcgASgJQi7I3h8A2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuRGVjUgttaW5HYXNQcmljZRJcChJtaW5fZ2FzX211bHRpcGxpZXIYCCABKAlCLsjeHwDa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5EZWNSEG1pbkdhc011bHRpcGxpZXJKBAgEEAVSEGluaXRpYWxfYmFzZV9mZWU=');
