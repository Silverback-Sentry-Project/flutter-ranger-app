import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/domain/repositories/location_repository.dart';
import '../../../../core/models/incident.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/tracking/patrol_tracking_service.dart';

class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  double? _distanceKm;

  ColorScheme get scheme => Theme.of(context).colorScheme;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final incident = await sl<IncidentRepository>().getById(widget.incidentId);
    if (incident == null || mounted == false) return;
    if (incident.lat.abs() < 0.0000001 && incident.lng.abs() < 0.0000001) return;
    final locationResult =
        await sl<LocationRepository>().getCurrentLocation();
    locationResult.fold((_) {}, (location) {
      if (!mounted) return;
      final d = _haversine(
        incident.lat,
        incident.lng,
        location.latitude,
        location.longitude,
      );
      if (d != null) setState(() => _distanceKm = d);
    });
  }

  double? _haversine(double lat1, double lng1, double lat2, double lng2) {
    const radius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radius * c;
  }

  double _toRad(double deg) => deg * math.pi / 180.0;

  Future<void> _respond(IncidentModel incident) async {
    final user = await sl<AuthRepository>().currentUser.first;
    await sl<IncidentRepository>().assignToSelf(incident.id);
    if (user != null) {
      await PatrolTrackingService().startTracking(user.uid, incident.park.wire);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Response started, tracking enabled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: StreamBuilder<IncidentModel?>(
        stream: _incidentStream(),
        builder: (context, snapshot) {
          final incident = snapshot.data;
          if (incident == null) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => _respond(incident),
                icon: const Icon(Icons.directions_walk),
                label: Text(
                  incident.assignedToName == null
                      ? 'Start Response'
                      : 'Resume Response',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ),
          );
        },
      ),
      body: StreamBuilder<IncidentModel?>(
        stream: _incidentStream(),
        builder: (context, snapshot) {
          final incident = snapshot.data;
          if (incident == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(incident),
              if (incident.evidencePhotoUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                _evidence(incident),
              ],
              const SizedBox(height: 16),
              _summaryCard(incident),
              const SizedBox(height: 16),
              _detailsCard(incident),
            ],
          );
        },
      ),
    );
  }

  Stream<IncidentModel?> _incidentStream() {
    return sl<IncidentRepository>()
        .observeAll()
        .map((list) {
          for (final i in list) {
            if (i.id == widget.incidentId) return i;
          }
          return null;
        })
        .distinct();
  }

  Widget _header(IncidentModel incident) {
    final accent = _severityColor(incident.severityName);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accent.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_typeIcon(incident.typeName), color: accent, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incident.species,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (incident.isEscalated)
                    const Icon(
                      Icons.local_fire_department,
                      color: AppThemeColors.destructive,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statusPill(
                    incident.statusName,
                    _statusColor(incident.statusName),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(incident.severityName, accent),
                ],
              ),
              if (incident.assignedToName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Assigned to ${incident.assignedToName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _evidence(IncidentModel incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence (${incident.evidencePhotoUrls.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: incident.evidencePhotoUrls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  incident.evidencePhotoUrls[index],
                  width: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 180,
                    height: 180,
                    color: scheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(IncidentModel incident) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            incident.summary ?? 'No additional details provided.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(IncidentModel incident) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.place_outlined,
            'Location',
            incident.locationName ?? incident.community,
          ),
          _detailRow(
            Icons.person_outline,
            'Reported by',
            incident.userName ?? 'Anonymous',
          ),
          _detailRow(Icons.schedule, 'Reported at', incident.reportedAt),
          if (_distanceKm != null)
            _detailRow(Icons.near_me_outlined, 'Distance',
                '${_distanceKm!.toStringAsFixed(1)} km away'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppThemeColors.success;
      case 'cancelled':
        return AppThemeColors.destructive;
      case 'inProgress':
        return AppThemeColors.instaBlue;
      default:
        return AppThemeColors.warning;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'emergency':
      case 'SOS':
        return Icons.sos;
      case 'poaching':
        return Icons.not_accessible;
      case 'snare':
        return Icons.close;
      case 'conflict':
        return Icons.warning_amber;
      default:
        return Icons.visibility;
    }
  }
}