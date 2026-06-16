import 'dart:async';
import '../../../../config/env/app_env.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_local_data_source.dart';
import '../datasources/location_service.dart';

/// Concrete implementation of [TrackingRepository].
///
/// Orchestrates [TrackingLocalDataSource] for persistence and
/// [LocationService] for GPS capture.
class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource _localDataSource;
  final LocationService _locationService;

  // Internal broadcast controller so multiple listeners can subscribe.
  final _locationController =
      StreamController<LocationPoint>.broadcast();
  StreamSubscription<LocationPoint>? _locationSub;

  TrackingRepositoryImpl(this._localDataSource, this._locationService);

  @override
  Future<TrackingSession> startSession() async {
    final session = await _localDataSource.createSession();

    // Bridge location service stream → internal controller.
    final locationStream = _locationService.startTracking(
      sessionId: session.id,
      intervalSeconds: AppEnv.locationInterval,
    );

    _locationSub = locationStream.listen(
      (point) async {
        await _localDataSource.savePoint(point);
        _locationController.add(point);
      },
    );

    return session;
  }

  @override
  Future<void> stopSession(String sessionId) async {
    await _locationService.stopTracking();
    await _locationSub?.cancel();
    _locationSub = null;
    await _localDataSource.endSession(sessionId);
  }

  @override
  Future<void> saveLocationPoint(LocationPoint point) =>
      _localDataSource.savePoint(point);

  @override
  Future<TrackingSession?> getActiveSession() async =>
      _localDataSource.getActiveSession();

  @override
  Stream<LocationPoint> watchLocationPoints(String sessionId) =>
      _locationController.stream
          .where((p) => p.sessionId == sessionId);
}
