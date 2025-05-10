///
//  Generated code. Do not modify.
//  source: secret/registration/v1beta1/query.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import '../../../google/protobuf/empty.pb.dart' as $0;
import 'msg.pb.dart' as $1;
import 'query.pb.dart' as $2;
export 'query.pb.dart';

class QueryClient extends $grpc.Client {
  static final _$txKey = $grpc.ClientMethod<$0.Empty, $1.Key>(
      '/secret.registration.v1beta1.Query/TxKey',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Key.fromBuffer(value));
  static final _$registrationKey = $grpc.ClientMethod<$0.Empty, $1.Key>(
      '/secret.registration.v1beta1.Query/RegistrationKey',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.Key.fromBuffer(value));
  static final _$encryptedSeed = $grpc.ClientMethod<
          $2.QueryEncryptedSeedRequest, $2.QueryEncryptedSeedResponse>(
      '/secret.registration.v1beta1.Query/EncryptedSeed',
      ($2.QueryEncryptedSeedRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $2.QueryEncryptedSeedResponse.fromBuffer(value));

  QueryClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$1.Key> txKey($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$txKey, request, options: options);
  }

  $grpc.ResponseFuture<$1.Key> registrationKey($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$registrationKey, request, options: options);
  }

  $grpc.ResponseFuture<$2.QueryEncryptedSeedResponse> encryptedSeed(
      $2.QueryEncryptedSeedRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$encryptedSeed, request, options: options);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'secret.registration.v1beta1.Query';

  QueryServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Key>(
        'TxKey',
        txKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Key value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.Key>(
        'RegistrationKey',
        registrationKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.Key value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.QueryEncryptedSeedRequest,
            $2.QueryEncryptedSeedResponse>(
        'EncryptedSeed',
        encryptedSeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.QueryEncryptedSeedRequest.fromBuffer(value),
        ($2.QueryEncryptedSeedResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.Key> txKey_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return txKey(call, await request);
  }

  $async.Future<$1.Key> registrationKey_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return registrationKey(call, await request);
  }

  $async.Future<$2.QueryEncryptedSeedResponse> encryptedSeed_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.QueryEncryptedSeedRequest> request) async {
    return encryptedSeed(call, await request);
  }

  $async.Future<$1.Key> txKey($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$1.Key> registrationKey(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$2.QueryEncryptedSeedResponse> encryptedSeed(
      $grpc.ServiceCall call, $2.QueryEncryptedSeedRequest request);
}
