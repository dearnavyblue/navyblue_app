// lib/features/home/presentation/controllers/home_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import 'package:navyblue_app/brick/models/step_attempt.model.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
import 'package:navyblue_app/core/services/connectivity_service.dart';
import 'package:navyblue_app/features/home/domain/entities/performance_data.dart';
import 'package:navyblue_app/features/home/domain/entities/subject_progress.dart';
import 'package:navyblue_app/features/home/domain/entities/topic_breakdown.dart';
import '../../domain/entities/progress_summary.dart';
import '../../domain/providers/home_use_case_providers.dart';
import '../../../attempts/domain/providers/attempts_use_case_providers.dart';
import '../../../../brick/models/student_attempt.model.dart';
import '../../../../brick/repository.dart';

class HomeState {
  final ProgressSummary? progressSummary;
  final List<StudentAttempt> activeAttempts;
  final bool isLoadingProgress;
  final bool isLoadingAttempts;
  final String? error;
  final bool isOffline;

  const HomeState({
    this.progressSummary,
    this.activeAttempts = const [],
    this.isLoadingProgress = false,
    this.isLoadingAttempts = false,
    this.error,
    this.isOffline = false,
  });

  HomeState copyWith({
    ProgressSummary? progressSummary,
    List<StudentAttempt>? activeAttempts,
    bool? isLoadingProgress,
    bool? isLoadingAttempts,
    String? error,
    bool? isOffline,
  }) {
    return HomeState(
      progressSummary: progressSummary ?? this.progressSummary,
      activeAttempts: activeAttempts ?? this.activeAttempts,
      isLoadingProgress: isLoadingProgress ?? this.isLoadingProgress,
      isLoadingAttempts: isLoadingAttempts ?? this.isLoadingAttempts,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get hasData => progressSummary?.hasData ?? false;
  bool get hasActiveAttempts => activeAttempts.isNotEmpty;
  bool get isLoading => isLoadingProgress || isLoadingAttempts;
}

class HomeController extends StateNotifier<HomeState> {
  final Ref _ref;
  final Repository _repository = Repository.instance;
  bool _connectivityListenerSetup = false;

  HomeController(this._ref) : super(const HomeState());

  Future<void> loadDashboardData() async {
    if (!_connectivityListenerSetup) {
      _setupConnectivityListener();
      _connectivityListenerSetup = true;
    }

    state = state.copyWith(
      isLoadingProgress: true,
      isLoadingAttempts: true,
      error: null,
    );

    try {
      await _loadDataFromLocal();
      _syncDashboardDataWithServer();
    } catch (e) {
      state = state.copyWith(
        isLoadingProgress: false,
        isLoadingAttempts: false,
        error: 'Failed to load dashboard data: $e',
      );
    }
  }

  void _setupConnectivityListener() {
    _ref.listen(connectivityProvider, (previous, next) {
      next.whenData((isOnline) {
        // Check if we're transitioning from offline to online BEFORE updating state
        final wasOffline = state.isOffline;

        // Always sync state with connectivity
        state = state.copyWith(isOffline: !isOnline);

        // Sync when coming back online (transitioning from offline to online)
        if (isOnline && wasOffline) {
          syncWhenOnline();
        }
      });
    });
  }

  Future<void> _loadDataFromLocal() async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      final localPapers = await _repository.get<ExamPaper>();
      final localStepAttempts = await _repository.get<StepAttempt>();
      final localSolutionSteps = await _repository.get<SolutionStep>();
      final localQuestionParts = await _repository.get<QuestionPart>();
      final localQuestions = await _repository.get<Question>();

      final activeLocalAttempts = localAttempts
          .where((attempt) => attempt.completedAt == null)
          .toList();

      final localProgress = _calculateLocalProgress(
        localAttempts,
        localPapers,
        localStepAttempts,
        localSolutionSteps,
        localQuestionParts,
        localQuestions,
      );

      state = state.copyWith(
        activeAttempts: activeLocalAttempts,
        progressSummary: localProgress,
        isLoadingProgress: false,
        isLoadingAttempts: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProgress: false,
        isLoadingAttempts: false,
      );
    }
  }

  ProgressSummary _calculateLocalProgress(
    List<StudentAttempt> attempts,
    List<ExamPaper> papers,
    List<StepAttempt> stepAttempts,
    List<SolutionStep> solutionSteps,
    List<QuestionPart> questionParts,
    List<Question> questions,
  ) {
    final completedAttempts =
        attempts.where((a) => a.completedAt != null).toList();

    if (completedAttempts.isEmpty) {
      return const ProgressSummary(
        subjects: {},
        hasData: false,
      );
    }

    final paperMap = Map.fromEntries(papers.map((p) => MapEntry(p.id, p)));
    final stepAttemptsMap = <String, List<StepAttempt>>{};
    final solutionStepsMap =
        Map.fromEntries(solutionSteps.map((s) => MapEntry(s.id, s)));
    final questionPartsMap =
        Map.fromEntries(questionParts.map((p) => MapEntry(p.id, p)));
    final questionsMap =
        Map.fromEntries(questions.map((q) => MapEntry(q.id, q)));

    for (final stepAttempt in stepAttempts) {
      stepAttemptsMap
          .putIfAbsent(stepAttempt.studentAttemptId, () => [])
          .add(stepAttempt);
    }

    final subjects = <String, SubjectProgress>{};

    final attemptsBySubject = <String, List<StudentAttempt>>{};
    for (final attempt in completedAttempts) {
      final paper = paperMap[attempt.paperId];
      final subjectKey = paper?.subject ?? 'Unknown';
      attemptsBySubject.putIfAbsent(subjectKey, () => []).add(attempt);
    }

    for (final entry in attemptsBySubject.entries) {
      final subjectAttempts = entry.value;

      final practiceAttempts =
          subjectAttempts.where((a) => a.isPracticeMode).toList();
      final examAttempts = subjectAttempts.where((a) => a.isExamMode).toList();

      final practicePerformance = _calculatePerformanceData(
        practiceAttempts,
        paperMap,
        stepAttemptsMap,
        solutionStepsMap,
        questionPartsMap,
        questionsMap,
      );
      final examPerformance = _calculatePerformanceData(
        examAttempts,
        paperMap,
        stepAttemptsMap,
        solutionStepsMap,
        questionPartsMap,
        questionsMap,
      );

      final overallScore = subjectAttempts.isNotEmpty
          ? subjectAttempts
                  .map((a) => a.percentageScore ?? 0.0)
                  .reduce((a, b) => a + b) /
              subjectAttempts.length
          : 0.0;

      final readinessLevel = _getReadinessLevel(overallScore);

      subjects[entry.key] = SubjectProgress(
        overallReadiness: overallScore.round(),
        readinessLevel: readinessLevel,
        practicePerformance: practicePerformance,
        examPerformance: examPerformance,
      );
    }

    return ProgressSummary(
      subjects: subjects,
      hasData: true,
    );
  }

  PerformanceData _calculatePerformanceData(
    List<StudentAttempt> attempts,
    Map<String, ExamPaper> paperMap,
    Map<String, List<StepAttempt>> stepAttemptsMap,
    Map<String, SolutionStep> solutionStepsMap,
    Map<String, QuestionPart> questionPartsMap,
    Map<String, Question> questionsMap,
  ) {
    if (attempts.isEmpty) {
      return const PerformanceData(
        averageScore: 0.0,
        attempts: 0,
        topicBreakdown: [],
      );
    }

    final averageScore =
        attempts.map((a) => a.percentageScore ?? 0.0).reduce((a, b) => a + b) /
            attempts.length;

    final topicScores = <String, List<double>>{};
    final topicCounts = <String, int>{};

    for (final attempt in attempts) {
      final attemptSteps = stepAttemptsMap[attempt.id] ?? [];

      for (final stepAttempt in attemptSteps) {
        final solutionStep = solutionStepsMap[stepAttempt.stepId];
        if (solutionStep == null) continue;

        final questionPart = questionPartsMap[solutionStep.partId];
        if (questionPart == null) continue;

        final question = questionsMap[questionPart.questionId];
        if (question == null) continue;

        final stepScore = stepAttempt.isCorrect ? 100.0 : 0.0;

        for (final topic in question.topics) {
          topicScores.putIfAbsent(topic, () => []).add(stepScore);
          topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
        }
      }
    }

    final topicBreakdown = topicScores.entries.map((entry) {
      final scores = entry.value;
      final avgScore = scores.isNotEmpty
          ? scores.reduce((a, b) => a + b) / scores.length
          : 0.0;
      return TopicBreakdown(
        topic: entry.key,
        score: avgScore,
        attempts: topicCounts[entry.key] ?? 0,
      );
    }).toList();

    return PerformanceData(
      averageScore: averageScore,
      attempts: attempts.length,
      topicBreakdown: topicBreakdown,
    );
  }

  String _getReadinessLevel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 50) return 'Below Average';
    return 'Needs Improvement';
  }

  Future<void> _syncDashboardDataWithServer() async {
    if (state.isOffline) return;

    try {
      final futures = await Future.wait([
        _syncProgressSummary(),
        _syncActiveAttempts(),
      ]);

      final progressSuccess = futures[0];
      final attemptsSuccess = futures[1];

      if (progressSuccess || attemptsSuccess) {
        state = state.copyWith(isOffline: false);
      } else {
        state = state.copyWith();
      }
    } catch (e) {
      state = state.copyWith();
    }
  }

  Future<bool> _syncProgressSummary() async {
    if (state.isOffline) return false;
    try {
      final getProgressUseCase = _ref.read(getProgressSummaryUseCaseProvider);
      final result = await getProgressUseCase();

      if (result.isSuccess) {
        state = state.copyWith(progressSummary: result.data);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncActiveAttempts() async {
    if (state.isOffline) return false;
    try {
      final getUserAttemptsUseCase = _ref.read(getUserAttemptsUseCaseProvider);
      final result = await getUserAttemptsUseCase(status: 'active');

      if (result.isSuccess) {
        final response = result.data!;
        final activeAttempts =
            response.attempts.where((a) => a.completedAt == null).toList();

        // Save both attempts and papers to local database
        for (final attempt in response.attempts) {
          await _repository.upsert<StudentAttempt>(attempt);
        }

        for (final paper in response.papers.values) {
          await _repository.upsert<ExamPaper>(paper);
        }

        state = state.copyWith(activeAttempts: activeAttempts);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> syncWhenOnline() async {
    if (state.isOffline) {
      await _syncDashboardDataWithServer();
    }
  }
}
