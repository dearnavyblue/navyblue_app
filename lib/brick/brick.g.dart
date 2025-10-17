// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_rest/brick_rest.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:navyblue_app/brick/models/mcq_option.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:navyblue_app/brick/models/question_part.model.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:navyblue_app/brick/models/solution_step.model.dart';// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_rest/brick_rest.dart' show RestProvider, RestModel, RestAdapter, RestModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../brick/models/exam_paper.model.dart';
import '../brick/models/mcq_option.model.dart';
import '../brick/models/paper_filters.model.dart';
import '../brick/models/question.model.dart';
import '../brick/models/question_part.model.dart';
import '../brick/models/solution_step.model.dart';
import '../brick/models/step_attempt.model.dart';
import '../brick/models/student_attempt.model.dart';
import '../brick/models/user.model.dart';

part 'adapters/exam_paper_adapter.g.dart';
part 'adapters/m_c_q_option_adapter.g.dart';
part 'adapters/paper_filters_adapter.g.dart';
part 'adapters/question_adapter.g.dart';
part 'adapters/question_part_adapter.g.dart';
part 'adapters/solution_step_adapter.g.dart';
part 'adapters/step_attempt_adapter.g.dart';
part 'adapters/student_attempt_adapter.g.dart';
part 'adapters/user_adapter.g.dart';

/// Rest mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  ExamPaper: ExamPaperAdapter(),
  MCQOption: MCQOptionAdapter(),
  PaperFilters: PaperFiltersAdapter(),
  Question: QuestionAdapter(),
  QuestionPart: QuestionPartAdapter(),
  SolutionStep: SolutionStepAdapter(),
  StepAttempt: StepAttemptAdapter(),
  StudentAttempt: StudentAttemptAdapter(),
  User: UserAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  ExamPaper: ExamPaperAdapter(),
  MCQOption: MCQOptionAdapter(),
  PaperFilters: PaperFiltersAdapter(),
  Question: QuestionAdapter(),
  QuestionPart: QuestionPartAdapter(),
  SolutionStep: SolutionStepAdapter(),
  StepAttempt: StepAttemptAdapter(),
  StudentAttempt: StudentAttemptAdapter(),
  User: UserAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
