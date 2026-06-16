import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../battery/presentation/bloc/battery_bloc.dart';
import '../../../battery/presentation/bloc/battery_event.dart';
import '../../../battery/presentation/widgets/battery_widget.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../../../tracking/presentation/widgets/tracking_control_widget.dart';
import '../../../session/presentation/screens/session_list_screen.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';

/// The main entry point of the application.
///
/// Displays battery status, tracking controls, and a shortcut
/// to the session history list.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BatteryBloc>().add(const LoadBattery());
    context.read<TrackingBloc>().add(const InitTracking());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPS Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Session History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SessionListScreen()),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _SectionLabel(label: 'DEVICE'),
              const SizedBox(height: AppSpacing.sm),
              const BatteryWidget(),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: 'TRACKING'),
              const SizedBox(height: AppSpacing.sm),
              const TrackingControlWidget(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        letterSpacing: 1.2,
        color: AppColors.textHint,
      ),
    );
  }
}
