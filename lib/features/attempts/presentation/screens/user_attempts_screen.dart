// lib/features/attempts/presentation/screens/user_attempts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/attempts_presentation_providers.dart';
import '../widgets/user_attempt_card.dart';
import '../widgets/user_attempts_filters.dart';
import '../widgets/user_attempt_search_bar.dart';

class UserAttemptsScreen extends ConsumerStatefulWidget {
  const UserAttemptsScreen({super.key});

  @override
  ConsumerState<UserAttemptsScreen> createState() => _UserAttemptsScreenState();
}

class _UserAttemptsScreenState extends ConsumerState<UserAttemptsScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  Map<String, String> _activeFilters = {};
  String _searchQuery = '';
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAttempts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // Only refresh when app comes from background, NOT when navigating back
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasLoadedOnce) {
      _refreshAttempts();
    }
  }

  void _loadUserAttempts() {
    ref
        .read(userAttemptsControllerProvider.notifier)
        .loadUserAttempts(page: 1, refresh: true);
    _hasLoadedOnce = true;
  }

  void _refreshAttempts() {
    ref.read(userAttemptsControllerProvider.notifier).refreshAttempts();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      // Load more for infinite scroll
      ref.read(userAttemptsControllerProvider.notifier).loadMoreAttempts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userAttemptsControllerProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Attempts',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAttempts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 16,
              8,
              isTablet ? 24 : 16,
              16,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                UserAttemptsFilters(
                  activeFilters: _activeFilters,
                  onFiltersChanged: (filters) {
                    setState(() {
                      _activeFilters = filters;
                    });
                  },
                ),

                const SizedBox(height: 12),
                UserAttemptSearchBar(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
   
               
              ],
            ),
          ),

          // Pagination Info Bar
          // if (state.totalAttemptsCount > 0)
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     decoration: BoxDecoration(
          //       color:
          //           theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          //       border: Border(
          //         bottom: BorderSide(
          //           color: theme.colorScheme.outline.withValues(alpha: 0.1),
          //           width: 1,
          //         ),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           _getPaginationText(state),
          //           style: theme.textTheme.bodySmall?.copyWith(
          //             color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          //           ),
          //         ),
          //         if (state.hasNextAttemptsPage)
          //           Text(
          //             'Page ${state.currentAttemptsPage} of ${state.totalAttemptsPages}',
          //             style: theme.textTheme.bodySmall?.copyWith(
          //               color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          //             ),
          //           ),
          //       ],
          //     ),
          //   ),
          // Attempts List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshAttempts();
              },
              child: _buildAttemptsContent(state, theme, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsContent(dynamic state, ThemeData theme, bool isTablet) {
    if (state.isLoadingUserAttempts && state.userAttempts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Loading your attempts...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    final filteredAttempts = _getFilteredAttempts(state);

    if (filteredAttempts.isEmpty) {
      return _buildEmptyState(theme, state);
    }

    return _buildAttemptsList(state, theme, isTablet, filteredAttempts);
  }

  Widget _buildAttemptsList(dynamic state, ThemeData theme, bool isTablet,
      List<dynamic> filteredAttempts) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: filteredAttempts.length + (state.hasNextAttemptsPage ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the bottom
        if (index == filteredAttempts.length) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  if (state.isLoadingMoreAttempts) ...[
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Loading more attempts...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(userAttemptsControllerProvider.notifier)
                            .loadMoreAttempts();
                      },
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Load More'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final attempt = filteredAttempts[index];
        final paper = state.papersCache[attempt.paperId];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: UserAttemptCard(
            attempt: attempt,
            paper: paper,
            onTap: () async {
              await context.push(
                '/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}&resume=${attempt.id}',
              );
              // Refresh when returning - this is fine because user explicitly went to an attempt
              if (mounted) {
                _refreshAttempts();
              }
            },
          ),
        );
      },
    );
  }

  String _getPaginationText(dynamic state) {
    const pageSize = 20;

    // Calculate the range for the current page
    final startIndex = (state.currentAttemptsPage - 1) * pageSize + 1;
    final endIndex = (state.currentAttemptsPage * pageSize)
        .clamp(0, state.totalAttemptsCount);

    // Apply filters to get the actual displayed count
    final filteredAttempts = _getFilteredAttempts(state);
    final displayedCount = filteredAttempts.length;

    if (_activeFilters.isNotEmpty || _searchQuery.isNotEmpty) {
      // When filters are active, show filtered results
      return 'Showing $displayedCount of ${state.totalAttemptsCount} attempts (filtered)';
    } else {
      // When no filters, show page range
      if (state.totalAttemptsCount <= pageSize) {
        // Single page
        return 'Showing $displayedCount of ${state.totalAttemptsCount} attempts';
      } else {
        // Multiple pages - show range
        return 'Showing $startIndex-$endIndex of ${state.totalAttemptsCount} attempts';
      }
    }
  }

  List<dynamic> _getFilteredAttempts(dynamic state) {
    var filteredAttempts = List.from(state.userAttempts);

    if (_searchQuery.isNotEmpty) {
      filteredAttempts = filteredAttempts.where((attempt) {
        final paper = state.papersCache[attempt.paperId];
        final title = paper?.title?.toLowerCase() ?? '';
        final subject = paper?.subject?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || subject.contains(query);
      }).toList();
    }

    if (_activeFilters.containsKey('status') &&
        _activeFilters['status'] != 'All') {
      final status = _activeFilters['status'];
      filteredAttempts = filteredAttempts.where((attempt) {
        if (status == 'Completed') return attempt.isCompleted;
        if (status == 'In Progress') return !attempt.isCompleted;
        return true;
      }).toList();
    }

    if (_activeFilters.containsKey('type') && _activeFilters['type'] != 'All') {
      final type = _activeFilters['type'];
      filteredAttempts = filteredAttempts.where((attempt) {
        if (type == 'Practice') return attempt.mode == 'PRACTICE';
        if (type == 'Exam') return attempt.mode == 'EXAM';
        return true;
      }).toList();
    }

    if (_activeFilters.containsKey('score') &&
        _activeFilters['score'] != 'All') {
      final scoreFilter = _activeFilters['score'];
      filteredAttempts = filteredAttempts.where((attempt) {
        if (!attempt.isCompleted) return false;
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

    if (_activeFilters.containsKey('period') &&
        _activeFilters['period'] != 'All Time') {
      final period = _activeFilters['period'];
      final now = DateTime.now();
      filteredAttempts = filteredAttempts.where((attempt) {
        final startDate = attempt.startedAt;
        switch (period) {
          case 'Today':
            return startDate.year == now.year &&
                startDate.month == now.month &&
                startDate.day == now.day;
          case 'This Week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return startDate.isAfter(weekStart);
          case 'This Month':
            return startDate.year == now.year && startDate.month == now.month;
          case 'Last 3 Months':
            final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
            return startDate.isAfter(threeMonthsAgo);
          default:
            return true;
        }
      }).toList();
    }

    return filteredAttempts;
  }

  Widget _buildEmptyState(ThemeData theme, dynamic state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                state.userAttemptsError != null
                    ? Icons.error_outline_rounded
                    : Icons.assignment_turned_in_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.userAttemptsError != null
                  ? 'Something went wrong'
                  : 'No attempts found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.userAttemptsError ??
                  (_activeFilters.isNotEmpty || _searchQuery.isNotEmpty
                      ? 'Try adjusting your search or filters'
                      : 'Start practicing to build your readiness score and track your progress'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/papers'),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Start Practicing'),
            ),
          ],
        ),
      ),
    );
  }
}
