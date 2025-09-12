// lib/features/auth/data/providers/auth_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../brick/repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final repositoryProvider = Provider<Repository>((ref) => Repository.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final repository = ref.watch(repositoryProvider);
  return AuthRepositoryImpl(
    httpClient: httpClient,
    repository: repository,
  );
});