import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/models/incident.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class IncidentListScreen extends StatelessWidget {
  const IncidentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/report'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<IncidentModel>>(
        stream: sl<IncidentRepository>().observeAll(),
        builder: (context, snapshot) {
          final incidents = snapshot.data ?? [];
          if (incidents.isEmpty) {
            return const Center(child: Text('No incidents reported'));
          }
          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return _IncidentTile(incident: incident);
            },
          );
        },
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final IncidentModel incident;
  const _IncidentTile({required this.incident});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () => context.push('/incidents/${incident.id}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _iconFor(incident),
            color: scheme.primary,
          ),
        ),
        title: Text(incident.species.isEmpty ? 'Unknown species' : incident.species),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${incident.park.wire} · ${incident.statusName}'),
            if (incident.syncStatus != SyncStatus.synced)
              Row(
                children: [
                  Icon(
                    _syncIcon(incident.syncStatus),
                    size: 12,
                    color: _syncColor(incident.syncStatus),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Not synced',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _syncColor(incident.syncStatus),
                        ),
                  ),
                ],
              ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  IconData _iconFor(IncidentModel incident) {
    switch (incident.type) {
      case IncidentType.emergency:
        return Icons.sos;
      case IncidentType.poaching:
        return Icons.not_accessible;
      case IncidentType.snare:
        return Icons.close;
      case IncidentType.conflict:
        return Icons.warning_amber;
      default:
        return Icons.visibility;
    }
  }

  IconData _syncIcon(SyncStatus status) =>
      status == SyncStatus.failed
          ? Icons.error_outline
          : Icons.cloud_upload_outlined;

  Color _syncColor(SyncStatus status) =>
      status == SyncStatus.failed
          ? AppThemeColors.destructive
          : AppThemeColors.warning;
}