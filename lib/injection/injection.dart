import 'package:get_it/get_it.dart';
import '../features/battery/data/datasources/battery_data_source.dart';
import '../features/battery/data/repositories/battery_repository_impl.dart';
import '../features/battery/domain/repositories/battery_repository.dart';
import '../features/battery/domain/usecases/get_battery_level_use_case.dart';
import '../features/battery/domain/usecases/watch_battery_use_case.dart';
import '../features/battery/presentation/bloc/battery_bloc.dart';

import '../features/tracking/data/datasources/tracking_local_data_source.dart';
import '../features/tracking/data/datasources/location_service.dart';
import '../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../features/tracking/domain/repositories/tracking_repository.dart';
import '../features/tracking/domain/usecases/start_tracking_use_case.dart';
import '../features/tracking/domain/usecases/stop_tracking_use_case.dart';
import '../features/tracking/domain/usecases/get_active_session_use_case.dart';
import '../features/tracking/presentation/bloc/tracking_bloc.dart';

import '../features/session/data/repositories/session_repository_impl.dart';
import '../features/session/domain/repositories/session_repository.dart';
import '../features/session/domain/usecases/session_use_cases.dart';
import '../features/session/presentation/bloc/session_bloc.dart';

import '../features/permissions/domain/repositories/permission_repository.dart';
import '../features/permissions/presentation/bloc/permission_bloc.dart';

/// Service locator instance.
final sl = GetIt.instance;

/// Registers all dependencies in the service locator.
///
/// Call once from [main] before [runApp].
Future<void> configureDependencies() async {
  // ── Data Sources ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BatteryDataSource>(() => BatteryDataSource());
  sl.registerLazySingleton<TrackingLocalDataSource>(
      () => TrackingLocalDataSource());
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // ── Repositories ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BatteryRepository>(
    () => BatteryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(),
  );

  // ── Use Cases ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetBatteryLevelUseCase(sl()));
  sl.registerLazySingleton(() => WatchBatteryUseCase(sl()));

  sl.registerLazySingleton(() => StartTrackingUseCase(sl()));
  sl.registerLazySingleton(() => StopTrackingUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveSessionUseCase(sl()));

  sl.registerLazySingleton(() => GetAllSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionPointsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSessionUseCase(sl()));

  sl.registerLazySingleton(() => CheckPermissionsUseCase(sl()));
  sl.registerLazySingleton(() => RequestPermissionsUseCase(sl()));

  // ── BLoCs ───────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => BatteryBloc(
      getBatteryLevel: sl(),
      watchBattery: sl(),
    ),
  );
  sl.registerFactory(
    () => TrackingBloc(
      startTracking: sl(),
      stopTracking: sl(),
      getActiveSession: sl(),
    ),
  );
  sl.registerFactory(
    () => SessionBloc(
      getAllSessions: sl(),
      getPoints: sl(),
      deleteSession: sl(),
    ),
  );
  sl.registerFactory(
    () => PermissionBloc(
      checkPermissions: sl(),
      requestPermissions: sl(),
      repository: sl(),
    ),
  );
}
