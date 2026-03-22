import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkGuard {
  static final NetworkGuard _instance = NetworkGuard._internal();
  factory NetworkGuard() => _instance;

  bool _isConnected = true;

  NetworkGuard._internal() {
    if (!Platform.isMacOS && !Platform.isLinux && !Platform.isWindows) {
      Connectivity().onConnectivityChanged.listen((result) {
        _isConnected = !result.contains(ConnectivityResult.none);
      });
    }
  }

  Future<void> init() async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      _isConnected = await _socketCheck();
    } else {
      try {
        final result = await Connectivity().checkConnectivity();
        _isConnected = !result.contains(ConnectivityResult.none);
      } catch (_) {
        // Fallback to socket check if connectivity_plus fails
        _isConnected = await _socketCheck();
      }
    }
  }

  Future<bool> _socketCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get isConnected => _isConnected;

  void throwIfOffline() {
    if (!_isConnected) throw Exception('No internet connection');
  }

  /// Use in tests or anywhere you need a fresh real-time check
  Future<bool> checkNow() async {
    await init();
    return _isConnected;
  }
}
