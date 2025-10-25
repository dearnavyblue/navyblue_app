// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/student_attempt.model.dart';
import 'package:navyblue_app/core/config/app_config.dart';
import 'package:navyblue_app/core/constants/app_constants.dart';
import 'package:navyblue_app/features/auth/presentation/providers/auth_presentation_providers.dart';
import 'package:navyblue_app/features/greeting/presentation/greeting_bar.dart';
import 'package:navyblue_app/features/greeting/presentation/greeting_patterns_corner.dart';
import 'package:navyblue_app/features/home/presentation/controllers/home_controller.dart';
import 'package:navyblue_app/features/home/presentation/providers/home_presentation_providers.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import 'package:navyblue_app/features/attempts/presentation/widgets/user_attempts_filters.dart';
import 'package:navyblue_app/features/attempts/presentation/widgets/user_attempt_card.dart';
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
  String? _selectedPaper;
  Map<String, String> _completedAttemptFilters = {};
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

  List<StudentAttempt> _getFilteredCompletedAttempts(HomeState state) {
    var attempts = List<StudentAttempt>.from(state.completedAttempts)
      ..removeWhere((attempt) => attempt.completedAt == null)
      ..sort((a, b) {
        final aDate = a.completedAt ?? a.startedAt;
        final bDate = b.completedAt ?? b.startedAt;
        return bDate.compareTo(aDate);
      });

    final typeFilter = _completedAttemptFilters['type'];
    if (typeFilter != null && typeFilter != 'All') {
      attempts = attempts.where((attempt) {
        if (typeFilter == 'Practice') return attempt.mode == 'PRACTICE';
        if (typeFilter == 'Exam') return attempt.mode == 'EXAM';
        return true;
      }).toList();
    }

    final scoreFilter = _completedAttemptFilters['score'];
    if (scoreFilter != null && scoreFilter != 'All') {
      attempts = attempts.where((attempt) {
        final score = attempt.percentageScore;
        if (score == null) return scoreFilter == 'Unscored';
        switch (scoreFilter) {
          case 'Excellent (80%+)':
            return score >= 80;
          case 'Good (60-79%)':
            return score >= 60 && score < 80;
          case 'Needs Work (<60%)':
            return score < 60;
          default:
            return true;
        }
      }).toList();
    }

    final periodFilter = _completedAttemptFilters['period'];
    if (periodFilter != null && periodFilter != 'All Time') {
      final now = DateTime.now();
      attempts = attempts.where((attempt) {
        final reference = attempt.completedAt ?? attempt.startedAt;
        switch (periodFilter) {
          case 'Today':
            return reference.year == now.year &&
                reference.month == now.month &&
                reference.day == now.day;
          case 'This Week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return reference.isAfter(weekStart);
          case 'This Month':
            return reference.year == now.year && reference.month == now.month;
          case 'Last 3 Months':
            final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
            return reference.isAfter(threeMonthsAgo);
          default:
            return true;
        }
      }).toList();
    }

    return attempts;
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
    if (_selectedSubject == null &&
        state.progressSummary != null &&
        state.progressSummary!.subjects.isNotEmpty) {
      _selectedSubject = state.progressSummary!.subjects.keys.first;

      // Set default selected paper (first paper of the selected subject)
      if (_selectedPaper == null && _selectedSubject != null) {
        final subjectProgress =
            state.progressSummary!.subjects[_selectedSubject!];
        if (subjectProgress != null && subjectProgress.papers.isNotEmpty) {
          _selectedPaper = subjectProgress.papers.keys.first;
        }
      }
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
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(0, 0, 0, 0), // page margin
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      clipBehavior:
                          Clip.antiAlias, // clip gradient/pattern to radius
                      child: GreetingBar(
                        displayName:
                            authState.user?.firstName.trim() ?? 'Student',
                        pattern: CornerPattern
                            .cornerDots, // or cornerChevrons / none
                        patternOpacity: 0.06,
                        brandTint: const Color(0xFFEFF6FF),
                        height: 84, // ↑ give it a bit more headroom than 70
                        colorCoverage: 1, // < 30% colored area
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
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        .withValues(alpha: 0.3),
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
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.02,
                  color: Colors.black,
                ),
              ),
              if (state.hasActiveAttempts)
                TextButton(
                  onPressed: () => context.push('/user-attempts/in-progress'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: theme.textTheme.labelSmall?.copyWith(
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
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Exam Readiness',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.4,
              letterSpacing: -0.02,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'See how ready you are for the exams',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.4,
              letterSpacing: -0.02,
              color: Color(0xFF9C9C9C),
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
                        // Auto-select first paper of the new subject
                        final subjectProgress = subjects[subject];
                        if (subjectProgress != null &&
                            subjectProgress.papers.isNotEmpty) {
                          _selectedPaper = subjectProgress.papers.keys.first;
                        } else {
                          _selectedPaper = null;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        AppConfig.getSubjectDisplayName(subject),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Selected Subject Content
          if (selectedProgress != null && _selectedPaper != null)
            _buildSubjectCard(theme, selectedProgress),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme, dynamic subjectProgress) {
    final txt = Theme.of(context).extension<AppTextStyles>()!;
    final papers = subjectProgress.papers as Map<String, dynamic>;

    // Calculate overall readiness from all papers
    double totalScore = 0;
    int paperCount = 0;
    for (var paper in papers.values) {
      totalScore += (paper.averageScore ?? 0.0);
      paperCount++;
    }
    final overallReadiness = paperCount > 0 ? totalScore / paperCount : 0.0;
    final readinessLevel = _getReadinessLevelFromScore(overallReadiness);

    // Get selected paper data
    final selectedPaperProgress = papers[_selectedPaper];
    if (selectedPaperProgress == null) return const SizedBox.shrink();

    final topics = selectedPaperProgress.topics as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.zero,
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
                        AppConfig.getSubjectDisplayName(_selectedSubject!),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(context, readinessLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    readinessLevel,
                    style: txt.extraSmall.copyWith(
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
                value: overallReadiness / 100,
                minHeight: 5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  overallReadiness > 0
                      ? _statusColor(context, readinessLevel)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Papers Section - Show all papers with click functionality
            Row(
              children: papers.entries.map((entry) {
                final paperType = entry.key;
                final paperProgress = entry.value;
                final isSelected = _selectedPaper == paperType;
                final paperName = paperType
                    .split('_')
                    .map((word) =>
                        word[0].toUpperCase() + word.substring(1).toLowerCase())
                    .join(' ');

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: entry.key != papers.keys.last ? 12 : 0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPaper = paperType;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _buildPaperProgress(
                          theme,
                          paperName,
                          paperProgress.averageScore ?? 0.0,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Topics Breakdown for selected paper
            if (topics.isNotEmpty) ...[
              ...topics.entries.map((entry) {
                final topicName = entry.key;
                final topicProgress = entry.value;
                final topicAccuracy = topicProgress.performance ?? 0.0;
                final topicDisplayName = topicName
                    .split('_')
                    .map((word) =>
                        word[0].toUpperCase() + word.substring(1).toLowerCase())
                    .join(' ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topic name with % Ready
                      Row(
                        children: [
                          Text(
                            topicDisplayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${topicAccuracy.toInt()}%',
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
                          minHeight: 5,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            topicAccuracy > 0
                                ? _statusColor(context,
                                    _getReadinessLevelFromScore(topicAccuracy))
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
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${score.toInt()}%',
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
            minHeight: 5,
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
    final filteredAttempts = _getFilteredCompletedAttempts(state);
    final attemptsToShow = filteredAttempts.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attempts',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.02,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your previous attempts',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.4,
                        letterSpacing: -0.02,
                        color: Color(0xFF9C9C9C),
                      ),
                    ),
                  ],
                ),
              ),
              if (filteredAttempts.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/user-attempts'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: theme.textTheme.labelSmall?.copyWith(
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
          const SizedBox(height: 16),
          UserAttemptsFilters(
            activeFilters: _completedAttemptFilters,
            includeStatus: false,
            compact: true,
            onFiltersChanged: (filters) {
              setState(() => _completedAttemptFilters = filters);
            },
          ),
          const SizedBox(height: 12),
          if (attemptsToShow.isEmpty)
            _buildNoAttemptsCard(context, theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attemptsToShow.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final attempt = attemptsToShow[index];
                return UserAttemptCard(
                  attempt: attempt,
                  paper: null,
                  showModeBadge: true,
                  onTap: () async {
                    await context.push(
                      '/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}&resume=${attempt.id}',
                    );
                    if (mounted) {
                      _loadDashboardData();
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoAttemptsCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No completed attempts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete a paper to unlock your stats here.',
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
  String _getReadinessLevelFromScore(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Work';
  }
}
