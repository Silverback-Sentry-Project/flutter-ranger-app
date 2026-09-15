import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/domain/repositories/user_data_repository.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/models/user.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    sl<UserDataRepository>().darkThemeConfig.listen((value) {
      if (value != null && mounted) setState(() => _dark = value);
    }).onError((_) {});
  }

  Future<void> _signOut() async {
    sl<AuthRepository>().signOut();
    currentUserNotifier.value = null;
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = currentUserNotifier.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppThemeColors.forestGreen,
                    child: Icon(Icons.person, size: 44, color: scheme.onTertiary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayNameOrFallback ?? 'Guest',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(_roleLabel(user)),
                    backgroundColor: scheme.primaryContainer,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
                    value: _dark,
                    onChanged: (value) async {
                      setState(() => _dark = value);
                      await sl<UserDataRepository>().setDarkThemeConfig(value);
                    },
                  ),
                  Divider(color: scheme.outline.withAlpha(26)),
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: scheme.primary),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/notifications'),
                  ),
                  Divider(color: scheme.outline.withAlpha(26)),
                  ListTile(
                    leading: Icon(Icons.campaign_outlined, color: scheme.primary),
                    title: const Text('Alerts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/alerts'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeColors.destructive,
                side: const BorderSide(color: AppThemeColors.destructive),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(User? user) {
    switch (user?.role) {
      case UserRole.ranger:
        return 'Park Ranger';
      case UserRole.warden:
        return 'Warden';
      case UserRole.uwaOfficial:
        return 'UWA Official';
      default:
        return user?.isGuest == true ? 'Guest' : 'Community Member';
    }
  }
}