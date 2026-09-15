import 'package:flutter/material.dart';

import '../../../../core/domain/repositories/alert_repository.dart';
import '../../../../core/models/alert.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Alerts')),
      body: StreamBuilder<List<AlertModel>>(
        stream: sl<AlertRepository>().observeAll(),
        builder: (context, snapshot) {
          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(alert: alert);
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _severityColor(alert.severity);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_categoryIcon(alert.category), color: color),
        ),
        title: Text(alert.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              alert.location,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _severityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.urgent:
        return AppThemeColors.destructive;
      case AlertSeverity.caution:
        return AppThemeColors.warning;
      default:
        return AppThemeColors.instaBlue;
    }
  }

  IconData _categoryIcon(AlertCategory category) {
    switch (category) {
      case AlertCategory.patrols:
        return Icons.gps_fixed;
      case AlertCategory.trapping:
        return Icons.close;
      case AlertCategory.safety:
        return Icons.health_and_safety;
      default:
        return Icons.pets;
    }
  }
}