// lib/features/attempts/presentation/widgets/user_attempts_filters.dart
import 'package:flutter/material.dart';

class UserAttemptsFilters extends StatelessWidget {
  final Map<String, String> activeFilters;
  final Function(Map<String, String>) onFiltersChanged;

  const UserAttemptsFilters({
    super.key,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter
          _buildFilterChip(
            context,
            'Status',
            'status',
            ['All', 'Completed', 'In Progress'],
            Icons.flag_outlined,
          ),
          const SizedBox(width: 8),

          // Type filter
          _buildFilterChip(
            context,
            'Type',
            'type',
            ['All', 'Practice', 'Exam'],
            Icons.category_outlined,
          ),
          const SizedBox(width: 8),

          // Time period filter
          _buildFilterChip(
            context,
            'Period',
            'period',
            ['All Time', 'Today', 'This Week', 'This Month', 'Last 3 Months'],
            Icons.date_range_outlined,
          ),
          const SizedBox(width: 8),

          // Score range filter
          _buildFilterChip(
            context,
            'Score',
            'score',
            [
              'All',
              'Excellent (80%+)',
              'Good (60-79%)',
              'Needs Work (<60%)',
              'Unscored'
            ],
            Icons.grade_outlined,
          ),

          // Clear filters button
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onFiltersChanged({}),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String key,
    List<String> options,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final currentValue = activeFilters[key] ?? options.first;
    final borderColor = theme.chipTheme.side?.color ?? const Color(0xFFE6E6E6);
    final backgroundColor = theme.chipTheme.backgroundColor ?? Colors.white;
    final borderWidth = theme.chipTheme.side?.width ?? 1.0;
    final borderRadius = (theme.chipTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius as BorderRadius? ??
        BorderRadius.circular(20);

    return Container(
      height: 34,
      padding: theme.chipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
            isExpanded: false,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            final newFilters = Map<String, String>.from(activeFilters);
            if (value == null || value == options.first) {
              newFilters.remove(key); // Reset to default if "All"
            } else {
              newFilters[key] = value;
            }
            onFiltersChanged(newFilters);
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}
