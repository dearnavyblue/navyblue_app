// lib/features/admin/data/providers/admin_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../auth/presentation/providers/auth_presentation_providers.dart';
import '../repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';

final adminHttpClientProvider = Provider<http.Client>((ref) => http.Client());

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final httpClient = ref.watch(adminHttpClientProvider);
  final authState = ref.watch(authControllerProvider);
  return AdminRepositoryImpl(
    httpClient: httpClient,
    accessToken: authState.user?.accessToken,
  );
});