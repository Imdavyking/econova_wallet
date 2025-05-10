///
//  Generated code. Do not modify.
//  source: agoric/swingset/msgs.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'msgs.pb.dart' as $0;
export 'msgs.pb.dart';

class MsgClient extends $grpc.Client {
  static final _$installBundle =
      $grpc.ClientMethod<$0.MsgInstallBundle, $0.MsgInstallBundleResponse>(
          '/agoric.swingset.Msg/InstallBundle',
          ($0.MsgInstallBundle value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.MsgInstallBundleResponse.fromBuffer(value));
  static final _$deliverInbound =
      $grpc.ClientMethod<$0.MsgDeliverInbound, $0.MsgDeliverInboundResponse>(
          '/agoric.swingset.Msg/DeliverInbound',
          ($0.MsgDeliverInbound value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.MsgDeliverInboundResponse.fromBuffer(value));
  static final _$walletAction =
      $grpc.ClientMethod<$0.MsgWalletAction, $0.MsgWalletActionResponse>(
          '/agoric.swingset.Msg/WalletAction',
          ($0.MsgWalletAction value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.MsgWalletActionResponse.fromBuffer(value));
  static final _$walletSpendAction = $grpc.ClientMethod<$0.MsgWalletSpendAction,
          $0.MsgWalletSpendActionResponse>(
      '/agoric.swingset.Msg/WalletSpendAction',
      ($0.MsgWalletSpendAction value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.MsgWalletSpendActionResponse.fromBuffer(value));
  static final _$provision =
      $grpc.ClientMethod<$0.MsgProvision, $0.MsgProvisionResponse>(
          '/agoric.swingset.Msg/Provision',
          ($0.MsgProvision value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.MsgProvisionResponse.fromBuffer(value));

  MsgClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.MsgInstallBundleResponse> installBundle(
      $0.MsgInstallBundle request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$installBundle, request, options: options);
  }

  $grpc.ResponseFuture<$0.MsgDeliverInboundResponse> deliverInbound(
      $0.MsgDeliverInbound request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deliverInbound, request, options: options);
  }

  $grpc.ResponseFuture<$0.MsgWalletActionResponse> walletAction(
      $0.MsgWalletAction request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$walletAction, request, options: options);
  }

  $grpc.ResponseFuture<$0.MsgWalletSpendActionResponse> walletSpendAction(
      $0.MsgWalletSpendAction request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$walletSpendAction, request, options: options);
  }

  $grpc.ResponseFuture<$0.MsgProvisionResponse> provision(
      $0.MsgProvision request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$provision, request, options: options);
  }
}

abstract class MsgServiceBase extends $grpc.Service {
  $core.String get $name => 'agoric.swingset.Msg';

  MsgServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.MsgInstallBundle, $0.MsgInstallBundleResponse>(
            'InstallBundle',
            installBundle_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.MsgInstallBundle.fromBuffer(value),
            ($0.MsgInstallBundleResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.MsgDeliverInbound, $0.MsgDeliverInboundResponse>(
            'DeliverInbound',
            deliverInbound_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.MsgDeliverInbound.fromBuffer(value),
            ($0.MsgDeliverInboundResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.MsgWalletAction, $0.MsgWalletActionResponse>(
            'WalletAction',
            walletAction_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.MsgWalletAction.fromBuffer(value),
            ($0.MsgWalletActionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MsgWalletSpendAction,
            $0.MsgWalletSpendActionResponse>(
        'WalletSpendAction',
        walletSpendAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MsgWalletSpendAction.fromBuffer(value),
        ($0.MsgWalletSpendActionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MsgProvision, $0.MsgProvisionResponse>(
        'Provision',
        provision_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MsgProvision.fromBuffer(value),
        ($0.MsgProvisionResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.MsgInstallBundleResponse> installBundle_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.MsgInstallBundle> request) async {
    return installBundle(call, await request);
  }

  $async.Future<$0.MsgDeliverInboundResponse> deliverInbound_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.MsgDeliverInbound> request) async {
    return deliverInbound(call, await request);
  }

  $async.Future<$0.MsgWalletActionResponse> walletAction_Pre(
      $grpc.ServiceCall call, $async.Future<$0.MsgWalletAction> request) async {
    return walletAction(call, await request);
  }

  $async.Future<$0.MsgWalletSpendActionResponse> walletSpendAction_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.MsgWalletSpendAction> request) async {
    return walletSpendAction(call, await request);
  }

  $async.Future<$0.MsgProvisionResponse> provision_Pre(
      $grpc.ServiceCall call, $async.Future<$0.MsgProvision> request) async {
    return provision(call, await request);
  }

  $async.Future<$0.MsgInstallBundleResponse> installBundle(
      $grpc.ServiceCall call, $0.MsgInstallBundle request);
  $async.Future<$0.MsgDeliverInboundResponse> deliverInbound(
      $grpc.ServiceCall call, $0.MsgDeliverInbound request);
  $async.Future<$0.MsgWalletActionResponse> walletAction(
      $grpc.ServiceCall call, $0.MsgWalletAction request);
  $async.Future<$0.MsgWalletSpendActionResponse> walletSpendAction(
      $grpc.ServiceCall call, $0.MsgWalletSpendAction request);
  $async.Future<$0.MsgProvisionResponse> provision(
      $grpc.ServiceCall call, $0.MsgProvision request);
}
