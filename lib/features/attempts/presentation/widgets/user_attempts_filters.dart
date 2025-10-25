// lib/features/attempts/presentation/widgets/user_attempts_filters.dart
import 'package:flutter/material.dart';

import '../../../../core/widgets/pill.dart';

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
            label: 'Status',
            keyName: 'status',
            options: const ['All', 'Completed', 'In Progress'],
            icon: Icons.flag_outlined,
          ),
          const SizedBox(width: 8),

          // Type filter
          _buildFilterChip(
            context,
            label: 'Type',
            keyName: 'type',
            options: const ['All', 'Practice', 'Exam'],
            icon: Icons.category_outlined,
          ),
          const SizedBox(width: 8),

          // Time period filter
          _buildFilterChip(
            context,
            label: 'Period',
            keyName: 'period',
            options: const [
              'All Time',
              'Today',
              'This Week',
              'This Month',
              'Last 3 Months'
            ],
            icon: Icons.date_range_outlined,
          ),
          const SizedBox(width: 8),

          // Score range filter
          _buildFilterChip(
            context,
            label: 'Score',
            keyName: 'score',
            options: const [
              'All',
              'Excellent (80%+)',
              'Good (60-79%)',
              'Needs Work (<60%)',
              'Unscored'
            ],
            icon: Icons.grade_outlined,
          ),

          // Clear filters button
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(width: 16),
            Pill(
              label: 'Clear',
              leading: const Icon(Icons.clear_all_rounded, size: 16),
              textColor: theme.colorScheme.onSurfaceVariant,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
              onTap: () => onFiltersChanged({}),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String keyName,
    required List<String> options,
    required IconData icon,
  }) {
    final currentValue = activeFilters[keyName];

    return PillDropdown<String>(
      items: options,
      value: currentValue,
      hint: label,
      leading: Icon(icon, size: 16),
      labelBuilder: (value) => value,
      includeAllOption: false,
      onChanged: (value) {
        if (value == null || value == options.first) {
          final copy = Map<String, String>.from(activeFilters);
          copy.remove(keyName);
          onFiltersChanged(copy);
        } else {
          onFiltersChanged({...activeFilters, keyName: value});
        }
      },
    );
  }
}
