import 'package:intl/intl.dart';

/// Utility methods for formatting dates and durations in the UI.
class DateUtils {
  DateUtils._();

  static final DateFormat _dateTimeFormat =
      DateFormat('MMM d, yyyy • HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');

  /// Formats [dateTime] as "Jan 5, 2024 • 14:30".
  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime);

  /// Formats [dateTime] as "14:30:45".
  static String formatTime(DateTime dateTime) =>
      _timeFormat.format(dateTime);

  /// Formats [dateTime] as "Jan 5".
  static String formatShortDate(DateTime dateTime) =>
      _shortDateFormat.format(dateTime);

  /// Converts a [Duration] to a human-readable string like "1h 23m 45s".
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
