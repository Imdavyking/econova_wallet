import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

abstract class IJsonRpcConnection with IEvents {
  bool get connected;
  bool get connecting;

  Future<void> open({String? url});
  Future<void> close();
  Future<void> send({required JsonRpcPayload payload, dynamic context});
}
