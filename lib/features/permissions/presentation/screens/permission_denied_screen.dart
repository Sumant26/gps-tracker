import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/constants/permission_constants.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';

/// Shown when the user has denied a required location permission.
///
/// Instructs the user to open Settings and grant the appropriate level.
class PermissionDeniedScreen extends StatelessWidget {
  /// True when the background (always) location permission is what's missing.
  final bool isBackgroundPermission;

  const PermissionDeniedScreen({
    super.key,
    this.isBackgroundPermission = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permission Required')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                isBackgroundPermission
                    ? Icons.location_searching_rounded
                    : Icons.location_disabled_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isBackgroundPermission
                    ? PermissionConstants.backgroundLocationTitle
                    : PermissionConstants.locationRequiredTitle,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isBackgroundPermission
                    ? PermissionConstants.backgroundLocationMessage
                    : PermissionConstants.locationRequiredMessage,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings_rounded),
                label: Text(PermissionConstants.openSettingsButton),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(PermissionConstants.notNowButton),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
