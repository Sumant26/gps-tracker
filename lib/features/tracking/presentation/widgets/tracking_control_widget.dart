import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tracking_bloc.dart';
import '../bloc/tracking_event.dart';
import '../bloc/tracking_state.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';
import '../../../../config/themes/app_radius.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

/// Displays tracking controls and, when active, a live session summary.
class TrackingControlWidget extends StatelessWidget {
  const TrackingControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state is TrackingRunning) _ActiveSessionCard(state: state),
            if (state is TrackingRunning)
              const SizedBox(height: AppSpacing.md),
            _TrackingButton(state: state),
            if (state is TrackingError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  state.message,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActiveSessionCard extends StatefulWidget {
  final TrackingRunning state;
  const _ActiveSessionCard({required this.state});

  @override
  State<_ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<_ActiveSessionCard> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Refresh elapsed time every second.
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _now = DateTime.now());
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.state.session;
    final elapsed = _now.difference(session.startTime);
    final points = widget.state.points;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.trackingActive.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.trackingActive.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Pulsing dot indicator
          _PulsingDot(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Active',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.trackingActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started ${app_date.DateUtils.formatTime(session.startTime)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                app_date.DateUtils.formatDuration(elapsed),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.trackingActive,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${points.length} points',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.trackingActive,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _TrackingButton extends StatelessWidget {
  final TrackingState state;
  const _TrackingButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state is TrackingLoading;
    final isRunning = state is TrackingRunning;

    if (isRunning) {
      return OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () => context.read<TrackingBloc>().add(const StopTracking()),
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('Stop Tracking'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => context.read<TrackingBloc>().add(const StartTracking()),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.play_circle_outline_rounded),
      label: Text(isLoading ? 'Starting…' : 'Start Tracking'),
    );
  }
}
