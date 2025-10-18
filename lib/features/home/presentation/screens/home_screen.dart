// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/student_attempt.model.dart';
import 'package:navyblue_app/core/config/app_config.dart';
import 'package:navyblue_app/core/constants/app_constants.dart';
import 'package:navyblue_app/features/auth/presentation/providers/auth_presentation_providers.dart';
import 'package:navyblue_app/features/home/presentation/controllers/home_controller.dart';
import 'package:navyblue_app/features/home/presentation/providers/home_presentation_providers.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import 'package:navyblue_app/brick/repository.dart';
import 'dart:async';

import '../../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _hasLoadedOnce = false;
  String? _selectedSubject;
  int _lastAttemptCount = 0;
  DateTime? _lastRefreshTime;
  Timer? _debounceTimer;

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
      // OPTIMIZATION: Only refresh if it's been more than 30 seconds
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

    // OPTIMIZATION: Debounced listener for attempt changes
    ref.listen(userAttemptsControllerProvider, (previous, next) {
      if (previous != null &&
          previous.userAttempts.length != next.userAttempts.length &&
          next.userAttempts.length != _lastAttemptCount) {
        _lastAttemptCount = next.userAttempts.length;

        // Cancel existing timer
        _debounceTimer?.cancel();

        // Debounce refresh by 500ms
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted && _lastAttemptCount == next.userAttempts.length) {
            ref.read(homeControllerProvider.notifier).loadDashboardData();
          }
        });
      }
    });

    // Set default selected subject if none is selected
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

  // OPTIMIZATION: Skeleton loader for better perceived performance
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
          // Title row with "View All" link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'In Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (state.hasActiveAttempts)
                TextButton(
                  onPressed: () => context.push('/user-attempts'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Horizontal scrollable list of active attempts OR fallback cards
          if (state.hasActiveAttempts)
            SizedBox(
              height:
                  118, // Changed to accommodate new card height (91 + some padding)
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.activeAttempts.length,
                itemBuilder: (context, index) {
                  final attempt = state.activeAttempts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < state.activeAttempts.length - 1 ? 8 : 0,
                    ),
                    child:
                        _buildActiveAttemptQuickCard(context, theme, attempt),
                  );
                },
              ),
            )
          else
            // Fallback: Show Browse Papers and Past Attempts when no active attempts
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
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
                  child: _buildActionCard(
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

  Widget _buildActiveAttemptQuickCard(
      BuildContext context, ThemeData theme, StudentAttempt attempt) {
    final scheme = theme.colorScheme;
    final status = theme.extension<StatusColors>()!;
    final isExam = attempt.mode == 'EXAM';

    // Calculate progress (questions answered out of total)
    final totalQuestions = attempt.calculatedTotalSteps > 0
        ? attempt.calculatedTotalSteps
        : attempt.questionsCompleted;
    final answeredQuestions = attempt.calculatedMarkedSteps > 0
        ? attempt.calculatedMarkedSteps
        : attempt.questionsAttempted;

    final progressPercentage = totalQuestions > 0
        ? (answeredQuestions / totalQuestions * 100).round()
        : 0;

    return SizedBox(
      width: 250,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        color: scheme.surface,
        child: InkWell(
          onTap: () async {
            await context.push(
              '/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}&resume=${attempt.id}',
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 57,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow:
                        (theme.extension<CustomShadows>()?.cardShadows) ??
                            const [],
                    image: const DecorationImage(
                      image: AssetImage(AppConstants.pastPaperThumbnailPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPaperInfoWithSubject(theme, attempt.paperId),
                      const SizedBox(height: 10),
                      // progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressPercentage / 100,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: status.success,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$progressPercentage% complete',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaperInfoWithSubject(ThemeData theme, String paperId) {
    return FutureBuilder<ExamPaper?>(
      future: Repository.instance
          .get<ExamPaper>(
            query: Query.where('id', paperId, limit1: true),
          )
          .then((papers) => papers.isNotEmpty ? papers.first : null),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'Loading...',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        }

        final paper = snapshot.data!;

        final grade = AppConfig.getGradeDisplayName(paper.grade); // ← Add this
        final subject = AppConfig.getSubjectDisplayName(paper.subject);
        final examPeriod = AppConfig.getExamPeriodDisplayName(paper.examPeriod);
        final paperType = AppConfig.getPaperTypeDisplayName(paper.paperType);
        final provinceAbbr =
            AppConfig.getProvinceAbbreviation(paper.province ?? '');

        // Build grade and subject text (e.g., "Grade 10 · Mathematics")
        final gradeSubjectText = '$grade · $subject'; // ← Add this

        // Build main paper text (year, period, type)
        final parts = <String>[];
        if (paper.year > 0) parts.add(paper.year.toString());
        if (examPeriod.isNotEmpty) parts.add(examPeriod);
        if (paperType.isNotEmpty) parts.add(paperType);

        final mainText = parts.join(' ');

        final txt = theme.extension<AppTextStyles>()!;

        // Add province if available (e.g., "2024 November P2 - KZN")
        final paperText =
            provinceAbbr.isNotEmpty ? '$mainText - $provinceAbbr' : mainText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grade and Subject text with dot separator
            Text(
              gradeSubjectText,
              style: txt.extraExtraSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              paperText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
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
    final gradients = theme.extension<GradientColors>()!;
    
    return Card(
      elevation: isPrimary ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isPrimary ? gradients.primaryGradient : null,
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
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPrimary
                      ? theme.colorScheme.onPrimary.withOpacity(0.85)
                      : theme.colorScheme.onSurfaceVariant,
                ),
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
              fontSize: 18,
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
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        AppConfig.getSubjectDisplayName(subject),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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
                                  color: theme.colorScheme.onSurface,
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
                            color: _statusColor(
                                context, selectedProgress.readinessLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedProgress.readinessLevel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
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
                              ? _statusColor(
                                  context, selectedProgress.readinessLevel)
                              : theme.colorScheme.outline,
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
                            selectedProgress.practicePerformance.averageScore,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Paper 2
                        Expanded(
                          child: _buildPaperProgress(
                            theme,
                            'Paper 2',
                            selectedProgress.examPerformance.averageScore,
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
                                      color: theme.colorScheme.onSurface,
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
                                        ? _statusColor(context, topic.status)
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
                  ? _statusColor(context, _getReadinessLevelFromScore(score))
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
                onPressed: () => context.push('/user-attempts'),
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
      BuildContext context, ThemeData theme, StudentAttempt attempt) {
    final isExam = attempt.mode == 'EXAM';
    final timeElapsed = DateTime.now().difference(attempt.startedAt);
    final scheme = theme.colorScheme;
    final container =
        isExam ? scheme.tertiaryContainer : scheme.secondaryContainer;
    final onContainer =
        isExam ? scheme.onTertiaryContainer : scheme.onSecondaryContainer;


    return Card(
      child: InkWell(
        onTap: () => context.push('/user-attempts'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: container,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExam ? Icons.timer : Icons.psychology,
                  size: 20,
                  color: onContainer,
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

Color _statusColor(BuildContext context, String level) {
    final status = Theme.of(context).extension<StatusColors>()!;
    switch (level.toLowerCase()) {
      case 'excellent':
        return status.success;
      case 'good':
        return status.info;
      case 'fair':
        return status.warning;
      case 'needs work':
        return status.negative;
      default:
        return Theme.of(context).colorScheme.primary;
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
