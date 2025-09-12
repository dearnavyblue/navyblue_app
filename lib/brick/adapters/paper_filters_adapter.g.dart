// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<PaperFilters> _$PaperFiltersFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return PaperFilters(
      id: data['id'] as String,
      subjects: data['subjects'].toList().cast<String>(),
      grades: data['grades'].toList().cast<String>(),
      syllabi: data['syllabi'].toList().cast<String>(),
      years: data['years'].toList().cast<int>(),
      paperTypes: data['paperTypes'].toList().cast<String>(),
      provinces: data['provinces'].toList().cast<String>(),
      examPeriods: data['examPeriods'].toList().cast<String>(),
      examLevels: data['examLevels'].toList().cast<String>(),
      updatedAt: DateTime.parse(data['updatedAt'] as String));
}

Future<Map<String, dynamic>> _$PaperFiltersToRest(PaperFilters instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'subjects': instance.subjects,
    'grades': instance.grades,
    'syllabi': instance.syllabi,
    'years': instance.years,
    'paperTypes': instance.paperTypes,
    'provinces': instance.provinces,
    'examPeriods': instance.examPeriods,
    'examLevels': instance.examLevels,
    'updatedAt': instance.updatedAt.toIso8601String()
  };
}

Future<PaperFilters> _$PaperFiltersFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return PaperFilters(
      id: data['id'] as String,
      subjects: jsonDecode(data['subjects']).toList().cast<String>(),
      grades: jsonDecode(data['grades']).toList().cast<String>(),
      syllabi: jsonDecode(data['syllabi']).toList().cast<String>(),
      years: jsonDecode(data['years']).toList().cast<int>(),
      paperTypes: jsonDecode(data['paper_types']).toList().cast<String>(),
      provinces: jsonDecode(data['provinces']).toList().cast<String>(),
      examPeriods: jsonDecode(data['exam_periods']).toList().cast<String>(),
      examLevels: jsonDecode(data['exam_levels']).toList().cast<String>(),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$PaperFiltersToSqlite(PaperFilters instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'subjects': jsonEncode(instance.subjects),
    'grades': jsonEncode(instance.grades),
    'syllabi': jsonEncode(instance.syllabi),
    'years': jsonEncode(instance.years),
    'paper_types': jsonEncode(instance.paperTypes),
    'provinces': jsonEncode(instance.provinces),
    'exam_periods': jsonEncode(instance.examPeriods),
    'exam_levels': jsonEncode(instance.examLevels),
    'updated_at': instance.updatedAt.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo
  };
}

/// Construct a [PaperFilters]
class PaperFiltersAdapter extends OfflineFirstWithRestAdapter<PaperFilters> {
  PaperFiltersAdapter();

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
    'subjects': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'subjects',
      iterable: true,
      type: String,
    ),
    'grades': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'grades',
      iterable: true,
      type: String,
    ),
    'syllabi': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'syllabi',
      iterable: true,
      type: String,
    ),
    'years': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'years',
      iterable: true,
      type: int,
    ),
    'paperTypes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'paper_types',
      iterable: true,
      type: String,
    ),
    'provinces': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'provinces',
      iterable: true,
      type: String,
    ),
    'examPeriods': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'exam_periods',
      iterable: true,
      type: String,
    ),
    'examLevels': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'exam_levels',
      iterable: true,
      type: String,
    ),
    'updatedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'updated_at',
      iterable: false,
      type: DateTime,
    ),
    'lastSyncedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_synced_at',
      iterable: false,
      type: DateTime,
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
      PaperFilters instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `PaperFilters` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'PaperFilters';

  @override
  Future<PaperFilters> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PaperFiltersFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(PaperFilters input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PaperFiltersToRest(input,
          provider: provider, repository: repository);
  @override
  Future<PaperFilters> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PaperFiltersFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(PaperFilters input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$PaperFiltersToSqlite(input,
          provider: provider, repository: repository);
}
