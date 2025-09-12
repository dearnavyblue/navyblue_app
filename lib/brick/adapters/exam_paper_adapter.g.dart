// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<ExamPaper> _$ExamPaperFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return ExamPaper(
      id: data['id'] as String,
      title: data['title'] as String,
      subject: data['subject'] as String,
      grade: data['grade'] as String,
      syllabus: data['syllabus'] as String,
      year: data['year'] as int,
      examPeriod: data['examPeriod'] as String,
      examLevel: data['examLevel'] as String,
      paperType: data['paperType'] as String,
      province: data['province'] as String?,
      durationMinutes: data['durationMinutes'] as int,
      instructions: data['instructions'] as String?,
      totalMarks: data['totalMarks'] as int?,
      isActive: data['isActive'] as bool,
      uploadedAt: DateTime.parse(data['uploadedAt'] as String));
}

Future<Map<String, dynamic>> _$ExamPaperToRest(ExamPaper instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'title': instance.title,
    'subject': instance.subject,
    'grade': instance.grade,
    'syllabus': instance.syllabus,
    'year': instance.year,
    'examPeriod': instance.examPeriod,
    'examLevel': instance.examLevel,
    'paperType': instance.paperType,
    'province': instance.province,
    'durationMinutes': instance.durationMinutes,
    'instructions': instance.instructions,
    'totalMarks': instance.totalMarks,
    'isActive': instance.isActive,
    'uploadedAt': instance.uploadedAt.toIso8601String()
  };
}

Future<ExamPaper> _$ExamPaperFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return ExamPaper(
      id: data['id'] as String,
      title: data['title'] as String,
      subject: data['subject'] as String,
      grade: data['grade'] as String,
      syllabus: data['syllabus'] as String,
      year: data['year'] as int,
      examPeriod: data['exam_period'] as String,
      examLevel: data['exam_level'] as String,
      paperType: data['paper_type'] as String,
      province: data['province'] == null ? null : data['province'] as String?,
      durationMinutes: data['duration_minutes'] as int,
      instructions:
          data['instructions'] == null ? null : data['instructions'] as String?,
      totalMarks:
          data['total_marks'] == null ? null : data['total_marks'] as int?,
      isActive: data['is_active'] == 1,
      uploadedAt: DateTime.parse(data['uploaded_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      isFavorite: data['is_favorite'] == 1,
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$ExamPaperToSqlite(ExamPaper instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'title': instance.title,
    'subject': instance.subject,
    'grade': instance.grade,
    'syllabus': instance.syllabus,
    'year': instance.year,
    'exam_period': instance.examPeriod,
    'exam_level': instance.examLevel,
    'paper_type': instance.paperType,
    'province': instance.province,
    'duration_minutes': instance.durationMinutes,
    'instructions': instance.instructions,
    'total_marks': instance.totalMarks,
    'is_active': instance.isActive ? 1 : 0,
    'uploaded_at': instance.uploadedAt.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'is_favorite': instance.isFavorite ? 1 : 0,
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo
  };
}

/// Construct a [ExamPaper]
class ExamPaperAdapter extends OfflineFirstWithRestAdapter<ExamPaper> {
  ExamPaperAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
    'title': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'title',
      iterable: false,
      type: String,
    ),
    'subject': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'subject',
      iterable: false,
      type: String,
    ),
    'grade': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'grade',
      iterable: false,
      type: String,
    ),
    'syllabus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'syllabus',
      iterable: false,
      type: String,
    ),
    'year': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'year',
      iterable: false,
      type: int,
    ),
    'examPeriod': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'exam_period',
      iterable: false,
      type: String,
    ),
    'examLevel': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'exam_level',
      iterable: false,
      type: String,
    ),
    'paperType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'paper_type',
      iterable: false,
      type: String,
    ),
    'province': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'province',
      iterable: false,
      type: String,
    ),
    'durationMinutes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'duration_minutes',
      iterable: false,
      type: int,
    ),
    'instructions': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'instructions',
      iterable: false,
      type: String,
    ),
    'totalMarks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_marks',
      iterable: false,
      type: int,
    ),
    'isActive': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_active',
      iterable: false,
      type: bool,
    ),
    'uploadedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'uploaded_at',
      iterable: false,
      type: DateTime,
    ),
    'lastSyncedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_synced_at',
      iterable: false,
      type: DateTime,
    ),
    'isFavorite': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_favorite',
      iterable: false,
      type: bool,
    ),
    'needsSync': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'needs_sync',
      iterable: false,
      type: bool,
    ),
    'deviceInfo': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'device_info',
      iterable: false,
      type: String,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      ExamPaper instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `ExamPaper` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'ExamPaper';

  @override
  Future<ExamPaper> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$ExamPaperFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(ExamPaper input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$ExamPaperToRest(input,
          provider: provider, repository: repository);
  @override
  Future<ExamPaper> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$ExamPaperFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(ExamPaper input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$ExamPaperToSqlite(input,
          provider: provider, repository: repository);
}
