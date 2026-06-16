import 'package:flutter/material.dart';
import '../../../../shared/models/tracking_session.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';
import '../../../../config/themes/app_radius.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

/// A card representing a single [TrackingSession] in the list.
class SessionTile extends StatelessWidget {
  final TrackingSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionTile({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _SessionIcon(isActive: session.isActive),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          app_date.DateUtils.formatDateTime(session.startTime),
                          style: AppTextStyles.labelLarge,
                        ),
                        if (session.isActive) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _ActiveBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app_date.DateUtils.formatDuration(session.duration)}  ·  '
                      '${session.totalLocations} points',
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (session.endTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Ended ${app_date.DateUtils.formatTime(session.endTime!)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                tooltip: 'Delete session',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text(
          'This will permanently remove the session and all its location data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

class _SessionIcon extends StatelessWidget {
  final bool isActive;
  const _SessionIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.trackingActive.withOpacity(0.12)
            : AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        isActive ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
        color: isActive ? AppColors.trackingActive : AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.trackingActive.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'LIVE',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.trackingActive,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
