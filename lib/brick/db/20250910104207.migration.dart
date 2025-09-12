// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250910104207_up = [
  DropColumn('hint_text', onTable: 'SolutionStep'),
  InsertColumn('hint_text', Column.varchar, onTable: 'Question'),
  InsertColumn('hint_text', Column.varchar, onTable: 'QuestionPart')
];

const List<MigrationCommand> _migration_20250910104207_down = [
  DropColumn('hint_text', onTable: 'Question'),
  DropColumn('hint_text', onTable: 'QuestionPart')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250910104207',
  up: _migration_20250910104207_up,
  down: _migration_20250910104207_down,
)
class Migration20250910104207 extends Migration {
  const Migration20250910104207()
    : super(
        version: 20250910104207,
        up: _migration_20250910104207_up,
        down: _migration_20250910104207_down,
      );
}
