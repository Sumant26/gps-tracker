import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/battery_bloc.dart';
import '../bloc/battery_state.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';
import '../../../../config/themes/app_radius.dart';

/// Displays the current battery percentage sourced from [BatteryBloc].
class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteryBloc, BatteryState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              _BatteryIcon(state: state),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battery',
                      style: AppTextStyles.labelMedium.copyWith(
                        letterSpacing: 0.8,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _BatteryValue(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  final BatteryState state;
  const _BatteryIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final level = state is BatteryLoaded ? (state as BatteryLoaded).level : 50;
    final color = _colorForLevel(level);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        _iconForLevel(level),
        color: color,
        size: 26,
      ),
    );
  }

  Color _colorForLevel(int level) {
    if (level <= 20) return AppColors.error;
    if (level <= 50) return AppColors.accent;
    return AppColors.trackingActive;
  }

  IconData _iconForLevel(int level) {
    if (level <= 20) return Icons.battery_1_bar_rounded;
    if (level <= 40) return Icons.battery_3_bar_rounded;
    if (level <= 60) return Icons.battery_4_bar_rounded;
    if (level <= 80) return Icons.battery_5_bar_rounded;
    return Icons.battery_full_rounded;
  }
}

class _BatteryValue extends StatelessWidget {
  final BatteryState state;
  const _BatteryValue({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      BatteryLoading() => const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      BatteryLoaded(:final level) => Text(
          '$level%',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      BatteryError() => Text(
          'Unavailable',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      _ => Text('—', style: AppTextStyles.headlineLarge),
    };
  }
}
