import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/domain_enums.dart';
import '../../../../config/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = currentUserNotifier.value;
    final isRanger = user?.role == UserRole.ranger;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Response'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.folder_open, color: scheme.tertiary),
                title: const Text('All Reports'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/incidents'),
              ),
            ),
            if (isRanger) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(Icons.explore, color: scheme.primary),
                  title: const Text('Start Patrol'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/tracking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}