import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../session/presentation/bloc/session_bloc.dart';
import '../../../../shared/models/location_point.dart';
import '../../../../config/env/app_env.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../config/themes/app_text_styles.dart';
import '../../../../config/themes/app_spacing.dart';

/// Renders a session's route on an OpenStreetMap tile layer.
///
/// Uses [flutter_map] with the OSM tile provider — no Google Maps dependency.
class MapScreen extends StatefulWidget {
  final String sessionId;

  const MapScreen({super.key, required this.sessionId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(OpenSession(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Map')),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SessionDetailLoaded) {
            return _MapBody(points: state.points);
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

class _MapBody extends StatelessWidget {
  final List<LocationPoint> points;

  const _MapBody({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text('No locations to display.',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    final latLngs = points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final center = _centroid(latLngs);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: AppEnv.mapTileUrl,
          userAgentPackageName: 'com.gps.tracker',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: latLngs,
              color: AppColors.primary,
              strokeWidth: 3.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Start marker
            Marker(
              point: latLngs.first,
              width: 36,
              height: 36,
              child: _MapMarker(
                color: AppColors.trackingActive,
                icon: Icons.play_arrow_rounded,
              ),
            ),
            // End marker (only shown when session has ended)
            if (latLngs.length > 1)
              Marker(
                point: latLngs.last,
                width: 36,
                height: 36,
                child: _MapMarker(
                  color: AppColors.error,
                  icon: Icons.stop_rounded,
                ),
              ),
            // Intermediate points
            ...latLngs.skip(1).take(latLngs.length - 2).map(
                  (ll) => Marker(
                    point: ll,
                    width: 14,
                    height: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  /// Calculates the geographic centroid of a list of [LatLng] points.
  LatLng _centroid(List<LatLng> points) {
    final lat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lng);
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
