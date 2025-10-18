// lib/features/papers/presentation/controllers/papers_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import '../../../../brick/models/exam_paper.model.dart';
import '../../../../brick/models/paper_filters.model.dart';
import '../../domain/providers/papers_use_case_providers.dart';
import '../../../../brick/repository.dart';

// New class to track paper availability per mode
class PaperAvailability {
  final ExamPaper paper;
  final bool canStartPractice;
  final bool canStartExam;
  final int practiceAttempts;
  final int examAttempts;

  const PaperAvailability({
    required this.paper,
    required this.canStartPractice,
    required this.canStartExam,
    required this.practiceAttempts,
    required this.examAttempts,
  });

  bool get hasAnyAvailability => canStartPractice || canStartExam;
}

class PapersState {
  final List<PaperAvailability> paperAvailabilities;
  final PaperFilters? filters;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingFilters;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final String? searchQuery;
  final Map<String, dynamic> activeFilters;
  final bool isOffline;
  final int totalAvailablePapers;
  final int serverTotalCount;

  const PapersState({
    this.paperAvailabilities = const [],
    this.filters,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isLoadingFilters = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.searchQuery,
    this.activeFilters = const {},
    this.isOffline = false,
    this.totalAvailablePapers = 0,
    this.serverTotalCount = 0,
  });

  List<ExamPaper> get papers =>
      paperAvailabilities.map((pa) => pa.paper).toList();

  PapersState copyWith({
    List<PaperAvailability>? paperAvailabilities,
    PaperFilters? filters,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingFilters,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
    String? searchQuery,
    Map<String, dynamic>? activeFilters,
    bool? isOffline,
    int? totalAvailablePapers,
    int? serverTotalCount,
  }) {
    return PapersState(
      paperAvailabilities: paperAvailabilities ?? this.paperAvailabilities,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      isOffline: isOffline ?? this.isOffline,
      totalAvailablePapers: totalAvailablePapers ?? this.totalAvailablePapers,
      serverTotalCount: serverTotalCount ?? this.serverTotalCount,
    );
  }
}

class PapersController extends StateNotifier<PapersState> {
  final Ref _ref;
  final Repository _repository = Repository.instance;
  bool _connectivityListenerSetup = false;

  PapersController(this._ref) : super(const PapersState());

  Future<void> loadPapers({bool refresh = false}) async {
    if (!_connectivityListenerSetup) {
      _setupConnectivityListener();
      _connectivityListenerSetup = true;
    }

    if (refresh) {
      state = state.copyWith(
          isLoading: true,
          error: null,
          paperAvailabilities: [],
          currentPage: 1);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      await _ensureUserAttemptsLoaded();
      await _loadPapersFromLocal(refresh);
      _syncPapersWithServer(refresh);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load papers: $e',
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

  Future<void> _ensureUserAttemptsLoaded() async {
    final attemptsController =
        _ref.read(userAttemptsControllerProvider.notifier);
    final attemptsState = _ref.read(userAttemptsControllerProvider);

    if (attemptsState.userAttempts.isEmpty && !attemptsState.isInitialized) {
      await attemptsController.loadUserAttempts();
    }
  }

  Future<void> _loadPapersFromLocal(bool refresh) async {
    try {
      // OPTIMIZATION: Load data in parallel
      final results = await Future.wait([
        _repository.get<ExamPaper>(),
        Future.value(_ref.read(userAttemptsControllerProvider)),
      ]);

      final localPapers = results[0] as List<ExamPaper>;
      final attemptsState = results[1] as dynamic;

      // OPTIMIZATION: Build attempt counts map once
      final attemptCounts = <String, Map<String, int>>{};
      for (final attempt in attemptsState.userAttempts) {
        final paperId = attempt.paperId;
        final mode = attempt.mode;
        attemptCounts.putIfAbsent(paperId, () => {'PRACTICE': 0, 'EXAM': 0});
        attemptCounts[paperId]![mode] =
            (attemptCounts[paperId]![mode] ?? 0) + 1;
      }

      // OPTIMIZATION: Process in batches to avoid blocking UI
      const batchSize = 50;
      final allPaperAvailabilities = <PaperAvailability>[];

      for (int i = 0; i < localPapers.length; i += batchSize) {
        final endIndex = (i + batchSize).clamp(0, localPapers.length);
        final batch = localPapers.sublist(i, endIndex);

        for (final paper in batch) {
          if (!_matchesFilters(paper)) continue;

          final counts = attemptCounts[paper.id] ?? {'PRACTICE': 0, 'EXAM': 0};
          final practiceAttempts = counts['PRACTICE'] ?? 0;
          final examAttempts = counts['EXAM'] ?? 0;

          final canStartPractice = practiceAttempts < 1;
          final canStartExam = examAttempts < 1;

          if (canStartPractice || canStartExam) {
            allPaperAvailabilities.add(PaperAvailability(
              paper: paper,
              canStartPractice: canStartPractice,
              canStartExam: canStartExam,
              practiceAttempts: practiceAttempts,
              examAttempts: examAttempts,
            ));
          }
        }

        // OPTIMIZATION: Yield to UI thread between batches
        if (i + batchSize < localPapers.length) {
          await Future.delayed(Duration.zero);
        }
      }

      // OPTIMIZATION: Sort once at the end
      allPaperAvailabilities
          .sort((a, b) => b.paper.year.compareTo(a.paper.year));

      // Calculate pagination
      const pageSize = 10;
      final totalAvailable = allPaperAvailabilities.length;
      final totalPages = (totalAvailable / pageSize).ceil();

      final startIndex = refresh ? 0 : (state.currentPage - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalAvailable);

      final pageAvailabilities =
          allPaperAvailabilities.sublist(startIndex, endIndex);

      final combinedAvailabilities = refresh
          ? pageAvailabilities
          : [...state.paperAvailabilities, ...pageAvailabilities];

      state = state.copyWith(
        paperAvailabilities: combinedAvailabilities,
        totalPages: totalPages,
        hasNextPage: endIndex < totalAvailable,
        totalAvailablePapers: totalAvailable,
        serverTotalCount: localPapers.length,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      print('Error loading papers: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> _syncPapersWithServer(bool refresh) async {
    if (state.isOffline) return;

    try {
      final getPapersUseCase = _ref.read(getPapersUseCaseProvider);

      if (refresh) {
        final allPapersResult = await getPapersUseCase();
        if (allPapersResult.isSuccess) {
          await _syncPaperDeletions(allPapersResult.data!.papers);
        }
      }

      final result = await getPapersUseCase(
        subject: state.activeFilters['subject'],
        grade: state.activeFilters['grade'],
        syllabus: state.activeFilters['syllabus'],
        year: state.activeFilters['year'],
        paperType: state.activeFilters['paperType'],
        examPeriod: state.activeFilters['examPeriod'],
        province: state.activeFilters['province'],
        search: state.searchQuery,
        page: refresh ? 1 : state.currentPage + 1,
        limit: 10,
        sortBy: 'year',
        sortType: 'desc',
      );

      if (result.isSuccess) {
        final response = result.data!;

        // OPTIMIZATION: Save papers in parallel
        await Future.wait(response.papers
            .map((paper) => _repository.upsert<ExamPaper>(paper)));

        final attemptsState = _ref.read(userAttemptsControllerProvider);
        final attemptCounts = <String, Map<String, int>>{};

        for (final attempt in attemptsState.userAttempts) {
          final paperId = attempt.paperId;
          final mode = attempt.mode;
          attemptCounts.putIfAbsent(paperId, () => {'PRACTICE': 0, 'EXAM': 0});
          attemptCounts[paperId]![mode] =
              (attemptCounts[paperId]![mode] ?? 0) + 1;
        }

        final newAvailabilities = <PaperAvailability>[];

        for (final paper in response.papers) {
          final counts = attemptCounts[paper.id] ?? {'PRACTICE': 0, 'EXAM': 0};
          final practiceAttempts = counts['PRACTICE'] ?? 0;
          final examAttempts = counts['EXAM'] ?? 0;

          final canStartPractice = practiceAttempts < 1;
          final canStartExam = examAttempts < 1;

          if (canStartPractice || canStartExam) {
            newAvailabilities.add(PaperAvailability(
              paper: paper,
              canStartPractice: canStartPractice,
              canStartExam: canStartExam,
              practiceAttempts: practiceAttempts,
              examAttempts: examAttempts,
            ));
          }
        }

        final finalAvailabilities = refresh
            ? newAvailabilities
            : [...state.paperAvailabilities, ...newAvailabilities];

        final availabilityRatio = response.papers.isNotEmpty
            ? newAvailabilities.length / response.papers.length
            : 1.0;
        final estimatedTotalAvailable =
            (response.totalCount * availabilityRatio).round();

        state = state.copyWith(
          paperAvailabilities: finalAvailabilities,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasNextPage: response.currentPage < response.totalPages,
          totalAvailablePapers:
              refresh ? estimatedTotalAvailable : state.totalAvailablePapers,
          serverTotalCount: response.totalCount,
          isLoading: false,
          isLoadingMore: false,
          isOffline: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> _syncPaperDeletions(List<ExamPaper> serverPapers) async {
    try {
      final localPapers = await _repository.get<ExamPaper>();
      final serverPaperIds = {for (var p in serverPapers) p.id};

      final papersToDelete = localPapers
          .where((local) => !serverPaperIds.contains(local.id))
          .toList();

      // OPTIMIZATION: Delete in parallel
      if (papersToDelete.isNotEmpty) {
        await Future.wait(papersToDelete
            .map((paper) => _repository.delete<ExamPaper>(paper)));

        print(
            'PapersController: Deleted ${papersToDelete.length} papers from local storage');
        await _refreshPaperAvailabilities();
      }
    } catch (e) {
      print('Failed to sync paper deletions: $e');
    }
  }

  Future<void> _refreshPaperAvailabilities() async {
    try {
      // OPTIMIZATION: Load data in parallel
      final results = await Future.wait([
        _repository.get<ExamPaper>(),
        Future.value(_ref.read(userAttemptsControllerProvider)),
      ]);

      final localPapers = results[0] as List<ExamPaper>;
      final attemptsState = results[1] as dynamic;

      final attemptCounts = <String, Map<String, int>>{};
      for (final attempt in attemptsState.userAttempts) {
        final paperId = attempt.paperId;
        final mode = attempt.mode;
        attemptCounts.putIfAbsent(paperId, () => {'PRACTICE': 0, 'EXAM': 0});
        attemptCounts[paperId]![mode] =
            (attemptCounts[paperId]![mode] ?? 0) + 1;
      }

      final updatedAvailabilities = <PaperAvailability>[];
      for (final paper in localPapers) {
        if (!_matchesFilters(paper)) continue;

        final counts = attemptCounts[paper.id] ?? {'PRACTICE': 0, 'EXAM': 0};
        final practiceAttempts = counts['PRACTICE'] ?? 0;
        final examAttempts = counts['EXAM'] ?? 0;

        final canStartPractice = practiceAttempts < 1;
        final canStartExam = examAttempts < 1;

        if (canStartPractice || canStartExam) {
          updatedAvailabilities.add(PaperAvailability(
            paper: paper,
            canStartPractice: canStartPractice,
            canStartExam: canStartExam,
            practiceAttempts: practiceAttempts,
            examAttempts: examAttempts,
          ));
        }
      }

      state = state.copyWith(paperAvailabilities: updatedAvailabilities);
    } catch (e) {
      print('Failed to refresh paper availabilities: $e');
    }
  }

  Future<void> searchPapers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchQuery: null);
      await loadPapers(refresh: true);
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      isLoading: true,
      error: null,
      paperAvailabilities: [],
      currentPage: 1,
    );

    try {
      await _ensureUserAttemptsLoaded();
      await _loadPapersFromLocal(true);
      _syncSearchWithServer(query);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  Future<void> _syncSearchWithServer(String query) async {
    if (state.isOffline) return;
    try {
      final searchUseCase = _ref.read(searchPapersUseCaseProvider);
      final result = await searchUseCase(query: query, page: 1, limit: 10);

      if (result.isSuccess) {
        final response = result.data!;

        // OPTIMIZATION: Save papers in parallel
        await Future.wait(response.papers
            .map((paper) => _repository.upsert<ExamPaper>(paper)));

        final attemptsState = _ref.read(userAttemptsControllerProvider);
        final attemptCounts = <String, Map<String, int>>{};

        for (final attempt in attemptsState.userAttempts) {
          final paperId = attempt.paperId;
          final mode = attempt.mode;
          attemptCounts.putIfAbsent(paperId, () => {'PRACTICE': 0, 'EXAM': 0});
          attemptCounts[paperId]![mode] =
              (attemptCounts[paperId]![mode] ?? 0) + 1;
        }

        final filteredAvailabilities = <PaperAvailability>[];

        for (final paper in response.papers) {
          final counts = attemptCounts[paper.id] ?? {'PRACTICE': 0, 'EXAM': 0};
          final practiceAttempts = counts['PRACTICE'] ?? 0;
          final examAttempts = counts['EXAM'] ?? 0;

          final canStartPractice = practiceAttempts < 1;
          final canStartExam = examAttempts < 1;

          if (canStartPractice || canStartExam) {
            filteredAvailabilities.add(PaperAvailability(
              paper: paper,
              canStartPractice: canStartPractice,
              canStartExam: canStartExam,
              practiceAttempts: practiceAttempts,
              examAttempts: examAttempts,
            ));
          }
        }

        final availabilityRatio = response.papers.isNotEmpty
            ? filteredAvailabilities.length / response.papers.length
            : 1.0;
        final estimatedAvailable =
            (response.totalCount * availabilityRatio).round();

        state = state.copyWith(
          paperAvailabilities: filteredAvailabilities,
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          hasNextPage: response.currentPage < response.totalPages,
          totalAvailablePapers: estimatedAvailable,
          serverTotalCount: response.totalCount,
          isLoading: false,
          isOffline: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void onUserAttemptsChanged() {
    print('User attempts changed, refreshing papers...');
    loadPapers(refresh: true);
  }

  bool _matchesFilters(ExamPaper paper) {
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();
      return paper.title.toLowerCase().contains(query) ||
          paper.subject.toLowerCase().contains(query);
    }

    if (state.activeFilters['subject'] != null &&
        paper.subject != state.activeFilters['subject']) {
      return false;
    }

    if (state.activeFilters['grade'] != null &&
        paper.grade != state.activeFilters['grade']) {
      return false;
    }

    if (state.activeFilters['year'] != null &&
        paper.year != state.activeFilters['year']) {
      return false;
    }

    if (state.activeFilters['paperType'] != null &&
        paper.paperType != state.activeFilters['paperType']) {
      return false;
    }

    if (state.activeFilters['examPeriod'] != null &&
        paper.examPeriod != state.activeFilters['examPeriod']) {
      return false;
    }

    if (state.activeFilters['province'] != null &&
        paper.province != state.activeFilters['province']) {
      return false;
    }

    if (state.activeFilters['syllabus'] != null &&
        paper.syllabus != state.activeFilters['syllabus']) {
      return false;
    }

    if (state.activeFilters['examLevel'] != null &&
        paper.examLevel != state.activeFilters['examLevel']) {
      return false;
    }

    return true;
  }

  Future<void> loadFilterOptions() async {
    state = state.copyWith(isLoadingFilters: true, error: null);

    try {
      await _loadFiltersFromLocal();
      _syncFiltersWithServer();
    } catch (e) {
      print('Error loading filters: $e');
      state = state.copyWith(
        isLoadingFilters: false,
        error: 'Failed to load filters: $e',
      );
    }
  }

  Future<void> _loadFiltersFromLocal() async {
    try {
      final cachedFilters = await _repository.get<PaperFilters>();

      if (cachedFilters.isNotEmpty) {
        final latestFilters = cachedFilters
            .reduce((a, b) => a.lastSyncedAt.isAfter(b.lastSyncedAt) ? a : b);

        print('Loaded cached filters from local storage');
        state = state.copyWith(
          filters: latestFilters,
          isLoadingFilters: false,
        );
        return;
      }

      final localPapers = await _repository.get<ExamPaper>();

      if (localPapers.isNotEmpty) {
        print('Generating filters from ${localPapers.length} local papers');
        final generatedFilters =
            await PaperFilters.generateFromPapers(localPapers);

        await _repository.upsert<PaperFilters>(generatedFilters);

        state = state.copyWith(
          filters: generatedFilters,
          isLoadingFilters: false,
        );
      } else {
        final emptyFilters = PaperFilters(
          id: 'empty_filters',
          subjects: [],
          grades: [],
          syllabi: [],
          years: [],
          paperTypes: [],
          provinces: [],
          examPeriods: [],
          examLevels: [],
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          filters: emptyFilters,
          isLoadingFilters: false,
        );
      }
    } catch (e) {
      print('Error loading filters from local: $e');
      state = state.copyWith(isLoadingFilters: false);
    }
  }

  Future<void> _syncFiltersWithServer() async {
    if (state.isOffline) return;

    try {
      final getFilterOptionsUseCase =
          _ref.read(getFilterOptionsUseCaseProvider);
      final result = await getFilterOptionsUseCase();

      if (result.isSuccess) {
        final serverFilters = result.data!;

        final brickFilters = PaperFilters(
          id: 'server_filters_${DateTime.now().millisecondsSinceEpoch}',
          subjects: serverFilters.subjects,
          grades: serverFilters.grades,
          syllabi: serverFilters.syllabi,
          years: serverFilters.years,
          paperTypes: serverFilters.paperTypes,
          provinces: serverFilters.provinces,
          examPeriods: [],
          examLevels: [],
          updatedAt: DateTime.now(),
        );

        await _repository.upsert<PaperFilters>(brickFilters);

        state = state.copyWith(
          filters: brickFilters,
          isLoadingFilters: false,
          isOffline: false,
        );

        print('Synced filters with server successfully');
      } else {
        print('Failed to sync filters with server: ${result.error}');
        state = state.copyWith(isLoadingFilters: false);
      }
    } catch (e) {
      print('Error syncing filters with server: $e');
      state = state.copyWith(isLoadingFilters: false);
    }
  }

  Future<void> refreshFiltersFromPapers() async {
    try {
      final localPapers = await _repository.get<ExamPaper>();

      if (localPapers.isNotEmpty) {
        final updatedFilters =
            await PaperFilters.generateFromPapers(localPapers);

        await _repository.upsert<PaperFilters>(updatedFilters);
        state = state.copyWith(filters: updatedFilters);

        print('Refreshed filters from ${localPapers.length} papers');
      }
    } catch (e) {
      print('Error refreshing filters from papers: $e');
    }
  }

  void applyFilters(Map<String, dynamic> filters) {
    state = state.copyWith(activeFilters: filters);
    loadPapers(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: {});
    loadPapers(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> syncWhenOnline() async {
    if (state.isOffline) {
      await loadPapers(refresh: true);
      await loadFilterOptions();
    }
  }

  bool shouldRefreshFilters() {
    if (state.filters == null) return true;

    final hoursSinceLastSync =
        DateTime.now().difference(state.filters!.lastSyncedAt).inHours;

    return hoursSinceLastSync > 24;
  }

  Future<void> onPapersUpdated() async {
    await refreshFiltersFromPapers();
  }
}
