/// Represents the current state of the GPS tracking service.
enum TrackingStatus {
  /// No session is active.
  stopped,

  /// A session is currently recording location points.
  running,

  /// Transitioning between states.
  loading,
}
