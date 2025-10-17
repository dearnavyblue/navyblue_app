// lib/brick/models/exam_paper.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class ExamPaper extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'title')
  final String title;

  // OPTIMIZATION: Index subject for filtering by subject
  @Sqlite(index: true)
  @Rest(name: 'subject')
  final String subject;

  // OPTIMIZATION: Index grade for filtering by grade
  @Sqlite(index: true)
  @Rest(name: 'grade')
  final String grade;

  // OPTIMIZATION: Index syllabus for filtering
  @Sqlite(index: true)
  @Rest(name: 'syllabus')
  final String syllabus;

  // OPTIMIZATION: Index year for sorting and filtering
  @Sqlite(index: true)
  @Rest(name: 'year')
  final int year;

  // OPTIMIZATION: Index examPeriod for filtering
  @Sqlite(index: true)
  @Rest(name: 'examPeriod')
  final String examPeriod;

  @Rest(name: 'examLevel')
  final String examLevel;

  // OPTIMIZATION: Index paperType for filtering
  @Sqlite(index: true)
  @Rest(name: 'paperType')
  final String paperType;

  @Rest(name: 'province')
  final String? province;

  @Rest(name: 'durationMinutes')
  final int durationMinutes;

  @Rest(name: 'instructions')
  final String? instructions;

  @Rest(name: 'totalMarks')
  final int? totalMarks;

  // OPTIMIZATION: Index isActive for filtering active papers
  @Sqlite(index: true)
  @Rest(name: 'isActive')
  final bool isActive;

  // OPTIMIZATION: Index uploadedAt for sorting by upload date
  @Sqlite(index: true)
  @Rest(name: 'uploadedAt')
  final DateTime uploadedAt;

  // Local-only fields for offline functionality
  @Sqlite(index: true)
  @Rest(ignore: true)
  final DateTime lastSyncedAt;

  @Sqlite()
  @Rest(ignore: true)
  final bool isFavorite;

  @Sqlite(index: true)
  @Rest(ignore: true)
  final bool needsSync;

  @Sqlite()
  @Rest(ignore: true)
  final String? deviceInfo;

  ExamPaper({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.syllabus,
    required this.year,
    required this.examPeriod,
    required this.examLevel,
    required this.paperType,
    this.province,
    required this.durationMinutes,
    this.instructions,
    this.totalMarks,
    this.isActive = true,
    required this.uploadedAt,
    DateTime? lastSyncedAt,
    this.isFavorite = false,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  ExamPaper copyWith({
    String? id,
    String? title,
    String? subject,
    String? grade,
    String? syllabus,
    int? year,
    String? examPeriod,
    String? examLevel,
    String? paperType,
    String? province,
    int? durationMinutes,
    String? instructions,
    int? totalMarks,
    bool? isActive,
    DateTime? uploadedAt,
    DateTime? lastSyncedAt,
    bool? isFavorite,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return ExamPaper(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      syllabus: syllabus ?? this.syllabus,
      year: year ?? this.year,
      examPeriod: examPeriod ?? this.examPeriod,
      examLevel: examLevel ?? this.examLevel,
      paperType: paperType ?? this.paperType,
      province: province ?? this.province,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      instructions: instructions ?? this.instructions,
      totalMarks: totalMarks ?? this.totalMarks,
      isActive: isActive ?? this.isActive,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      grade: json['grade'] ?? '',
      syllabus: json['syllabus'] ?? '',
      year: json['year'] ?? 0,
      examPeriod: json['examPeriod'] ?? '',
      examLevel: json['examLevel'] ?? '',
      paperType: json['paperType'] ?? '',
      province: json['province'],
      durationMinutes: json['durationMinutes'] ?? 0,
      instructions: json['instructions'],
      totalMarks: json['totalMarks'],
      isActive: json['isActive'] ?? true,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'grade': grade,
      'syllabus': syllabus,
      'year': year,
      'examPeriod': examPeriod,
      'examLevel': examLevel,
      'paperType': paperType,
      'province': province,
      'durationMinutes': durationMinutes,
      'instructions': instructions,
      'totalMarks': totalMarks,
      'isActive': isActive,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
    };
  }
}
