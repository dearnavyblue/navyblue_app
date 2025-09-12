// lib/core/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../../features/auth/presentation/providers/auth_presentation_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the app after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      print('Splash: Starting app initialization...');

      // Initialize auth controller - this will trigger router redirects automatically
      await ref.read(authControllerProvider.notifier).initialize();

      print('Splash: Auth initialization completed');

      // Keep splash visible for minimum duration for UX
      await Future.delayed(const Duration(seconds: 2));

      print('Splash: Minimum display time completed');

      // Don't manually navigate - let the router handle it automatically
      // The router's redirect function will handle navigation based on auth state
    } catch (e) {
      print('Splash initialization error: $e');
      if (mounted) {
        // Show error but don't navigate manually
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App name
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppConfig.appDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 64),

            // Loading indicator
            CircularProgressIndicator(
              color: scheme.primary,
              strokeWidth: 3,
            ),

            const SizedBox(height: 24),

            // Version
            Text(
              'Version ${AppConfig.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
            ),

            const SizedBox(height: 16),

            // Status indicator (optional - helps with debugging)
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authControllerProvider);
                return Text(
                  authState.isInitialized
                      ? 'Initialization complete...'
                      : 'Initializing...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
