/// Strings and messages related to permission flows.
class PermissionConstants {
  PermissionConstants._();

  static const String locationRequiredTitle = 'Location Access Required';
  static const String locationRequiredMessage =
      'GPS Tracker needs location access to record your route. '
      'Please grant permission to continue.';

  static const String backgroundLocationTitle = 'Always Allow Location';
  static const String backgroundLocationMessage =
      'To track your route while the app is in the background, '
      'please set location access to "Always" in Settings.';

  static const String openSettingsButton = 'Open Settings';
  static const String grantPermissionButton = 'Grant Permission';
  static const String notNowButton = 'Not Now';
}
