// lib/brick/models/paper_filters.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class PaperFilters extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'subjects')
  final List<String> subjects;

  @Rest(name: 'grades')
  final List<String> grades;

  @Rest(name: 'syllabi')
  final List<String> syllabi;

  @Rest(name: 'years')
  final List<int> years;

  @Rest(name: 'paperTypes')
  final List<String> paperTypes;

  @Rest(name: 'provinces')
  final List<String> provinces;

  @Rest(name: 'examPeriods')
  final List<String> examPeriods;

  @Rest(name: 'examLevels')
  final List<String> examLevels;

  @Rest(name: 'updatedAt')
  final DateTime updatedAt;

  // Local-only fields for offline functionality
  @Sqlite()
  @Rest(ignore: true)
  final DateTime lastSyncedAt;

  @Sqlite()
  @Rest(ignore: true)
  final bool needsSync;

  @Sqlite()
  @Rest(ignore: true)
  final String? deviceInfo;

  PaperFilters({
    required this.id,
    required this.subjects,
    required this.grades,
    required this.syllabi,
    required this.years,
    required this.paperTypes,
    required this.provinces,
    required this.examPeriods,
    required this.examLevels,
    required this.updatedAt,
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  PaperFilters copyWith({
    String? id,
    List<String>? subjects,
    List<String>? grades,
    List<String>? syllabi,
    List<int>? years,
    List<String>? paperTypes,
    List<String>? provinces,
    List<String>? examPeriods,
    List<String>? examLevels,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return PaperFilters(
      id: id ?? this.id,
      subjects: subjects ?? this.subjects,
      grades: grades ?? this.grades,
      syllabi: syllabi ?? this.syllabi,
      years: years ?? this.years,
      paperTypes: paperTypes ?? this.paperTypes,
      provinces: provinces ?? this.provinces,
      examPeriods: examPeriods ?? this.examPeriods,
      examLevels: examLevels ?? this.examLevels,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory PaperFilters.fromJson(Map<String, dynamic> json) {
    return PaperFilters(
      id: json['id'] ?? 'default_filters',
      subjects: List<String>.from(json['subjects'] ?? []),
      grades: List<String>.from(json['grades'] ?? []),
      syllabi: List<String>.from(json['syllabi'] ?? []),
      years: List<int>.from(json['years'] ?? []),
      paperTypes: List<String>.from(json['paperTypes'] ?? []),
      provinces: List<String>.from(json['provinces'] ?? []),
      examPeriods: List<String>.from(json['examPeriods'] ?? []),
      examLevels: List<String>.from(json['examLevels'] ?? []),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
      needsSync: json['needsSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjects': subjects,
      'grades': grades,
      'syllabi': syllabi,
      'years': years,
      'paperTypes': paperTypes,
      'provinces': provinces,
      'examPeriods': examPeriods,
      'examLevels': examLevels,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
    };
  }

  // Helper method to get unique subjects from local papers
  static Future<List<String>> getSubjectsFromPapers(List<dynamic> papers) async {
    final subjects = papers
        .map((paper) => paper.subject as String)
        .where((subject) => subject.isNotEmpty)
        .toSet()
        .toList();
    subjects.sort();
    return subjects;
  }

  // Helper method to get unique grades from local papers
  static Future<List<String>> getGradesFromPapers(List<dynamic> papers) async {
    final grades = papers
        .map((paper) => paper.grade as String)
        .where((grade) => grade.isNotEmpty)
        .toSet()
        .toList();
    grades.sort();
    return grades;
  }

  // Helper method to get unique years from local papers
  static Future<List<int>> getYearsFromPapers(List<dynamic> papers) async {
    final years = papers
        .map((paper) => paper.year as int)
        .where((year) => year > 0)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a)); // Descending order
    return years;
  }

  // Helper method to get unique paper types from local papers
  static Future<List<String>> getPaperTypesFromPapers(List<dynamic> papers) async {
    final paperTypes = papers
        .map((paper) => paper.paperType as String)
        .where((paperType) => paperType.isNotEmpty)
        .toSet()
        .toList();
    paperTypes.sort();
    return paperTypes;
  }

  // Helper method to get unique provinces from local papers
  static Future<List<String>> getProvincesFromPapers(List<dynamic> papers) async {
    final provinces = papers
        .map((paper) => paper.province as String?)
        .where((province) => province != null && province.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    provinces.sort();
    return provinces;
  }

  // Helper method to get unique exam periods from local papers
  static Future<List<String>> getExamPeriodsFromPapers(List<dynamic> papers) async {
    final examPeriods = papers
        .map((paper) => paper.examPeriod as String)
        .where((examPeriod) => examPeriod.isNotEmpty)
        .toSet()
        .toList();
    examPeriods.sort();
    return examPeriods;
  }

  // Helper method to get unique exam levels from local papers
  static Future<List<String>> getExamLevelsFromPapers(List<dynamic> papers) async {
    final examLevels = papers
        .map((paper) => paper.examLevel as String)
        .where((examLevel) => examLevel.isNotEmpty)
        .toSet()
        .toList();
    examLevels.sort();
    return examLevels;
  }

  // Helper method to generate filters from local papers
  static Future<PaperFilters> generateFromPapers(List<dynamic> papers) async {
    final subjects = await getSubjectsFromPapers(papers);
    final grades = await getGradesFromPapers(papers);
    final years = await getYearsFromPapers(papers);
    final paperTypes = await getPaperTypesFromPapers(papers);
    final provinces = await getProvincesFromPapers(papers);
    final examPeriods = await getExamPeriodsFromPapers(papers);
    final examLevels = await getExamLevelsFromPapers(papers);

    return PaperFilters(
      id: 'local_generated_filters',
      subjects: subjects,
      grades: grades,
      syllabi: [],
      years: years,
      paperTypes: paperTypes,
      provinces: provinces,
      examPeriods: examPeriods,
      examLevels: examLevels,
      updatedAt: DateTime.now(),
    );
  }
}