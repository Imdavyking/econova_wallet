import 'package:event_bus/event_bus.dart';

abstract class EventBusService {
  static final instance = EventBus();
}

class CryptoNotificationEvent {
  final String title;
  final String body;

  CryptoNotificationEvent({
    required this.title,
    required this.body,
  });
}
