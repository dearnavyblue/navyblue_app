import 'package:flutter/material.dart';
import '../../../../brick/models/paper_filters.model.dart';

class PapersFilters extends StatefulWidget {
  final PaperFilters? filters;
  final Map<String, dynamic> activeFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const PapersFilters({
    super.key,
    required this.filters,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  State<PapersFilters> createState() => _PapersFiltersState();
}

class _PapersFiltersState extends State<PapersFilters> {
  @override
  Widget build(BuildContext context) {
    if (widget.filters == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 1. Subject (most important filter)
            if (widget.filters!.subjects.isNotEmpty) ...[
              _buildPillDropdown(
                items: widget.filters!.subjects,
                value: widget.activeFilters['subject'],
                hint: 'Subject',
                displayMapper: _getSubjectDisplay,
                onChanged: (value) => _updateFilter('subject', value),
                isPrimary: true,
              ),
              const SizedBox(width: 8),
            ],

            // 2. Grade (second most important)
            if (widget.filters!.grades.isNotEmpty) ...[
              _buildPillDropdown(
                items: widget.filters!.grades,
                value: widget.activeFilters['grade'],
                hint: 'Grade',
                displayMapper: _getGradeDisplay,
                onChanged: (value) => _updateFilter('grade', value),
                isDark: true,
              ),
              const SizedBox(width: 8),
            ],

            // 3. Paper Type (commonly used)
            if (widget.filters!.paperTypes.isNotEmpty) ...[
              _buildPillDropdown(
                items: widget.filters!.paperTypes,
                value: widget.activeFilters['paperType'],
                hint: 'Paper',
                displayMapper: _getPaperTypeDisplay,
                onChanged: (value) => _updateFilter('paperType', value),
              ),
              const SizedBox(width: 8),
            ],

            // 4. Year
            if (widget.filters!.years.isNotEmpty) ...[
              _buildYearPillDropdown(),
              const SizedBox(width: 8),
            ],

            // 5. Syllabus (less frequently changed)
            if (widget.filters!.syllabi.isNotEmpty) ...[
              _buildPillDropdown(
                items: widget.filters!.syllabi,
                value: widget.activeFilters['syllabus'],
                hint: 'Syllabus',
                displayMapper: (value) => value,
                onChanged: (value) => _updateFilter('syllabus', value),
              ),
              const SizedBox(width: 8),
            ],

            // 6. Province (least commonly used, often empty)
            if (widget.filters!.provinces.isNotEmpty) ...[
              _buildPillDropdown(
                items: widget.filters!.provinces,
                value: widget.activeFilters['province'],
                hint: 'Province',
                displayMapper: _getProvinceDisplay,
                onChanged: (value) => _updateFilter('province', value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPillDropdown({
    required List<String> items,
    required String? value,
    required String hint,
    required String Function(String) displayMapper,
    required Function(String?) onChanged,
    bool isDark = false,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = value != null;

    Color backgroundColor;
    Color textColor;

    if (isDark) {
      backgroundColor = theme.colorScheme.onSurface;
      textColor = theme.colorScheme.surface;
    } else if (isPrimary) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else {
      backgroundColor = isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest;
      textColor = isSelected
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSelected ? displayMapper(value) : hint,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: textColor,
                ),
              ],
            ),
          ),
          selectedItemBuilder: (context) {
            return [null, ...items].map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item != null ? displayMapper(item) : hint,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: textColor,
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All ${hint}s'),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(displayMapper(item)),
                )),
          ],
          onChanged: onChanged,
          icon: const SizedBox.shrink(),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildYearPillDropdown() {
    final theme = Theme.of(context);
    final value = widget.activeFilters['year'];
    final isSelected = value != null;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSelected ? '$value' : 'Year',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          selectedItemBuilder: (context) {
            return [null, ...widget.filters!.years].map((year) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      year != null ? '$year' : 'Year',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('All Years'),
            ),
            ...widget.filters!.years.map((year) => DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year'),
                )),
          ],
          onChanged: (value) => _updateFilter('year', value),
          icon: const SizedBox.shrink(),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _updateFilter(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(widget.activeFilters);
    if (value == null) {
      newFilters.remove(key);
    } else {
      newFilters[key] = value;
    }
    widget.onFiltersChanged(newFilters);
  }

  String _getSubjectDisplay(String subject) {
    switch (subject) {
      case 'MATH':
        return 'Maths';
      case 'PHYS_SCI':
        return 'Physics';
      default:
        return subject;
    }
  }

  String _getGradeDisplay(String grade) {
    switch (grade) {
      case 'GRADE_10':
        return '10';
      case 'GRADE_11':
        return '11';
      case 'GRADE_12':
        return '12';
      default:
        return grade.replaceAll('GRADE_', '');
    }
  }

  String _getPaperTypeDisplay(String paperType) {
    switch (paperType) {
      case 'PAPER_1':
        return 'Paper 1';
      case 'PAPER_2':
        return 'Paper 2';
      case 'PAPER_3':
        return 'Paper 3';
      default:
        return paperType.replaceAll('PAPER_', 'Paper ');
    }
  }

  String _getProvinceDisplay(String province) {
    switch (province) {
      case 'GAUTENG':
        return 'Gauteng';
      case 'WESTERN_CAPE':
        return 'Western Cape';
      case 'KWAZULU_NATAL':
        return 'KwaZulu-Natal';
      case 'EASTERN_CAPE':
        return 'Eastern Cape';
      case 'LIMPOPO':
        return 'Limpopo';
      case 'MPUMALANGA':
        return 'Mpumalanga';
      case 'NORTH_WEST':
        return 'North West';
      case 'FREE_STATE':
        return 'Free State';
      case 'NORTHERN_CAPE':
        return 'Northern Cape';
      default:
        return province
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }
}
