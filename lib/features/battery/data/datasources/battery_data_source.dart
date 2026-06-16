import 'package:flutter/services.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Native battery data source.
///
/// Uses a [MethodChannel] for one-time reads and an [EventChannel]
/// for streaming updates — no Flutter battery packages used.
class BatteryDataSource {
  static const _tag = 'BatteryDataSource';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  BatteryDataSource()
      : _methodChannel =
            const MethodChannel(AppConstants.batteryMethodChannel),
        _eventChannel =
            const EventChannel(AppConstants.batteryEventChannel);

  /// Invokes [getBatteryLevel] on the native side and returns the result.
  ///
  /// Throws [BatteryException] if the channel call fails.
  Future<int> getBatteryLevel() async {
    try {
      final level =
          await _methodChannel.invokeMethod<int>('getBatteryLevel');
      AppLogger.info(_tag, 'Battery level: $level%');
      return level ?? -1;
    } on PlatformException catch (e) {
      AppLogger.error(_tag, 'getBatteryLevel failed', e);
      throw BatteryException(e.message ?? 'Unknown battery error');
    }
  }

  /// Returns a [Stream] of battery level updates from the [EventChannel].
  ///
  /// Throws [BatteryException] if the stream encounters an error.
  Stream<int> watchBatteryLevel() {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as int)
        .handleError((Object e) {
      AppLogger.error(_tag, 'Battery stream error', e);
      throw BatteryException(e.toString());
    });
  }
}
