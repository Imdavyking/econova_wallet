///
//  Generated code. Do not modify.
//  source: ethermint/types/v1/indexer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use txResultDescriptor instead')
const TxResult$json = const {
  '1': 'TxResult',
  '2': const [
    const {'1': 'height', '3': 1, '4': 1, '5': 3, '10': 'height'},
    const {'1': 'tx_index', '3': 2, '4': 1, '5': 13, '10': 'txIndex'},
    const {'1': 'msg_index', '3': 3, '4': 1, '5': 13, '10': 'msgIndex'},
    const {'1': 'eth_tx_index', '3': 4, '4': 1, '5': 5, '10': 'ethTxIndex'},
    const {'1': 'failed', '3': 5, '4': 1, '5': 8, '10': 'failed'},
    const {'1': 'gas_used', '3': 6, '4': 1, '5': 4, '10': 'gasUsed'},
    const {'1': 'cumulative_gas_used', '3': 7, '4': 1, '5': 4, '10': 'cumulativeGasUsed'},
  ],
  '7': const {},
};

/// Descriptor for `TxResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List txResultDescriptor = $convert.base64Decode('CghUeFJlc3VsdBIWCgZoZWlnaHQYASABKANSBmhlaWdodBIZCgh0eF9pbmRleBgCIAEoDVIHdHhJbmRleBIbCgltc2dfaW5kZXgYAyABKA1SCG1zZ0luZGV4EiAKDGV0aF90eF9pbmRleBgEIAEoBVIKZXRoVHhJbmRleBIWCgZmYWlsZWQYBSABKAhSBmZhaWxlZBIZCghnYXNfdXNlZBgGIAEoBFIHZ2FzVXNlZBIuChNjdW11bGF0aXZlX2dhc191c2VkGAcgASgEUhFjdW11bGF0aXZlR2FzVXNlZDoEiKAfAA==');
