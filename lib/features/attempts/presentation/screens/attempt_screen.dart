// lib/features/attempts/presentation/screens/attempt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/attempt_config.dart';
import '../providers/attempts_presentation_providers.dart';
import '../widgets/paper_tab_widget.dart';
import '../widgets/memo_tab_widget.dart';
import '../widgets/attempt_center_switcher.dart';
import '../widgets/paper_header_data.dart';

class AttemptScreen extends ConsumerStatefulWidget {
  final String paperId;
  final String mode;
  final String? resumeAttemptId;

  const AttemptScreen({
    super.key,
    required this.paperId,
    required this.mode,
    this.resumeAttemptId,
  });

  @override
  ConsumerState<AttemptScreen> createState() => _AttemptScreenState();
}

class _AttemptScreenState extends ConsumerState<AttemptScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = widget.mode == 'practice'
          ? AttemptConfig.practice(widget.paperId)
          : AttemptConfig.exam(widget.paperId, 180);

      ref
          .read(attemptsControllerProvider(widget.paperId).notifier)
          .startAttempt(config, resumeAttemptId: widget.resumeAttemptId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    super.dispose();
  }

  // Handle app going to background/foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final attemptState = ref.read(attemptsControllerProvider(widget.paperId));
    final controller =
        ref.read(attemptsControllerProvider(widget.paperId).notifier);

    if (attemptState.isExamMode &&
        attemptState.currentAttempt != null &&
        !attemptState.currentAttempt!.isCompleted) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          // App going to background - pause timer
          controller.pauseExamTimer();
          break;
        case AppLifecycleState.resumed:
          // App coming to foreground - resume timer
          controller.resumeExamTimer();
          break;
        case AppLifecycleState.hidden:
          // Handle if needed
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attemptsControllerProvider(widget.paperId));
    final theme = Theme.of(context);

    if (state.isLoading && state.currentAttempt == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                state.isOffline ? 'Loading offline...' : 'Loading attempt...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(attemptsControllerProvider(widget.paperId)
                              .notifier)
                          .clearError();
                      final config = widget.mode == 'practice'
                          ? AttemptConfig.practice(widget.paperId)
                          : AttemptConfig.exam(widget.paperId, 180);
                      ref
                          .read(attemptsControllerProvider(widget.paperId)
                              .notifier)
                          .startAttempt(config);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final showCompleteButton =
        state.currentAttempt != null && !state.currentAttempt!.isCompleted;

        final headerData = state.paper?.toHeaderData();

    return WillPopScope(
      onWillPop: () => _handleBackPress(context, state),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AttemptAppBar(
            selectedIndex: _getTabController().index,
            memoEnabled: state.memoEnabled,
            onChanged: (i) {
              _handleTabChange(i);
              _getTabController().animateTo(i);
            },
            isExamMode: state.isExamMode,
            isTimerRunning: state.isTimerRunning,
            remainingSeconds: state.remainingSeconds,
            isPracticeMode: state.isPracticeMode,
            canShowHints: state.canShowHints,
            onToggleHints: () {
              ref
                  .read(attemptsControllerProvider(widget.paperId).notifier)
                  .toggleHints();
            },
            isOffline: state.isOffline,
          ),
          body: Column(
            children: [
              if (showCompleteButton)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.isPracticeMode
                              ? 'Complete to count towards readiness'
                              : 'Submit to count towards readiness',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showCompleteAttemptDialog(context),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: Text(
                          state.isPracticeMode ? 'Complete' : 'Submit',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _getTabController(),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PaperTabWidget(
                      questions: state.currentPageQuestions,
                      instructions: state.paper?.instructions ??
                          'Read all questions carefully before answering.\n\n'
                              'Answer ALL questions.\n\n'
                              'Show all working clearly.\n\n'
                              'Write your answers in the spaces provided.\n\n'
                              'Calculators may be used unless otherwise stated.\n\n'
                              'Time allocation: Plan your time carefully across all questions.',
                      currentPage: state.currentPage,
                      totalPages: state.totalPages,
                      showHints: state.canShowHints,
                      isPracticeMode: state.isPracticeMode,
                      onPreviousPage: () => ref
                          .read(attemptsControllerProvider(widget.paperId)
                              .notifier)
                          .goToPreviousPage(),
                      onNextPage: () => ref
                          .read(attemptsControllerProvider(widget.paperId)
                              .notifier)
                          .goToNextPage(),
                      onToggleHints: () => ref
                          .read(attemptsControllerProvider(widget.paperId)
                              .notifier)
                          .toggleHints(),
                      // NEW: Smart navigation properties
                      canGoToPrevious: state.canGoToPreviousPage,
                      canGoToNext: state.canGoToNextPage,
                      pageDisplayText: state.pageDisplayText,
                      isOnInstructionsPage: state.isOnInstructionsPage,
                        headerData: headerData,
                    ),
                    state.memoEnabled
                        ? MemoTabWidget(
                            questions: state.currentPageQuestions,
                            progress: state.progress,
                            expandedSolutions: state.expandedSolutions,
                            stepStatuses: state.stepStatuses,
                            onMarkStep: (stepId, status) => ref
                                .read(attemptsControllerProvider(widget.paperId)
                                    .notifier)
                                .markStep(stepId: stepId, status: status),
                            onToggleExpansion: (partId) => ref
                                .read(attemptsControllerProvider(widget.paperId)
                                    .notifier)
                                .toggleSolutionExpansion(partId),
                            onPreviousPage: () => ref
                                .read(attemptsControllerProvider(widget.paperId)
                                    .notifier)
                                .goToPreviousPage(),
                            onNextPage: () => ref
                                .read(attemptsControllerProvider(widget.paperId)
                                    .notifier)
                                .goToNextPage(),
                            currentPage: state.currentPage,
                            totalPages: state.totalPages,
                            // NEW: Smart navigation properties
                            canGoToPrevious: state.canGoToPreviousPage,
                            canGoToNext: state.canGoToNextPage,
                            pageDisplayText: state.pageDisplayText,
                            isOnInstructionsPage: state.isOnInstructionsPage,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 64, color: theme.disabledColor),
                                const SizedBox(height: 16),
                                Text(
                                  'Memo will be available after exam time expires',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Continue working on the paper',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (state.isExamMode && state.isTimerRunning)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: theme
                                                .colorScheme.onPrimaryContainer,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Time remaining: ${_formatTime(state.remainingSeconds ?? 0)}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TabController _getTabController() {
    if (_tabController == null) {
      _tabController = TabController(length: 2, vsync: this);
      final state = ref.read(attemptsControllerProvider(widget.paperId));
      _tabController!.index = state.currentTab == 'memo' ? 1 : 0;
    }
    return _tabController!;
  }

  void _handleTabChange(int index) {
    final tab = index == 0 ? 'paper' : 'memo';
    ref
        .read(attemptsControllerProvider(widget.paperId).notifier)
        .switchTab(tab);
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  void _showCompleteAttemptDialog(BuildContext context) {
    final state = ref.read(attemptsControllerProvider(widget.paperId));
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(state.isPracticeMode ? 'Complete Practice?' : 'Submit Exam?'),
        content: const Text('Counts towards your readiness assessment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Working'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(attemptsControllerProvider(widget.paperId).notifier)
                  .completeAttempt();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isPracticeMode
                        ? 'Practice completed! Counts towards readiness.'
                        : 'Exam submitted! Counts towards readiness.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              if (!state.isPracticeMode) {
                ref
                    .read(attemptsControllerProvider(widget.paperId).notifier)
                    .switchTab('memo');
                _tabController?.animateTo(1);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: Text(state.isPracticeMode ? 'Complete' : 'Submit'),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleBackPress(BuildContext context, state) async {
    if (state.currentAttempt?.isCompleted == true) {
      return true;
    }

    // Pause exam timer when leaving
    if (state.isExamMode && !state.currentAttempt!.isCompleted) {
      ref
          .read(attemptsControllerProvider(widget.paperId).notifier)
          .pauseExamTimer();
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Attempt?'),
        content: Text(
          state.isExamMode
              ? 'Your progress will be saved. You can resume this exam later, and the timer will be paused while you\'re away.'
              : 'Your progress will be saved. You can resume this practice session later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Resume timer if they choose to stay
              if (state.isExamMode && !state.currentAttempt!.isCompleted) {
                ref
                    .read(attemptsControllerProvider(widget.paperId).notifier)
                    .resumeExamTimer();
              }
              Navigator.of(context).pop(false);
            },
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    // If they decided to stay, timer is already resumed above
    // If they're leaving, timer is already paused above
    return shouldLeave ?? false;
  }
}
