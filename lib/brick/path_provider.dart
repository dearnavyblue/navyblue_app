// lib/brick/path_provider.dart
import 'path_provider_stub.dart'
    if (dart.library.io) 'path_provider_io.dart'
    if (dart.library.js) 'path_provider_web.dart';

// This will be implemented by platform-specific files
Future<Map<String, String>> getPlatformDatabasePaths() => getDatabasePaths();