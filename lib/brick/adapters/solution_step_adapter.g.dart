// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SolutionStep> _$SolutionStepFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return SolutionStep(
      id: data['id'] as String,
      partId: data['partId'] as String?,
      questionId: data['questionId'] as String?,
      stepNumber: data['stepNumber'] as int,
      description: data['description'] as String,
      workingOut: data['workingOut'] as String?,
      marksForThisStep: data['marksForThisStep'] as int?,
      solutionImages: data['solutionImages'].toList().cast<String>(),
      teachingNote: data['teachingNote'] as String?,
      orderIndex: data['orderIndex'] as int,
      isCriticalStep: data['isCriticalStep'] as bool,
      createdAt: DateTime.parse(data['createdAt'] as String));
}

Future<Map<String, dynamic>> _$SolutionStepToRest(SolutionStep instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'partId': instance.partId,
    'questionId': instance.questionId,
    'stepNumber': instance.stepNumber,
    'description': instance.description,
    'workingOut': instance.workingOut,
    'marksForThisStep': instance.marksForThisStep,
    'solutionImages': instance.solutionImages,
    'teachingNote': instance.teachingNote,
    'orderIndex': instance.orderIndex,
    'isCriticalStep': instance.isCriticalStep,
    'createdAt': instance.createdAt.toIso8601String(),
    'belongs_to_part': instance.belongsToPart,
    'belongs_to_question': instance.belongsToQuestion,
    'has_images': instance.hasImages,
    'has_working_out': instance.hasWorkingOut,
    'has_teaching_note': instance.hasTeachingNote,
    'has_marks': instance.hasMarks
  };
}

Future<SolutionStep> _$SolutionStepFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return SolutionStep(
      id: data['id'] as String,
      partId: data['part_id'] == null ? null : data['part_id'] as String?,
      questionId:
          data['question_id'] == null ? null : data['question_id'] as String?,
      stepNumber: data['step_number'] as int,
      description: data['description'] as String,
      workingOut:
          data['working_out'] == null ? null : data['working_out'] as String?,
      marksForThisStep: data['marks_for_this_step'] == null
          ? null
          : data['marks_for_this_step'] as int?,
      solutionImages:
          jsonDecode(data['solution_images']).toList().cast<String>(),
      teachingNote: data['teaching_note'] == null
          ? null
          : data['teaching_note'] as String?,
      orderIndex: data['order_index'] as int,
      isCriticalStep: data['is_critical_step'] == 1,
      createdAt: DateTime.parse(data['created_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SolutionStepToSqlite(SolutionStep instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'part_id': instance.partId,
    'question_id': instance.questionId,
    'step_number': instance.stepNumber,
    'description': instance.description,
    'working_out': instance.workingOut,
    'marks_for_this_step': instance.marksForThisStep,
    'solution_images': jsonEncode(instance.solutionImages),
    'teaching_note': instance.teachingNote,
    'order_index': instance.orderIndex,
    'is_critical_step': instance.isCriticalStep ? 1 : 0,
    'created_at': instance.createdAt.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'belongs_to_part': instance.belongsToPart ? 1 : 0,
    'belongs_to_question': instance.belongsToQuestion ? 1 : 0,
    'has_images': instance.hasImages ? 1 : 0,
    'has_working_out': instance.hasWorkingOut ? 1 : 0,
    'has_teaching_note': instance.hasTeachingNote ? 1 : 0,
    'has_marks': instance.hasMarks ? 1 : 0
  };
}

/// Construct a [SolutionStep]
class SolutionStepAdapter extends OfflineFirstWithRestAdapter<SolutionStep> {
  SolutionStepAdapter();

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
    'partId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'part_id',
      iterable: false,
      type: String,
    ),
    'questionId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'question_id',
      iterable: false,
      type: String,
    ),
    'stepNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'step_number',
      iterable: false,
      type: int,
    ),
    'description': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description',
      iterable: false,
      type: String,
    ),
    'workingOut': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'working_out',
      iterable: false,
      type: String,
    ),
    'marksForThisStep': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'marks_for_this_step',
      iterable: false,
      type: int,
    ),
    'solutionImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'solution_images',
      iterable: true,
      type: String,
    ),
    'teachingNote': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'teaching_note',
      iterable: false,
      type: String,
    ),
    'orderIndex': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'order_index',
      iterable: false,
      type: int,
    ),
    'isCriticalStep': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_critical_step',
      iterable: false,
      type: bool,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
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
    ),
    'belongsToPart': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'belongs_to_part',
      iterable: false,
      type: bool,
    ),
    'belongsToQuestion': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'belongs_to_question',
      iterable: false,
      type: bool,
    ),
    'hasImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_images',
      iterable: false,
      type: bool,
    ),
    'hasWorkingOut': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_working_out',
      iterable: false,
      type: bool,
    ),
    'hasTeachingNote': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_teaching_note',
      iterable: false,
      type: bool,
    ),
    'hasMarks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_marks',
      iterable: false,
      type: bool,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      SolutionStep instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `SolutionStep` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'SolutionStep';

  @override
  Future<SolutionStep> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$SolutionStepFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(SolutionStep input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$SolutionStepToRest(input,
          provider: provider, repository: repository);
  @override
  Future<SolutionStep> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$SolutionStepFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(SolutionStep input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$SolutionStepToSqlite(input,
          provider: provider, repository: repository);
}
