// lib/brick/path_provider_io.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../core/config/app_config.dart';

Future<Map<String, String>> getDatabasePaths() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbDirectory = Directory(join(directory.path, 'databases'));
  
  // Create the directory if it doesn't exist
  if (!await dbDirectory.exists()) {
    await dbDirectory.create(recursive: true);
  }
  
  return {
    'mainDbPath': join(dbDirectory.path, AppConfig.databaseName),
    'queueDbPath': join(dbDirectory.path, 'navyblue_offline_queue.sqlite'),
  };
}