// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<QuestionPart> _$QuestionPartFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return QuestionPart(
      id: data['id'] as String,
      questionId: data['questionId'] as String,
      parentPartId: data['parentPartId'] as String?,
      partNumber: data['partNumber'] as String,
      partText: data['partText'] as String,
      marks: data['marks'] as int,
      partImages: data['partImages'].toList().cast<String>(),
      hintText: data['hintText'] as String?,
      nestingLevel: data['nestingLevel'] as int,
      orderIndex: data['orderIndex'] as int,
      requiresWorking: data['requiresWorking'] as bool,
      isActive: data['isActive'] as bool,
      createdAt: DateTime.parse(data['createdAt'] as String),
      mcqOptions: await Future.wait<MCQOption>(
          data['mcqOptions']?.map((d) => MCQOptionAdapter().fromRest(d, provider: provider, repository: repository)).toList().cast<Future<MCQOption>>() ??
              []),
      solutionSteps: await Future.wait<SolutionStep>(data['solutionSteps']
              ?.map((d) => SolutionStepAdapter()
                  .fromRest(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<SolutionStep>>() ??
          []),
      subParts: await Future.wait<QuestionPart>(data['subParts']
              ?.map((d) => QuestionPartAdapter().fromRest(d, provider: provider, repository: repository))
              .toList()
              .cast<Future<QuestionPart>>() ??
          []));
}

Future<Map<String, dynamic>> _$QuestionPartToRest(QuestionPart instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'questionId': instance.questionId,
    'parentPartId': instance.parentPartId,
    'partNumber': instance.partNumber,
    'partText': instance.partText,
    'marks': instance.marks,
    'partImages': instance.partImages,
    'hintText': instance.hintText,
    'nestingLevel': instance.nestingLevel,
    'orderIndex': instance.orderIndex,
    'requiresWorking': instance.requiresWorking,
    'isActive': instance.isActive,
    'createdAt': instance.createdAt.toIso8601String(),
    'mcqOptions': await Future.wait<Map<String, dynamic>>(instance.mcqOptions
            ?.map((s) => MCQOptionAdapter()
                .toRest(s, provider: provider, repository: repository))
            .toList() ??
        []),
    'solutionSteps': await Future.wait<Map<String, dynamic>>(instance
        .solutionSteps
        .map((s) => SolutionStepAdapter()
            .toRest(s, provider: provider, repository: repository))
        .toList()),
    'subParts': await Future.wait<Map<String, dynamic>>(instance.subParts
        .map((s) => QuestionPartAdapter()
            .toRest(s, provider: provider, repository: repository))
        .toList()),
    'has_sub_parts': instance.hasSubParts,
    'has_solution_steps': instance.hasSolutionSteps,
    'total_steps': instance.totalSteps,
    'is_m_c_q_part': instance.isMCQPart
  };
}

Future<QuestionPart> _$QuestionPartFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return QuestionPart(
      id: data['id'] as String,
      questionId: data['question_id'] as String,
      parentPartId: data['parent_part_id'] == null
          ? null
          : data['parent_part_id'] as String?,
      partNumber: data['part_number'] as String,
      partText: data['part_text'] as String,
      marks: data['marks'] as int,
      partImages: jsonDecode(data['part_images']).toList().cast<String>(),
      hintText: data['hint_text'] == null ? null : data['hint_text'] as String?,
      nestingLevel: data['nesting_level'] as int,
      orderIndex: data['order_index'] as int,
      requiresWorking: data['requires_working'] == 1,
      isActive: data['is_active'] == 1,
      createdAt: DateTime.parse(data['created_at'] as String),
      mcqOptions: (await provider.rawQuery('SELECT DISTINCT `f_MCQOption_brick_id` FROM `_brick_QuestionPart_mcq_options` WHERE l_QuestionPart_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_MCQOption_brick_id']);
        return Future.wait<MCQOption>(ids.map((primaryKey) => repository!
            .getAssociation<MCQOption>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<MCQOption>(),
      solutionSteps: (await provider
              .rawQuery('SELECT DISTINCT `f_SolutionStep_brick_id` FROM `_brick_QuestionPart_solution_steps` WHERE l_QuestionPart_brick_id = ?',
                  [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_SolutionStep_brick_id']);
        return Future.wait<SolutionStep>(ids.map((primaryKey) => repository!
            .getAssociation<SolutionStep>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<SolutionStep>(),
      subParts: (await provider.rawQuery(
              'SELECT DISTINCT `f_QuestionPart_brick_id` FROM `_brick_QuestionPart_sub_parts` WHERE l_QuestionPart_brick_id = ?',
              [data['_brick_id'] as int]).then((results) {
        final ids = results.map((r) => r['f_QuestionPart_brick_id']);
        return Future.wait<QuestionPart>(ids.map((primaryKey) => repository!
            .getAssociation<QuestionPart>(
              Query.where('primaryKey', primaryKey, limit1: true),
            )
            .then((r) => r!.first)));
      }))
          .toList()
          .cast<QuestionPart>(),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo: data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$QuestionPartToSqlite(QuestionPart instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'question_id': instance.questionId,
    'parent_part_id': instance.parentPartId,
    'part_number': instance.partNumber,
    'part_text': instance.partText,
    'marks': instance.marks,
    'part_images': jsonEncode(instance.partImages),
    'hint_text': instance.hintText,
    'nesting_level': instance.nestingLevel,
    'order_index': instance.orderIndex,
    'requires_working': instance.requiresWorking ? 1 : 0,
    'is_active': instance.isActive ? 1 : 0,
    'created_at': instance.createdAt.toIso8601String(),
    'mcq_options':
        instance.mcqOptions != null ? jsonEncode(instance.mcqOptions) : null,
    'solution_steps': jsonEncode(instance.solutionSteps),
    'sub_parts': jsonEncode(instance.subParts),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'has_sub_parts': instance.hasSubParts ? 1 : 0,
    'has_solution_steps': instance.hasSolutionSteps ? 1 : 0,
    'total_steps': instance.totalSteps,
    'is_m_c_q_part': instance.isMCQPart ? 1 : 0
  };
}

/// Construct a [QuestionPart]
class QuestionPartAdapter extends OfflineFirstWithRestAdapter<QuestionPart> {
  QuestionPartAdapter();

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
    'parentPartId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'parent_part_id',
      iterable: false,
      type: String,
    ),
    'partNumber': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'part_number',
      iterable: false,
      type: String,
    ),
    'partText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'part_text',
      iterable: false,
      type: String,
    ),
    'marks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'marks',
      iterable: false,
      type: int,
    ),
    'partImages': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'part_images',
      iterable: true,
      type: String,
    ),
    'hintText': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'hint_text',
      iterable: false,
      type: String,
    ),
    'nestingLevel': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'nesting_level',
      iterable: false,
      type: int,
    ),
    'orderIndex': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'order_index',
      iterable: false,
      type: int,
    ),
    'requiresWorking': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'requires_working',
      iterable: false,
      type: bool,
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
    'mcqOptions': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'mcq_options',
      iterable: true,
      type: Map,
    ),
    'solutionSteps': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'solution_steps',
      iterable: true,
      type: Map,
    ),
    'subParts': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'sub_parts',
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
    'hasSubParts': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_sub_parts',
      iterable: false,
      type: bool,
    ),
    'hasSolutionSteps': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'has_solution_steps',
      iterable: false,
      type: bool,
    ),
    'totalSteps': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_steps',
      iterable: false,
      type: int,
    ),
    'isMCQPart': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_m_c_q_part',
      iterable: false,
      type: bool,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      QuestionPart instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `QuestionPart` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'QuestionPart';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final mcqOptionsOldColumns = await provider.rawQuery(
          'SELECT `f_MCQOption_brick_id` FROM `_brick_QuestionPart_mcq_options` WHERE `l_QuestionPart_brick_id` = ?',
          [instance.primaryKey]);
      final mcqOptionsOldIds =
          mcqOptionsOldColumns.map((a) => a['f_MCQOption_brick_id']);
      final mcqOptionsNewIds =
          instance.mcqOptions?.map((s) => s.primaryKey).whereType<int>() ?? [];
      final mcqOptionsIdsToDelete =
          mcqOptionsOldIds.where((id) => !mcqOptionsNewIds.contains(id));

      await Future.wait<void>(mcqOptionsIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_QuestionPart_mcq_options` WHERE `l_QuestionPart_brick_id` = ? AND `f_MCQOption_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.mcqOptions?.map((s) async {
            final id = s.primaryKey ??
                await provider.upsert<MCQOption>(s, repository: repository);
            return await provider.rawInsert(
                'INSERT OR IGNORE INTO `_brick_QuestionPart_mcq_options` (`l_QuestionPart_brick_id`, `f_MCQOption_brick_id`) VALUES (?, ?)',
                [instance.primaryKey, id]);
          }) ??
          []);
    }

    if (instance.primaryKey != null) {
      final solutionStepsOldColumns = await provider.rawQuery(
          'SELECT `f_SolutionStep_brick_id` FROM `_brick_QuestionPart_solution_steps` WHERE `l_QuestionPart_brick_id` = ?',
          [instance.primaryKey]);
      final solutionStepsOldIds =
          solutionStepsOldColumns.map((a) => a['f_SolutionStep_brick_id']);
      final solutionStepsNewIds =
          instance.solutionSteps.map((s) => s.primaryKey).whereType<int>();
      final solutionStepsIdsToDelete =
          solutionStepsOldIds.where((id) => !solutionStepsNewIds.contains(id));

      await Future.wait<void>(solutionStepsIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_QuestionPart_solution_steps` WHERE `l_QuestionPart_brick_id` = ? AND `f_SolutionStep_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.solutionSteps.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<SolutionStep>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_QuestionPart_solution_steps` (`l_QuestionPart_brick_id`, `f_SolutionStep_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }

    if (instance.primaryKey != null) {
      final subPartsOldColumns = await provider.rawQuery(
          'SELECT `f_QuestionPart_brick_id` FROM `_brick_QuestionPart_sub_parts` WHERE `l_QuestionPart_brick_id` = ?',
          [instance.primaryKey]);
      final subPartsOldIds =
          subPartsOldColumns.map((a) => a['f_QuestionPart_brick_id']);
      final subPartsNewIds =
          instance.subParts.map((s) => s.primaryKey).whereType<int>();
      final subPartsIdsToDelete =
          subPartsOldIds.where((id) => !subPartsNewIds.contains(id));

      await Future.wait<void>(subPartsIdsToDelete.map((id) async {
        return await provider.rawExecute(
            'DELETE FROM `_brick_QuestionPart_sub_parts` WHERE `l_QuestionPart_brick_id` = ? AND `f_QuestionPart_brick_id` = ?',
            [instance.primaryKey, id]).catchError((e) => null);
      }));

      await Future.wait<int?>(instance.subParts.map((s) async {
        final id = s.primaryKey ??
            await provider.upsert<QuestionPart>(s, repository: repository);
        return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_QuestionPart_sub_parts` (`l_QuestionPart_brick_id`, `f_QuestionPart_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id]);
      }));
    }
  }

  @override
  Future<QuestionPart> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionPartFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(QuestionPart input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionPartToRest(input,
          provider: provider, repository: repository);
  @override
  Future<QuestionPart> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionPartFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(QuestionPart input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$QuestionPartToSqlite(input,
          provider: provider, repository: repository);
}
