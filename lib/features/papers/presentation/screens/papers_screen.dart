// lib/features/papers/presentation/screens/papers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import 'package:navyblue_app/features/papers/presentation/controllers/papers_controller.dart';
import '../providers/papers_presentation_providers.dart';
import '../widgets/paper_card.dart';
import '../widgets/papers_filters.dart';
import '../widgets/paper_search_bar.dart';
import 'dart:async';

class PapersScreen extends ConsumerStatefulWidget {
  const PapersScreen({super.key});

  @override
  ConsumerState<PapersScreen> createState() => _PapersScreenState();
}

class _PapersScreenState extends ConsumerState<PapersScreen> {
  late ScrollController _scrollController;
  bool _isInitializing = true;
  DateTime? _lastRefreshTime;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isInitializing = true);

      // OPTIMIZATION: Load in parallel instead of sequentially
      Future.wait([
        ref.read(userAttemptsControllerProvider.notifier).loadUserAttempts(),
        ref.read(papersControllerProvider.notifier).loadFilterOptions(),
      ]).then((_) {
        return ref
            .read(papersControllerProvider.notifier)
            .loadPapers(refresh: true);
      }).then((_) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _lastRefreshTime = DateTime.now();
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitializing && mounted) {
        // OPTIMIZATION: Only refresh if enough time has passed
        final now = DateTime.now();
        if (_lastRefreshTime == null ||
            now.difference(_lastRefreshTime!) > const Duration(seconds: 30)) {
          ref.read(userAttemptsControllerProvider.notifier).refreshAttempts();
          _lastRefreshTime = now;
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      final state = ref.read(papersControllerProvider);
      if (state.hasNextPage && !state.isLoadingMore) {
        ref.read(papersControllerProvider.notifier).loadPapers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(papersControllerProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Papers')),
        body: _buildSkeletonLoader(theme, isTablet),
      );
    }

    // OPTIMIZATION: Debounced listener for user attempts changes
    ref.listen(userAttemptsControllerProvider, (previous, next) {
      final attemptsChanged = previous != null &&
          previous.userAttempts.length != next.userAttempts.length;

      final wasLoading = previous?.isLoadingUserAttempts ?? false;
      final nowLoaded = !next.isLoadingUserAttempts && next.isInitialized;

      if (attemptsChanged || (wasLoading && nowLoaded)) {
        // Cancel existing timer
        _debounceTimer?.cancel();

        // Debounce refresh by 500ms
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            print('REFRESHING PAPERS - Attempts changed or just loaded');
            ref.read(papersControllerProvider.notifier).onUserAttemptsChanged();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Exam Papers',
          style: theme.textTheme.headlineSmall?.copyWith(
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
            onPressed: () {
              _lastRefreshTime = DateTime.now();
              // OPTIMIZATION: Refresh both attempts and papers
              ref
                  .read(userAttemptsControllerProvider.notifier)
                  .refreshAttempts();
              ref
                  .read(papersControllerProvider.notifier)
                  .loadPapers(refresh: true);
            },
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
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                PaperSearchBar(
                  onSearch: (query) {
                    ref
                        .read(papersControllerProvider.notifier)
                        .searchPapers(query);
                  },
                ),
                const SizedBox(height: 12),
                PapersFilters(
                  filters: state.filters,
                  activeFilters: state.activeFilters,
                  onFiltersChanged: (filters) {
                    ref
                        .read(papersControllerProvider.notifier)
                        .applyFilters(filters);
                  },
                ),
              ],
            ),
          ),

          // Pagination Info Bar
          if (state.paperAvailabilities.isNotEmpty ||
              (state.totalAvailablePapers == 0 && state.serverTotalCount > 0))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getPapersPaginationText(state),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (state.hasNextPage)
                    Text(
                      'Page ${state.currentPage} of ${state.totalPages}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),

          // Papers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _lastRefreshTime = DateTime.now();
                // Refresh both attempts and papers
                await ref
                    .read(userAttemptsControllerProvider.notifier)
                    .refreshAttempts();
                await ref
                    .read(papersControllerProvider.notifier)
                    .loadPapers(refresh: true);
              },
              child: state.isLoading && state.paperAvailabilities.isEmpty
                  ? _buildSkeletonLoader(theme, isTablet)
                  : state.paperAvailabilities.isEmpty
                      ? _buildEmptyState(theme, state)
                      : _buildPapersList(state, theme, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  // OPTIMIZATION: Skeleton loader for better perceived performance
  Widget _buildSkeletonLoader(ThemeData theme, bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
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
                      const SizedBox(width: 12),
                      Container(
                        width: 60,
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
          ),
        );
      },
    );
  }

  String _getPapersPaginationText(PapersState state) {
    const pageSize = 10;
    final totalAvailable = state.totalAvailablePapers;
    final totalFromServer = state.serverTotalCount;
    final attemptedCount = totalFromServer - totalAvailable;

    final displayedCount = state.paperAvailabilities.length;

    if (totalAvailable == 0 && attemptedCount > 0) {
      return state.isOffline
          ? '$attemptedCount papers attempted - check online for more'
          : '$attemptedCount papers attempted - more coming soon';
    }

    if (state.activeFilters.isNotEmpty ||
        (state.searchQuery?.isNotEmpty ?? false)) {
      if (attemptedCount > 0) {
        return '$displayedCount available, $attemptedCount attempted (filtered)';
      }
      return 'Showing $displayedCount available papers (filtered)';
    } else {
      if (totalAvailable <= pageSize) {
        if (attemptedCount > 0) {
          return '$displayedCount available, $attemptedCount already attempted';
        }
        return 'Showing $displayedCount available papers';
      } else {
        final startIndex = (state.currentPage - 1) * pageSize + 1;
        final actualEndIndex =
            (startIndex + displayedCount - 1).clamp(startIndex, totalAvailable);

        if (attemptedCount > 0) {
          return 'Showing $startIndex-$actualEndIndex of $totalAvailable ($attemptedCount attempted)';
        }
        return 'Showing $startIndex-$actualEndIndex of $totalAvailable available';
      }
    }
  }

  Widget _buildEmptyState(ThemeData theme, PapersState state) {
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
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                state.error != null
                    ? Icons.error_outline_rounded
                    : Icons.description_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.error != null ? 'Something went wrong' : 'No papers found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.error ??
                  (state.activeFilters.isNotEmpty || state.searchQuery != null
                      ? 'Try adjusting your search or filters'
                      : 'Check back later for new exam papers'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (state.error != null) ...[
              FilledButton.icon(
                onPressed: () {
                  ref.read(papersControllerProvider.notifier).clearError();
                  ref
                      .read(userAttemptsControllerProvider.notifier)
                      .refreshAttempts();
                  ref
                      .read(papersControllerProvider.notifier)
                      .loadPapers(refresh: true);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ] else if (state.activeFilters.isNotEmpty ||
                state.searchQuery != null) ...[
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(papersControllerProvider.notifier).clearFilters();
                  ref.read(papersControllerProvider.notifier).searchPapers('');
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear All Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPapersList(PapersState state, ThemeData theme, bool isTablet) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: state.paperAvailabilities.length + (state.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.paperAvailabilities.length) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading more papers...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final paperAvailability = state.paperAvailabilities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PaperCard(paperAvailability: paperAvailability),
        );
      },
    );
  }
}
