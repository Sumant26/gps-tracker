import 'package:flutter/foundation.dart';
import '../../config/env/app_env.dart';

/// Simple structured logger that respects the [AppEnv.enableLogging] flag.
class AppLogger {
  AppLogger._();

  static void info(String tag, String message) {
    if (AppEnv.enableLogging || kDebugMode) {
      debugPrint('ℹ️  [$tag] $message');
    }
  }

  static void warning(String tag, String message) {
    if (AppEnv.enableLogging || kDebugMode) {
      debugPrint('⚠️  [$tag] $message');
    }
  }

  static void error(String tag, String message, [Object? error]) {
    if (AppEnv.enableLogging || kDebugMode) {
      debugPrint('❌  [$tag] $message${error != null ? '\n   $error' : ''}');
    }
  }

  static void debug(String tag, String message) {
    if (kDebugMode) {
      debugPrint('🐛  [$tag] $message');
    }
  }
}
