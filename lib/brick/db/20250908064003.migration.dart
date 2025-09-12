// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250908064003_up = [
  InsertTable('PaperFilters'),
  InsertColumn('id', Column.varchar, onTable: 'PaperFilters', unique: true),
  InsertColumn('subjects', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('grades', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('syllabi', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('years', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('paper_types', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('provinces', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('exam_periods', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('exam_levels', Column.varchar, onTable: 'PaperFilters'),
  InsertColumn('updated_at', Column.datetime, onTable: 'PaperFilters'),
  InsertColumn('last_synced_at', Column.datetime, onTable: 'PaperFilters'),
  InsertColumn('needs_sync', Column.boolean, onTable: 'PaperFilters'),
  InsertColumn('device_info', Column.varchar, onTable: 'PaperFilters')
];

const List<MigrationCommand> _migration_20250908064003_down = [
  DropTable('PaperFilters'),
  DropColumn('id', onTable: 'PaperFilters'),
  DropColumn('subjects', onTable: 'PaperFilters'),
  DropColumn('grades', onTable: 'PaperFilters'),
  DropColumn('syllabi', onTable: 'PaperFilters'),
  DropColumn('years', onTable: 'PaperFilters'),
  DropColumn('paper_types', onTable: 'PaperFilters'),
  DropColumn('provinces', onTable: 'PaperFilters'),
  DropColumn('exam_periods', onTable: 'PaperFilters'),
  DropColumn('exam_levels', onTable: 'PaperFilters'),
  DropColumn('updated_at', onTable: 'PaperFilters'),
  DropColumn('last_synced_at', onTable: 'PaperFilters'),
  DropColumn('needs_sync', onTable: 'PaperFilters'),
  DropColumn('device_info', onTable: 'PaperFilters')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250908064003',
  up: _migration_20250908064003_up,
  down: _migration_20250908064003_down,
)
class Migration20250908064003 extends Migration {
  const Migration20250908064003()
    : super(
        version: 20250908064003,
        up: _migration_20250908064003_up,
        down: _migration_20250908064003_down,
      );
}
