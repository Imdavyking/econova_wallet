///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/genesis.proto
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
    const {'1': 'accounts', '3': 1, '4': 3, '5': 11, '6': '.ethermint.evm.v1.GenesisAccount', '8': const {}, '10': 'accounts'},
    const {'1': 'params', '3': 2, '4': 1, '5': 11, '6': '.ethermint.evm.v1.Params', '8': const {}, '10': 'params'},
  ],
};

/// Descriptor for `GenesisState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List genesisStateDescriptor = $convert.base64Decode('CgxHZW5lc2lzU3RhdGUSQgoIYWNjb3VudHMYASADKAsyIC5ldGhlcm1pbnQuZXZtLnYxLkdlbmVzaXNBY2NvdW50QgTI3h8AUghhY2NvdW50cxI2CgZwYXJhbXMYAiABKAsyGC5ldGhlcm1pbnQuZXZtLnYxLlBhcmFtc0IEyN4fAFIGcGFyYW1z');
@$core.Deprecated('Use genesisAccountDescriptor instead')
const GenesisAccount$json = const {
  '1': 'GenesisAccount',
  '2': const [
    const {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    const {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    const {'1': 'storage', '3': 3, '4': 3, '5': 11, '6': '.ethermint.evm.v1.State', '8': const {}, '10': 'storage'},
  ],
};

/// Descriptor for `GenesisAccount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List genesisAccountDescriptor = $convert.base64Decode('Cg5HZW5lc2lzQWNjb3VudBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhIKBGNvZGUYAiABKAlSBGNvZGUSQgoHc3RvcmFnZRgDIAMoCzIXLmV0aGVybWludC5ldm0udjEuU3RhdGVCD8jeHwCq3x8HU3RvcmFnZVIHc3RvcmFnZQ==');
