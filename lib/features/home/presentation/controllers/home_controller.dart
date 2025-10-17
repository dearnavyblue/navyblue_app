// lib/features/home/presentation/controllers/home_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import 'package:navyblue_app/brick/models/step_attempt.model.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
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
        final wasOffline = state.isOffline;
        state = state.copyWith(isOffline: !isOnline);
        if (isOnline && wasOffline) {
          syncWhenOnline();
        }
      });
    });
  }

  Future<void> _loadDataFromLocal() async {
    try {
      // OPTIMIZATION: Load data in parallel
      final results = await Future.wait([
        _repository.get<StudentAttempt>(),
        _repository.get<ExamPaper>(),
        _repository.get<StepAttempt>(),
        _repository.get<SolutionStep>(),
        _repository.get<QuestionPart>(),
        _repository.get<Question>(),
      ]);

      final localAttempts = results[0] as List<StudentAttempt>;
      final localPapers = results[1] as List<ExamPaper>;
      final localStepAttempts = results[2] as List<StepAttempt>;
      final localSolutionSteps = results[3] as List<SolutionStep>;
      final localQuestionParts = results[4] as List<QuestionPart>;
      final localQuestions = results[5] as List<Question>;

      // OPTIMIZATION: Filter active attempts early
      final activeLocalAttempts = localAttempts
          .where((attempt) => attempt.completedAt == null)
          .toList();

      // OPTIMIZATION: Calculate progress efficiently
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
    // OPTIMIZATION: Early return for empty data
    final completedAttempts =
        attempts.where((a) => a.completedAt != null).toList();
    if (completedAttempts.isEmpty) {
      return const ProgressSummary(
        subjects: {},
        hasData: false,
      );
    }

    // OPTIMIZATION: Build lookup maps once at the start
    final paperMap = {for (var p in papers) p.id: p};
    final stepAttemptsMap = <String, List<StepAttempt>>{};
    for (final stepAttempt in stepAttempts) {
      (stepAttemptsMap[stepAttempt.studentAttemptId] ??= []).add(stepAttempt);
    }
    final solutionStepsMap = {for (var s in solutionSteps) s.id: s};
    final questionPartsMap = {for (var p in questionParts) p.id: p};
    final questionsMap = {for (var q in questions) q.id: q};

    final subjects = <String, SubjectProgress>{};

    // OPTIMIZATION: Group attempts by subject once
    final attemptsBySubject = <String, List<StudentAttempt>>{};
    for (final attempt in completedAttempts) {
      final paper = paperMap[attempt.paperId];
      if (paper == null) continue;

      final subjectKey = paper.subject;
      (attemptsBySubject[subjectKey] ??= []).add(attempt);
    }

    // Process each subject
    for (final entry in attemptsBySubject.entries) {
      final subjectAttempts = entry.value;

      final practiceAttempts =
          subjectAttempts.where((a) => a.isPracticeMode).toList();
      final examAttempts = subjectAttempts.where((a) => a.isExamMode).toList();

      final practicePerformance = _calculatePerformanceData(
        practiceAttempts,
        stepAttemptsMap,
        solutionStepsMap,
        questionPartsMap,
        questionsMap,
      );

      final examPerformance = _calculatePerformanceData(
        examAttempts,
        stepAttemptsMap,
        solutionStepsMap,
        questionPartsMap,
        questionsMap,
      );

      // OPTIMIZATION: Calculate average more efficiently
      var totalScore = 0.0;
      var scoreCount = 0;
      for (final attempt in subjectAttempts) {
        if (attempt.percentageScore != null) {
          totalScore += attempt.percentageScore!;
          scoreCount++;
        }
      }
      final overallScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

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

    // OPTIMIZATION: Calculate average more efficiently
    var totalScore = 0.0;
    var scoreCount = 0;
    for (final attempt in attempts) {
      if (attempt.percentageScore != null) {
        totalScore += attempt.percentageScore!;
        scoreCount++;
      }
    }
    final averageScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

    // OPTIMIZATION: Aggregate topic data efficiently
    final topicScores = <String, List<double>>{};
    final topicCounts = <String, int>{};

    for (final attempt in attempts) {
      final attemptSteps = stepAttemptsMap[attempt.id];
      if (attemptSteps == null) continue;

      for (final stepAttempt in attemptSteps) {
        final solutionStep = solutionStepsMap[stepAttempt.stepId];
        if (solutionStep == null) continue;

        final questionPart = questionPartsMap[solutionStep.partId];
        if (questionPart == null) continue;

        final question = questionsMap[questionPart.questionId];
        if (question == null || question.topics.isEmpty) continue;

        final stepScore = stepAttempt.isCorrect ? 100.0 : 0.0;

        for (final topic in question.topics) {
          (topicScores[topic] ??= []).add(stepScore);
          topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
        }
      }
    }

    // Build topic breakdown
    final topicBreakdown = <TopicBreakdown>[];
    for (final entry in topicScores.entries) {
      final scores = entry.value;
      if (scores.isEmpty) continue;

      var sum = 0.0;
      for (final score in scores) {
        sum += score;
      }
      final avgScore = sum / scores.length;

      topicBreakdown.add(TopicBreakdown(
        topic: entry.key,
        score: avgScore,
        attempts: topicCounts[entry.key] ?? 0,
      ));
    }

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
      }
    } catch (e) {
      // Silent fail - keep local data
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

        // Save to local database
        await Future.wait([
          ...response.attempts
              .map((a) => _repository.upsert<StudentAttempt>(a)),
          ...response.papers.values
              .map((p) => _repository.upsert<ExamPaper>(p)),
        ]);

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
