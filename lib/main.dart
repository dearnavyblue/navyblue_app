// lib/main.dart
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/startup/app_startup_widget.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only non-failable initialization here
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Skip URL strategy for now to avoid web import issues
    print('Basic Flutter setup completed');
  } catch (e) {
    print('Basic setup failed: $e');
  }

  usePathUrlStrategy();
  await TeXRenderingServer.start();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only in debug mode
      builder: (context) => const ProviderScope(child: NavyBlueApp()),
    ),
  );
}

class NavyBlueApp extends StatelessWidget {
  const NavyBlueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      home: const AppStartupWidget(),
    );
  }
}
