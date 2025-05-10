///
//  Generated code. Do not modify.
//  source: ethermint/evm/v1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'query.pb.dart' as $1;
import 'tx.pb.dart' as $0;
export 'query.pb.dart';

class QueryClient extends $grpc.Client {
  static final _$account =
      $grpc.ClientMethod<$1.QueryAccountRequest, $1.QueryAccountResponse>(
          '/ethermint.evm.v1.Query/Account',
          ($1.QueryAccountRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryAccountResponse.fromBuffer(value));
  static final _$cosmosAccount = $grpc.ClientMethod<
          $1.QueryCosmosAccountRequest, $1.QueryCosmosAccountResponse>(
      '/ethermint.evm.v1.Query/CosmosAccount',
      ($1.QueryCosmosAccountRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $1.QueryCosmosAccountResponse.fromBuffer(value));
  static final _$validatorAccount = $grpc.ClientMethod<
          $1.QueryValidatorAccountRequest, $1.QueryValidatorAccountResponse>(
      '/ethermint.evm.v1.Query/ValidatorAccount',
      ($1.QueryValidatorAccountRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $1.QueryValidatorAccountResponse.fromBuffer(value));
  static final _$balance =
      $grpc.ClientMethod<$1.QueryBalanceRequest, $1.QueryBalanceResponse>(
          '/ethermint.evm.v1.Query/Balance',
          ($1.QueryBalanceRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryBalanceResponse.fromBuffer(value));
  static final _$storage =
      $grpc.ClientMethod<$1.QueryStorageRequest, $1.QueryStorageResponse>(
          '/ethermint.evm.v1.Query/Storage',
          ($1.QueryStorageRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryStorageResponse.fromBuffer(value));
  static final _$code =
      $grpc.ClientMethod<$1.QueryCodeRequest, $1.QueryCodeResponse>(
          '/ethermint.evm.v1.Query/Code',
          ($1.QueryCodeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryCodeResponse.fromBuffer(value));
  static final _$params =
      $grpc.ClientMethod<$1.QueryParamsRequest, $1.QueryParamsResponse>(
          '/ethermint.evm.v1.Query/Params',
          ($1.QueryParamsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryParamsResponse.fromBuffer(value));
  static final _$ethCall =
      $grpc.ClientMethod<$1.EthCallRequest, $0.MsgEthereumTxResponse>(
          '/ethermint.evm.v1.Query/EthCall',
          ($1.EthCallRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.MsgEthereumTxResponse.fromBuffer(value));
  static final _$estimateGas =
      $grpc.ClientMethod<$1.EthCallRequest, $1.EstimateGasResponse>(
          '/ethermint.evm.v1.Query/EstimateGas',
          ($1.EthCallRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.EstimateGasResponse.fromBuffer(value));
  static final _$traceTx =
      $grpc.ClientMethod<$1.QueryTraceTxRequest, $1.QueryTraceTxResponse>(
          '/ethermint.evm.v1.Query/TraceTx',
          ($1.QueryTraceTxRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryTraceTxResponse.fromBuffer(value));
  static final _$traceBlock =
      $grpc.ClientMethod<$1.QueryTraceBlockRequest, $1.QueryTraceBlockResponse>(
          '/ethermint.evm.v1.Query/TraceBlock',
          ($1.QueryTraceBlockRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryTraceBlockResponse.fromBuffer(value));
  static final _$baseFee =
      $grpc.ClientMethod<$1.QueryBaseFeeRequest, $1.QueryBaseFeeResponse>(
          '/ethermint.evm.v1.Query/BaseFee',
          ($1.QueryBaseFeeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $1.QueryBaseFeeResponse.fromBuffer(value));

  QueryClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$1.QueryAccountResponse> account(
      $1.QueryAccountRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$account, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryCosmosAccountResponse> cosmosAccount(
      $1.QueryCosmosAccountRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$cosmosAccount, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryValidatorAccountResponse> validatorAccount(
      $1.QueryValidatorAccountRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$validatorAccount, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryBalanceResponse> balance(
      $1.QueryBalanceRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$balance, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryStorageResponse> storage(
      $1.QueryStorageRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$storage, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryCodeResponse> code($1.QueryCodeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$code, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryParamsResponse> params(
      $1.QueryParamsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$params, request, options: options);
  }

  $grpc.ResponseFuture<$0.MsgEthereumTxResponse> ethCall(
      $1.EthCallRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ethCall, request, options: options);
  }

  $grpc.ResponseFuture<$1.EstimateGasResponse> estimateGas(
      $1.EthCallRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$estimateGas, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryTraceTxResponse> traceTx(
      $1.QueryTraceTxRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$traceTx, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryTraceBlockResponse> traceBlock(
      $1.QueryTraceBlockRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$traceBlock, request, options: options);
  }

  $grpc.ResponseFuture<$1.QueryBaseFeeResponse> baseFee(
      $1.QueryBaseFeeRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$baseFee, request, options: options);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'ethermint.evm.v1.Query';

  QueryServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$1.QueryAccountRequest, $1.QueryAccountResponse>(
            'Account',
            account_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryAccountRequest.fromBuffer(value),
            ($1.QueryAccountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryCosmosAccountRequest,
            $1.QueryCosmosAccountResponse>(
        'CosmosAccount',
        cosmosAccount_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QueryCosmosAccountRequest.fromBuffer(value),
        ($1.QueryCosmosAccountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryValidatorAccountRequest,
            $1.QueryValidatorAccountResponse>(
        'ValidatorAccount',
        validatorAccount_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QueryValidatorAccountRequest.fromBuffer(value),
        ($1.QueryValidatorAccountResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.QueryBalanceRequest, $1.QueryBalanceResponse>(
            'Balance',
            balance_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryBalanceRequest.fromBuffer(value),
            ($1.QueryBalanceResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.QueryStorageRequest, $1.QueryStorageResponse>(
            'Storage',
            storage_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryStorageRequest.fromBuffer(value),
            ($1.QueryStorageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryCodeRequest, $1.QueryCodeResponse>(
        'Code',
        code_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.QueryCodeRequest.fromBuffer(value),
        ($1.QueryCodeResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.QueryParamsRequest, $1.QueryParamsResponse>(
            'Params',
            params_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryParamsRequest.fromBuffer(value),
            ($1.QueryParamsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.EthCallRequest, $0.MsgEthereumTxResponse>(
        'EthCall',
        ethCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.EthCallRequest.fromBuffer(value),
        ($0.MsgEthereumTxResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.EthCallRequest, $1.EstimateGasResponse>(
        'EstimateGas',
        estimateGas_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.EthCallRequest.fromBuffer(value),
        ($1.EstimateGasResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.QueryTraceTxRequest, $1.QueryTraceTxResponse>(
            'TraceTx',
            traceTx_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryTraceTxRequest.fromBuffer(value),
            ($1.QueryTraceTxResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.QueryTraceBlockRequest,
            $1.QueryTraceBlockResponse>(
        'TraceBlock',
        traceBlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.QueryTraceBlockRequest.fromBuffer(value),
        ($1.QueryTraceBlockResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.QueryBaseFeeRequest, $1.QueryBaseFeeResponse>(
            'BaseFee',
            baseFee_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $1.QueryBaseFeeRequest.fromBuffer(value),
            ($1.QueryBaseFeeResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.QueryAccountResponse> account_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryAccountRequest> request) async {
    return account(call, await request);
  }

  $async.Future<$1.QueryCosmosAccountResponse> cosmosAccount_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QueryCosmosAccountRequest> request) async {
    return cosmosAccount(call, await request);
  }

  $async.Future<$1.QueryValidatorAccountResponse> validatorAccount_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QueryValidatorAccountRequest> request) async {
    return validatorAccount(call, await request);
  }

  $async.Future<$1.QueryBalanceResponse> balance_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryBalanceRequest> request) async {
    return balance(call, await request);
  }

  $async.Future<$1.QueryStorageResponse> storage_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryStorageRequest> request) async {
    return storage(call, await request);
  }

  $async.Future<$1.QueryCodeResponse> code_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryCodeRequest> request) async {
    return code(call, await request);
  }

  $async.Future<$1.QueryParamsResponse> params_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryParamsRequest> request) async {
    return params(call, await request);
  }

  $async.Future<$0.MsgEthereumTxResponse> ethCall_Pre(
      $grpc.ServiceCall call, $async.Future<$1.EthCallRequest> request) async {
    return ethCall(call, await request);
  }

  $async.Future<$1.EstimateGasResponse> estimateGas_Pre(
      $grpc.ServiceCall call, $async.Future<$1.EthCallRequest> request) async {
    return estimateGas(call, await request);
  }

  $async.Future<$1.QueryTraceTxResponse> traceTx_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryTraceTxRequest> request) async {
    return traceTx(call, await request);
  }

  $async.Future<$1.QueryTraceBlockResponse> traceBlock_Pre(
      $grpc.ServiceCall call,
      $async.Future<$1.QueryTraceBlockRequest> request) async {
    return traceBlock(call, await request);
  }

  $async.Future<$1.QueryBaseFeeResponse> baseFee_Pre($grpc.ServiceCall call,
      $async.Future<$1.QueryBaseFeeRequest> request) async {
    return baseFee(call, await request);
  }

  $async.Future<$1.QueryAccountResponse> account(
      $grpc.ServiceCall call, $1.QueryAccountRequest request);
  $async.Future<$1.QueryCosmosAccountResponse> cosmosAccount(
      $grpc.ServiceCall call, $1.QueryCosmosAccountRequest request);
  $async.Future<$1.QueryValidatorAccountResponse> validatorAccount(
      $grpc.ServiceCall call, $1.QueryValidatorAccountRequest request);
  $async.Future<$1.QueryBalanceResponse> balance(
      $grpc.ServiceCall call, $1.QueryBalanceRequest request);
  $async.Future<$1.QueryStorageResponse> storage(
      $grpc.ServiceCall call, $1.QueryStorageRequest request);
  $async.Future<$1.QueryCodeResponse> code(
      $grpc.ServiceCall call, $1.QueryCodeRequest request);
  $async.Future<$1.QueryParamsResponse> params(
      $grpc.ServiceCall call, $1.QueryParamsRequest request);
  $async.Future<$0.MsgEthereumTxResponse> ethCall(
      $grpc.ServiceCall call, $1.EthCallRequest request);
  $async.Future<$1.EstimateGasResponse> estimateGas(
      $grpc.ServiceCall call, $1.EthCallRequest request);
  $async.Future<$1.QueryTraceTxResponse> traceTx(
      $grpc.ServiceCall call, $1.QueryTraceTxRequest request);
  $async.Future<$1.QueryTraceBlockResponse> traceBlock(
      $grpc.ServiceCall call, $1.QueryTraceBlockRequest request);
  $async.Future<$1.QueryBaseFeeResponse> baseFee(
      $grpc.ServiceCall call, $1.QueryBaseFeeRequest request);
}
