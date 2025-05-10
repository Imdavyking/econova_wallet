///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/remote_attestation/types.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use quoteReportDescriptor instead')
const QuoteReport$json = const {
  '1': 'QuoteReport',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'id'},
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 9, '10': 'timestamp'},
    const {'1': 'version', '3': 3, '4': 1, '5': 4, '10': 'version'},
    const {'1': 'isv_enclave_quote_status', '3': 4, '4': 1, '5': 9, '8': const {}, '10': 'isvEnclaveQuoteStatus'},
    const {'1': 'platform_info_blob', '3': 5, '4': 1, '5': 9, '8': const {}, '10': 'platformInfoBlob'},
    const {'1': 'isv_enclave_quote_body', '3': 6, '4': 1, '5': 9, '8': const {}, '10': 'isvEnclaveQuoteBody'},
    const {'1': 'advisory_ids', '3': 7, '4': 3, '5': 9, '8': const {}, '10': 'advisoryIds'},
  ],
};

/// Descriptor for `QuoteReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteReportDescriptor = $convert.base64Decode('CgtRdW90ZVJlcG9ydBIWCgJpZBgBIAEoCUIG4t4fAklEUgJpZBIcCgl0aW1lc3RhbXAYAiABKAlSCXRpbWVzdGFtcBIYCgd2ZXJzaW9uGAMgASgEUgd2ZXJzaW9uElIKGGlzdl9lbmNsYXZlX3F1b3RlX3N0YXR1cxgEIAEoCUIZ6t4fFWlzdkVuY2xhdmVRdW90ZVN0YXR1c1IVaXN2RW5jbGF2ZVF1b3RlU3RhdHVzEkIKEnBsYXRmb3JtX2luZm9fYmxvYhgFIAEoCUIU6t4fEHBsYXRmb3JtSW5mb0Jsb2JSEHBsYXRmb3JtSW5mb0Jsb2ISTAoWaXN2X2VuY2xhdmVfcXVvdGVfYm9keRgGIAEoCUIX6t4fE2lzdkVuY2xhdmVRdW90ZUJvZHlSE2lzdkVuY2xhdmVRdW90ZUJvZHkSQQoMYWR2aXNvcnlfaWRzGAcgAygJQh7i3h8LQWR2aXNvcnlJRHPq3h8LYWR2aXNvcnlJRHNSC2Fkdmlzb3J5SWRz');
@$core.Deprecated('Use quoteReportBodyDescriptor instead')
const QuoteReportBody$json = const {
  '1': 'QuoteReportBody',
  '2': const [
    const {'1': 'mr_enclave', '3': 1, '4': 1, '5': 9, '10': 'mrEnclave'},
    const {'1': 'mr_signer', '3': 2, '4': 1, '5': 9, '10': 'mrSigner'},
    const {'1': 'report_data', '3': 3, '4': 1, '5': 9, '10': 'reportData'},
  ],
};

/// Descriptor for `QuoteReportBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteReportBodyDescriptor = $convert.base64Decode('Cg9RdW90ZVJlcG9ydEJvZHkSHQoKbXJfZW5jbGF2ZRgBIAEoCVIJbXJFbmNsYXZlEhsKCW1yX3NpZ25lchgCIAEoCVIIbXJTaWduZXISHwoLcmVwb3J0X2RhdGEYAyABKAlSCnJlcG9ydERhdGE=');
@$core.Deprecated('Use quoteReportDataDescriptor instead')
const QuoteReportData$json = const {
  '1': 'QuoteReportData',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 4, '10': 'version'},
    const {'1': 'sign_type', '3': 2, '4': 1, '5': 4, '10': 'signType'},
    const {'1': 'report_body', '3': 3, '4': 1, '5': 11, '6': '.secret.registration.v1beta1.remote_attestation.QuoteReportBody', '10': 'reportBody'},
  ],
};

/// Descriptor for `QuoteReportData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteReportDataDescriptor = $convert.base64Decode('Cg9RdW90ZVJlcG9ydERhdGESGAoHdmVyc2lvbhgBIAEoBFIHdmVyc2lvbhIbCglzaWduX3R5cGUYAiABKARSCHNpZ25UeXBlEmAKC3JlcG9ydF9ib2R5GAMgASgLMj8uc2VjcmV0LnJlZ2lzdHJhdGlvbi52MWJldGExLnJlbW90ZV9hdHRlc3RhdGlvbi5RdW90ZVJlcG9ydEJvZHlSCnJlcG9ydEJvZHk=');
@$core.Deprecated('Use endorsedAttestationReportDescriptor instead')
const EndorsedAttestationReport$json = const {
  '1': 'EndorsedAttestationReport',
  '2': const [
    const {'1': 'report', '3': 1, '4': 1, '5': 12, '10': 'report'},
    const {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
    const {'1': 'signing_cert', '3': 3, '4': 1, '5': 12, '10': 'signingCert'},
  ],
};

/// Descriptor for `EndorsedAttestationReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endorsedAttestationReportDescriptor = $convert.base64Decode('ChlFbmRvcnNlZEF0dGVzdGF0aW9uUmVwb3J0EhYKBnJlcG9ydBgBIAEoDFIGcmVwb3J0EhwKCXNpZ25hdHVyZRgCIAEoDFIJc2lnbmF0dXJlEiEKDHNpZ25pbmdfY2VydBgDIAEoDFILc2lnbmluZ0NlcnQ=');
@$core.Deprecated('Use sGXEC256SignatureDescriptor instead')
const SGXEC256Signature$json = const {
  '1': 'SGXEC256Signature',
  '2': const [
    const {'1': 'gx', '3': 1, '4': 1, '5': 9, '10': 'gx'},
    const {'1': 'gy', '3': 2, '4': 1, '5': 9, '10': 'gy'},
  ],
};

/// Descriptor for `SGXEC256Signature`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sGXEC256SignatureDescriptor = $convert.base64Decode('ChFTR1hFQzI1NlNpZ25hdHVyZRIOCgJneBgBIAEoCVICZ3gSDgoCZ3kYAiABKAlSAmd5');
@$core.Deprecated('Use platformInfoBlobDescriptor instead')
const PlatformInfoBlob$json = const {
  '1': 'PlatformInfoBlob',
  '2': const [
    const {'1': 'sgx_epid_group_flags', '3': 1, '4': 1, '5': 13, '10': 'sgxEpidGroupFlags'},
    const {'1': 'sgx_tcb_evaluation_flags', '3': 2, '4': 1, '5': 13, '10': 'sgxTcbEvaluationFlags'},
    const {'1': 'pse_evaluation_flags', '3': 3, '4': 1, '5': 13, '10': 'pseEvaluationFlags'},
    const {'1': 'latest_equivalent_tcb_psvn', '3': 4, '4': 1, '5': 9, '10': 'latestEquivalentTcbPsvn'},
    const {'1': 'latest_pse_isvsvn', '3': 5, '4': 1, '5': 9, '10': 'latestPseIsvsvn'},
    const {'1': 'latest_psda_svn', '3': 6, '4': 1, '5': 9, '10': 'latestPsdaSvn'},
    const {'1': 'xeid', '3': 7, '4': 1, '5': 13, '10': 'xeid'},
    const {'1': 'gid', '3': 8, '4': 1, '5': 13, '10': 'gid'},
    const {'1': 'sgx_ec256_signature_t', '3': 9, '4': 1, '5': 11, '6': '.secret.registration.v1beta1.remote_attestation.SGXEC256Signature', '10': 'sgxEc256SignatureT'},
  ],
};

/// Descriptor for `PlatformInfoBlob`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List platformInfoBlobDescriptor = $convert.base64Decode('ChBQbGF0Zm9ybUluZm9CbG9iEi8KFHNneF9lcGlkX2dyb3VwX2ZsYWdzGAEgASgNUhFzZ3hFcGlkR3JvdXBGbGFncxI3ChhzZ3hfdGNiX2V2YWx1YXRpb25fZmxhZ3MYAiABKA1SFXNneFRjYkV2YWx1YXRpb25GbGFncxIwChRwc2VfZXZhbHVhdGlvbl9mbGFncxgDIAEoDVIScHNlRXZhbHVhdGlvbkZsYWdzEjsKGmxhdGVzdF9lcXVpdmFsZW50X3RjYl9wc3ZuGAQgASgJUhdsYXRlc3RFcXVpdmFsZW50VGNiUHN2bhIqChFsYXRlc3RfcHNlX2lzdnN2bhgFIAEoCVIPbGF0ZXN0UHNlSXN2c3ZuEiYKD2xhdGVzdF9wc2RhX3N2bhgGIAEoCVINbGF0ZXN0UHNkYVN2bhISCgR4ZWlkGAcgASgNUgR4ZWlkEhAKA2dpZBgIIAEoDVIDZ2lkEnQKFXNneF9lYzI1Nl9zaWduYXR1cmVfdBgJIAEoCzJBLnNlY3JldC5yZWdpc3RyYXRpb24udjFiZXRhMS5yZW1vdGVfYXR0ZXN0YXRpb24uU0dYRUMyNTZTaWduYXR1cmVSEnNneEVjMjU2U2lnbmF0dXJlVA==');
