// lib/features/papers/data/providers/papers_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/repositories/papers_repository.dart';
import '../repositories/papers_repository_impl.dart';
import '../../../auth/presentation/providers/auth_presentation_providers.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final papersRepositoryProvider = Provider<PapersRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authState = ref.watch(authControllerProvider);

  return PapersRepositoryImpl(
    httpClient: httpClient,
    accessToken: authState.user?.accessToken,
  );
});
