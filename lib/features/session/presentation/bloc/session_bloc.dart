import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';
import '../../domain/usecases/session_use_cases.dart';
import '../../../../core/utils/logger.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}

/// Triggers a full reload of the sessions list.
class LoadSessions extends SessionEvent {
  const LoadSessions();
}

/// Permanently deletes the session with [sessionId].
class DeleteSession extends SessionEvent {
  final String sessionId;
  const DeleteSession(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

/// Loads the location points for [sessionId] for the detail view.
class OpenSession extends SessionEvent {
  final String sessionId;
  const OpenSession(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionLoaded extends SessionState {
  final List<TrackingSession> sessions;
  const SessionLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class SessionDetailLoaded extends SessionState {
  final TrackingSession session;
  final List<LocationPoint> points;
  const SessionDetailLoaded({required this.session, required this.points});
  @override
  List<Object?> get props => [session, points];
}

class SessionError extends SessionState {
  final String message;
  const SessionError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

/// Manages the session list and session detail states.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  static const _tag = 'SessionBloc';

  final GetAllSessionsUseCase _getAllSessions;
  final GetSessionPointsUseCase _getPoints;
  final DeleteSessionUseCase _deleteSession;

  SessionBloc({
    required GetAllSessionsUseCase getAllSessions,
    required GetSessionPointsUseCase getPoints,
    required DeleteSessionUseCase deleteSession,
  })  : _getAllSessions = getAllSessions,
        _getPoints = getPoints,
        _deleteSession = deleteSession,
        super(const SessionLoading()) {
    on<LoadSessions>(_onLoad);
    on<DeleteSession>(_onDelete);
    on<OpenSession>(_onOpen);
  }

  Future<void> _onLoad(
    LoadSessions event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final sessions = await _getAllSessions();
      emit(SessionLoaded(sessions));
    } catch (e) {
      AppLogger.error(_tag, 'LoadSessions failed', e);
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteSession event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await _deleteSession(event.sessionId);
      AppLogger.info(_tag, 'Deleted session ${event.sessionId}');
      add(const LoadSessions());
    } catch (e) {
      AppLogger.error(_tag, 'DeleteSession failed', e);
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onOpen(
    OpenSession event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final sessions = await _getAllSessions();
      final session =
          sessions.firstWhere((s) => s.id == event.sessionId);
      final points = await _getPoints(event.sessionId);
      emit(SessionDetailLoaded(session: session, points: points));
    } catch (e) {
      AppLogger.error(_tag, 'OpenSession failed', e);
      emit(SessionError(e.toString()));
    }
  }
}
