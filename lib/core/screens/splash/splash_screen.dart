// lib/core/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../../features/auth/presentation/providers/auth_presentation_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.progressValue, this.progressText});

  final double? progressValue;
  final String? progressText;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _brandBlue = Color(0xFF1C34C5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    if (widget.progressValue != null) return;

    try {
      await ref.read(authControllerProvider.notifier).initialize();
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize app: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _brandBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/whole_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Navy Blue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/dancing.webp',
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: LinearProgressIndicator(
                  value: widget.progressValue,
                  minHeight: 6,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.progressText ?? _buildStatusText(context),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Version ${AppConfig.appVersion}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildStatusText(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return authState.isInitialized
        ? 'Initialization complete'
        : 'Getting things ready...';
  }
}
