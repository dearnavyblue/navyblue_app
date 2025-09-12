// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250908123137_up = [
  InsertTable('_brick_Question_solution_steps'),
  InsertForeignKey('_brick_Question_solution_steps', 'Question', foreignKeyColumn: 'l_Question_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Question_solution_steps', 'SolutionStep', foreignKeyColumn: 'f_SolutionStep_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertColumn('question_text', Column.varchar, onTable: 'Question'),
  InsertColumn('solution_steps', Column.varchar, onTable: 'Question'),
  InsertColumn('is_simple_question', Column.boolean, onTable: 'Question'),
  InsertColumn('is_multi_part_question', Column.boolean, onTable: 'Question'),
  InsertColumn('question_id', Column.varchar, onTable: 'SolutionStep'),
  InsertColumn('belongs_to_part', Column.boolean, onTable: 'SolutionStep'),
  InsertColumn('belongs_to_question', Column.boolean, onTable: 'SolutionStep'),
  CreateIndex(columns: ['l_Question_brick_id', 'f_SolutionStep_brick_id'], onTable: '_brick_Question_solution_steps', unique: true)
];

const List<MigrationCommand> _migration_20250908123137_down = [
  DropTable('_brick_Question_solution_steps'),
  DropColumn('l_Question_brick_id', onTable: '_brick_Question_solution_steps'),
  DropColumn('f_SolutionStep_brick_id', onTable: '_brick_Question_solution_steps'),
  DropColumn('question_text', onTable: 'Question'),
  DropColumn('solution_steps', onTable: 'Question'),
  DropColumn('is_simple_question', onTable: 'Question'),
  DropColumn('is_multi_part_question', onTable: 'Question'),
  DropColumn('question_id', onTable: 'SolutionStep'),
  DropColumn('belongs_to_part', onTable: 'SolutionStep'),
  DropColumn('belongs_to_question', onTable: 'SolutionStep'),
  DropIndex('index__brick_Question_solution_steps_on_l_Question_brick_id_f_SolutionStep_brick_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250908123137',
  up: _migration_20250908123137_up,
  down: _migration_20250908123137_down,
)
class Migration20250908123137 extends Migration {
  const Migration20250908123137()
    : super(
        version: 20250908123137,
        up: _migration_20250908123137_up,
        down: _migration_20250908123137_down,
      );
}
