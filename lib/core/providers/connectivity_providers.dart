// lib/core/providers/connectivity_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.onConnectivityChanged;
});

final isOnlineProvider = FutureProvider<bool>((ref) {
  return ConnectivityService.isOnline;
});
