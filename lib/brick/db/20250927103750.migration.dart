// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250927103750_up = [
  InsertTable('_brick_Question_organized_parts'),
  InsertForeignKey('_brick_Question_organized_parts', 'Question', foreignKeyColumn: 'l_Question_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Question_organized_parts', 'QuestionPart', foreignKeyColumn: 'f_QuestionPart_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertColumn('mcq_options', Column.varchar, onTable: 'Question'),
  InsertColumn('is_m_c_q_question', Column.boolean, onTable: 'Question'),
  InsertColumn('organized_parts', Column.varchar, onTable: 'Question'),
  InsertColumn('mcq_options', Column.varchar, onTable: 'QuestionPart'),
  InsertColumn('is_m_c_q_part', Column.boolean, onTable: 'QuestionPart'),
  CreateIndex(columns: ['l_Question_brick_id', 'f_QuestionPart_brick_id'], onTable: '_brick_Question_organized_parts', unique: true)
];

const List<MigrationCommand> _migration_20250927103750_down = [
  DropTable('_brick_Question_organized_parts'),
  DropColumn('l_Question_brick_id', onTable: '_brick_Question_organized_parts'),
  DropColumn('f_QuestionPart_brick_id', onTable: '_brick_Question_organized_parts'),
  DropColumn('mcq_options', onTable: 'Question'),
  DropColumn('is_m_c_q_question', onTable: 'Question'),
  DropColumn('organized_parts', onTable: 'Question'),
  DropColumn('mcq_options', onTable: 'QuestionPart'),
  DropColumn('is_m_c_q_part', onTable: 'QuestionPart'),
  DropIndex('index__brick_Question_organized_parts_on_l_Question_brick_id_f_QuestionPart_brick_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250927103750',
  up: _migration_20250927103750_up,
  down: _migration_20250927103750_down,
)
class Migration20250927103750 extends Migration {
  const Migration20250927103750()
    : super(
        version: 20250927103750,
        up: _migration_20250927103750_up,
        down: _migration_20250927103750_down,
      );
}
