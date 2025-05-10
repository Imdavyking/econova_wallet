///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/msg.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use msgStoreCodeDescriptor instead')
const MsgStoreCode$json = const {
  '1': 'MsgStoreCode',
  '2': const [
    const {'1': 'sender', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'sender'},
    const {'1': 'wasm_byte_code', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'wasmByteCode'},
    const {'1': 'source', '3': 3, '4': 1, '5': 9, '10': 'source'},
    const {'1': 'builder', '3': 4, '4': 1, '5': 9, '10': 'builder'},
  ],
  '7': const {},
};

/// Descriptor for `MsgStoreCode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgStoreCodeDescriptor = $convert.base64Decode('CgxNc2dTdG9yZUNvZGUSSQoGc2VuZGVyGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgZzZW5kZXISNgoOd2FzbV9ieXRlX2NvZGUYAiABKAxCEOLeHwxXQVNNQnl0ZUNvZGVSDHdhc21CeXRlQ29kZRIWCgZzb3VyY2UYAyABKAlSBnNvdXJjZRIYCgdidWlsZGVyGAQgASgJUgdidWlsZGVyOgSIoB8A');
@$core.Deprecated('Use msgInstantiateContractDescriptor instead')
const MsgInstantiateContract$json = const {
  '1': 'MsgInstantiateContract',
  '2': const [
    const {'1': 'sender', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'sender'},
    const {'1': 'callback_code_hash', '3': 2, '4': 1, '5': 9, '10': 'callbackCodeHash'},
    const {'1': 'code_id', '3': 3, '4': 1, '5': 4, '8': const {}, '10': 'codeId'},
    const {'1': 'label', '3': 4, '4': 1, '5': 9, '10': 'label'},
    const {'1': 'init_msg', '3': 5, '4': 1, '5': 12, '10': 'initMsg'},
    const {'1': 'init_funds', '3': 6, '4': 3, '5': 11, '6': '.cosmos.base.v1beta1.Coin', '8': const {}, '10': 'initFunds'},
    const {'1': 'callback_sig', '3': 7, '4': 1, '5': 12, '8': const {}, '10': 'callbackSig'},
  ],
  '7': const {},
};

/// Descriptor for `MsgInstantiateContract`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgInstantiateContractDescriptor = $convert.base64Decode('ChZNc2dJbnN0YW50aWF0ZUNvbnRyYWN0EkkKBnNlbmRlchgBIAEoDEIx+t4fLWdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQWNjQWRkcmVzc1IGc2VuZGVyEiwKEmNhbGxiYWNrX2NvZGVfaGFzaBgCIAEoCVIQY2FsbGJhY2tDb2RlSGFzaBIjCgdjb2RlX2lkGAMgASgEQgri3h8GQ29kZUlEUgZjb2RlSWQSFAoFbGFiZWwYBCABKAlSBWxhYmVsEhkKCGluaXRfbXNnGAUgASgMUgdpbml0TXNnEmoKCmluaXRfZnVuZHMYBiADKAsyGS5jb3Ntb3MuYmFzZS52MWJldGExLkNvaW5CMMjeHwCq3x8oZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5Db2luc1IJaW5pdEZ1bmRzEjIKDGNhbGxiYWNrX3NpZxgHIAEoDEIP4t4fC0NhbGxiYWNrU2lnUgtjYWxsYmFja1NpZzoEiKAfAA==');
@$core.Deprecated('Use msgExecuteContractDescriptor instead')
const MsgExecuteContract$json = const {
  '1': 'MsgExecuteContract',
  '2': const [
    const {'1': 'sender', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'sender'},
    const {'1': 'contract', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'contract'},
    const {'1': 'msg', '3': 3, '4': 1, '5': 12, '10': 'msg'},
    const {'1': 'callback_code_hash', '3': 4, '4': 1, '5': 9, '10': 'callbackCodeHash'},
    const {'1': 'sent_funds', '3': 5, '4': 3, '5': 11, '6': '.cosmos.base.v1beta1.Coin', '8': const {}, '10': 'sentFunds'},
    const {'1': 'callback_sig', '3': 6, '4': 1, '5': 12, '8': const {}, '10': 'callbackSig'},
  ],
  '7': const {},
};

/// Descriptor for `MsgExecuteContract`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List msgExecuteContractDescriptor = $convert.base64Decode('ChJNc2dFeGVjdXRlQ29udHJhY3QSSQoGc2VuZGVyGAEgASgMQjH63h8tZ2l0aHViLmNvbS9jb3Ntb3MvY29zbW9zLXNkay90eXBlcy5BY2NBZGRyZXNzUgZzZW5kZXISTQoIY29udHJhY3QYAiABKAxCMfreHy1naXRodWIuY29tL2Nvc21vcy9jb3Ntb3Mtc2RrL3R5cGVzLkFjY0FkZHJlc3NSCGNvbnRyYWN0EhAKA21zZxgDIAEoDFIDbXNnEiwKEmNhbGxiYWNrX2NvZGVfaGFzaBgEIAEoCVIQY2FsbGJhY2tDb2RlSGFzaBJqCgpzZW50X2Z1bmRzGAUgAygLMhkuY29zbW9zLmJhc2UudjFiZXRhMS5Db2luQjDI3h8Aqt8fKGdpdGh1Yi5jb20vY29zbW9zL2Nvc21vcy1zZGsvdHlwZXMuQ29pbnNSCXNlbnRGdW5kcxIyCgxjYWxsYmFja19zaWcYBiABKAxCD+LeHwtDYWxsYmFja1NpZ1ILY2FsbGJhY2tTaWc6BIigHwA=');
