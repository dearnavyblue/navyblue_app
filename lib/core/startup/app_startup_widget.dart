// lib/core/startup/app_startup_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_startup_providers.dart';
import 'main_app_router.dart';
import '../screens/splash/splash_screen.dart';

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    
    return appStartupState.when(
      loading: () => const AppStartupAnimatedSplash(),
      error: (error, stackTrace) => AppStartupErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
      data: (_) => const MainAppRouter(),
    );
  }
}

class AppStartupAnimatedSplash extends StatefulWidget {
  const AppStartupAnimatedSplash({super.key});

  @override
  State<AppStartupAnimatedSplash> createState() => _AppStartupAnimatedSplashState();
}

class _AppStartupAnimatedSplashState extends State<AppStartupAnimatedSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SplashScreen(
          progressText: _controller.value < 0.5
              ? 'Preparing resources...'
              : 'Initializing app...',
          progressValue: _controller.value,
        );
      },
    );
  }
}

class AppStartupErrorWidget extends StatelessWidget {
  const AppStartupErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: scheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Startup Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong during app initialization. Please try again or contact support if the problem persists.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (message.isNotEmpty) ...[
                ExpansionTile(
                  title: Text(
                    'Error Details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.6),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
