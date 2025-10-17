// lib/features/attempts/presentation/controllers/attempts_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/attempt_config.dart';
import '../../domain/entities/attempt_progress.dart';
import '../../domain/providers/attempts_use_case_providers.dart';
import '../../../papers/domain/providers/papers_use_case_providers.dart';
import '../../../../brick/models/student_attempt.model.dart';
import '../../../../brick/models/exam_paper.model.dart';
import '../../../../brick/models/question.model.dart';
import '../../../../brick/models/step_attempt.model.dart';
import '../../../../brick/repository.dart';

class AttemptsState {
  final StudentAttempt? currentAttempt;
  final ExamPaper? paper;
  final Map<int, List<Question>> allPagesQuestions;
  final AttemptProgress? progress;
  final bool isLoading;
  final bool isMarkingStep;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool showHints;
  final String currentTab;
  final bool memoEnabled;
  final Map<String, bool> expandedSolutions;
  final Map<String, String> stepStatuses;
  final bool isOffline;
  final DateTime? timerStartedAt;
  final int? remainingSeconds;
  final bool isTimerPaused;
  final List<StudentAttempt> userAttempts;
  final Map<String, ExamPaper> papersCache;
  final bool isLoadingUserAttempts;
  final String? userAttemptsError;
  final bool isInitialized;

  final int currentAttemptsPage;
  final int totalAttemptsPages;
  final bool hasNextAttemptsPage;
  final bool isLoadingMoreAttempts;
  final int totalAttemptsCount;

  const AttemptsState({
    this.currentAttempt,
    this.paper,
    this.allPagesQuestions = const {},
    this.progress,
    this.isLoading = false,
    this.isMarkingStep = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.showHints = false,
    this.currentTab = 'paper',
    this.memoEnabled = true,
    this.expandedSolutions = const {},
    this.stepStatuses = const {},
    this.isOffline = false,
    this.timerStartedAt,
    this.remainingSeconds,
    this.isTimerPaused = false,
    this.userAttempts = const [],
    this.papersCache = const {},
    this.isLoadingUserAttempts = false,
    this.userAttemptsError,
    this.isInitialized = false,
    this.currentAttemptsPage = 1,
    this.totalAttemptsPages = 1,
    this.hasNextAttemptsPage = false,
    this.isLoadingMoreAttempts = false,
    this.totalAttemptsCount = 0,
  });

  AttemptsState copyWith({
    StudentAttempt? currentAttempt,
    ExamPaper? paper,
    Map<int, List<Question>>? allPagesQuestions,
    AttemptProgress? progress,
    bool? isLoading,
    bool? isMarkingStep,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? showHints,
    String? currentTab,
    bool? memoEnabled,
    Map<String, bool>? expandedSolutions,
    Map<String, String>? stepStatuses,
    bool? isOffline,
    DateTime? timerStartedAt,
    int? remainingSeconds,
    bool? isTimerPaused,
    List<StudentAttempt>? userAttempts,
    Map<String, ExamPaper>? papersCache,
    bool? isLoadingUserAttempts,
    String? userAttemptsError,
    bool? isInitialized,
    int? currentAttemptsPage,
    int? totalAttemptsPages,
    bool? hasNextAttemptsPage,
    bool? isLoadingMoreAttempts,
    int? totalAttemptsCount,
  }) {
    return AttemptsState(
      currentAttempt: currentAttempt ?? this.currentAttempt,
      paper: paper ?? this.paper,
      allPagesQuestions: allPagesQuestions ?? this.allPagesQuestions,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      isMarkingStep: isMarkingStep ?? this.isMarkingStep,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      showHints: showHints ?? this.showHints,
      currentTab: currentTab ?? this.currentTab,
      memoEnabled: memoEnabled ?? this.memoEnabled,
      expandedSolutions: expandedSolutions ?? this.expandedSolutions,
      stepStatuses: stepStatuses ?? this.stepStatuses,
      isOffline: isOffline ?? this.isOffline,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      userAttempts: userAttempts ?? this.userAttempts,
      papersCache: papersCache ?? this.papersCache,
      isLoadingUserAttempts:
          isLoadingUserAttempts ?? this.isLoadingUserAttempts,
      userAttemptsError: userAttemptsError,
      isInitialized: isInitialized ?? this.isInitialized,
      currentAttemptsPage: currentAttemptsPage ?? this.currentAttemptsPage,
      totalAttemptsPages: totalAttemptsPages ?? this.totalAttemptsPages,
      hasNextAttemptsPage: hasNextAttemptsPage ?? this.hasNextAttemptsPage,
      isLoadingMoreAttempts:
          isLoadingMoreAttempts ?? this.isLoadingMoreAttempts,
      totalAttemptsCount: totalAttemptsCount ?? this.totalAttemptsCount,
    );
  }

  bool get isExamMode => currentAttempt?.mode == 'EXAM';
  bool get isPracticeMode => currentAttempt?.mode == 'PRACTICE';
  bool get canShowHints => isPracticeMode && showHints;

  List<Question> get currentPageQuestions {
    if (currentPage == 1) return [];
    return allPagesQuestions[currentPage] ?? [];
  }

  bool get isOnInstructionsPage => currentPage == 1;

  String get pageDisplayText {
    if (allDisplayPages.isEmpty) return 'Page 1 of 1';
    final currentDisplayIndex = allDisplayPages.indexOf(currentPage);
    if (currentDisplayIndex == -1) return 'Page 1 of $displayTotalPages';
    if (currentPage == 1) {
      return 'Instructions';
    } else {
      return 'Page $currentPage of $totalPages';
    }
  }

  bool get canGoToPreviousPage {
    if (allDisplayPages.isEmpty) return false;
    final currentIndex = allDisplayPages.indexOf(currentPage);
    return currentIndex > 0;
  }

  bool get canGoToNextPage {
    if (allDisplayPages.isEmpty) return false;
    final currentIndex = allDisplayPages.indexOf(currentPage);
    return currentIndex >= 0 && currentIndex < allDisplayPages.length - 1;
  }

  int? get previousPage {
    if (!canGoToPreviousPage) return null;
    final currentIndex = allDisplayPages.indexOf(currentPage);
    return allDisplayPages[currentIndex - 1];
  }

  int? get nextPage {
    if (!canGoToNextPage) return null;
    final currentIndex = allDisplayPages.indexOf(currentPage);
    return allDisplayPages[currentIndex + 1];
  }

  bool get isTimerRunning =>
      timerStartedAt != null &&
      remainingSeconds != null &&
      remainingSeconds! > 0 &&
      !isTimerPaused;
  bool get isTimeUp =>
      isExamMode && remainingSeconds != null && remainingSeconds! <= 0;

  String getStepStatus(String stepId) =>
      stepStatuses[stepId] ?? 'NOT_ATTEMPTED';

  List<int> get availableServerPages => allPagesQuestions.keys
      .where((page) => allPagesQuestions[page]?.isNotEmpty == true)
      .toList()
    ..sort();

  List<int> get allDisplayPages => [1, ...availableServerPages];

  int get displayTotalPages => allDisplayPages.length;
}

class AttemptsController extends StateNotifier<AttemptsState> {
  final Ref _ref;
  final String? _paperId;
  final Repository _repository = Repository.instance;
  bool _connectivityListenerSetup = false;

  AttemptsController(this._ref, this._paperId) : super(const AttemptsState());

  // OPTIMIZATION: User Attempts Management
  Future<void> loadUserAttempts({int page = 1, bool refresh = false}) async {
    if (!_connectivityListenerSetup) {
      _setupConnectivityListener();
      _connectivityListenerSetup = true;
    }

    if (refresh) {
      state = state.copyWith(
        isLoadingUserAttempts: true,
        userAttemptsError: null,
        userAttempts: [],
        currentAttemptsPage: 1,
      );
    } else {
      state =
          state.copyWith(isLoadingMoreAttempts: true, userAttemptsError: null);
    }

    try {
      await _loadUserAttemptsFromLocal(page, refresh);
      _syncUserAttemptsWithServer(page, refresh);
    } catch (e) {
      state = state.copyWith(
          isLoadingUserAttempts: false,
          isLoadingMoreAttempts: false,
          userAttemptsError: 'Failed to load attempts: $e',
          isInitialized: true);
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

  Future<void> _loadUserAttemptsFromLocal(int page, bool refresh) async {
    try {
      // OPTIMIZATION: Load attempts and papers in parallel
      final results = await Future.wait([
        _repository.get<StudentAttempt>(),
        _repository.get<ExamPaper>(),
      ]);

      final localAttempts = results[0] as List<StudentAttempt>;
      final allPapers = results[1] as List<ExamPaper>;

      localAttempts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      // OPTIMIZATION: Build papers cache efficiently
      final papersCache = {for (var paper in allPapers) paper.id: paper};

      const pageSize = 20;
      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, localAttempts.length);

      final pageAttempts = localAttempts.sublist(startIndex, endIndex);
      final totalPages = (localAttempts.length / pageSize).ceil();

      final combinedAttempts =
          refresh ? pageAttempts : [...state.userAttempts, ...pageAttempts];

      state = state.copyWith(
        userAttempts: combinedAttempts,
        papersCache: papersCache,
        currentAttemptsPage: page,
        totalAttemptsPages: totalPages,
        hasNextAttemptsPage: endIndex < localAttempts.length,
        totalAttemptsCount: localAttempts.length,
        isLoadingUserAttempts: false,
        isLoadingMoreAttempts: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingUserAttempts: false,
        isLoadingMoreAttempts: false,
        isInitialized: true,
      );
    }
  }

  Future<void> _syncUserAttemptsWithServer(int page, bool refresh) async {
    if (state.isOffline) return;

    try {
      await _syncPendingChangesToServer();
      final getUserAttemptsUseCase = _ref.read(getUserAttemptsUseCaseProvider);

      if (refresh) {
        final allAttemptsResult = await getUserAttemptsUseCase();
        if (allAttemptsResult.isSuccess) {
          await _syncAttemptDeletions(allAttemptsResult.data!.attempts);
        }
      }

      final result = await getUserAttemptsUseCase.getPage(
        page: page,
        limit: 20,
      );

      if (result.isSuccess) {
        final response = result.data!;

        // OPTIMIZATION: Save attempts in parallel
        await Future.wait(response.attempts
            .map((a) => _repository.upsert<StudentAttempt>(a)));

        final updatedPapersCache = {...state.papersCache, ...response.papers};

        List<StudentAttempt> finalAttempts;

        if (refresh) {
          finalAttempts = response.attempts;
        } else {
          // OPTIMIZATION: Use map for O(1) lookups
          final attemptMap = {for (var a in state.userAttempts) a.id: a};
          for (var attempt in response.attempts) {
            attemptMap[attempt.id] = attempt;
          }

          await _repository.get<StudentAttempt>();
          final serverAttemptIds = {for (var a in response.attempts) a.id};

          attemptMap.removeWhere((id, attempt) =>
              !serverAttemptIds.contains(id) && !attempt.needsSync);

          finalAttempts = attemptMap.values.toList();
        }

        finalAttempts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

        if (finalAttempts.length > response.totalCount) {
          finalAttempts = finalAttempts.take(response.totalCount).toList();
        }

        state = state.copyWith(
          userAttempts: finalAttempts,
          papersCache: updatedPapersCache,
          currentAttemptsPage: response.currentPage,
          totalAttemptsPages: response.totalPages,
          hasNextAttemptsPage: response.currentPage < response.totalPages,
          totalAttemptsCount: response.totalCount,
          isLoadingUserAttempts: false,
          isLoadingMoreAttempts: false,
          isOffline: false,
          isInitialized: true,
        );

        unawaited(
            _processAttemptsInBackground(response.attempts, response.papers));
      } else {
        state = state.copyWith(
          isLoadingUserAttempts: false,
          isLoadingMoreAttempts: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingUserAttempts: false,
        isLoadingMoreAttempts: false,
        isInitialized: true,
      );
    }
  }

  Future<void> _syncAttemptDeletions(
      List<StudentAttempt> serverAttempts) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      final serverAttemptIds = {for (var a in serverAttempts) a.id};

      final attemptsToDelete = localAttempts
          .where((local) =>
              !serverAttemptIds.contains(local.id) && !local.needsSync)
          .toList();

      // OPTIMIZATION: Delete in parallel
      if (attemptsToDelete.isNotEmpty) {
        await Future.wait(attemptsToDelete.map((attempt) async {
          await _repository.delete<StudentAttempt>(attempt);

          final stepAttempts = await _repository.get<StepAttempt>();
          final associatedSteps = stepAttempts
              .where((step) => step.studentAttemptId == attempt.id)
              .toList();

          await Future.wait(associatedSteps
              .map((step) => _repository.delete<StepAttempt>(step)));
        }));
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _processAttemptsInBackground(
      List<StudentAttempt> attempts, Map<String, ExamPaper> papers) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      final merged = {for (var local in localAttempts) local.id: local};

      // OPTIMIZATION: Save in parallel
      await Future.wait([
        ...attempts.map((a) {
          merged[a.id] = a;
          return _repository.upsert<StudentAttempt>(a);
        }),
        ...papers.values.map((p) => _repository.upsert<ExamPaper>(p)),
      ]);

      final sortedAttempts = merged.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      state = state.copyWith(
        userAttempts: sortedAttempts,
        papersCache: {...state.papersCache, ...papers},
      );

      await _syncPendingChangesToServer();
    } catch (e) {
      // Background fail - UI shows server data
    }
  }

  Future<void> _syncPendingChangesToServer() async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      final pendingAttempts = localAttempts.where((a) => a.needsSync).toList();

      for (final attempt in pendingAttempts) {
        try {
          if (attempt.completedAt != null) {
            final completeAttemptUseCase =
                _ref.read(completeAttemptUseCaseProvider);
            final result = await completeAttemptUseCase(
              attemptId: attempt.id,
              autoSubmitted: attempt.autoSubmitted,
            );

            if (result.isSuccess) {
              final syncedAttempt = result.data!.copyWith(
                timerStartedAt: attempt.timerStartedAt,
                lastActivityAt: attempt.lastActivityAt,
                needsSync: false,
              );
              await _repository.upsert<StudentAttempt>(syncedAttempt);
            }
          }

          final stepAttempts = await _repository.get<StepAttempt>();
          final pendingSteps = stepAttempts
              .where((s) => s.studentAttemptId == attempt.id && s.needsSync)
              .toList();

          for (final stepAttempt in pendingSteps) {
            final markStepUseCase = _ref.read(markStepUseCaseProvider);
            final stepResult = await markStepUseCase(
              attemptId: attempt.id,
              stepId: stepAttempt.stepId,
              status: stepAttempt.status,
            );

            if (stepResult.isSuccess) {
              final syncedStep = stepAttempt.copyWith(needsSync: false);
              await _repository.upsert<StepAttempt>(syncedStep);
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Retry later
    }
  }

  // Attempt Management
  Future<void> startAttempt(
    AttemptConfig config, {
    String? resumeAttemptId,
  }) async {
    if (_paperId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Paper ID is required for starting attempts',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (resumeAttemptId != null && resumeAttemptId.isNotEmpty) {
        await _resumeAttemptOfflineFirst(resumeAttemptId);
      } else {
        await _createAttemptOfflineFirst(config);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start attempt: ${e.toString()}',
      );
    }
  }

  Future<void> _createAttemptOfflineFirst(AttemptConfig config) async {
    await _checkAndHandleExistingAttempts(config);

    try {
      final now = DateTime.now();
      final localAttempt = StudentAttempt(
        id: const Uuid().v4(),
        paperId: _paperId!,
        mode: config.mode,
        enableHints: config.enableHints,
        startedAt: now,
        timerStartedAt: config.isExamMode ? now : null,
        needsSync: true,
      );

      await _repository.upsert<StudentAttempt>(localAttempt);

      final updatedUserAttempts = [localAttempt, ...state.userAttempts];
      state = state.copyWith(userAttempts: updatedUserAttempts);

      await _loadCompleteAttemptDataOfflineFirst(localAttempt, config);

      unawaited(_syncCreateAttemptWithServer(config, localAttempt.id));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create attempt: ${e.toString()}',
      );
    }
  }

  Future<void> _resumeAttemptOfflineFirst(String attemptId) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>(
        query: Query.where('id', attemptId, limit1: true),
      );

      if (localAttempts.isEmpty) {
        throw Exception('Attempt not found locally');
      }

      final localAttempt = localAttempts.first;

      final config = AttemptConfig(
        paperId: _paperId!,
        mode: localAttempt.mode,
        enableHints: localAttempt.enableHints,
      );

      await _loadCompleteAttemptDataOfflineFirst(localAttempt, config);
      await _loadExistingStepStatusesOfflineFirst(attemptId);

      if (localAttempt.isExamMode && !localAttempt.isCompleted) {
        _setupResumedTimer(localAttempt);
      }

      _syncResumeAttemptWithServer(attemptId);
    } catch (e) {
      throw Exception('Failed to resume attempt: ${e.toString()}');
    }
  }

  Future<void> _loadCompleteAttemptDataOfflineFirst(
      StudentAttempt attempt, AttemptConfig config) async {
    await _loadPaperMetadata();

    if (state.paper == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load paper data',
      );
      return;
    }

    await _preloadAllPages();
    await _repository.upsert<StudentAttempt>(attempt);

    final memoEnabled = config.isPracticeMode || attempt.isCompleted;

    state = state.copyWith(
      currentAttempt: attempt,
      isLoading: false,
      memoEnabled: memoEnabled,
      showHints: config.enableHints,
    );

    if (attempt.isExamMode && !attempt.isCompleted) {
      if (attempt.lastActivityAt != null &&
          attempt.lastActivityAt!
              .isAfter(attempt.startedAt.add(const Duration(minutes: 1)))) {
        resumeExamTimer();
      } else {
        final remaining = _calculateRemainingSeconds(attempt);
        state = state.copyWith(
          remainingSeconds: remaining,
          timerStartedAt: attempt.startedAt,
        );
        if (remaining > 0) {
          _startTimerCountdown();
        } else {
          _handleTimerExpired();
        }
      }
    }

    await loadProgressOfflineFirst();
  }

  Future<void> _loadPaperMetadata() async {
    if (_paperId == null) return;

    try {
      await _loadPaperFromLocal();
      _syncPaperWithServer();
    } catch (e) {
      state = state.copyWith(error: 'Failed to load paper: $e');
    }
  }

  Future<void> _loadPaperFromLocal() async {
    try {
      final localPapers = await _repository.get<ExamPaper>(
        query: Query.where('id', _paperId!, limit1: true),
      );

      if (localPapers.isNotEmpty) {
        state = state.copyWith(paper: localPapers.first);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _syncPaperWithServer() async {
    try {
      final getPaperUseCase = _ref.read(getPaperUseCaseProvider);
      final result = await getPaperUseCase(_paperId!, includeSolutions: false);

      if (result.isSuccess) {
        final serverPaper = result.data!;
        await _repository.upsert<ExamPaper>(serverPaper);
        state = state.copyWith(paper: serverPaper, isOffline: false);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _preloadAllPages() async {
    if (state.paper == null || _paperId == null) return;

    try {
      await _loadQuestionsFromLocal();
      _syncQuestionsWithServer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load questions: $e',
      );
    }
  }

  Future<void> _loadQuestionsFromLocal() async {
    try {
      final localQuestions = await _repository.get<Question>(
        query: Query(where: [
          const Where('paperId').isExactly(_paperId!),
          const Where('isActive').isExactly(true),
        ]),
      );

      if (localQuestions.isNotEmpty) {
        // OPTIMIZATION: Build questions map in single pass
        final questionsByPage = <int, List<Question>>{};
        var maxPage = 1;

        for (final question in localQuestions) {
          final pageNumber = question.pageNumber;
          (questionsByPage[pageNumber] ??= []).add(question);
          maxPage = max(maxPage, pageNumber);
        }

        // OPTIMIZATION: Sort all pages at once
        for (final pageQuestions in questionsByPage.values) {
          pageQuestions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }

        questionsByPage.removeWhere((page, questions) => questions.isEmpty);

        state = state.copyWith(
          allPagesQuestions: questionsByPage,
          totalPages: maxPage,
        );

        _setInitialPage(state.currentPage, maxPage);
        return;
      }

      state = state.copyWith(
        allPagesQuestions: {},
        totalPages: 1,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        allPagesQuestions: {},
        totalPages: 1,
        currentPage: 1,
      );
    }
  }

  Future<void> _syncQuestionsWithServer() async {
    if (state.isOffline) return;

    try {
      final getPaperPageUseCase = _ref.read(getPaperPageUseCaseProvider);

      final firstPageResult =
          await getPaperPageUseCase(_paperId!, 1, includeSolutions: true);

      if (firstPageResult.isSuccess) {
        final pageData = firstPageResult.data!;
        final totalPages = pageData['totalPages'] as int;
        final firstPageQuestions = pageData['questions'] as List<Question>;

        final updatedPages =
            Map<int, List<Question>>.from(state.allPagesQuestions);
        if (firstPageQuestions.isNotEmpty) {
          updatedPages[1] = firstPageQuestions;
        }

        state = state.copyWith(
          allPagesQuestions: updatedPages,
          totalPages: totalPages,
          isOffline: false,
        );

        // OPTIMIZATION: Save first page questions in parallel
        await Future.wait(
            firstPageQuestions.map((q) => _repository.upsert<Question>(q)));

        _setInitialPage(1, totalPages);
        _loadRemainingPagesInBackground(totalPages);
      }
    } catch (e) {
      state = state.copyWith(isOffline: true);
    }
  }

  Future<void> _loadRemainingPagesInBackground(int totalPages) async {
    final getPaperPageUseCase = _ref.read(getPaperPageUseCaseProvider);

    // OPTIMIZATION: Load pages in parallel (batches of 3)
    const batchSize = 3;
    for (int i = 2; i <= totalPages; i += batchSize) {
      final futures = <Future<void>>[];
      final endIndex = min(i + batchSize, totalPages + 1);

      for (int page = i; page < endIndex; page++) {
        futures.add(_loadSinglePage(page, getPaperPageUseCase));
      }

      await Future.wait(futures);
    }
  }

  Future<void> _loadSinglePage(
      int pageNumber, dynamic getPaperPageUseCase) async {
    try {
      final pageResult = await getPaperPageUseCase(_paperId!, pageNumber,
          includeSolutions: true);

      if (pageResult.isSuccess) {
        final pageData = pageResult.data!;
        final questions = pageData['questions'] as List<Question>;

        if (questions.isNotEmpty) {
          final updatedPages =
              Map<int, List<Question>>.from(state.allPagesQuestions);
          updatedPages[pageNumber] = questions;

          state = state.copyWith(allPagesQuestions: updatedPages);

          // OPTIMIZATION: Save questions in parallel
          await Future.wait(
              questions.map((q) => _repository.upsert<Question>(q)));
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadExistingStepStatusesOfflineFirst(String attemptId) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>(
        query: Query.where('id', attemptId, limit1: true),
      );

      Map<String, String> stepStatuses = {};

      if (localAttempts.isNotEmpty &&
          localAttempts.first.stepStatuses != null) {
        stepStatuses =
            Map<String, String>.from(localAttempts.first.stepStatuses!);
      }

      state = state.copyWith(stepStatuses: stepStatuses);
    } catch (e) {
      state = state.copyWith(stepStatuses: <String, String>{});
    }
  }

  Future<void> markStep({
    required String stepId,
    required String status,
  }) async {
    if (state.currentAttempt == null) return;

    final updatedStatuses = Map<String, String>.from(state.stepStatuses);
    updatedStatuses[stepId] = status;

    final updatedAttempt = state.currentAttempt!.copyWith(
      stepStatuses: updatedStatuses,
      lastActivityAt: DateTime.now(),
    );

    state = state.copyWith(
      stepStatuses: updatedStatuses,
      currentAttempt: updatedAttempt,
      isMarkingStep: true,
    );

    try {
      await _repository.upsert<StudentAttempt>(updatedAttempt);

      final stepAttempt = StepAttempt(
        id: const Uuid().v4(),
        studentAttemptId: state.currentAttempt!.id,
        stepId: stepId,
        status: status,
        needsSync: true,
      );

      await _repository.upsert<StepAttempt>(stepAttempt);
    } catch (e) {
      state = state.copyWith(
        isMarkingStep: false,
        error: 'Failed to save step marking locally',
      );
      return;
    }

    _calculateLocalProgress();
    _syncStepToServer(stepId, status);
    state = state.copyWith(isMarkingStep: false);
  }

  Future<void> _syncStepToServer(String stepId, String status) async {
    if (state.isOffline || state.currentAttempt == null) return;

    try {
      final markStepUseCase = _ref.read(markStepUseCaseProvider);
      await markStepUseCase(
        attemptId: state.currentAttempt!.id,
        stepId: stepId,
        status: status,
      );

      final stepAttempts = await _repository.get<StepAttempt>();
      final stepAttempt = stepAttempts.firstWhere(
        (s) =>
            s.stepId == stepId &&
            s.studentAttemptId == state.currentAttempt!.id,
      );

      final syncedStep = stepAttempt.copyWith(needsSync: false);
      await _repository.upsert<StepAttempt>(syncedStep);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> loadProgressOfflineFirst() async {
    if (state.currentAttempt == null) return;
    _calculateLocalProgress();
    if (!state.isOffline) {
      _syncProgressWithServer();
    }
  }

  Future<void> _syncProgressWithServer() async {
    if (state.currentAttempt == null) return;

    try {
      final getProgressUseCase = _ref.read(getAttemptProgressUseCaseProvider);
      final result = await getProgressUseCase(state.currentAttempt!.id);

      if (result.isSuccess) {
        state = state.copyWith(progress: result.data, isOffline: false);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // OPTIMIZATION: Improved progress calculation
  void _calculateLocalProgress() {
    var totalSteps = 0;
    var markedSteps = 0;
    var correctSteps = 0;
    var totalMarks = 0;
    var earnedMarks = 0;

    for (final questions in state.allPagesQuestions.values) {
      for (final question in questions) {
        if (question.mcqOptions != null) {
          // MCQ question with direct solution steps
          for (final step in question.solutionSteps) {
            totalSteps++;
            totalMarks += step.marksForThisStep ?? 0;

            final status = state.stepStatuses[step.id];
            if (status != null && status != 'NOT_ATTEMPTED') {
              markedSteps++;
              if (status == 'CORRECT') {
                correctSteps++;
                earnedMarks += step.marksForThisStep ?? 0;
              }
            }
          }
        } else if (question.parts.isNotEmpty) {
          // Multi-part question
          for (final part in question.parts) {
            if (part.mcqOptions != null) {
              // MCQ part
              for (final step in part.solutionSteps) {
                totalSteps++;
                totalMarks += step.marksForThisStep ?? 0;

                final status = state.stepStatuses[step.id];
                if (status != null && status != 'NOT_ATTEMPTED') {
                  markedSteps++;
                  if (status == 'CORRECT') {
                    correctSteps++;
                    earnedMarks += step.marksForThisStep ?? 0;
                  }
                }
              }
            } else {
              // Regular part
              for (final step in part.solutionSteps) {
                totalSteps++;
                totalMarks += step.marksForThisStep ?? 0;

                final status = state.stepStatuses[step.id];
                if (status != null && status != 'NOT_ATTEMPTED') {
                  markedSteps++;
                  if (status == 'CORRECT') {
                    correctSteps++;
                    earnedMarks += step.marksForThisStep ?? 0;
                  }
                }
              }
            }
          }
        } else {
          // Simple question with direct solution steps
          for (final step in question.solutionSteps) {
            totalSteps++;
            totalMarks += step.marksForThisStep ?? 0;

            final status = state.stepStatuses[step.id];
            if (status != null && status != 'NOT_ATTEMPTED') {
              markedSteps++;
              if (status == 'CORRECT') {
                correctSteps++;
                earnedMarks += step.marksForThisStep ?? 0;
              }
            }
          }
        }
      }
    }

    final progress = AttemptProgress(
      attemptId: state.currentAttempt!.id,
      totalSteps: totalSteps,
      markedSteps: markedSteps,
      correctSteps: correctSteps,
      totalMarksEarned: earnedMarks,
      totalMarksPossible: totalMarks,
      percentageScore: totalMarks > 0 ? (earnedMarks / totalMarks) * 100 : 0.0,
    );

    state = state.copyWith(progress: progress);
  }

  // Timer Management
  int _calculateRemainingSeconds(StudentAttempt attempt) {
    final timerStart = attempt.timerStartedAt ?? attempt.startedAt;
    final elapsed = DateTime.now().difference(timerStart);
    final totalSeconds = (state.paper?.durationMinutes ?? 180) * 60;
    return max(0, totalSeconds - elapsed.inSeconds);
  }

  void _setupResumedTimer(StudentAttempt attempt) {
    resumeExamTimer();
  }

  void pauseExamTimer() {
    if (state.currentAttempt == null ||
        !state.currentAttempt!.isExamMode ||
        state.currentAttempt!.isCompleted) {
      return;
    }

    final now = DateTime.now();
    final updatedAttempt = state.currentAttempt!.copyWith(
      lastActivityAt: now,
      needsSync: true,
    );

    state = state.copyWith(
      currentAttempt: updatedAttempt,
      isTimerPaused: true,
    );

    _repository.upsert<StudentAttempt>(updatedAttempt);
  }

  void resumeExamTimer() {
    if (state.currentAttempt == null ||
        !state.currentAttempt!.isExamMode ||
        state.currentAttempt!.isCompleted) {
      return;
    }

    final now = DateTime.now();
    final attempt = state.currentAttempt!;

    final pauseStart = attempt.lastActivityAt ?? attempt.startedAt;
    final pauseDuration = now.difference(pauseStart);

    final originalTimerStart = attempt.timerStartedAt ?? attempt.startedAt;
    final adjustedTimerStart = originalTimerStart.add(pauseDuration);

    final updatedAttempt = attempt.copyWith(
      timerStartedAt: adjustedTimerStart,
      lastActivityAt: now,
      needsSync: true,
    );

    final newRemainingSeconds =
        state.remainingSeconds ?? _calculateRemainingSeconds(updatedAttempt);

    state = state.copyWith(
      currentAttempt: updatedAttempt,
      remainingSeconds: newRemainingSeconds,
      isTimerPaused: false,
    );

    _repository.upsert<StudentAttempt>(updatedAttempt);

    if (newRemainingSeconds > 0) {
      _startTimerCountdown();
    } else {
      _handleTimerExpired();
    }
  }

  void startTimer(int durationSeconds) {
    state = state.copyWith(
      timerStartedAt: DateTime.now(),
      remainingSeconds: durationSeconds,
    );
    _startTimerCountdown();
  }

  void _startTimerCountdown() async {
    while (state.isTimerRunning && !state.isTimeUp && !state.isTimerPaused) {
      await Future.delayed(const Duration(seconds: 1));

      if (state.isTimerPaused) {
        break;
      }

      if (state.remainingSeconds != null && state.remainingSeconds! > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds! - 1);
      } else {
        _handleTimerExpired();
        break;
      }
    }
  }

  void _handleTimerExpired() {
    state = state.copyWith(
      remainingSeconds: 0,
      memoEnabled: true,
      isTimerPaused: false,
    );
    completeAttempt(autoSubmitted: true);
  }

  // CRITICAL FIX: Completion Management
  Future<void> completeAttempt({bool autoSubmitted = false}) async {
    if (state.currentAttempt == null) return;

    state = state.copyWith(isLoading: true);

    final completedAttempt = state.currentAttempt!.copyWith(
      completedAt: DateTime.now(),
      autoSubmitted: autoSubmitted,
      needsSync: true,
    );

    await _repository.upsert<StudentAttempt>(completedAttempt);

    // CRITICAL: Update the userAttempts list with completed attempt
    final updatedUserAttempts = state.userAttempts.map((attempt) {
      if (attempt.id == completedAttempt.id) {
        return completedAttempt;
      }
      return attempt;
    }).toList();

    state = state.copyWith(
      currentAttempt: completedAttempt,
      userAttempts: updatedUserAttempts,
      isLoading: false,
      memoEnabled: true,
    );

    _syncCompletedAttemptToServer(completedAttempt, autoSubmitted);
  }

  Future<void> _syncCompletedAttemptToServer(
      StudentAttempt attempt, bool autoSubmitted) async {
    if (state.isOffline) return;

    try {
      final completeAttemptUseCase = _ref.read(completeAttemptUseCaseProvider);
      final result = await completeAttemptUseCase(
        attemptId: attempt.id,
        autoSubmitted: autoSubmitted,
      );

      if (result.isSuccess) {
        final serverAttempt = result.data!;
        final syncedAttempt = serverAttempt.copyWith(
          timerStartedAt: attempt.timerStartedAt,
          lastActivityAt: attempt.lastActivityAt,
          needsSync: false,
        );

        await _repository.upsert<StudentAttempt>(syncedAttempt);

        // CRITICAL: Update userAttempts list with synced attempt
        final updatedUserAttempts = state.userAttempts.map((a) {
          if (a.id == syncedAttempt.id) {
            return syncedAttempt;
          }
          return a;
        }).toList();

        state = state.copyWith(
          currentAttempt: syncedAttempt,
          userAttempts: updatedUserAttempts,
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _syncCreateAttemptWithServer(
      AttemptConfig config, String localAttemptId) async {
    try {
      final createAttemptUseCase = _ref.read(createAttemptUseCaseProvider);
      final result = await createAttemptUseCase(config);

      if (result.isSuccess) {
        final serverAttempt = result.data!.attempt;

        final localAttempts = await _repository.get<StudentAttempt>(
          query: Query.where('id', localAttemptId, limit1: true),
        );

        if (localAttempts.isNotEmpty) {
          await _repository.delete<StudentAttempt>(localAttempts.first);
        }

        final updatedAttempt = serverAttempt.copyWith(
          stepStatuses: state.currentAttempt?.stepStatuses ?? {},
          needsSync: false,
        );

        await _repository.upsert<StudentAttempt>(updatedAttempt);

        final updatedUserAttempts =
            state.userAttempts.where((a) => a.id != localAttemptId).toList();
        updatedUserAttempts.insert(0, updatedAttempt);

        state = state.copyWith(
          currentAttempt: updatedAttempt,
          userAttempts: updatedUserAttempts,
          isOffline: false,
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _syncResumeAttemptWithServer(String attemptId) async {
    try {
      final getAttemptUseCase = _ref.read(getAttemptUseCaseProvider);
      final result = await getAttemptUseCase(attemptId);

      if (result.isSuccess) {
        final serverAttempt = result.data!;

        final mergedStepStatuses = {
          ...state.stepStatuses,
          if (serverAttempt.stepStatuses != null)
            ...Map<String, String>.from(serverAttempt.stepStatuses!),
        };

        final updatedAttempt = serverAttempt.copyWith(
          stepStatuses: mergedStepStatuses,
          timerStartedAt: state.currentAttempt?.timerStartedAt ??
              serverAttempt.timerStartedAt,
          lastActivityAt: state.currentAttempt?.lastActivityAt ??
              serverAttempt.lastActivityAt,
        );

        await _repository.upsert<StudentAttempt>(updatedAttempt);

        state = state.copyWith(
          currentAttempt: updatedAttempt,
          stepStatuses: mergedStepStatuses,
          isOffline: false,
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _checkAndHandleExistingAttempts(AttemptConfig config) async {
    if (_paperId == null) return;

    try {
      final allAttempts = await _repository.get<StudentAttempt>();
      final incompleteAttempts = allAttempts
          .where((attempt) =>
              attempt.paperId == _paperId &&
              attempt.completedAt == null &&
              attempt.mode == config.mode)
          .toList();

      // OPTIMIZATION: Complete all incomplete attempts in parallel
      if (incompleteAttempts.isNotEmpty) {
        await Future.wait(incompleteAttempts.map((existingAttempt) async {
          final completedAttempt = existingAttempt.copyWith(
            completedAt: DateTime.now(),
            autoSubmitted: true,
            needsSync: true,
          );
          await _repository.upsert<StudentAttempt>(completedAttempt);

          if (!state.isOffline) {
            try {
              final completeAttemptUseCase =
                  _ref.read(completeAttemptUseCaseProvider);
              await completeAttemptUseCase(
                attemptId: existingAttempt.id,
                autoSubmitted: true,
              );
            } catch (e) {
              // Silent fail
            }
          }
        }));
      }
    } catch (e) {
      await _createOfflineAttempt(config);
    }
  }

  Future<void> _createOfflineAttempt(AttemptConfig config) async {
    if (_paperId == null) return;

    final now = DateTime.now();
    final offlineAttempt = StudentAttempt(
      id: const Uuid().v4(),
      paperId: _paperId!,
      mode: config.mode,
      enableHints: config.enableHints,
      startedAt: now,
      timerStartedAt: config.isExamMode ? now : null,
      needsSync: true,
    );

    await _repository.upsert<StudentAttempt>(offlineAttempt);
    await _loadCompleteAttemptDataOfflineFirst(offlineAttempt, config);
  }

  Future<void> loadProgress() async {
    await loadProgressOfflineFirst();
  }

  void goToPage(int page) {
    if (state.allDisplayPages.contains(page)) {
      state = state.copyWith(currentPage: page);
    }
  }

  void goToPreviousPage() {
    final prevPage = state.previousPage;
    if (prevPage != null) {
      goToPage(prevPage);
    }
  }

  void goToNextPage() {
    final nextPage = state.nextPage;
    if (nextPage != null) {
      goToPage(nextPage);
    }
  }

  void _setInitialPage(int serverCurrentPage, int serverTotalPages) {
    state = state.copyWith(totalPages: serverTotalPages);

    if (state.allPagesQuestions.containsKey(serverCurrentPage) &&
        state.allPagesQuestions[serverCurrentPage]!.isNotEmpty) {
      state = state.copyWith(currentPage: serverCurrentPage);
    } else if (state.availableServerPages.isNotEmpty) {
      state = state.copyWith(currentPage: state.availableServerPages.first);
    } else {
      state = state.copyWith(currentPage: 1);
    }
  }

  void switchTab(String tab) {
    if (tab == 'memo' && !state.memoEnabled) return;
    state = state.copyWith(currentTab: tab);
  }

  void toggleHints() {
    if (state.isPracticeMode) {
      state = state.copyWith(showHints: !state.showHints);
    }
  }

  void toggleSolutionExpansion(String questionPartId) {
    final expanded = Map<String, bool>.from(state.expandedSolutions);
    expanded[questionPartId] = !(expanded[questionPartId] ?? false);
    state = state.copyWith(expandedSolutions: expanded);
  }

  void enableMemo() {
    state = state.copyWith(memoEnabled: true);
  }

  Future<void> loadMoreAttempts() async {
    if (!state.hasNextAttemptsPage || state.isLoadingMoreAttempts) return;
    final nextPage = state.currentAttemptsPage + 1;
    await loadUserAttempts(page: nextPage, refresh: false);
  }

  Future<void> refreshAttempts() async {
    await loadUserAttempts(page: 1, refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearUserAttemptsError() {
    state = state.copyWith(userAttemptsError: null);
  }

  Future<void> syncWhenOnline() async {
    if (state.isOffline) {
      await _syncPendingChangesToServer();
      await loadUserAttempts(page: 1, refresh: true);
    }
  }
}

void unawaited(Future<void> future) {
  future.catchError((error) {
    // Silent fail
  });
}
