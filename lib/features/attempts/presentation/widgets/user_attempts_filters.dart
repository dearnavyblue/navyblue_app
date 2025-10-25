// lib/features/attempts/presentation/widgets/user_attempts_filters.dart
import 'package:flutter/material.dart';

import '../../../../core/widgets/pill.dart';

class UserAttemptsFilters extends StatelessWidget {
  final Map<String, String> activeFilters;
  final Function(Map<String, String>) onFiltersChanged;
  final bool includeStatus;
  final bool compact;

  const UserAttemptsFilters({
    super.key,
    required this.activeFilters,
    required this.onFiltersChanged,
    this.includeStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding =
        compact ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : null;
    final iconSize = compact ? 16.0 : 18.0;
    final minHeight = compact ? 30.0 : 32.0;
    final maxLabelWidth = compact ? 160.0 : 200.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (includeStatus) ...[
            _buildFilterChip(
              context,
              label: 'Status',
              keyName: 'status',
              options: const ['All', 'Completed', 'In Progress'],
              icon: Icons.flag_outlined,
              padding: padding,
              iconSize: iconSize,
              minHeight: minHeight,
              maxLabelWidth: maxLabelWidth,
            ),
            const SizedBox(width: 8),
          ],
          _buildFilterChip(
            context,
            label: 'Type',
            keyName: 'type',
            options: const ['All', 'Practice', 'Exam'],
            icon: Icons.category_outlined,
            padding: padding,
            iconSize: iconSize,
            minHeight: minHeight,
            maxLabelWidth: maxLabelWidth,
          ),
          const SizedBox(width: 8),
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
            padding: padding,
            iconSize: iconSize,
            minHeight: minHeight,
            maxLabelWidth: maxLabelWidth,
          ),
          const SizedBox(width: 8),
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
            padding: padding,
            iconSize: iconSize,
            minHeight: minHeight,
            maxLabelWidth: maxLabelWidth,
          ),
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
    EdgeInsetsGeometry? padding,
    double? iconSize,
    double? minHeight,
    double? maxLabelWidth,
  }) {
    final currentValue = activeFilters[keyName];

    final resolvedIconSize = iconSize ?? 16.0;

    return PillDropdown<String>(
      items: options,
      value: currentValue,
      hint: label,
      leading: Icon(icon, size: resolvedIconSize),
      labelBuilder: (value) => value,
      includeAllOption: false,
      padding: padding,
      iconSize: iconSize,
      minHeight: minHeight,
      maxLabelWidth: maxLabelWidth,
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
