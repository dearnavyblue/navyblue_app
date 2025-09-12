// lib/brick/database_factory_web.dart
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

DatabaseFactory createDatabaseFactory() {
  return databaseFactoryFfiWeb;
}

void initDatabase() {
  // No initialization needed for web
}