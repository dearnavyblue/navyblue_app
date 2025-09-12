// lib/brick/repository.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import 'database_factory.dart';
import 'path_provider.dart';

// Import generated files
import 'brick.g.dart';
import 'db/schema.g.dart';

// Export query classes for easy access
export 'package:brick_core/query.dart'
    show And, Or, Query, QueryAction, Where, WherePhrase;

class Repository extends OfflineFirstWithRestRepository {
  static Repository? _instance;

  // Private constructor that takes database paths
  Repository._({
    required String mainDbPath,
    required String queueDbPath,
  }) : super(
          migrations: migrations,
          restProvider: RestProvider(
            AppConfig.apiBaseUrl,
            modelDictionary: restModelDictionary,
          ),
          sqliteProvider: SqliteProvider(
            mainDbPath,
            databaseFactory: getDatabaseFactory(), // Using your factory
            modelDictionary: sqliteModelDictionary,
          ),
          offlineQueueManager: RestRequestSqliteCacheManager(
            queueDbPath,
            databaseFactory: getDatabaseFactory(), // Using your factory
          ),
        );

  /// Singleton instance
  static Repository get instance {
    if (_instance == null) {
      throw StateError(
          'Repository not configured. Call Repository.configure() first.');
    }
    return _instance!;
  }

  /// Initialize the repository with proper database paths
  static Future<void> configure() async {
    try {
      // Initialize platform-specific database factory using your method
      initializeDatabaseFactory();

      // Get platform-appropriate database paths using your pattern
      final dbPaths = await getPlatformDatabasePaths();

      // Create the repository instance with proper paths
      _instance = Repository._(
        mainDbPath: dbPaths['mainDbPath']!,
        queueDbPath: dbPaths['queueDbPath']!,
      );

      // Initialize the repository
      await _instance!.initialize();

      if (kDebugMode) {
        print(
            'Repository configured successfully for ${kIsWeb ? 'web' : 'mobile'}');
        print('Main DB path: ${dbPaths['mainDbPath']}');
        print('Queue DB path: ${dbPaths['queueDbPath']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configuring repository: $e');
      }

      if (kIsWeb) {
        print(
            'Web database configuration failed, this might affect offline functionality');
      }
      rethrow;
    }
  }
}
