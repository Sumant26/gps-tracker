/// Base failure class representing all domain-level failures.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Failure originating from local data storage operations.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failure originating from location service operations.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Failure originating from battery channel operations.
class BatteryFailure extends Failure {
  const BatteryFailure(super.message);
}

/// Failure due to missing or denied permissions.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Unexpected or unclassified failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
