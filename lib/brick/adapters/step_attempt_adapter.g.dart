// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<StepAttempt> _$StepAttemptFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return StepAttempt(
      id: data['id'] as String,
      studentAttemptId: data['studentAttemptId'] as String,
      stepId: data['stepId'] as String,
      status: data['status'] as String,
      markedAt: data['markedAt'] == null
          ? null
          : DateTime.tryParse(data['markedAt'] as String));
}

Future<Map<String, dynamic>> _$StepAttemptToRest(StepAttempt instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'studentAttemptId': instance.studentAttemptId,
    'stepId': instance.stepId,
    'status': instance.status,
    'markedAt': instance.markedAt.toIso8601String(),
    'is_correct': instance.isCorrect,
    'is_incorrect': instance.isIncorrect,
    'is_not_attempted': instance.isNotAttempted
  };
}

Future<StepAttempt> _$StepAttemptFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return StepAttempt(
      id: data['id'] as String,
      studentAttemptId: data['student_attempt_id'] as String,
      stepId: data['step_id'] as String,
      status: data['status'] as String,
      markedAt: DateTime.parse(data['marked_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$StepAttemptToSqlite(StepAttempt instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'student_attempt_id': instance.studentAttemptId,
    'step_id': instance.stepId,
    'status': instance.status,
    'marked_at': instance.markedAt.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'is_correct': instance.isCorrect ? 1 : 0,
    'is_incorrect': instance.isIncorrect ? 1 : 0,
    'is_not_attempted': instance.isNotAttempted ? 1 : 0
  };
}

/// Construct a [StepAttempt]
class StepAttemptAdapter extends OfflineFirstWithRestAdapter<StepAttempt> {
  StepAttemptAdapter();

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
    'studentAttemptId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'student_attempt_id',
      iterable: false,
      type: String,
    ),
    'stepId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'step_id',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: String,
    ),
    'markedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'marked_at',
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
    'isCorrect': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_correct',
      iterable: false,
      type: bool,
    ),
    'isIncorrect': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_incorrect',
      iterable: false,
      type: bool,
    ),
    'isNotAttempted': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_not_attempted',
      iterable: false,
      type: bool,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      StepAttempt instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `StepAttempt` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'StepAttempt';

  @override
  Future<StepAttempt> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StepAttemptFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(StepAttempt input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StepAttemptToRest(input,
          provider: provider, repository: repository);
  @override
  Future<StepAttempt> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StepAttemptFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(StepAttempt input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StepAttemptToSqlite(input,
          provider: provider, repository: repository);
}
