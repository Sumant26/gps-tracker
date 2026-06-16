import 'package:flutter/material.dart';
import '../constants/route_constants.dart';
import '../../features/tracking/presentation/screens/home_screen.dart';
import '../../features/session/presentation/screens/session_list_screen.dart';
import '../../features/session/presentation/screens/session_detail_screen.dart';
import '../../features/permissions/presentation/screens/permission_denied_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../shared/models/tracking_session.dart';

/// Centralized route generator for the GPS Tracker application.
class AppRouter {
  AppRouter._();

  /// Generates the appropriate [Route] for the given [RouteSettings].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RouteConstants.sessionList:
        return MaterialPageRoute(builder: (_) => const SessionListScreen());

      case RouteConstants.sessionDetail:
        final session = settings.arguments as TrackingSession;
        return MaterialPageRoute(
          builder: (_) => SessionDetailScreen(session: session),
        );

      case RouteConstants.permissionDenied:
        final isBackground = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) =>
              PermissionDeniedScreen(isBackgroundPermission: isBackground),
        );

      case RouteConstants.map:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MapScreen(sessionId: sessionId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
