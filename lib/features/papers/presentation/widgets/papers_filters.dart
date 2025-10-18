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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Grade
          if (widget.filters!.grades.isNotEmpty) ...[
            _buildPillDropdown(
              items: widget.filters!.grades,
              value: widget.activeFilters['grade'],
              hint: 'Grade',
              displayMapper: _getGradeDisplay,
              onChanged: (value) => _updateFilter('grade', value),

              // 👇 make it black with white text & caret (and border)
              backgroundOverride: Colors.black,
              textColorOverride: Colors.white,
              borderColorOverride: Colors.black,
            ),
            const SizedBox(width: 8),
          ],
    
          // 2. Subject
          if (widget.filters!.subjects.isNotEmpty) ...[
            _buildPillDropdown(
              items: widget.filters!.subjects,
              value: widget.activeFilters['subject'],
              hint: 'Subject',
              displayMapper: _getSubjectDisplay,
              onChanged: (value) => _updateFilter('subject', value),
            ),
            const SizedBox(width: 8),
          ],

          // 3. Paper Type
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
        ],
      ),
    );
  }

Widget _buildPillContent({
    required String text,
    required TextStyle labelStyle,
  }) {
    return ConstrainedBox(
      // optional soft cap
      constraints: const BoxConstraints(maxWidth: 160),
      child: Text(
        text,
        style: labelStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }


Widget _buildPillDropdown({
    required List<String> items,
    required String? value,
    required String hint,
    required String Function(String) displayMapper,
    required Function(String?) onChanged,
    // 👇 new (optional)
    Color? backgroundOverride,
    Color? textColorOverride,
    Color? borderColorOverride,
  }) {
    final theme = Theme.of(context);
    final chipTheme = theme.chipTheme;
    final isSelected = value != null;

    final backgroundColor =
        backgroundOverride ?? (chipTheme.backgroundColor ?? Colors.white);
    final borderColor = borderColorOverride ??
        (chipTheme.side?.color ?? const Color(0xFFE6E6E6));
    final borderWidth = chipTheme.side?.width ?? 1.0;
    final borderRadius = (chipTheme.shape as RoundedRectangleBorder?)
            ?.borderRadius as BorderRadius? ??
        BorderRadius.circular(20);

    // use override if provided; otherwise fall back to theme or black
    final baseLabelStyle = chipTheme.labelStyle ??
        const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black);
    final textColor =
        textColorOverride ?? (baseLabelStyle.color ?? Colors.black);
    final labelStyle = baseLabelStyle.copyWith(color: textColor);

    return Container(
      height: 32,
      padding: chipTheme.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: false,
          icon: Icon(Icons.expand_more,
              size: 18, color: textColor), // caret follows text color
          iconEnabledColor: textColor,
          iconDisabledColor: textColor,
          hint: _buildPillContent(
            text: isSelected ? displayMapper(value!) : hint,
            labelStyle: labelStyle, // uses textColor
          ),
          selectedItemBuilder: (context) {
            return [null, ...items].map((item) {
              return _buildPillContent(
                text: item != null ? displayMapper(item) : hint,
                labelStyle: labelStyle,
              );
            }).toList();
          },
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('All')),
            ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(displayMapper(item)),
                )),
          ],
          onChanged: onChanged,
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          isDense: true,
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
