// lib/presentation/screens/more/more_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../features/auth/presentation/providers/auth_presentation_providers.dart';
import '../../constants/app_constants.dart';
import '../../config/app_config.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const _brandBlue = Color(0xFF2D6EFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'More',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      // Only edges get 16 padding. Children use padding, not margins.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Learner info (radial gradient banner)
            _LearnerInfoBanner(
              name: user?.fullName ?? 'Guest User',
              email: user?.email ?? 'No email',
              gradeShort: _gradeToShort(user?.gradeDisplayName),
              subject: user?.subjectDisplayName ?? 'CAPS',
            ),

            const SizedBox(height: 24),

            // 2) How to (header + link + horizontal tiles)
            _HowToSection(
              onLearnMore: () {
                // TODO: route to your help/guide screen
                // context.go('/help');
              },
            ),

            const SizedBox(height: 24),

            // 3) Story + Share + Logout (no card)
            _JourneySection(
              onShare: () {
                final appName = AppConfig.appName;
                Share.share(
                  'I’m practising smarter with $appName. Join me! 📚',
                  subject: appName,
                );
              },
              onLogout: () => _showLogoutDialog(context, theme, ref),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---------------------------------------------------------------

  static String _gradeToShort(String? src) {
    if (src == null || src.trim().isEmpty) return 'Gr 12';
    final m = RegExp(r'(\d{1,2})').firstMatch(src);
    final n = m != null ? m.group(1) : null;
    return n != null ? 'Gr $n' : 'Gr 12';
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text('Are you sure you want to logout?',
            style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go(AppConstants.loginRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logged out successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// === 1) Learner info banner (no Card) ========================================
class _LearnerInfoBanner extends StatelessWidget {
  const _LearnerInfoBanner({
    required this.name,
    required this.email,
    required this.gradeShort,
    required this.subject,
  });

  final String name;
  final String email;
  final String gradeShort; // e.g. "Gr 10"
  final String subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 213,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        gradient: RadialGradient(
          // radial-gradient(76.29% 90.94% at 40.53% 50.47%, #374CFF 0%, #1849B7 53.37%, #2D6EFF 100%)
          center: Alignment(-0.189, 0.009),
          radius: 0.9094,
          colors: [Color(0xFF374CFF), Color(0xFF1849B7), Color(0xFF2D6EFF)],
          stops: [0.0, 0.5337, 1.0],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-left tag only (student number removed)
              Row(
                children: [
                  const Icon(Icons.flag_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Navy Blue',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  _pill(theme, gradeShort),
                  const SizedBox(width: 8),
                  _pill(theme, subject),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// === 2) How to ===============================================================
// === 2) How to (Figma-accurate) =============================================
class _HowToSection extends StatelessWidget {
  const _HowToSection({this.onLearnMore});
  final VoidCallback? onLearnMore;

  static const _black = Color(0xFF000000);
  static const _grey = Color(0xFF9E9E9E);
  static const _tileGrey = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    // Inter per spec
    const howToStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.40,
      letterSpacing: -0.02,
      color: _black,
    );

    const subtitleStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w300,
      fontSize: 12,
      height: 1.40,
      letterSpacing: -0.02,
      color: _grey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header (padding: 8px 16px, gap: 4px) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How to', style: howToStyle),
              const SizedBox(height: 4),
              // Tap to navigate if a handler is provided; otherwise just text
              GestureDetector(
                onTap: onLearnMore,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Learn how to get your way around the app',
                  style: subtitleStyle,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5), // gap between header and tiles

        // --- Tiles row (padding: 0px 19px, gap: 15px, h: 173) ---
        // --- Tiles row (padding: 0px 19px, gap: 15px, h: 173) ---
        SizedBox(
          height: 173,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Row(
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 15),
                  child: Container(
                    width: 115,
                    height: 173,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// === 3) Story + Share + Logout ==============================================
class _JourneySection extends ConsumerWidget {
  const _JourneySection({required this.onShare, required this.onLogout});
  final VoidCallback onShare;
  final VoidCallback onLogout;

  static const _brandBlue = Color(0xFF2D6EFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurface,
    );

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Making our journey great together', style: titleStyle),
        const SizedBox(height: 8),
        Text(
          'Every South African learner deserves a fair shot. '
          'We built ${AppConfig.appName} to help you practise smarter for Maths and Physical Sciences — '
          'clear steps, solid working, and a little less stress before exams. '
          'Keep going — your future self will thank you.',
          style: bodyStyle,
        ),
        const SizedBox(height: 16),

        // Share button — matches your styling exactly
        SizedBox(
          height: 40,
          width: double.infinity,
          child: FilledButton(
            onPressed: authState.isLoading ? null : onShare,
            style: FilledButton.styleFrom(
              backgroundColor: _brandBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Share App'),
          ),
        ),
        const SizedBox(height: 12),

        // Logout button (same height + radius; outlined look)
        SizedBox(
          height: 40,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: authState.isLoading ? null : onLogout,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}
