///
//  Generated code. Do not modify.
//  source: ethermint/feemarket/v1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'query.pb.dart' as $0;
export 'query.pb.dart';

class QueryClient extends $grpc.Client {
  static final _$params =
      $grpc.ClientMethod<$0.QueryParamsRequest, $0.QueryParamsResponse>(
          '/ethermint.feemarket.v1.Query/Params',
          ($0.QueryParamsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.QueryParamsResponse.fromBuffer(value));
  static final _$baseFee =
      $grpc.ClientMethod<$0.QueryBaseFeeRequest, $0.QueryBaseFeeResponse>(
          '/ethermint.feemarket.v1.Query/BaseFee',
          ($0.QueryBaseFeeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.QueryBaseFeeResponse.fromBuffer(value));
  static final _$blockGas =
      $grpc.ClientMethod<$0.QueryBlockGasRequest, $0.QueryBlockGasResponse>(
          '/ethermint.feemarket.v1.Query/BlockGas',
          ($0.QueryBlockGasRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.QueryBlockGasResponse.fromBuffer(value));

  QueryClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.QueryParamsResponse> params(
      $0.QueryParamsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$params, request, options: options);
  }

  $grpc.ResponseFuture<$0.QueryBaseFeeResponse> baseFee(
      $0.QueryBaseFeeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$baseFee, request, options: options);
  }

  $grpc.ResponseFuture<$0.QueryBlockGasResponse> blockGas(
      $0.QueryBlockGasRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$blockGas, request, options: options);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'ethermint.feemarket.v1.Query';

  QueryServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.QueryParamsRequest, $0.QueryParamsResponse>(
            'Params',
            params_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.QueryParamsRequest.fromBuffer(value),
            ($0.QueryParamsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.QueryBaseFeeRequest, $0.QueryBaseFeeResponse>(
            'BaseFee',
            baseFee_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.QueryBaseFeeRequest.fromBuffer(value),
            ($0.QueryBaseFeeResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.QueryBlockGasRequest, $0.QueryBlockGasResponse>(
            'BlockGas',
            blockGas_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.QueryBlockGasRequest.fromBuffer(value),
            ($0.QueryBlockGasResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.QueryParamsResponse> params_Pre($grpc.ServiceCall call,
      $async.Future<$0.QueryParamsRequest> request) async {
    return params(call, await request);
  }

  $async.Future<$0.QueryBaseFeeResponse> baseFee_Pre($grpc.ServiceCall call,
      $async.Future<$0.QueryBaseFeeRequest> request) async {
    return baseFee(call, await request);
  }

  $async.Future<$0.QueryBlockGasResponse> blockGas_Pre($grpc.ServiceCall call,
      $async.Future<$0.QueryBlockGasRequest> request) async {
    return blockGas(call, await request);
  }

  $async.Future<$0.QueryParamsResponse> params(
      $grpc.ServiceCall call, $0.QueryParamsRequest request);
  $async.Future<$0.QueryBaseFeeResponse> baseFee(
      $grpc.ServiceCall call, $0.QueryBaseFeeRequest request);
  $async.Future<$0.QueryBlockGasResponse> blockGas(
      $grpc.ServiceCall call, $0.QueryBlockGasRequest request);
}
