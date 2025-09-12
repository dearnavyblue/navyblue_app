// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<StudentAttempt> _$StudentAttemptFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return StudentAttempt(
      id: data['id'] as String,
      paperId: data['paperId'] as String,
      mode: data['mode'] as String,
      enableHints: data['enableHints'] as bool,
      startedAt: DateTime.parse(data['startedAt'] as String),
      timerStartedAt: data['timerStartedAt'] == null
          ? null
          : DateTime.tryParse(data['timerStartedAt'] as String),
      completedAt: data['completedAt'] == null
          ? null
          : DateTime.tryParse(data['completedAt'] as String),
      lastActivityAt: data['lastActivityAt'] == null
          ? null
          : DateTime.tryParse(data['lastActivityAt'] as String),
      totalMarksEarned: data['totalMarksEarned'] as int?,
      totalMarksPossible: data['totalMarksPossible'] as int?,
      percentageScore: data['percentageScore'] as double?,
      timeSpentMinutes: data['timeSpentMinutes'] as int?,
      questionsAttempted: data['questionsAttempted'] as int,
      questionsCompleted: data['questionsCompleted'] as int,
      isAbandoned: data['isAbandoned'] as bool,
      autoSubmitted: data['autoSubmitted'] as bool,
      stepStatuses: data['stepStatuses'],
      calculatedProgress: data['calculatedProgress']);
}

Future<Map<String, dynamic>> _$StudentAttemptToRest(StudentAttempt instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'paperId': instance.paperId,
    'mode': instance.mode,
    'enableHints': instance.enableHints,
    'startedAt': instance.startedAt.toIso8601String(),
    'timerStartedAt': instance.timerStartedAt?.toIso8601String(),
    'completedAt': instance.completedAt?.toIso8601String(),
    'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
    'totalMarksEarned': instance.totalMarksEarned,
    'totalMarksPossible': instance.totalMarksPossible,
    'percentageScore': instance.percentageScore,
    'timeSpentMinutes': instance.timeSpentMinutes,
    'questionsAttempted': instance.questionsAttempted,
    'questionsCompleted': instance.questionsCompleted,
    'isAbandoned': instance.isAbandoned,
    'autoSubmitted': instance.autoSubmitted,
    'stepStatuses': instance.stepStatuses,
    'calculatedProgress': instance.calculatedProgress,
    'is_completed': instance.isCompleted,
    'is_in_progress': instance.isInProgress,
    'is_practice_mode': instance.isPracticeMode,
    'is_exam_mode': instance.isExamMode,
    'effective_last_activity_at':
        instance.effectiveLastActivityAt.toIso8601String(),
    'effective_last_synced_at':
        instance.effectiveLastSyncedAt.toIso8601String(),
    'progress_percentage': instance.progressPercentage,
    'marked_steps_count': instance.markedStepsCount,
    'correct_steps_count': instance.correctStepsCount,
    'calculated_earned_marks': instance.calculatedEarnedMarks,
    'calculated_possible_marks': instance.calculatedPossibleMarks,
    'calculated_marked_steps': instance.calculatedMarkedSteps,
    'calculated_total_steps': instance.calculatedTotalSteps
  };
}

Future<StudentAttempt> _$StudentAttemptFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return StudentAttempt(
      id: data['id'] as String,
      paperId: data['paper_id'] as String,
      mode: data['mode'] as String,
      enableHints: data['enable_hints'] == 1,
      startedAt: DateTime.parse(data['started_at'] as String),
      timerStartedAt: data['timer_started_at'] == null
          ? null
          : data['timer_started_at'] == null
              ? null
              : DateTime.tryParse(data['timer_started_at'] as String),
      completedAt: data['completed_at'] == null
          ? null
          : data['completed_at'] == null
              ? null
              : DateTime.tryParse(data['completed_at'] as String),
      lastActivityAt: data['last_activity_at'] == null
          ? null
          : data['last_activity_at'] == null
              ? null
              : DateTime.tryParse(data['last_activity_at'] as String),
      totalMarksEarned: data['total_marks_earned'] == null
          ? null
          : data['total_marks_earned'] as int?,
      totalMarksPossible: data['total_marks_possible'] == null
          ? null
          : data['total_marks_possible'] as int?,
      percentageScore: data['percentage_score'] == null
          ? null
          : data['percentage_score'] as double?,
      timeSpentMinutes: data['time_spent_minutes'] == null
          ? null
          : data['time_spent_minutes'] as int?,
      questionsAttempted: data['questions_attempted'] as int,
      questionsCompleted: data['questions_completed'] as int,
      isAbandoned: data['is_abandoned'] == 1,
      autoSubmitted: data['auto_submitted'] == 1,
      stepStatuses: data['step_statuses'] == null
          ? null
          : jsonDecode(data['step_statuses']),
      calculatedProgress: data['calculated_progress'] == null
          ? null
          : jsonDecode(data['calculated_progress']),
      lastSyncedAt: data['last_synced_at'] == null
          ? null
          : data['last_synced_at'] == null
              ? null
              : DateTime.tryParse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$StudentAttemptToSqlite(StudentAttempt instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'paper_id': instance.paperId,
    'mode': instance.mode,
    'enable_hints': instance.enableHints ? 1 : 0,
    'started_at': instance.startedAt.toIso8601String(),
    'timer_started_at': instance.timerStartedAt?.toIso8601String(),
    'completed_at': instance.completedAt?.toIso8601String(),
    'last_activity_at': instance.lastActivityAt?.toIso8601String(),
    'total_marks_earned': instance.totalMarksEarned,
    'total_marks_possible': instance.totalMarksPossible,
    'percentage_score': instance.percentageScore,
    'time_spent_minutes': instance.timeSpentMinutes,
    'questions_attempted': instance.questionsAttempted,
    'questions_completed': instance.questionsCompleted,
    'is_abandoned': instance.isAbandoned ? 1 : 0,
    'auto_submitted': instance.autoSubmitted ? 1 : 0,
    'step_statuses': jsonEncode(instance.stepStatuses ?? {}),
    'calculated_progress': jsonEncode(instance.calculatedProgress ?? {}),
    'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'is_completed': instance.isCompleted ? 1 : 0,
    'is_in_progress': instance.isInProgress ? 1 : 0,
    'is_practice_mode': instance.isPracticeMode ? 1 : 0,
    'is_exam_mode': instance.isExamMode ? 1 : 0,
    'effective_last_activity_at':
        instance.effectiveLastActivityAt.toIso8601String(),
    'effective_last_synced_at':
        instance.effectiveLastSyncedAt.toIso8601String(),
    'progress_percentage': instance.progressPercentage,
    'marked_steps_count': instance.markedStepsCount,
    'correct_steps_count': instance.correctStepsCount,
    'calculated_earned_marks': instance.calculatedEarnedMarks,
    'calculated_possible_marks': instance.calculatedPossibleMarks,
    'calculated_marked_steps': instance.calculatedMarkedSteps,
    'calculated_total_steps': instance.calculatedTotalSteps
  };
}

/// Construct a [StudentAttempt]
class StudentAttemptAdapter
    extends OfflineFirstWithRestAdapter<StudentAttempt> {
  StudentAttemptAdapter();

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
    'mode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'mode',
      iterable: false,
      type: String,
    ),
    'enableHints': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'enable_hints',
      iterable: false,
      type: bool,
    ),
    'startedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'started_at',
      iterable: false,
      type: DateTime,
    ),
    'timerStartedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'timer_started_at',
      iterable: false,
      type: DateTime,
    ),
    'completedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'completed_at',
      iterable: false,
      type: DateTime,
    ),
    'lastActivityAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_activity_at',
      iterable: false,
      type: DateTime,
    ),
    'totalMarksEarned': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_marks_earned',
      iterable: false,
      type: int,
    ),
    'totalMarksPossible': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'total_marks_possible',
      iterable: false,
      type: int,
    ),
    'percentageScore': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'percentage_score',
      iterable: false,
      type: double,
    ),
    'timeSpentMinutes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'time_spent_minutes',
      iterable: false,
      type: int,
    ),
    'questionsAttempted': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'questions_attempted',
      iterable: false,
      type: int,
    ),
    'questionsCompleted': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'questions_completed',
      iterable: false,
      type: int,
    ),
    'isAbandoned': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_abandoned',
      iterable: false,
      type: bool,
    ),
    'autoSubmitted': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'auto_submitted',
      iterable: false,
      type: bool,
    ),
    'stepStatuses': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'step_statuses',
      iterable: false,
      type: Map,
    ),
    'calculatedProgress': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'calculated_progress',
      iterable: false,
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
    'isCompleted': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_completed',
      iterable: false,
      type: bool,
    ),
    'isInProgress': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_in_progress',
      iterable: false,
      type: bool,
    ),
    'isPracticeMode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_practice_mode',
      iterable: false,
      type: bool,
    ),
    'isExamMode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_exam_mode',
      iterable: false,
      type: bool,
    ),
    'effectiveLastActivityAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'effective_last_activity_at',
      iterable: false,
      type: DateTime,
    ),
    'effectiveLastSyncedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'effective_last_synced_at',
      iterable: false,
      type: DateTime,
    ),
    'progressPercentage': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'progress_percentage',
      iterable: false,
      type: double,
    ),
    'markedStepsCount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'marked_steps_count',
      iterable: false,
      type: int,
    ),
    'correctStepsCount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'correct_steps_count',
      iterable: false,
      type: int,
    ),
    'calculatedEarnedMarks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'calculated_earned_marks',
      iterable: false,
      type: int,
    ),
    'calculatedPossibleMarks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'calculated_possible_marks',
      iterable: false,
      type: int,
    ),
    'calculatedMarkedSteps': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'calculated_marked_steps',
      iterable: false,
      type: int,
    ),
    'calculatedTotalSteps': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'calculated_total_steps',
      iterable: false,
      type: int,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      StudentAttempt instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `StudentAttempt` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'StudentAttempt';

  @override
  Future<StudentAttempt> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StudentAttemptFromRest(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(StudentAttempt input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StudentAttemptToRest(input,
          provider: provider, repository: repository);
  @override
  Future<StudentAttempt> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StudentAttemptFromSqlite(input,
          provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(StudentAttempt input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$StudentAttemptToSqlite(input,
          provider: provider, repository: repository);
}
