import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/env/app_env.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'config/constants/hive_constants.dart';
import 'injection/injection.dart';
import 'shared/models/tracking_session.dart';
import 'shared/models/location_point.dart';
import 'features/battery/presentation/bloc/battery_bloc.dart';
import 'features/tracking/presentation/bloc/tracking_bloc.dart';
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/permissions/presentation/bloc/permission_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment configuration.
  await AppEnv.load(env: 'dev');

  // Initialise Hive.
  await Hive.initFlutter();
  Hive.registerAdapter(TrackingSessionAdapter());
  Hive.registerAdapter(LocationPointAdapter());
  await Hive.openBox<TrackingSession>(HiveConstants.trackingSessionBox);
  await Hive.openBox<LocationPoint>(HiveConstants.locationPointBox);

  // Wire up dependency injection.
  await configureDependencies();

  runApp(const GpsTrackerApp());
}

/// Root widget of the GPS Tracker application.
class GpsTrackerApp extends StatelessWidget {
  const GpsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BatteryBloc>(create: (_) => sl<BatteryBloc>()),
        BlocProvider<TrackingBloc>(create: (_) => sl<TrackingBloc>()),
        BlocProvider<SessionBloc>(create: (_) => sl<SessionBloc>()),
        BlocProvider<PermissionBloc>(
          create: (_) => sl<PermissionBloc>()
            ..add(const CheckPermissions()),
        ),
      ],
      child: MaterialApp(
        title: AppEnv.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
