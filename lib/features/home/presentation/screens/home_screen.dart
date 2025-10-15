// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/core/config/app_config.dart';
import 'package:navyblue_app/features/auth/presentation/providers/auth_presentation_providers.dart';
import 'package:navyblue_app/features/home/presentation/controllers/home_controller.dart';
import 'package:navyblue_app/features/home/presentation/providers/home_presentation_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _hasLoadedOnce = false;
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detect when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasLoadedOnce) {
      // Refresh data when user returns to app
      _loadDashboardData();
    }
  }

  // Load dashboard data and track that we've loaded once
  void _loadDashboardData() {
    ref.read(homeControllerProvider.notifier).loadDashboardData();
    _hasLoadedOnce = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

if (_selectedSubject == null && state.progressSummary != null) {
      _selectedSubject = state.progressSummary!.subjects.keys.first;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeControllerProvider.notifier).refreshData(),
        child: CustomScrollView(
          slivers: [
            if ((state.isLoading && !state.hasData) ||
                state.activeAttempts.isEmpty && !_hasLoadedOnce)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              _buildErrorSliver(theme, state.error!)
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  // Simple greeting header with refresh button
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
                            onPressed: _loadDashboardData,
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Actions
                  _buildQuickActions(context, theme, state),

                  const SizedBox(height: 24),

                  // Main content based on hasData
                  if (state.hasData)
                    _buildProgressOverview(theme, state)
                  else
                    _buildGetStartedSection(context, theme),

                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildActivitySection(context, theme, state),

                  const SizedBox(height: 100),
                ]),
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
                        onTap: () async {
                          await context.push('/user-attempts');
                          // Refresh when returning from user attempts
                          if (mounted) {
                            _loadDashboardData();
                          }
                        },
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
                        onTap: () async {
                          await context.push('/user-attempts');
                          // Refresh when returning from user attempts
                          if (mounted) {
                            _loadDashboardData();
                          }
                        },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
          // Title
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

          // Selected Subject Content
          if (selectedProgress != null)
            Card(
              color: Colors.grey[100], // Gray background
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Header with Status Badge and % Ready
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                AppConfig.getSubjectDisplayName(
                                    _selectedSubject!),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
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

                    // Overall Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: selectedProgress.overallReadiness / 100,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          selectedProgress.overallReadiness > 0
                              ? _getReadinessColor(
                                  theme, selectedProgress.readinessLevel)
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Papers Section - Always show Paper 1 and Paper 2
                    Row(
                      children: [
                        // Paper 1
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
                        // Paper 2
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

                    // Topics Breakdown
                    if (selectedProgress
                        .practicePerformance.topicBreakdown.isNotEmpty) ...[
                      ...selectedProgress.practicePerformance.topicBreakdown
                          .map((topic) {
                        final topicAccuracy = topic.overallAccuracy;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Topic name with % Ready
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
                                    '${topicAccuracy.toInt()}% Ready',
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
                                  value: topicAccuracy / 100,
                                  minHeight: 6,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    topicAccuracy > 0
                                        ? _getReadinessColor(
                                            theme, topic.status)
                                        : Colors.grey[300]!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
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
  Widget _buildSubjectProgressCard(ThemeData theme, String subject, progress) {
    final readinessColor = _getReadinessColor(theme, progress.readinessLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppConfig.getSubjectDisplayName(subject),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: readinessColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progress.readinessLevel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: readinessColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.overallReadiness / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(readinessColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.overallReadiness}% Ready',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceChip(
                    theme,
                    'Practice',
                    '${progress.practicePerformance.averageScore.toInt()}%',
                    '${progress.practicePerformance.attempts} attempts',
                    Icons.psychology_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPerformanceChip(
                    theme,
                    'Exam',
                    '${progress.examPerformance.averageScore.toInt()}%',
                    '${progress.examPerformance.attempts} attempts',
                    Icons.timer_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChip(
    ThemeData theme,
    String label,
    String score,
    String attempts,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            attempts,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
          if (state.hasActiveAttempts) ...[
            Text(
              'Active Attempts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...state.activeAttempts.take(3).map((attempt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildActiveAttemptCard(context, theme, attempt),
              );
            }),
            if (state.activeAttempts.length > 3)
              TextButton(
                onPressed: () async {
                  await context.push('/user-attempts');
                  // Refresh when returning from user attempts
                  if (mounted) {
                    _loadDashboardData();
                  }
                },
                child: Text('View all ${state.activeAttempts.length} attempts'),
              ),
          ] else ...[
            _buildNoActivityCard(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveAttemptCard(
      BuildContext context, ThemeData theme, attempt) {
    final isExam = attempt.mode == 'EXAM';
    final timeElapsed = DateTime.now().difference(attempt.startedAt);

    return Card(
      child: InkWell(
        onTap: () async {
          await context.push('/user-attempts');
          // Refresh when returning from user attempts
          if (mounted) {
            _loadDashboardData();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExam
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExam ? Icons.timer : Icons.psychology,
                  size: 20,
                  color: isExam
                      ? theme.colorScheme.onTertiaryContainer
                      : theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isExam ? 'Exam' : 'Practice'} in Progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Started ${_formatDuration(timeElapsed)} ago',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoActivityCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No recent activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start practicing to see your progress here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/papers'),
              child: const Text('Browse Papers'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(ThemeData theme, String error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.read(homeControllerProvider.notifier).clearError();
                  _loadDashboardData();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _getReadinessColor(ThemeData theme, String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
      case 'needs work':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return 'now';
  }

  String _getReadinessLevelFromScore(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Work';
  }
}
