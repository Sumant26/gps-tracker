/// Base exception for all application-level exceptions.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a Hive storage operation fails.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Thrown when a location fetch or stream operation fails.
class LocationException extends AppException {
  const LocationException(super.message);
}

/// Thrown when a native battery channel call fails.
class BatteryException extends AppException {
  const BatteryException(super.message);
}

/// Thrown when a required permission is not granted.
class PermissionException extends AppException {
  const PermissionException(super.message);
}
