// lib/brick/database_factory_io.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DatabaseFactory createDatabaseFactory() {
  return databaseFactoryFfi;
}

void initDatabase() {
  sqfliteFfiInit();
}