// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Question> _$QuestionFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return Question(
      id: data['id'] as String,
      paperId: data['paperId'] as String,
      questionNumber: data['questionNumber'] as String,
      contextText: data['contextText'] as String,
      contextImages: data['contextImages'].toList().cast<String>(),
      topics: data['topics'].toList().cast<String>(),
      totalMarks: data['totalMarks'] as int?,
      orderIndex: data['orderIndex'] as int,
      pageNumber: data['pageNumber'] as int,
      questionText: data['questionText'] as String?,
      hintText: data['hintText'] as String?,
      isActive: data['isActive'] as bool,
      createdAt: DateTime.parse(data['createdAt'] as String),
      parts: await Future.wait<QuestionPart>(data['parts']
              ?.map((d) => QuestionPartAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<QuestionPart>>() ??
          []),
      solutionSteps: await Future.wait<SolutionStep>(data['solutionSteps']
              ?.map((d) => SolutionStepAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<SolutionStep>>() ??
          []));
}

Future<Map<String, dynamic>> _$QuestionToRest(Question instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'paperId': instance.paperId,
    'questionNumber': instance.questionNumber,
    'contextText': instance.contextText,
    'contextImages': instance.contextImages,
    'topics': instance.topics,
    'totalMarks': instance.totalMarks,
    'orderIndex': instance.orderIndex,
    'pageNumber': instance.pageNumber,
    'questionText': instance.questionText,
    'hintText': instance.hintText,
    'isActive': instance.isActive,
    'createdAt': instance.createdAt.toIso8601String(),
    'parts': await Future.wait<Map<String, dynamic>>(instance.parts
        .map((s) => QuestionPartAdapter()
            .toRest(s, provider: provider, repository: repository))
        .toList()),
    'solutionSteps': await Future.wait<Map<String, dynamic>>(instance
        .solutionSteps
        .map((s) => SolutionStepAdapter()
            .toRest(s, provider: provider, repository: repository))
        .toList()),
    'is_simple_question': instance.isSimpleQuestion,
    'is_multi_part_question': instance.isMultiPartQuestion
  };
}

Future<Question> _$QuestionFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return Question(
      id: data['id'] as String,
      paperId: data['paper_id'] as String,
      questionNumber: data['question_number'] as String,
      contextText: data['context_text'] as String,
      contextImages: jsonDecode(data['context_images']).toList().cast<String>(),
      topics: jsonDecode(data['topics']).toList().cast<String>(),
      totalMarks:
          data['total_marks'] == null ? null : data['total_marks'] as int?,
      orderIndex: data['order_index'] as int,
      pageNumber: data['page_number'] as int,
      questionText: data['question_text'] == null
          ? null
          : data['question_text'] as String?,
      hintText: data['hint_text'] == null ? null : data['hint_text'] as String?,
      isActive: data['is_active'] == 1,
      createdAt: DateTime.parse(data['created_at'] as String),
      parts: (await provider.rawQuery(
              'SELECT DISTINCT `f_QuestionPart_brick_id` FROM `_brick_Question_parts` WHERE l_Question_brick_id = ?',
              [
            data['_brick_id'] as int
          ]).then((results) {
        final ids = results.map((r) => r['f_QuestionPart_brick_id']);
        return Future.wait<QuestionPart>(ids.map((primaryKey) => repository!
            .getAssociation<QuestionPart>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<QuestionPart>(),
      solutionSteps: (await provider.rawQuery(
              'SELECT DISTINCT `f_SolutionStep_brick_id` FROM `_brick_Question_solution_steps` WHERE l_Question_brick_id = ?',
              [
            data['_brick_id'] as int
          ]).then((results) {
        final ids = results.map((r) => r['f_SolutionStep_brick_id']);
        return Future.wait<SolutionStep>(ids.map((primaryKey) => repository!
            .getAssociation<SolutionStep>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<SolutionStep>(),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$QuestionToSqlite(Question instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'paper_id': instance.paperId,
    'question_number': instance.questionNumber,
    'context_text': instance.contextText,
    'context_images': jsonEncode(instance.contextImages),
    'topics': jsonEncode(instance.topics),
    'total_marks': instance.totalMarks,
    'order_index': instance.orderIndex,
    'page_number': instance.pageNumber,
    'question_text': instance.questionText,
    'hint_text': instance.hintText,
    'is_active': instance.isActive ? 1 : 0,
    'created_at': instance.createdAt.toIso8601String(),
    'parts': jsonEncode(instance.parts),
    'solution_steps': jsonEncode(instance.solutionSteps),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'is_simple_question': instance.isSimpleQuestion ? 1 : 0,
    'is_multi_part_question': instance.isMultiPartQuestion ? 1 : 0
  };
}

/// Construct a [Question]
class QuestionAdapter extends OfflineFirstWithRestAdapter<Question> {
  QuestionAdapter();

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
    'paperId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'paper_id',
      iterable: false,
      type: String,
    ),
    'questionNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'question_number',
      iterable: false,
      type: String,
    ),
    'contextText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'context_text',
      iterable: false,
      type: String,
    ),
    'contextImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'context_images',
      iterable: true,
      type: String,
    ),
    'topics': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'topics',
      iterable: true,
      type: String,
    ),
    'totalMarks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_marks',
      iterable: false,
      type: int,
    ),
    'orderIndex': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'order_index',
      iterable: false,
      type: int,
    ),
    'pageNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'page_number',
      iterable: false,
      type: int,
    ),
    'questionText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'question_text',
      iterable: false,
      type: String,
    ),
    'hintText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'hint_text',
      iterable: false,
      type: String,
    ),
    'isActive': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_active',
      iterable: false,
      type: bool,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
    'parts': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'parts',
      iterable: true,
      type: Map,
    ),
    'solutionSteps': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'solution_steps',
      iterable: true,
      type: Map,
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
    'isSimpleQuestion': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_simple_question',
      iterable: false,
      type: bool,
    ),
    'isMultiPartQuestion': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_multi_part_question',
      iterable: false,
      type: bool,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      Question instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `Question` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Question';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final partsOldColumns = await provider.rawQuery(
          'SELECT `f_QuestionPart_brick_id` FROM `_brick_Question_parts` WHERE `l_Question_brick_id` = ?',
          [instance.primaryKey]);
      final partsOldIds =
          partsOldColumns.map((a) => a['f_QuestionPart_brick_id']);
      final partsNewIds =
          instance.parts.map((s) => s.primaryKey).whereType<int>();
      final partsIdsToDelete =
          partsOldIds.where((id) => !partsNewIds.contains(id));

      await Future.wait<void>(partsIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_Question_parts` WHERE `l_Question_brick_id` = ? AND `f_QuestionPart_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.parts.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<QuestionPart>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Question_parts` (`l_Question_brick_id`, `f_QuestionPart_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      final solutionStepsOldColumns = await provider.rawQuery(
          'SELECT `f_SolutionStep_brick_id` FROM `_brick_Question_solution_steps` WHERE `l_Question_brick_id` = ?',
          [instance.primaryKey]);
      final solutionStepsOldIds =
          solutionStepsOldColumns.map((a) => a['f_SolutionStep_brick_id']);
      final solutionStepsNewIds =
          instance.solutionSteps.map((s) => s.primaryKey).whereType<int>();
      final solutionStepsIdsToDelete =
          solutionStepsOldIds.where((id) => !solutionStepsNewIds.contains(id));

      await Future.wait<void>(solutionStepsIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_Question_solution_steps` WHERE `l_Question_brick_id` = ? AND `f_SolutionStep_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.solutionSteps.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<SolutionStep>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Question_solution_steps` (`l_Question_brick_id`, `f_SolutionStep_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  @override
  Future<Question> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(Question input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionToRest(input, provider: provider, repository: repository);
  @override
  Future<Question> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(Question input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionToSqlite(input,
          provider: provider, repository: repository);
}
