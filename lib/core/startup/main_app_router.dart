// lib/core/startup/main_app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routing/app_router.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';

class MainAppRouter extends ConsumerWidget {
  const MainAppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final goRouter = ref.watch(goRouterProvider);

      return MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        routerConfig: goRouter,
      );
    } catch (e) {
      print('GoRouter error: $e');
      // Fallback if router fails
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Router initialization failed'),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force rebuild by invalidating the router
                    ref.invalidate(goRouterProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
