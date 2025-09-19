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
    try {
      final newState = AttemptsState(
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

      return newState;
    } catch (e) {
      rethrow;
    }
  }

  bool get isExamMode => currentAttempt?.mode == 'EXAM';
  bool get isPracticeMode => currentAttempt?.mode == 'PRACTICE';
  bool get canShowHints => isPracticeMode && showHints;
  List<Question> get currentPageQuestions =>
      allPagesQuestions[currentPage] ?? [];
  bool get canGoToPreviousPage => currentPage > 1;
  bool get canGoToNextPage => currentPage < totalPages;
  bool get isTimerRunning =>
      timerStartedAt != null &&
      remainingSeconds != null &&
      remainingSeconds! > 0 &&
      !isTimerPaused;
  bool get isTimeUp =>
      isExamMode && remainingSeconds != null && remainingSeconds! <= 0;

  String getStepStatus(String stepId) =>
      stepStatuses[stepId] ?? 'NOT_ATTEMPTED';
}

class AttemptsController extends StateNotifier<AttemptsState> {
  final Ref _ref;
  final String? _paperId;
  final Repository _repository = Repository.instance;
  bool _connectivityListenerSetup = false;

  AttemptsController(this._ref, this._paperId) : super(const AttemptsState());

  // User Attempts Management - Following Papers Pattern
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

  Future<void> _loadUserAttemptsFromLocal(int page, bool refresh) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      localAttempts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      final papersCache = <String, ExamPaper>{};
      final allPapers = await _repository.get<ExamPaper>();

      for (final paper in allPapers) {
        papersCache[paper.id] = paper;
      }

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

      print('Loaded ${combinedAttempts.length} attempts from local database');
    } catch (e) {
      state = state.copyWith(
        isLoadingUserAttempts: false,
        isLoadingMoreAttempts: false,
        isInitialized: true,
      );
    }
  }

  Future<void> _syncUserAttemptsWithServer(int page, bool refresh) async {
    // Check connectivity first
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

        for (final attempt in response.attempts) {
          await _repository.upsert<StudentAttempt>(attempt);
        }

        final updatedPapersCache = {...state.papersCache, ...response.papers};

        final Map<String, StudentAttempt> attemptMap = {};

        if (refresh) {
          for (final attempt in response.attempts) {
            attemptMap[attempt.id] = attempt;
          }
        } else {
          for (final attempt in state.userAttempts) {
            attemptMap[attempt.id] = attempt;
          }
          for (final attempt in response.attempts) {
            attemptMap[attempt.id] = attempt;
          }
        }

        final combinedAttempts = attemptMap.values.toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        final finalAttempts = combinedAttempts.length > response.totalCount
            ? combinedAttempts.take(response.totalCount).toList()
            : combinedAttempts;

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
      final serverAttemptIds = serverAttempts.map((a) => a.id).toSet();

      final attemptsToDelete = localAttempts
          .where((local) =>
              !serverAttemptIds.contains(local.id) && !local.needsSync)
          .toList();

      for (final attempt in attemptsToDelete) {
        await _repository.delete<StudentAttempt>(attempt);

        final stepAttempts = await _repository.get<StepAttempt>();
        final associatedSteps = stepAttempts
            .where((step) => step.studentAttemptId == attempt.id)
            .toList();

        for (final step in associatedSteps) {
          await _repository.delete<StepAttempt>(step);
        }
      }
    } catch (e) {
      print('Failed to sync attempt deletions: $e');
    }
  }

  Future<void> _processAttemptsInBackground(
      List<StudentAttempt> attempts, Map<String, ExamPaper> papers) async {
    try {
      final localAttempts = await _repository.get<StudentAttempt>();
      final merged = <String, StudentAttempt>{};

      for (final local in localAttempts) {
        merged[local.id] = local;
      }

      for (final server in attempts) {
        merged[server.id] = server;
        await _repository.upsert<StudentAttempt>(server);
      }

      for (final paper in papers.values) {
        await _repository.upsert<ExamPaper>(paper);
      }

      final sortedAttempts = merged.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      state = state.copyWith(
        userAttempts: sortedAttempts,
        papersCache: {...state.papersCache, ...papers},
      );

      await _syncPendingChangesToServer();
    } catch (e) {
      // Background processing failed - UI already shows server data
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
      // Sync will retry next time
    }
  }

  // Attempt Management - Offline First Pattern
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
      await _loadCompleteAttemptDataOfflineFirst(null, config);
      _syncCreateAttemptWithServer(config);
    } catch (e) {
      await _createOfflineAttempt(config);
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
      StudentAttempt? attempt, AttemptConfig config) async {
    await _loadPaperMetadata();

    if (state.paper == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load paper data',
      );
      return;
    }

    await _preloadAllPages();

    if (attempt == null) {
      final now = DateTime.now();
      attempt = StudentAttempt(
        id: const Uuid().v4(),
        paperId: _paperId!,
        mode: config.mode,
        enableHints: config.enableHints,
        startedAt: now,
        timerStartedAt: config.isExamMode ? now : null,
        needsSync: true,
      );
      await _repository.upsert<StudentAttempt>(attempt);
    }

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

  // Paper and Questions Loading - Offline First
  Future<void> _loadPaperMetadata() async {
    if (_paperId == null) return;

    try {
      await _loadPaperFromLocal();
      _syncPaperWithServer();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load paper: $e',
      );
    }
  }

  Future<void> _loadPaperFromLocal() async {
    try {
      final localPapers = await _repository.get<ExamPaper>(
        query: Query.where('id', _paperId!, limit1: true),
      );

      if (localPapers.isNotEmpty) {
        final localPaper = localPapers.first;
        state = state.copyWith(
          paper: localPaper,
        );
        print('Loaded paper from local database: ${localPaper.title}');
      } else {
        print('No local paper found with id $_paperId');
      }
    } catch (e) {
      print('Error loading paper from local: $e');
    }
  }

  Future<void> _syncPaperWithServer() async {
    try {
      final getPaperUseCase = _ref.read(getPaperUseCaseProvider);
      final result = await getPaperUseCase(_paperId!, includeSolutions: false);

      if (result.isSuccess) {
        final serverPaper = result.data!;
        await _repository.upsert<ExamPaper>(serverPaper);

        state = state.copyWith(
          paper: serverPaper,
          isOffline: false,
        );

        print('Synced paper with server: ${serverPaper.title}');
      } else {
        print('Failed to sync paper with server: ${result.error}');
        state = state.copyWith();
      }
    } catch (e) {
      print('Error syncing paper with server: $e');
      state = state.copyWith();
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
        print('Loaded ${localQuestions.length} questions from local database');

        final questionsByPage = <int, List<Question>>{};
        int maxPage = 1;

        for (final question in localQuestions) {
          final pageNumber = question.pageNumber;
          questionsByPage[pageNumber] ??= [];
          questionsByPage[pageNumber]!.add(question);
          maxPage = max(maxPage, pageNumber);
        }

        // Sort questions within each page by orderIndex
        for (final pageQuestions in questionsByPage.values) {
          pageQuestions.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }

        state = state.copyWith(
          allPagesQuestions: questionsByPage,
          totalPages: maxPage,
        );

        print('Organized questions into $maxPage pages offline');
        return;
      }

      print('No local questions found for paper $_paperId');
      state = state.copyWith(
        allPagesQuestions: {},
        totalPages: 1,
      );
    } catch (e) {
      print('Error loading questions from local: $e');
      state = state.copyWith(
        allPagesQuestions: {},
        totalPages: 1,
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
        final allPages = <int, List<Question>>{};

        allPages[1] = pageData['questions'] as List<Question>;

        for (final question in allPages[1]!) {
          await _repository.upsert<Question>(question);
        }

        for (int page = 2; page <= totalPages; page++) {
          final pageResult = await getPaperPageUseCase(_paperId!, page,
              includeSolutions: true);
          if (pageResult.isSuccess) {
            final pageData = pageResult.data!;
            allPages[page] = pageData['questions'] as List<Question>;

            for (final question in allPages[page]!) {
              await _repository.upsert<Question>(question);
            }
          }
        }

        state = state.copyWith(
          allPagesQuestions: allPages,
          totalPages: totalPages,
          isOffline: false,
        );

        print('Loaded and cached ${allPages.length} pages from server');
      } else {
        print('Failed to sync questions with server: ${firstPageResult.error}');
        state = state.copyWith();
      }
    } catch (e) {
      print('Error syncing questions with server: $e');
      state = state.copyWith();
    }
  }

  // Step Status Management - Offline First
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

      print('Loaded ${stepStatuses.length} step statuses from local database');
    } catch (e) {
      print('Error loading step statuses offline: $e');
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
      state = state.copyWith();
    }
  }

  // Progress Management - Offline First
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
        state = state.copyWith(
          progress: result.data,
          isOffline: false,
        );
        print('Successfully synced progress with server');
      } else {
        print('Failed to sync progress: ${result.error}');
      }
    } catch (e) {
      print('Error syncing progress: $e');
    }
  }

  void _calculateLocalProgress() {
    int totalSteps = 0;
    int markedSteps = 0;
    int correctSteps = 0;
    int totalMarks = 0;
    int earnedMarks = 0;

    for (final questions in state.allPagesQuestions.values) {
      for (final question in questions) {
        // Handle multi-part questions
        for (final part in question.parts) {
          for (final step in part.solutionSteps) {
            totalSteps++;
            totalMarks += step.marksForThisStep ?? 0; // Handle null

            final status = state.stepStatuses[step.id];
            if (status != null && status != 'NOT_ATTEMPTED') {
              markedSteps++;
              if (status == 'CORRECT') {
                correctSteps++;
                earnedMarks += step.marksForThisStep ?? 0; // Handle null
              }
            }
          }
        }

        // Handle simple questions with direct solution steps
        for (final step in question.solutionSteps) {
          totalSteps++;
          totalMarks += step.marksForThisStep ?? 0; // Handle null

          final status = state.stepStatuses[step.id];
          if (status != null && status != 'NOT_ATTEMPTED') {
            markedSteps++;
            if (status == 'CORRECT') {
              correctSteps++;
              earnedMarks += step.marksForThisStep ?? 0; // Handle null
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

  // Background Server Sync Methods
  Future<void> _syncCreateAttemptWithServer(AttemptConfig config) async {
    try {
      final createAttemptUseCase = _ref.read(createAttemptUseCaseProvider);
      final result = await createAttemptUseCase(config);

      if (result.isSuccess) {
        final serverAttempt = result.data!.attempt;

        final updatedAttempt = state.currentAttempt!.copyWith(
          id: serverAttempt.id,
          needsSync: false,
        );

        await _repository.upsert<StudentAttempt>(updatedAttempt);

        state = state.copyWith(
          currentAttempt: updatedAttempt,
          isOffline: false,
        );

        print('Successfully synced new attempt with server');
      } else {
        print('Failed to sync attempt with server: ${result.error}');
        state = state.copyWith();
      }
    } catch (e) {
      print('Error syncing attempt with server: $e');
      state = state.copyWith();
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

        print('Successfully synced resumed attempt with server');
      } else {
        print('Failed to sync resumed attempt: ${result.error}');
        state = state.copyWith();
      }
    } catch (e) {
      print('Error syncing resumed attempt: $e');
      state = state.copyWith();
    }
  }

  // Existing Attempts Management (preserved for compatibility)
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

      for (final existingAttempt in incompleteAttempts) {
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
            // Ignore sync errors
          }
        }
      }
    } catch (e) {
      // Only create offline attempt if server sync fails
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
    state = state.copyWith();
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
    print('Exam timer paused at: ${now.toIso8601String()}');
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

    print('Exam timer resumed. Paused for: ${pauseDuration.inMinutes} minutes');
    print('New remaining time: $newRemainingSeconds seconds');
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
        print('Timer countdown stopped - paused');
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

  // Navigation and UI Management
  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void goToPreviousPage() {
    if (state.canGoToPreviousPage) {
      goToPage(state.currentPage - 1);
    }
  }

  void goToNextPage() {
    if (state.canGoToNextPage) {
      goToPage(state.currentPage + 1);
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

  // Completion Management
  Future<void> completeAttempt({bool autoSubmitted = false}) async {
    if (state.currentAttempt == null) return;

    state = state.copyWith(isLoading: true);

    final completedAttempt = state.currentAttempt!.copyWith(
      completedAt: DateTime.now(),
      autoSubmitted: autoSubmitted,
      needsSync: true,
    );

    await _repository.upsert<StudentAttempt>(completedAttempt);

    state = state.copyWith(
      currentAttempt: completedAttempt,
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
        state = state.copyWith(currentAttempt: syncedAttempt);

        print('Completed attempt synced to server successfully');
      } else {
        print('Failed to sync completed attempt: ${result.error}');
      }
    } catch (e) {
      print('Error syncing completed attempt: $e');
      state = state.copyWith();
    }
  }

  // Utility Methods
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

  // Legacy method for compatibility
  Future<void> loadProgress() async {
    await loadProgressOfflineFirst();
  }
}

void unawaited(Future<void> future) {
  future.catchError((error) {
    print('Background operation failed: $error');
  });
}
