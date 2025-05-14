import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkGuard {
  static final NetworkGuard _instance = NetworkGuard._internal();
  factory NetworkGuard() => _instance;

  bool _isConnected = true;

  NetworkGuard._internal() {
    Connectivity().onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  bool get isConnected => _isConnected;

  void throwIfOffline() {
    if (!_isConnected) {
      throw Exception('No internet connection');
    }
  }
}
