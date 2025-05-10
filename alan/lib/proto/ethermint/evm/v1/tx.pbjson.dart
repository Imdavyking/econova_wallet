///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/tx.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use msgEthereumTxDescriptor instead')
const MsgEthereumTx$json = const {
  '1': 'MsgEthereumTx',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Any', '10': 'data'},
    const {'1': 'size', '3': 2, '4': 1, '5': 1, '8': const {}, '10': 'size'},
    const {'1': 'hash', '3': 3, '4': 1, '5': 9, '8': const {}, '10': 'hash'},
    const {'1': 'from', '3': 4, '4': 1, '5': 9, '10': 'from'},
  ],
  '7': const {},
};

/// Descriptor for `MsgEthereumTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgEthereumTxDescriptor = $convert.base64Decode('Cg1Nc2dFdGhlcmV1bVR4EigKBGRhdGEYASABKAsyFC5nb29nbGUucHJvdG9idWYuQW55UgRkYXRhEhkKBHNpemUYAiABKAFCBereHwEtUgRzaXplEh8KBGhhc2gYAyABKAlCC/LeHwdybHA6Ii0iUgRoYXNoEhIKBGZyb20YBCABKAlSBGZyb206BIigHwA=');
@$core.Deprecated('Use legacyTxDescriptor instead')
const LegacyTx$json = const {
  '1': 'LegacyTx',
  '2': const [
    const {'1': 'nonce', '3': 1, '4': 1, '5': 4, '10': 'nonce'},
    const {'1': 'gas_price', '3': 2, '4': 1, '5': 9, '8': const {}, '10': 'gasPrice'},
    const {'1': 'gas', '3': 3, '4': 1, '5': 4, '8': const {}, '10': 'gas'},
    const {'1': 'to', '3': 4, '4': 1, '5': 9, '10': 'to'},
    const {'1': 'value', '3': 5, '4': 1, '5': 9, '8': const {}, '10': 'value'},
    const {'1': 'data', '3': 6, '4': 1, '5': 12, '10': 'data'},
    const {'1': 'v', '3': 7, '4': 1, '5': 12, '10': 'v'},
    const {'1': 'r', '3': 8, '4': 1, '5': 12, '10': 'r'},
    const {'1': 's', '3': 9, '4': 1, '5': 12, '10': 's'},
  ],
  '7': const {},
};

/// Descriptor for `LegacyTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List legacyTxDescriptor = $convert.base64Decode('CghMZWdhY3lUeBIUCgVub25jZRgBIAEoBFIFbm9uY2USRwoJZ2FzX3ByaWNlGAIgASgJQira3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnRSCGdhc1ByaWNlEh4KA2dhcxgDIAEoBEIM4t4fCEdhc0xpbWl0UgNnYXMSDgoCdG8YBCABKAlSAnRvEkoKBXZhbHVlGAUgASgJQjTa3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnTi3h8GQW1vdW50UgV2YWx1ZRISCgRkYXRhGAYgASgMUgRkYXRhEgwKAXYYByABKAxSAXYSDAoBchgIIAEoDFIBchIMCgFzGAkgASgMUgFzOg6IoB8AyrQtBlR4RGF0YQ==');
@$core.Deprecated('Use accessListTxDescriptor instead')
const AccessListTx$json = const {
  '1': 'AccessListTx',
  '2': const [
    const {'1': 'chain_id', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'chainId'},
    const {'1': 'nonce', '3': 2, '4': 1, '5': 4, '10': 'nonce'},
    const {'1': 'gas_price', '3': 3, '4': 1, '5': 9, '8': const {}, '10': 'gasPrice'},
    const {'1': 'gas', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'gas'},
    const {'1': 'to', '3': 5, '4': 1, '5': 9, '10': 'to'},
    const {'1': 'value', '3': 6, '4': 1, '5': 9, '8': const {}, '10': 'value'},
    const {'1': 'data', '3': 7, '4': 1, '5': 12, '10': 'data'},
    const {'1': 'accesses', '3': 8, '4': 3, '5': 11, '6': '.ethermint.evm.v1.AccessTuple', '8': const {}, '10': 'accesses'},
    const {'1': 'v', '3': 9, '4': 1, '5': 12, '10': 'v'},
    const {'1': 'r', '3': 10, '4': 1, '5': 12, '10': 'r'},
    const {'1': 's', '3': 11, '4': 1, '5': 12, '10': 's'},
  ],
  '7': const {},
};

/// Descriptor for `AccessListTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessListTxDescriptor = $convert.base64Decode('CgxBY2Nlc3NMaXN0VHgSWwoIY2hhaW5faWQYASABKAlCQNreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludOLeHwdDaGFpbklE6t4fB2NoYWluSURSB2NoYWluSWQSFAoFbm9uY2UYAiABKARSBW5vbmNlEkcKCWdhc19wcmljZRgDIAEoCUIq2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW50UghnYXNQcmljZRIeCgNnYXMYBCABKARCDOLeHwhHYXNMaW1pdFIDZ2FzEg4KAnRvGAUgASgJUgJ0bxJKCgV2YWx1ZRgGIAEoCUI02t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW504t4fBkFtb3VudFIFdmFsdWUSEgoEZGF0YRgHIAEoDFIEZGF0YRJbCghhY2Nlc3NlcxgIIAMoCzIdLmV0aGVybWludC5ldm0udjEuQWNjZXNzVHVwbGVCIMjeHwDq3h8KYWNjZXNzTGlzdKrfHwpBY2Nlc3NMaXN0UghhY2Nlc3NlcxIMCgF2GAkgASgMUgF2EgwKAXIYCiABKAxSAXISDAoBcxgLIAEoDFIBczoOiKAfAMq0LQZUeERhdGE=');
@$core.Deprecated('Use dynamicFeeTxDescriptor instead')
const DynamicFeeTx$json = const {
  '1': 'DynamicFeeTx',
  '2': const [
    const {'1': 'chain_id', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'chainId'},
    const {'1': 'nonce', '3': 2, '4': 1, '5': 4, '10': 'nonce'},
    const {'1': 'gas_tip_cap', '3': 3, '4': 1, '5': 9, '8': const {}, '10': 'gasTipCap'},
    const {'1': 'gas_fee_cap', '3': 4, '4': 1, '5': 9, '8': const {}, '10': 'gasFeeCap'},
    const {'1': 'gas', '3': 5, '4': 1, '5': 4, '8': const {}, '10': 'gas'},
    const {'1': 'to', '3': 6, '4': 1, '5': 9, '10': 'to'},
    const {'1': 'value', '3': 7, '4': 1, '5': 9, '8': const {}, '10': 'value'},
    const {'1': 'data', '3': 8, '4': 1, '5': 12, '10': 'data'},
    const {'1': 'accesses', '3': 9, '4': 3, '5': 11, '6': '.ethermint.evm.v1.AccessTuple', '8': const {}, '10': 'accesses'},
    const {'1': 'v', '3': 10, '4': 1, '5': 12, '10': 'v'},
    const {'1': 'r', '3': 11, '4': 1, '5': 12, '10': 'r'},
    const {'1': 's', '3': 12, '4': 1, '5': 12, '10': 's'},
  ],
  '7': const {},
};

/// Descriptor for `DynamicFeeTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dynamicFeeTxDescriptor = $convert.base64Decode('CgxEeW5hbWljRmVlVHgSWwoIY2hhaW5faWQYASABKAlCQNreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludOLeHwdDaGFpbklE6t4fB2NoYWluSURSB2NoYWluSWQSFAoFbm9uY2UYAiABKARSBW5vbmNlEkoKC2dhc190aXBfY2FwGAMgASgJQira3h8mZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5JbnRSCWdhc1RpcENhcBJKCgtnYXNfZmVlX2NhcBgEIAEoCUIq2t4fJmdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuSW50UglnYXNGZWVDYXASHgoDZ2FzGAUgASgEQgzi3h8IR2FzTGltaXRSA2dhcxIOCgJ0bxgGIAEoCVICdG8SSgoFdmFsdWUYByABKAlCNNreHyZnaXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkludOLeHwZBbW91bnRSBXZhbHVlEhIKBGRhdGEYCCABKAxSBGRhdGESWwoIYWNjZXNzZXMYCSADKAsyHS5ldGhlcm1pbnQuZXZtLnYxLkFjY2Vzc1R1cGxlQiDI3h8A6t4fCmFjY2Vzc0xpc3Sq3x8KQWNjZXNzTGlzdFIIYWNjZXNzZXMSDAoBdhgKIAEoDFIBdhIMCgFyGAsgASgMUgFyEgwKAXMYDCABKAxSAXM6DoigHwDKtC0GVHhEYXRh');
@$core.Deprecated('Use extensionOptionsEthereumTxDescriptor instead')
const ExtensionOptionsEthereumTx$json = const {
  '1': 'ExtensionOptionsEthereumTx',
  '7': const {},
};

/// Descriptor for `ExtensionOptionsEthereumTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionOptionsEthereumTxDescriptor = $convert.base64Decode('ChpFeHRlbnNpb25PcHRpb25zRXRoZXJldW1UeDoEiKAfAA==');
@$core.Deprecated('Use msgEthereumTxResponseDescriptor instead')
const MsgEthereumTxResponse$json = const {
  '1': 'MsgEthereumTxResponse',
  '2': const [
    const {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    const {'1': 'logs', '3': 2, '4': 3, '5': 11, '6': '.ethermint.evm.v1.Log', '10': 'logs'},
    const {'1': 'ret', '3': 3, '4': 1, '5': 12, '10': 'ret'},
    const {'1': 'vm_error', '3': 4, '4': 1, '5': 9, '10': 'vmError'},
    const {'1': 'gas_used', '3': 5, '4': 1, '5': 4, '10': 'gasUsed'},
  ],
  '7': const {},
};

/// Descriptor for `MsgEthereumTxResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgEthereumTxResponseDescriptor = $convert.base64Decode('ChVNc2dFdGhlcmV1bVR4UmVzcG9uc2USEgoEaGFzaBgBIAEoCVIEaGFzaBIpCgRsb2dzGAIgAygLMhUuZXRoZXJtaW50LmV2bS52MS5Mb2dSBGxvZ3MSEAoDcmV0GAMgASgMUgNyZXQSGQoIdm1fZXJyb3IYBCABKAlSB3ZtRXJyb3ISGQoIZ2FzX3VzZWQYBSABKARSB2dhc1VzZWQ6BIigHwA=');
