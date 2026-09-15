import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/models/user.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUserNotifier.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SilverBack Sentry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(user: user),
            const SizedBox(height: 16),
            _QuickActions(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Reports',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _RecentIncidents(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User? user;
  const _Header({this.user});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppThemeColors.forestGreen,
            child: Icon(
              Icons.person,
              color: scheme.onTertiary,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayNameOrFallback ?? 'Guest',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.parkId == null
                      ? 'Public browsing'
                      : 'Based at ${user!.parkId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/report'),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Report'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/incidents'),
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('Incidents'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentIncidents extends StatefulWidget {
  @override
  State<_RecentIncidents> createState() => _RecentIncidentsState();
}

class _RecentIncidentsState extends State<_RecentIncidents> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<IncidentRepository>().observeAll(),
      builder: (context, AsyncSnapshot<List> snapshot) {
        final incidents = snapshot.data ?? [];
        if (incidents.isEmpty) {
          return const Center(
            child: Text('No reports yet'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: incidents.length > 5 ? 5 : incidents.length,
          itemBuilder: (context, index) {
            final incident = incidents[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  _incidentIcon(incident),
                  color: AppThemeColors.instaBlue,
                ),
                title: Text(incident.species.isEmpty
                    ? 'Unknown species'
                    : incident.species),
                subtitle: Text(
                  '${incident.typeName} · ${incident.statusName}',
                ),
                onTap: () => context.push('/incidents/${incident.id}'),
              ),
            );
          },
        );
      },
    );
  }

  dynamic _incidentIcon(dynamic incident) {
    switch (incident.typeName) {
      case 'emergency':
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