import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/core/config/app_config.dart';
import 'package:navyblue_app/features/auth/presentation/providers/auth_presentation_providers.dart';
import 'package:navyblue_app/features/home/presentation/controllers/home_controller.dart';
import 'package:navyblue_app/features/home/presentation/providers/home_presentation_providers.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _hasLoadedOnce = false;
  int _lastAttemptCount = 0;
  DateTime? _lastRefreshTime;
  Timer? _debounceTimer;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasLoadedOnce) {
      // Only refresh if it's been more than 30 seconds
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > const Duration(seconds: 30)) {
        _loadDashboardData();
        _lastRefreshTime = now;
      }
    }
  }

  void _loadDashboardData() {
    ref.read(homeControllerProvider.notifier).loadDashboardData().then((_) {
      if (mounted) {
        setState(() {
          _hasLoadedOnce = true;
          _lastRefreshTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    // Debounced listener for attempt changes
    ref.listen(userAttemptsControllerProvider, (previous, next) {
      if (previous != null &&
          previous.userAttempts.length != next.userAttempts.length &&
          next.userAttempts.length != _lastAttemptCount) {
        _lastAttemptCount = next.userAttempts.length;

        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted && _lastAttemptCount == next.userAttempts.length) {
            ref.read(homeControllerProvider.notifier).loadDashboardData();
          }
        });
      }
    });

    if (_selectedSubject == null && state.progressSummary != null) {
      _selectedSubject = state.progressSummary!.subjects.keys.first;
    }

    final isInitialLoading =
        !_hasLoadedOnce || (state.isLoading && !state.hasData);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          _lastRefreshTime = DateTime.now();
          await ref.read(homeControllerProvider.notifier).refreshData();
        },
        child: CustomScrollView(
          slivers: [
            if (isInitialLoading)
              SliverFillRemaining(
                child: _buildSkeletonLoader(theme),
              )
            else if (state.error != null)
              _buildErrorSliver(theme, state.error!)
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_getGreeting()}, ${authState.user?.firstName ?? 'Student'}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              _lastRefreshTime = DateTime.now();
                              _loadDashboardData();
                            },
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildQuickActions(context, theme, state),
                  const SizedBox(height: 24),
                  if (state.hasData)
                    _buildProgressOverview(theme, state)
                  else
                    _buildGetStartedSection(context, theme),
                  const SizedBox(height: 24),
                  _buildActivitySection(context, theme, state),
                  const SizedBox(height: 100),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // Skeleton loader
  Widget _buildSkeletonLoader(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        _buildSkeletonCard(theme, height: 120),
        const SizedBox(height: 16),
        _buildSkeletonCard(theme, height: 160),
        const SizedBox(height: 16),
        _buildSkeletonCard(theme, height: 120),
      ],
    );
  }

  Widget _buildSkeletonCard(ThemeData theme, {required double height}) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, HomeState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: state.hasActiveAttempts
                    ? _buildActionCard(
                        context,
                        theme,
                        icon: Icons.play_circle_fill_rounded,
                        title: 'Resume Study',
                        subtitle: '${state.activeAttempts.length} active',
                        onTap: () => context.push('/user-attempts'),
                        isPrimary: true,
                      )
                    : _buildActionCard(
                        context,
                        theme,
                        icon: Icons.library_books_rounded,
                        title: 'Browse Papers',
                        subtitle: 'Start practicing',
                        onTap: () => context.go('/papers'),
                        isPrimary: true,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: state.hasActiveAttempts
                    ? _buildActionCard(
                        context,
                        theme,
                        icon: Icons.library_books_rounded,
                        title: 'New Papers',
                        subtitle: 'Discover more',
                        onTap: () => context.go('/papers'),
                      )
                    : _buildActionCard(
                        context,
                        theme,
                        icon: Icons.history_rounded,
                        title: 'Past Attempts',
                        subtitle: 'View history',
                        onTap: () => context.push('/user-attempts'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: isPrimary ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isPrimary
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPrimary
                      ? theme.colorScheme.onPrimary.withOpacity(0.8)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.trending_up,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete an attempt to unlock your progress dashboard',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/papers'),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Start Practicing'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview(ThemeData theme, HomeState state) {
    if (state.progressSummary == null) return const SizedBox.shrink();

    final subjects = state.progressSummary!.subjects;
    final selectedProgress =
        _selectedSubject != null ? subjects[_selectedSubject] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam Readiness',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'See how ready you are for the exams',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Subject Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: subjects.keys.map((subject) {
                final isSelected = subject == _selectedSubject;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSubject = subject;
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[300],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        AppConfig.getSubjectDisplayName(subject),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Selected Subject Details
          if (selectedProgress != null)
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Header
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                AppConfig.getSubjectDisplayName(
                                    _selectedSubject!),
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                '${selectedProgress.overallReadiness}% Ready',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getReadinessColor(
                                theme, selectedProgress.readinessLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedProgress.readinessLevel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: selectedProgress.overallReadiness / 100,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          _getReadinessColor(
                              theme, selectedProgress.readinessLevel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Papers (Paper 1 + 2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaperProgress(
                            theme,
                            'Paper 1',
                            selectedProgress.practicePerformance
                                    .papers['PAPER_1']?.averageScore ??
                                0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPaperProgress(
                            theme,
                            'Paper 2',
                            selectedProgress.practicePerformance
                                    .papers['PAPER_2']?.averageScore ??
                                0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Topics
                    if (selectedProgress
                        .practicePerformance.topicBreakdown.isNotEmpty)
                      ...selectedProgress.practicePerformance.topicBreakdown
                          .map((topic) {
                        final accuracy = topic.overallAccuracy;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    topic.topic,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${accuracy.toInt()}% Ready',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: accuracy / 100,
                                  minHeight: 6,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    _getReadinessColor(theme, topic.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaperProgress(ThemeData theme, String paperName, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              paperName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${score.toInt()}% Ready',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              score > 0
                  ? _getReadinessColor(
                      theme, _getReadinessLevelFromScore(score))
                  : Colors.grey[300]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(
      BuildContext context, ThemeData theme, HomeState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (state.recentAttempts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No activity yet. Start practicing to see your progress here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...state.recentAttempts.map(
              (attempt) => Card(
                child: ListTile(
                  title: Text(
                      AppConfig.getSubjectDisplayName(attempt.paper.subject)),
                  subtitle: Text(
                      '${attempt.paper.name} • ${attempt.score.toStringAsFixed(1)}%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/user-attempts/${attempt.id}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getReadinessColor(ThemeData theme, String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.redAccent;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getReadinessLevelFromScore(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  SliverFillRemaining _buildErrorSliver(ThemeData theme, String error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadDashboardData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
