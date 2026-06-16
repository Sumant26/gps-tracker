import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session_bloc.dart';
import '../widgets/session_tile.dart';
import 'session_detail_screen.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';

/// Displays all stored GPS tracking sessions in a scrollable list.
class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(const LoadSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          return switch (state) {
            SessionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            SessionLoaded(:final sessions) when sessions.isEmpty =>
              _EmptyState(),
            SessionLoaded(:final sessions) => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: sessions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => SessionTile(
                  session: sessions[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionDetailScreen(session: sessions[i]),
                    ),
                  ),
                  onDelete: () => context
                      .read<SessionBloc>()
                      .add(DeleteSession(sessions[i].id)),
                ),
              ),
            SessionError(:final message) => Center(
                child: Text(message,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error)),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No sessions yet',
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start tracking from the home screen\nto record your first session.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
