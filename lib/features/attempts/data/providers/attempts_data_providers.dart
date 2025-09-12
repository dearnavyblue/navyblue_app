// lib/features/attempts/data/providers/attempts_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/repositories/attempts_repository.dart';
import '../repositories/attempts_repository_impl.dart';
import '../../../auth/presentation/providers/auth_presentation_providers.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final attemptsRepositoryProvider = Provider<AttemptsRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authState = ref.watch(authControllerProvider);

  return AttemptsRepositoryImpl(
    httpClient: httpClient,
    accessToken: authState.user?.accessToken,
  );
});