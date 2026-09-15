import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/domain/repositories/location_repository.dart';
import '../../../../core/domain/repositories/patrol_repository.dart';
import '../../../../core/domain/repositories/park_repository.dart';
import '../../../../core/models/incident.dart';
import '../../../../core/models/patrol_log.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/tracking/patrol_tracking_service.dart';

const String mapboxPublicToken =
    String.fromEnvironment('MAPBOX_PUBLIC_TOKEN', defaultValue: '');

bool _isMapboxConfigured() => mapboxPublicToken.isNotEmpty;

class RangerTrackingScreen extends StatefulWidget {
  const RangerTrackingScreen({super.key});

  @override
  State<RangerTrackingScreen> createState() => _RangerTrackingScreenState();
}

class _RangerTrackingScreenState extends State<RangerTrackingScreen> {
  mb.MapboxMap? _mapController;
  mb.PointAnnotationManager? _incidentManager;
  mb.PolylineAnnotationManager? _routeManager;
  final List<mb.PointAnnotation> _incidentAnnotations = [];
  mb.PolylineAnnotation? _routeAnnotation;

  mb.CameraViewportState? _viewport;
  String _styleUri = mb.MapboxStyles.STANDARD;
  PatrolLogModel? _activePatrol;
  bool _showAttractions = true;
  bool _showIncidents = true;
  bool _is3d = false;

  @override
  void initState() {
    super.initState();
    _loadActivePark();
    _initUserAndPatrol();
  }

  Future<void> _initUserAndPatrol() async {
    final user = await sl<AuthRepository>().currentUser.first;
    if (user == null) return;
    sl<PatrolRepository>().observeActivePatrol(user.uid).listen((patrol) {
      if (mounted) setState(() => _activePatrol = patrol);
      _drawRoute(patrol);
    });
  }

  Future<void> _loadActivePark() async {
    final user = await sl<AuthRepository>().currentUser.first;
    final park = await sl<ParkRepository>().getPark(user?.parkId ?? '');
    if (!mounted) return;
    if (park != null) {
      _viewport = mb.CameraViewportState(
        center: mb.Point(
          coordinates: mb.Position(park.centerLng, park.centerLat),
        ),
        zoom: park.zoomLevel,
      );
    } else {
      _viewport = mb.CameraViewportState(
        center: mb.Point(coordinates: mb.Position(29.66, -1.03)),
        zoom: 12.0,
      );
    }
    setState(() {});
  }

  Future<void> _onMapCreated(mb.MapboxMap controller) async {
    _mapController = controller;
    sl<IncidentRepository>().observeAll().listen((incidents) {
      _syncIncidents(incidents);
    });
  }

  Future<void> _syncIncidents(List<IncidentModel> incidents) async {
    if (_mapController == null) return;
    if (!_showIncidents) return;
    _incidentManager ??=
        await _mapController!.annotations.createPointAnnotationManager();
    for (final annotation in _incidentAnnotations) {
      await _incidentManager!.delete(annotation);
    }
    _incidentAnnotations.clear();
    for (final incident in incidents) {
      if (incident.lat.abs() < 0.0000001 || incident.lng.abs() < 0.0000001) {
        continue;
      }
      final color = _severityColor(incident.severityName);
      final annotation = await _incidentManager!.create(
        mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(incident.lng, incident.lat),
          ),
          iconColor: color.toARGB32(),
          iconSize: 1.4,
          customData: {'incidentId': incident.id},
        ),
      );
      _incidentAnnotations.add(annotation);
    }
  }

  Future<void> _drawRoute(PatrolLogModel? patrol) async {
    if (_mapController == null) return;
    _routeManager ??=
        await _mapController!.annotations.createPolylineAnnotationManager();
    if (patrol == null || patrol.routePoints.isEmpty) {
      if (_routeAnnotation != null) {
        await _routeManager!.delete(_routeAnnotation!);
        _routeAnnotation = null;
      }
      return;
    }
    final coordinates = [
      for (final point in patrol.routePoints)
        mb.Position(point.lng, point.lat),
    ];
    if (_routeAnnotation == null) {
      _routeAnnotation = await _routeManager!.create(
        mb.PolylineAnnotationOptions(
          geometry: mb.LineString(coordinates: coordinates),
          lineColor: AppThemeColors.forestGreenGlow.toARGB32(),
          lineWidth: 4.0,
        ),
      );
    } else {
      _routeAnnotation!.geometry = mb.LineString(coordinates: coordinates);
      await _routeManager!.update(_routeAnnotation!);
    }
  }

  Future<void> _togglePatrol() async {
    if (_activePatrol != null) {
      await PatrolTrackingService()
          .stopTracking(_activePatrol!.id);
      if (mounted) {
        setState(() => _activePatrol = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patrol ended')),
        );
      }
      return;
    }
    final hasPermission = await Geolocator.checkPermission();
    if (hasPermission == LocationPermission.denied ||
        hasPermission == LocationPermission.deniedForever) {
      final granted = await Geolocator.requestPermission();
      if (granted == LocationPermission.denied ||
          granted == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required')),
          );
        }
        return;
      }
    }
    final user = await sl<AuthRepository>().currentUser.first;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to start a patrol')),
        );
      }
      return;
    }
    await PatrolTrackingService().startTracking(user.uid, user.parkId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patrol started')),
      );
    }
  }

  Future<void> _recenter() async {
    final result = await sl<LocationRepository>().getCurrentLocation();
    result.fold((_) {}, (location) {
      _mapController?.flyTo(
        mb.CameraOptions(
          center: mb.Point(
            coordinates: mb.Position(location.longitude, location.latitude),
          ),
          zoom: 14.0,
        ),
        mb.MapAnimationOptions(duration: 800),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMapboxConfigured()) {
      return _MapUnavailableState();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Stack(
        children: [
          Positioned.fill(
            child: mb.MapWidget(
              styleUri: _styleUri,
              viewport: _viewport,
              onMapCreated: _onMapCreated,
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: _MapControlsColumn(
              activePatrol: _activePatrol != null,
              showAttractions: _showAttractions,
              showIncidents: _showIncidents,
              is3d: _is3d,
              onTogglePatrol: _togglePatrol,
              onToggle3d: _toggle3d,
              onToggleAttractions: () =>
                  setState(() => _showAttractions = !_showAttractions),
              onToggleIncidents: () =>
                  setState(() => _showIncidents = !_showIncidents),
              onRecenter: _recenter,
            ),
          ),
          if (_activePatrol != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _PatrolStatusCard(patrol: _activePatrol!),
            ),
        ],
      ),
    );
  }

  void _toggle3d() {
    setState(() {
      _is3d = !_is3d;
      _styleUri = _is3d
          ? 'mapbox://styles/mapbox/satellite-streets-v12'
          : mb.MapboxStyles.STANDARD;
    });
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
      case 'urgent':
        return AppThemeColors.destructive;
      case 'light':
        return AppThemeColors.success;
      default:
        return AppThemeColors.warning;
    }
  }
}

class _MapControlsColumn extends StatelessWidget {
  final bool activePatrol;
  final bool showAttractions;
  final bool showIncidents;
  final bool is3d;
  final VoidCallback onTogglePatrol;
  final VoidCallback onToggle3d;
  final VoidCallback onToggleAttractions;
  final VoidCallback onToggleIncidents;
  final VoidCallback onRecenter;

  const _MapControlsColumn({
    required this.activePatrol,
    required this.showAttractions,
    required this.showIncidents,
    required this.is3d,
    required this.onTogglePatrol,
    required this.onToggle3d,
    required this.onToggleAttractions,
    required this.onToggleIncidents,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ControlButton(
          icon: activePatrol ? Icons.stop : Icons.play_arrow,
          color: activePatrol ? AppThemeColors.destructive : AppThemeColors.forestGreen,
          tooltip: activePatrol ? 'End Patrol' : 'Start Patrol',
          onPressed: onTogglePatrol,
        ),
        _ControlButton(
          icon: Icons.height_outlined,
          color: showAttractions ? null : AppThemeColors.grey500,
          tooltip: 'Attractions',
          onPressed: onToggleAttractions,
        ),
        _ControlButton(
          icon: Icons.report_outlined,
          color: showIncidents ? null : AppThemeColors.grey500,
          tooltip: 'Incidents',
          onPressed: onToggleIncidents,
        ),
        _ControlButton(
          icon: is3d ? Icons.view_in_ar : Icons.layers_outlined,
          tooltip: 'Satellite view',
          onPressed: onToggle3d,
        ),
        _ControlButton(
          icon: Icons.my_location_outlined,
          tooltip: 'Recenter',
          onPressed: onRecenter,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onPressed;
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: color ?? scheme.surface,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Tooltip(
            message: tooltip,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color ?? scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline.withAlpha(26)),
              ),
              child: Icon(
                icon,
                size: 22,
                color: color != null
                    ? Colors.white
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PatrolStatusCard extends StatelessWidget {
  final PatrolLogModel patrol;
  const _PatrolStatusCard({required this.patrol});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppThemeColors.destructive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrol Active',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  patrol.parkId ?? 'No park assigned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${patrol.routePoints.length} pts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _MapUnavailableState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 64,
                color: AppThemeColors.grey500,
              ),
              const SizedBox(height: 16),
              Text(
                'Map unavailable',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Mapbox is not configured on this build. Add a '
                'MAPBOX_PUBLIC_TOKEN to enable offline park maps.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}