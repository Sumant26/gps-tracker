/// Core application constants used throughout the GPS Tracker app.
class AppConstants {
  AppConstants._();

  static const String appName = 'GPS Tracker';

  /// Location capture interval in seconds (from .env, default 60).
  static const int locationIntervalSeconds = 60;

  /// Android platform channel identifiers.
  static const String batteryMethodChannel = 'battery_channel';
  static const String batteryEventChannel = 'battery_event_channel';

  /// Android foreground service notification details.
  static const String trackingNotificationChannelId = 'gps_tracking_channel';
  static const String trackingNotificationChannelName = 'GPS Tracking';
  static const String trackingNotificationTitle = 'GPS Tracker Active';
  static const String trackingNotificationBody =
      'Recording your location in the background.';
  static const int trackingNotificationId = 1001;
}
