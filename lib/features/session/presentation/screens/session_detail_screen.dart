import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session_bloc.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../shared/models/location_point.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';
import '../../../../config/themes/app_radius.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../map/presentation/screens/map_screen.dart';

/// Shows full details for a single [TrackingSession], including
/// metadata, location history, and a link to the map view.
class SessionDetailScreen extends StatefulWidget {
  final TrackingSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(OpenSession(widget.session.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'View on Map',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MapScreen(sessionId: widget.session.id),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SessionDetailLoaded) {
            return _DetailBody(
              session: state.session,
              points: state.points,
            );
          }
          if (state is SessionError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final TrackingSession session;
  final List<LocationPoint> points;

  const _DetailBody({required this.session, required this.points});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _MetaCard(session: session, pointCount: points.length),
        const SizedBox(height: AppSpacing.md),
        if (points.isNotEmpty) ...[
          Text(
            'LOCATION HISTORY',
            style: AppTextStyles.labelMedium.copyWith(
              letterSpacing: 1.2,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...points.asMap().entries.map(
                (e) => _LocationRow(index: e.key + 1, point: e.value),
              ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No location points recorded.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  final TrackingSession session;
  final int pointCount;

  const _MetaCard({required this.session, required this.pointCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _MetaRow(
              icon: Icons.play_arrow_rounded,
              label: 'Start Time',
              value: app_date.DateUtils.formatDateTime(session.startTime),
            ),
            const Divider(height: AppSpacing.lg),
            _MetaRow(
              icon: Icons.stop_rounded,
              label: 'End Time',
              value: session.endTime != null
                  ? app_date.DateUtils.formatDateTime(session.endTime!)
                  : 'In progress',
            ),
            const Divider(height: AppSpacing.lg),
            _MetaRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: app_date.DateUtils.formatDuration(session.duration),
            ),
            const Divider(height: AppSpacing.lg),
            _MetaRow(
              icon: Icons.location_on_outlined,
              label: 'Locations',
              value: '$pointCount points',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  final int index;
  final LocationPoint point;

  const _LocationRow({required this.index, required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.latitude.toStringAsFixed(6)}, '
                  '${point.longitude.toStringAsFixed(6)}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '±${point.accuracy.toStringAsFixed(1)}m  ·  '
                  '${app_date.DateUtils.formatTime(point.timestamp)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
