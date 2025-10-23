// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20251023121303_up = [
  InsertColumn('context_topics', Column.varchar, onTable: 'Question'),
  InsertColumn('topics', Column.varchar, onTable: 'QuestionPart')
];

const List<MigrationCommand> _migration_20251023121303_down = [
  DropColumn('context_topics', onTable: 'Question'),
  DropColumn('topics', onTable: 'QuestionPart')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20251023121303',
  up: _migration_20251023121303_up,
  down: _migration_20251023121303_down,
)
class Migration20251023121303 extends Migration {
  const Migration20251023121303()
    : super(
        version: 20251023121303,
        up: _migration_20251023121303_up,
        down: _migration_20251023121303_down,
      );
}
