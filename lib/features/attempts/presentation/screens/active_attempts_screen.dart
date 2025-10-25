import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:navyblue_app/features/attempts/presentation/widgets/user_attempt_card.dart';
import 'package:navyblue_app/features/home/presentation/controllers/home_controller.dart';
import 'package:navyblue_app/features/home/presentation/providers/home_presentation_providers.dart';

class ActiveAttemptsScreen extends ConsumerStatefulWidget {
  const ActiveAttemptsScreen({super.key});

  @override
  ConsumerState<ActiveAttemptsScreen> createState() =>
      _ActiveAttemptsScreenState();
}

class _ActiveAttemptsScreenState extends ConsumerState<ActiveAttemptsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).loadDashboardData();
    });
  }

  Future<void> _refresh() async {
    await ref.read(homeControllerProvider.notifier).loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(homeControllerProvider);
    final attempts = state.activeAttempts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('In Progress'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: state.isLoadingAttempts && attempts.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 200),
                ],
              )
            : attempts.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        Icons.psychology_alt_outlined,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nothing in progress',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a paper to see it appear here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/papers'),
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Browse Papers'),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: attempts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final attempt = attempts[index];
                      return UserAttemptCard(
                        attempt: attempt,
                        paper: null,
                        showModeBadge: true,
                        onTap: () async {
                          await context.push(
                            '/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}&resume=${attempt.id}',
                          );
                          if (mounted) {
                            await _refresh();
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
