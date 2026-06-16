import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and exposes environment-specific configuration values.
class AppEnv {
  AppEnv._();

  /// Loads the appropriate .env file.
  /// Call once from [main] before [runApp].
  static Future<void> load({String env = 'dev'}) async {
    await dotenv.load(fileName: '.env.$env');
  }

  /// Application display name.
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'GPS Tracker';

  /// Location capture interval in seconds.
  static int get locationInterval =>
      int.tryParse(dotenv.env['LOCATION_INTERVAL'] ?? '60') ?? 60;

  /// Whether verbose logging is enabled.
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  /// OpenStreetMap tile URL template.
  static String get mapTileUrl =>
      dotenv.env['MAP_TILE_URL'] ??
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
