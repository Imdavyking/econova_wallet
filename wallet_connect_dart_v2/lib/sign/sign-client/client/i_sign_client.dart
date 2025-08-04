import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/core/pairing/models.dart';
import 'package:wallet_connect_dart_v2/sign/engine/i_engine.dart';
import 'package:wallet_connect_dart_v2/sign/engine/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/i_pending_request.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/i_proposal.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/i_session.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

abstract class ISignClient with IEvents {
  String get name;

  AppMetadata get metadata;

  ICore get core;

  Logger get logger;

  IEngine get engine;

  ISession get session;

  IProposal get proposal;

  IPendingRequest get pendingRequest;

  Future<EngineConnection> connect(SessionConnectParams params);

  Future<PairingStruct> pair(String uri);

  Future<EngineApproved> approve(SessionApproveParams params);

  Future<void> reject(SessionRejectParams params);

  Future<EngineAcknowledged> update(SessionUpdateParams params);

  Future<EngineAcknowledged> extend(String topic);

  Future<T> request<T>(SessionRequestParams params);

  Future<void> respond(SessionRespondParams params);

  Future<void> ping(String topic);

  Future<void> emit(SessionEmitParams params);

  Future<void> disconnect({
    required String topic,
    ErrorResponse? reason,
  });

  List<SessionStruct> find(params);

  List<PendingRequestStruct> getPendingSessionRequests();
}
