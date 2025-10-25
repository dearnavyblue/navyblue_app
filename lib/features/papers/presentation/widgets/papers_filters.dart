import 'package:flutter/material.dart';
import '../../../../brick/models/paper_filters.model.dart';
import '../../../../core/widgets/pill.dart';

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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Grade
          if (widget.filters!.grades.isNotEmpty) ...[
            PillDropdown<String>(
              items: widget.filters!.grades,
              value: widget.activeFilters['grade'],
              hint: 'Grade',
              variant: PillVariant.filled,
              labelBuilder: _getGradeDisplay,
              onChanged: (value) => _updateFilter('grade', value),
            ),
            const SizedBox(width: 8),
          ],

          // 2. Subject
          if (widget.filters!.subjects.isNotEmpty) ...[
            PillDropdown<String>(
              items: widget.filters!.subjects,
              value: widget.activeFilters['subject'],
              hint: 'Subject',
              labelBuilder: _getSubjectDisplay,
              onChanged: (value) => _updateFilter('subject', value),
            ),
            const SizedBox(width: 8),
          ],

          // 3. Paper Type
          if (widget.filters!.paperTypes.isNotEmpty) ...[
            PillDropdown<String>(
              items: widget.filters!.paperTypes,
              value: widget.activeFilters['paperType'],
              hint: 'Paper',
              labelBuilder: _getPaperTypeDisplay,
              onChanged: (value) => _updateFilter('paperType', value),
            ),
            const SizedBox(width: 8),
          ],
        ],
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
        return 'Gr 10';
      case 'GRADE_11':
        return 'Gr 11';
      case 'GRADE_12':
        return 'Gr 12';
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
}
