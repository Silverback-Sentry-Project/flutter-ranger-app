import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/domain/repositories/alert_repository.dart';
import '../../../../core/domain/repositories/article_repository.dart';
import '../../../../core/domain/repositories/incident_repository.dart';
import '../../../../core/models/alert.dart';
import '../../../../core/models/article.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/models/incident.dart';
import '../../../../core/models/user.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _dismissedAlertIds = {};

  void _dismissAlert(String id) {
    setState(() => _dismissedAlertIds.add(id));
  }

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            StreamBuilder<List<AlertModel>>(
              stream: sl<AlertRepository>().observeAll(),
              builder: (context, snapshot) {
                final alerts = (snapshot.data ?? [])
                    .where((a) => !_dismissedAlertIds.contains(a.id))
                    .toList();
                if (alerts.isEmpty) return const SizedBox.shrink();
                return _CommunityAlertsCard(
                  alerts: alerts,
                  parkName: _parkLabel(user),
                  onDismiss: _dismissAlert,
                );
              },
            ),
            StreamBuilder<List<IncidentModel>>(
              stream: sl<IncidentRepository>().observeAll(),
              builder: (context, snapshot) {
                final drafts = (snapshot.data ?? [])
                    .where((i) => i.syncStatus == SyncStatus.draft)
                    .toList();
                if (drafts.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _UnfinishedDrafts(drafts: drafts),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: _QuickReportCard(),
            ),
            StreamBuilder<List<IncidentModel>>(
              stream: sl<IncidentRepository>().observeAll(),
              builder: (context, snapshot) {
                final reports = (snapshot.data ?? [])
                    .where((i) => i.syncStatus != SyncStatus.draft)
                    .take(5)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _RecentReportsSection(reports: reports),
                );
              },
            ),
            StreamBuilder<List<ArticleModel>>(
              stream: sl<ArticleRepository>().observeAll(),
              builder: (context, snapshot) {
                final articles = snapshot.data ?? [];
                if (articles.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _LatestNewsSection(articles: articles),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _parkLabel(User? user) {
    final parkId = user?.parkId;
    if (parkId == null || parkId.trim().isEmpty) return '';
    return parkId
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1);
        })
        .join(' ');
  }
}

class _CommunityAlertsCard extends StatefulWidget {
  final List<AlertModel> alerts;
  final String parkName;
  final ValueChanged<String> onDismiss;
  const _CommunityAlertsCard({
    required this.alerts,
    required this.parkName,
    required this.onDismiss,
  });

  @override
  State<_CommunityAlertsCard> createState() => _CommunityAlertsCardState();
}

class _CommunityAlertsCardState extends State<_CommunityAlertsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _expanded
                          ? scheme.secondary
                          : scheme.primary,
                      child: Icon(
                        _expanded
                            ? Icons.notifications_off
                            : Icons.notifications_active,
                        size: 24,
                        color: _expanded
                            ? scheme.onSecondary
                            : scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _expanded
                                ? 'Active Alerts Details'
                                : 'Community Alerts',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _expanded
                                ? 'Tap to collapse'
                                : widget.parkName.isEmpty
                                    ? 'Active alerts in your area'
                                    : 'Active alerts near ${widget.parkName}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onDismiss(
                        widget.alerts.first.id,
                      ),
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      icon: Icon(
                        Icons.close,
                        color: scheme.outline,
                      ),
                      tooltip: 'Dismiss alert',
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 16),
                  Divider(color: scheme.outline.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  for (final alert in widget.alerts) ...[
                    _AlertDetail(alert: alert),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertDetail extends StatelessWidget {
  final AlertModel alert;
  const _AlertDetail({required this.alert});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          alert.title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          alert.location,
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          alert.description,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UnfinishedDrafts extends StatelessWidget {
  final List<IncidentModel> drafts;
  const _UnfinishedDrafts({required this.drafts});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unfinished Drafts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: drafts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return InkWell(
                onTap: () => context.push('/report?draftId=${draft.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        draft.type == IncidentType.sighting
                            ? Icons.add_a_photo
                            : Icons.warning,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        draft.species.isEmpty ? 'New Draft' : draft.species,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickReportCard extends StatelessWidget {
  const _QuickReportCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/report'),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Incident',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: scheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Fast, one-screen submission',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add, size: 24, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentReportsSection extends StatelessWidget {
  final List<IncidentModel> reports;
  const _RecentReportsSection({required this.reports});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My recent reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/history'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See all'),
            ),
          ],
        ),
        if (reports.isEmpty)
          const _EmptyFeedState()
        else ...[
          const SizedBox(height: 12),
          for (final (index, incident) in reports.indexed) ...[
            _IncidentCard(incident: incident),
            if (index < reports.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolved = incident.status == IncidentStatus.resolved;
    final statusColor = resolved
        ? AppThemeColors.success
        : AppThemeColors.warning;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/incidents/${incident.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.surfaceContainerHighest,
                child: Icon(
                  incident.type == IncidentType.sighting
                      ? Icons.add_a_photo
                      : Icons.warning,
                  color: scheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.species.isEmpty
                          ? 'Unknown species'
                          : incident.species,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_relativeTime(incident.reportedAt)} · ${_locationOf(incident)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  incident.statusName.split('_').join(' ').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _locationOf(IncidentModel incident) {
    final parts = <String>{
      if (incident.parish != null && incident.parish!.isNotEmpty)
        incident.parish!,
      if (incident.subCounty != null && incident.subCounty!.isNotEmpty)
        incident.subCounty!,
      if (incident.district != null && incident.district!.isNotEmpty)
        incident.district!,
      if (incident.community.isNotEmpty) incident.community,
    };
    if (parts.isNotEmpty) return parts.join(' · ');
    if (incident.locationName != null && incident.locationName!.isNotEmpty) {
      return incident.locationName!;
    }
    return incident.community.isEmpty ? 'Unknown location' : incident.community;
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2,
              size: 40,
              color: scheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Activity Yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "When you report sightings or conflicts, they'll appear here to help the community stay informed.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LatestNewsSection extends StatelessWidget {
  final List<ArticleModel> articles;
  const _LatestNewsSection({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest News',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        for (final article in articles) ...[
          _HomeArticleCard(article: article),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HomeArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _HomeArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/articles/${article.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.source.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                article.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                article.excerpt,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}