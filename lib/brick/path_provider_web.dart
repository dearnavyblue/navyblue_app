// lib/brick/path_provider_web.dart
import '../core/config/app_config.dart';

Future<Map<String, String>> getDatabasePaths() async {
  // For web, use virtual paths that work with IndexedDB
  return {
    'mainDbPath': '/web_databases/${AppConfig.databaseName}',
    'queueDbPath': '/web_databases/navyblue_offline_queue.sqlite',
  };
}