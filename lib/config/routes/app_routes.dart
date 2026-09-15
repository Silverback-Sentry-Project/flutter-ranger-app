import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/repositories/auth_repository.dart';
import '../../core/models/domain_enums.dart';
import '../../core/models/user.dart';
import '../../features/alerts/presentation/pages/alerts_screen.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/dashboard/presentation/pages/history_placeholder_screen.dart';
import '../../features/feed/presentation/pages/article_detail_screen.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/incidents/presentation/pages/camera_capture_screen.dart';
import '../../features/incidents/presentation/pages/incident_detail_screen.dart';
import '../../features/incidents/presentation/pages/incident_list_screen.dart';
import '../../features/incidents/presentation/pages/report_incident_screen.dart';
import '../../features/incidents/presentation/pages/report_submitted_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/sos/presentation/pages/sos_screen.dart';
import '../../features/tracking/presentation/pages/ranger_tracking_screen.dart';

final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

class RouterGate {
  static void bind(AuthRepository repository) {
    repository.currentUser.listen((user) {
      currentUserNotifier.value = user;
    });
  }
}

String? _authRedirect(BuildContext context, GoRouterState state) {
  final user = currentUserNotifier.value;
  final isOnAuth = state.uri.path == '/auth';
  if (user == null && !isOnAuth) return '/auth';
  if (user != null && isOnAuth) return '/home';
  return null;
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: currentUserNotifier,
  redirect: _authRedirect,
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          SilverBackSentryShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tracking',
              builder: (context, state) => const RangerTrackingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/incidents',
      builder: (context, state) => const IncidentListScreen(),
    ),
    GoRoute(
      path: '/incidents/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          IncidentDetailScreen(incidentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/report',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => ReportIncidentScreen(
        draftId: state.uri.queryParameters['draftId'],
      ),
    ),
    GoRoute(
      path: '/report/camera',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CameraCaptureScreen(),
    ),
    GoRoute(
      path: '/report/submitted',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ReportSubmittedScreen(),
    ),
    GoRoute(
      path: '/articles/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          ArticleDetailScreen(articleId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/alerts',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/sos',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SosScreen(),
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const HistoryPlaceholderScreen(),
    ),
  ],
);

class SilverBackSentryShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const SilverBackSentryShell({super.key, required this.navigationShell});

  static const List<_TabData> _allTabs = [
    _TabData('Home', Icons.home_outlined, Icons.home, 0),
    _TabData('Response', Icons.directions_run_outlined, Icons.directions_run, 1),
    _TabData('Feed', Icons.article_outlined, Icons.article, 2),
    _TabData('Tracking', Icons.my_location_outlined, Icons.my_location, 3),
    _TabData('Profile', Icons.account_circle_outlined, Icons.account_circle, 4),
  ];

  @override
  Widget build(BuildContext context) {
    final user = currentUserNotifier.value;
    final ranger = user?.role == UserRole.ranger;
    final visibleTabs = ranger
        ? [_allTabs[0], _allTabs[1], _allTabs[3], _allTabs[4]]
        : [_allTabs[0], _allTabs[2], _allTabs[4]];
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          _SosFloatingButton(
            onTap: () => context.push('/sos'),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withAlpha(26),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: visibleTabs.map((tab) {
                final selected = tab.index == currentIndex;
                return _SilverBackSentryTab(
                  tab: tab,
                  selected: selected,
                  onTap: () => navigationShell.goBranch(
                    tab.index,
                    initialLocation: tab.index == 0,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final String label;
  final IconData outlined;
  final IconData filled;
  final int index;
  const _TabData(this.label, this.outlined, this.filled, this.index);
}

class _SilverBackSentryTab extends StatelessWidget {
  final _TabData tab;
  final bool selected;
  final VoidCallback onTap;

  const _SilverBackSentryTab({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: selected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? tab.filled : tab.outlined,
                size: 26,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withAlpha(102),
              ),
              if (selected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosFloatingButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SosFloatingButton({required this.onTap});

  @override
  State<_SosFloatingButton> createState() => _SosFloatingButtonState();
}

class _SosFloatingButtonState extends State<_SosFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      right: 16,
      bottom: 72,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1 + 0.65 * t,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.error.withValues(
                          alpha: 0.5 * (1 - t),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.error,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sos,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}