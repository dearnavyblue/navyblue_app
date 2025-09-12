// lib/features/papers/domain/entities/paper_filters.dart
class PaperFilters {
  final List<String> subjects;
  final List<String> grades;
  final List<String> syllabi;
  final List<int> years;
  final List<String> paperTypes;
  final List<String> provinces;

  const PaperFilters({
    required this.subjects,
    required this.grades,
    required this.syllabi,
    required this.years,
    required this.paperTypes,
    required this.provinces,
  });

  factory PaperFilters.fromJson(Map<String, dynamic> json) {
    return PaperFilters(
      subjects: List<String>.from(json['subjects'] ?? []),
      grades: List<String>.from(json['grades'] ?? []),
      syllabi: List<String>.from(json['syllabi'] ?? []),
      years: List<int>.from(json['years'] ?? []),
      paperTypes: List<String>.from(json['paperTypes'] ?? []),
      provinces: List<String>.from(json['provinces'] ?? []),
    );
  }
}