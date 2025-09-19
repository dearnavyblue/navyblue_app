// lib/core/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> get isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();

      return result.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return true; // Default to online if check fails
    }
  }

  static Stream<bool> get onConnectivityChanged async* {
    // Emit initial connectivity state first
    try {
      yield await isOnline;
    } catch (e) {
      yield true;
    }

    // Then listen for changes
    await for (final result in _connectivity.onConnectivityChanged) {
      try {
        yield result.any((r) => r != ConnectivityResult.none);
      } catch (e) {
        yield true;
      }
    }
  }
}
