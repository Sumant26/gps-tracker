import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/logger.dart';

// ─── Repository interface ─────────────────────────────────────────────────────

/// Contract for device permission operations.
abstract class PermissionRepository {
  /// Returns true if fine location permission is granted.
  Future<bool> hasLocationPermission();

  /// Returns true if background (always) location permission is granted.
  Future<bool> hasBackgroundLocationPermission();

  /// Requests foreground location permission.
  /// Returns true if granted.
  Future<bool> requestLocationPermission();

  /// Requests background location permission.
  /// Returns true if granted.
  Future<bool> requestBackgroundLocationPermission();

  /// Opens the device settings page for this application.
  Future<void> openAppSettings();
}

// ─── Use cases ───────────────────────────────────────────────────────────────

/// Checks whether all required permissions are granted.
class CheckPermissionsUseCase {
  final PermissionRepository _repository;
  const CheckPermissionsUseCase(this._repository);

  Future<bool> call() async {
    final location = await _repository.hasLocationPermission();
    final background = await _repository.hasBackgroundLocationPermission();
    return location && background;
  }
}

/// Requests all required permissions sequentially.
class RequestPermissionsUseCase {
  final PermissionRepository _repository;
  const RequestPermissionsUseCase(this._repository);

  Future<bool> call() async {
    final location = await _repository.requestLocationPermission();
    if (!location) return false;
    final background =
        await _repository.requestBackgroundLocationPermission();
    return background;
  }
}

// ─── Repository implementation ────────────────────────────────────────────────

/// Concrete implementation of [PermissionRepository] using [permission_handler].
class PermissionRepositoryImpl implements PermissionRepository {
  static const _tag = 'PermissionRepositoryImpl';

  @override
  Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    AppLogger.info(_tag, 'Location permission: $status');
    return status.isGranted;
  }

  @override
  Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    AppLogger.info(_tag, 'Background location permission: $status');
    return status.isGranted;
  }

  @override
  Future<void> openAppSettings() => openAppSettings();
}
