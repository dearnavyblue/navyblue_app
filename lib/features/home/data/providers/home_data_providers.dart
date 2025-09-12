// lib/features/home/data/providers/home_data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/auth/data/providers/auth_data_providers.dart';
import '../../domain/repositories/home_repository.dart';
import '../repositories/home_repository_impl.dart';
import '../../../auth/presentation/providers/auth_presentation_providers.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authState = ref.watch(authControllerProvider);

  return HomeRepositoryImpl(
    httpClient: httpClient,
    accessToken: authState.user?.accessToken,
  );
});