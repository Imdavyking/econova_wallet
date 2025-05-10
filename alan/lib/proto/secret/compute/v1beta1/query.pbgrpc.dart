///
//  Generated code. Do not modify.
//  source: secret/compute/v1beta1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'query.pb.dart' as $1;
import '../../../google/protobuf/empty.pb.dart' as $2;
export 'query.pb.dart';

class QueryClient extends $grpc.Client {
  static final _$contractInfo = $grpc.ClientMethod<$1.QueryContractInfoRequest,
          $1.QueryContractInfoResponse>(
      '/secret.compute.v1beta1.Query/ContractInfo',
      ($1.QueryContractInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $1.QueryContractInfoResponse.fromBuffer(value));
  static final _$contractsByCode = $grpc.ClientMethod<
          $1.QueryContractsByCodeRequest, $1.QueryContractsByCodeResponse>(
      '/secret.compute.v1beta1.Query/ContractsByCode',
      ($1.QueryContractsByCodeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $1.QueryContractsByCodeResponse.fromBuffer(value));
  static final _$smartContractState = $grpc.ClientMethod<
          $1.QuerySmartContractStateRequest,
          $1.QuerySmartContractStateResponse>(
      '/secret.compute.v1beta1.Query/SmartContractState',
      ($1.QuerySmartContractStateRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $1.QuerySmartContractStateResponse.fromBuffer(value));
  static final _$code =
      $grpc.ClientMethod<$1.QueryCodeRequest, $1.QueryCodeResponse>(
          '/secret.compute.v1beta1.Query/Code',
          ($1.QueryCodeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryCodeResponse.fromBuffer(value));
  static final _$codes = $grpc.ClientMethod<$2.Empty, $1.QueryCodesResponse>(
      '/secret.compute.v1beta1.Query/Codes',
      ($2.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.QueryCodesResponse.fromBuffer(value));

  QueryClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$1.QueryContractInfoResponse> contractInfo(
      $1.QueryContractInfoRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$contractInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryContractsByCodeResponse> contractsByCode(
      $1.QueryContractsByCodeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$contractsByCode, request, options: options);
  }

  $grpc.ResponseFuture<$1.QuerySmartContractStateResponse> smartContractState(
      $1.QuerySmartContractStateRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$smartContractState, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryCodeResponse> code($1.QueryCodeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$code, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryCodesResponse> codes($2.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$codes, request, options: options);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'secret.compute.v1beta1.Query';

  QueryServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.QueryContractInfoRequest,
            $1.QueryContractInfoResponse>(
        'ContractInfo',
        contractInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QueryContractInfoRequest.fromBuffer(value),
        ($1.QueryContractInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryContractsByCodeRequest,
            $1.QueryContractsByCodeResponse>(
        'ContractsByCode',
        contractsByCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QueryContractsByCodeRequest.fromBuffer(value),
        ($1.QueryContractsByCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QuerySmartContractStateRequest,
            $1.QuerySmartContractStateResponse>(
        'SmartContractState',
        smartContractState_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QuerySmartContractStateRequest.fromBuffer(value),
        ($1.QuerySmartContractStateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryCodeRequest, $1.QueryCodeResponse>(
        'Code',
        code_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.QueryCodeRequest.fromBuffer(value),
        ($1.QueryCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $1.QueryCodesResponse>(
        'Codes',
        codes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($1.QueryCodesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.QueryContractInfoResponse> contractInfo_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QueryContractInfoRequest> request) async {
    return contractInfo(call, await request);
  }

  $async.Future<$1.QueryContractsByCodeResponse> contractsByCode_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QueryContractsByCodeRequest> request) async {
    return contractsByCode(call, await request);
  }

  $async.Future<$1.QuerySmartContractStateResponse> smartContractState_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QuerySmartContractStateRequest> request) async {
    return smartContractState(call, await request);
  }

  $async.Future<$1.QueryCodeResponse> code_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryCodeRequest> request) async {
    return code(call, await request);
  }

  $async.Future<$1.QueryCodesResponse> codes_Pre(
      $grpc.ServiceCall call, $async.Future<$2.Empty> request) async {
    return codes(call, await request);
  }

  $async.Future<$1.QueryContractInfoResponse> contractInfo(
      $grpc.ServiceCall call, $1.QueryContractInfoRequest request);
  $async.Future<$1.QueryContractsByCodeResponse> contractsByCode(
      $grpc.ServiceCall call, $1.QueryContractsByCodeRequest request);
  $async.Future<$1.QuerySmartContractStateResponse> smartContractState(
      $grpc.ServiceCall call, $1.QuerySmartContractStateRequest request);
  $async.Future<$1.QueryCodeResponse> code(
      $grpc.ServiceCall call, $1.QueryCodeRequest request);
  $async.Future<$1.QueryCodesResponse> codes(
      $grpc.ServiceCall call, $2.Empty request);
}
