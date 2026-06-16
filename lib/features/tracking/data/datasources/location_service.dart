import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/location_point.dart';

/// Wraps [Geolocator] to emit timed [LocationPoint] captures.
///
/// On Android this class coordinates with the native foreground service
/// via a MethodChannel. On iOS it uses CLLocationManager background updates.
class LocationService {
  static const _tag = 'LocationService';
  final _uuid = const Uuid();

  StreamController<LocationPoint>? _controller;
  StreamSubscription<Position>? _positionSub;
  Timer? _intervalTimer;
  String? _activeSessionId;

  /// Returns true if location capture is currently running.
  bool get isTracking => _activeSessionId != null;

  /// Begins capturing [LocationPoint] values every
  /// [intervalSeconds] seconds for [sessionId].
  ///
  /// Emits points on the returned [Stream].
  Stream<LocationPoint> startTracking({
    required String sessionId,
    required int intervalSeconds,
  }) {
    _activeSessionId = sessionId;
    _controller = StreamController<LocationPoint>.broadcast();

    AppLogger.info(_tag, 'Starting tracking for session $sessionId');

    // Capture immediately, then on each interval tick.
    _capturePosition(sessionId);
    _intervalTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _capturePosition(sessionId),
    );

    return _controller!.stream;
  }

  /// Cancels the interval timer and closes the stream.
  Future<void> stopTracking() async {
    AppLogger.info(_tag, 'Stopping tracking for session $_activeSessionId');
    _intervalTimer?.cancel();
    _intervalTimer = null;
    await _positionSub?.cancel();
    _positionSub = null;
    await _controller?.close();
    _controller = null;
    _activeSessionId = null;
  }

  Future<void> _capturePosition(String sessionId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LocationPoint(
        id: _uuid.v4(),
        sessionId: sessionId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
      AppLogger.debug(_tag,
          'Captured: ${point.latitude}, ${point.longitude} ±${point.accuracy}m');
      _controller?.add(point);
    } catch (e) {
      AppLogger.error(_tag, 'Position capture failed', e);
      _controller?.addError(LocationException('Position capture failed: $e'));
    }
  }

  /// Returns the current device position once.
  Future<Position> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw LocationException('Failed to get position: $e');
    }
  }
}
