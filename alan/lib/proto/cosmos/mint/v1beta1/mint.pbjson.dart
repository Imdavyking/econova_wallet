///
//  Generated code. Do not modify.
//  source: cosmos/mint/v1beta1/mint.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use minterDescriptor instead')
const Minter$json = const {
  '1': 'Minter',
  '2': const [
    const {'1': 'inflation', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'inflation'},
    const {'1': 'annual_provisions', '3': 2, '4': 1, '5': 9, '8': const {}, '10': 'annualProvisions'},
  ],
};

/// Descriptor for `Minter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List minterDescriptor = $convert.base64Decode('CgZNaW50ZXISTAoJaW5mbGF0aW9uGAEgASgJQi7I3h8A2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuRGVjUglpbmZsYXRpb24SdwoRYW5udWFsX3Byb3Zpc2lvbnMYAiABKAlCSsjeHwDa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5EZWPy3h8YeWFtbDoiYW5udWFsX3Byb3Zpc2lvbnMiUhBhbm51YWxQcm92aXNpb25z');
@$core.Deprecated('Use paramsDescriptor instead')
const Params$json = const {
  '1': 'Params',
  '2': const [
    const {'1': 'mint_denom', '3': 1, '4': 1, '5': 9, '10': 'mintDenom'},
    const {'1': 'inflation_rate_change', '3': 2, '4': 1, '5': 9, '8': const {}, '10': 'inflationRateChange'},
    const {'1': 'inflation_max', '3': 3, '4': 1, '5': 9, '8': const {}, '10': 'inflationMax'},
    const {'1': 'inflation_min', '3': 4, '4': 1, '5': 9, '8': const {}, '10': 'inflationMin'},
    const {'1': 'goal_bonded', '3': 5, '4': 1, '5': 9, '8': const {}, '10': 'goalBonded'},
    const {'1': 'blocks_per_year', '3': 6, '4': 1, '5': 4, '8': const {}, '10': 'blocksPerYear'},
  ],
  '7': const {},
};

/// Descriptor for `Params`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paramsDescriptor = $convert.base64Decode('CgZQYXJhbXMSHQoKbWludF9kZW5vbRgBIAEoCVIJbWludERlbm9tEoIBChVpbmZsYXRpb25fcmF0ZV9jaGFuZ2UYAiABKAlCTsjeHwDa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5EZWPy3h8ceWFtbDoiaW5mbGF0aW9uX3JhdGVfY2hhbmdlIlITaW5mbGF0aW9uUmF0ZUNoYW5nZRJrCg1pbmZsYXRpb25fbWF4GAMgASgJQkbI3h8A2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuRGVj8t4fFHlhbWw6ImluZmxhdGlvbl9tYXgiUgxpbmZsYXRpb25NYXgSawoNaW5mbGF0aW9uX21pbhgEIAEoCUJGyN4fANreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkRlY/LeHxR5YW1sOiJpbmZsYXRpb25fbWluIlIMaW5mbGF0aW9uTWluEmUKC2dvYWxfYm9uZGVkGAUgASgJQkTI3h8A2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuRGVj8t4fEnlhbWw6ImdvYWxfYm9uZGVkIlIKZ29hbEJvbmRlZBJCCg9ibG9ja3NfcGVyX3llYXIYBiABKARCGvLeHxZ5YW1sOiJibG9ja3NfcGVyX3llYXIiUg1ibG9ja3NQZXJZZWFyOgSYoB8A');
