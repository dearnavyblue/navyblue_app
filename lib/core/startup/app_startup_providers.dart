// lib/core/startup/app_startup_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../brick/repository.dart';
import '../../features/auth/presentation/providers/auth_presentation_providers.dart';

// Repository provider - initializes the repository
final repositoryProvider = FutureProvider<Repository>((ref) async {
  await Repository.configure();
  print('Repository configured successfully');
  return Repository.instance;
});

// App startup provider that coordinates all initialization
final appStartupProvider = FutureProvider<void>((ref) async {
  try {
    // Step 1: Initialize Repository
    await ref.watch(repositoryProvider.future);
    
    // Step 2: Initialize Auth Controller
    await ref.read(authControllerProvider.notifier).initialize();
    print('Auth controller initialized successfully');
    
    // Add any other initialization here in the future
    // await someOtherInitialization();
    
    print('App startup completed successfully');
    
  } catch (e, stackTrace) {
    print('App startup failed: $e');
    print('Stack trace: $stackTrace');
    rethrow; // Re-throw so the UI can handle it
  }
});