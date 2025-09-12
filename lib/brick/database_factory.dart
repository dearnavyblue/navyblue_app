// lib/brick/database_factory.dart
import 'package:sqflite_common/sqlite_api.dart';
import 'database_factory_stub.dart'
    if (dart.library.io) 'database_factory_io.dart'
    if (dart.library.js) 'database_factory_web.dart';

// This will be implemented by platform-specific files
DatabaseFactory getDatabaseFactory() => createDatabaseFactory();

// Initialization function
void initializeDatabaseFactory() => initDatabase();