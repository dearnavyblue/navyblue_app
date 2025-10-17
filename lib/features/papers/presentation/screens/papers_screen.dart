import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/attempts/presentation/providers/attempts_presentation_providers.dart';
import 'package:navyblue_app/features/papers/presentation/controllers/papers_controller.dart';
import '../providers/papers_presentation_providers.dart';
import '../widgets/paper_card.dart';
import '../widgets/papers_filters.dart';
import '../widgets/paper_search_bar.dart';

class PapersScreen extends ConsumerStatefulWidget {
  const PapersScreen({super.key});

  @override
  ConsumerState<PapersScreen> createState() => _PapersScreenState();
}

class _PapersScreenState extends ConsumerState<PapersScreen> {
  late ScrollController _scrollController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isInitializing = true);

      // Load user attempts first, then papers
      ref
          .read(userAttemptsControllerProvider.notifier)
          .loadUserAttempts()
          .then((_) {
        ref.read(papersControllerProvider.notifier).loadFilterOptions();
        ref.read(papersControllerProvider.notifier).loadPapers(refresh: true);

        setState(() => _isInitializing = false);
      });
    });
  }

  @override
  void dispose() {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Listen for changes in user attempts and refresh papers
    ref.listen(userAttemptsControllerProvider, (previous, next) {
      if (previous != null &&
          previous.userAttempts.length != next.userAttempts.length) {
        // User attempts have changed, refresh papers
        print(
            'User attempts changed from ${previous.userAttempts.length} to ${next.userAttempts.length}');
        ref.read(papersControllerProvider.notifier).onUserAttemptsChanged();
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 16,
              16,
              isTablet ? 24 : 16,
              4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
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
                const SizedBox(height: 16),
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
          // if (state.paperAvailabilities.isNotEmpty ||
          //     (state.totalAvailablePapers == 0 && state.serverTotalCount > 0))
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     decoration: BoxDecoration(
          //       color:
          //           theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          //       border: Border(
          //         bottom: BorderSide(
          //           color: theme.colorScheme.outline.withOpacity(0.1),
          //           width: 1,
          //         ),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           _getPapersPaginationText(state),
          //           style: theme.textTheme.bodySmall?.copyWith(
          //             color: theme.colorScheme.onSurface.withOpacity(0.7),
          //           ),
          //         ),
          //         if (state.hasNextPage)
          //           Text(
          //             'Page ${state.currentPage} of ${state.totalPages}',
          //             style: theme.textTheme.bodySmall?.copyWith(
          //               color: theme.colorScheme.onSurface.withOpacity(0.7),
          //             ),
          //           ),
          //       ],
          //     ),
          //   ),

          // Papers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(papersControllerProvider.notifier)
                  .loadPapers(refresh: true),
              child: state.isLoading && state.paperAvailabilities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading papers...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : state.paperAvailabilities.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildPapersList(state, theme, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  // // Updated helper method with messaging about attempted papers:
  // String _getPapersPaginationText(PapersState state) {
  //   const pageSize = 10;
  //   final totalAvailable = state.totalAvailablePapers;
  //   final totalFromServer = state.serverTotalCount;
  //   final attemptedCount = totalFromServer - totalAvailable;

  //   final displayedCount = state.paperAvailabilities.length;

  //   if (totalAvailable == 0 && attemptedCount > 0) {
  //     // All papers have been attempted
  //     return state.isOffline
  //         ? '$attemptedCount papers attempted - check online for more'
  //         : '$attemptedCount papers attempted - more coming soon';
  //   }

  //   if (state.activeFilters.isNotEmpty ||
  //       (state.searchQuery?.isNotEmpty ?? false)) {
  //     // When filters are active
  //     if (attemptedCount > 0) {
  //       return '$displayedCount available, $attemptedCount attempted (filtered)';
  //     }
  //     return 'Showing $displayedCount available papers (filtered)';
  //   } else {
  //     // When no filters, show page range
  //     if (totalAvailable <= pageSize) {
  //       // Single page
  //       if (attemptedCount > 0) {
  //         return '$displayedCount available, $attemptedCount already attempted';
  //       }
  //       return 'Showing $displayedCount available papers';
  //     } else {
  //       // Multiple pages - show range
  //       final startIndex = (state.currentPage - 1) * pageSize + 1;
  //       final actualEndIndex =
  //           (startIndex + displayedCount - 1).clamp(startIndex, totalAvailable);

  //       if (attemptedCount > 0) {
  //         return 'Showing $startIndex-$actualEndIndex of $totalAvailable ($attemptedCount attempted)';
  //       }
  //       return 'Showing $startIndex-$actualEndIndex of $totalAvailable available';
  //     }
  //   }
  // }

  Widget _buildEmptyState(ThemeData theme) {
    final state = ref.watch(papersControllerProvider);

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
      padding: EdgeInsets.all(isTablet ? 24 : 12),
      itemCount: state.paperAvailabilities.length + (state.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.paperAvailabilities.length) {
          return Container(
            padding: const EdgeInsets.all(16),
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
          padding: const EdgeInsets.only(bottom: 0),
          child: PaperCard(paperAvailability: paperAvailability), // Updated parameter
        );
      },
    );
  }
}
