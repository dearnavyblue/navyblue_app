// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<MCQOption> _$MCQOptionFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return MCQOption(
      id: data['id'] as String,
      questionId: data['questionId'] as String?,
      partId: data['partId'] as String?,
      label: data['label'] as String,
      text: data['text'] as String?,
      optionImages: data['optionImages'].toList().cast<String>(),
      isCorrect: data['isCorrect'] as bool,
      orderIndex: data['orderIndex'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String));
}

Future<Map<String, dynamic>> _$MCQOptionToRest(MCQOption instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'questionId': instance.questionId,
    'partId': instance.partId,
    'label': instance.label,
    'text': instance.text,
    'optionImages': instance.optionImages,
    'isCorrect': instance.isCorrect,
    'orderIndex': instance.orderIndex,
    'createdAt': instance.createdAt.toIso8601String(),
    'has_text': instance.hasText,
    'has_images': instance.hasImages,
    'belongs_to_question': instance.belongsToQuestion,
    'belongs_to_part': instance.belongsToPart
  };
}

Future<MCQOption> _$MCQOptionFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return MCQOption(
      id: data['id'] as String,
      questionId:
          data['question_id'] == null ? null : data['question_id'] as String?,
      partId: data['part_id'] == null ? null : data['part_id'] as String?,
      label: data['label'] as String,
      text: data['text'] == null ? null : data['text'] as String?,
      optionImages: jsonDecode(data['option_images']).toList().cast<String>(),
      isCorrect: data['is_correct'] == 1,
      orderIndex: data['order_index'] as int,
      createdAt: DateTime.parse(data['created_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MCQOptionToSqlite(MCQOption instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'question_id': instance.questionId,
    'part_id': instance.partId,
    'label': instance.label,
    'text': instance.text,
    'option_images': jsonEncode(instance.optionImages),
    'is_correct': instance.isCorrect ? 1 : 0,
    'order_index': instance.orderIndex,
    'created_at': instance.createdAt.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'has_text': instance.hasText ? 1 : 0,
    'has_images': instance.hasImages ? 1 : 0,
    'belongs_to_question': instance.belongsToQuestion ? 1 : 0,
    'belongs_to_part': instance.belongsToPart ? 1 : 0
  };
}

/// Construct a [MCQOption]
class MCQOptionAdapter extends OfflineFirstWithRestAdapter<MCQOption> {
  MCQOptionAdapter();

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
    'questionId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'question_id',
      iterable: false,
      type: String,
    ),
    'partId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'part_id',
      iterable: false,
      type: String,
    ),
    'label': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'label',
      iterable: false,
      type: String,
    ),
    'text': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'text',
      iterable: false,
      type: String,
    ),
    'optionImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'option_images',
      iterable: true,
      type: String,
    ),
    'isCorrect': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_correct',
      iterable: false,
      type: bool,
    ),
    'orderIndex': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'order_index',
      iterable: false,
      type: int,
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
    'hasText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_text',
      iterable: false,
      type: bool,
    ),
    'hasImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_images',
      iterable: false,
      type: bool,
    ),
    'belongsToQuestion': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'belongs_to_question',
      iterable: false,
      type: bool,
    ),
    'belongsToPart': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'belongs_to_part',
      iterable: false,
      type: bool,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      MCQOption instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `MCQOption` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'MCQOption';

  @override
  Future<MCQOption> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MCQOptionFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(MCQOption input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MCQOptionToRest(input,
          provider: provider, repository: repository);
  @override
  Future<MCQOption> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MCQOptionFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(MCQOption input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$MCQOptionToSqlite(input,
          provider: provider, repository: repository);
}
