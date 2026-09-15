import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/repositories/article_repository.dart';
import '../../../../core/models/article.dart';
import '../../../../core/service_locator.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
      ),
      body: StreamBuilder<List<ArticleModel>>(
        stream: sl<ArticleRepository>().observeAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(child: Text('No articles yet'));
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _ArticleCard(article: article);
            },
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/articles/${article.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Image.network(
                article.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 180,
                  color: scheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${article.readTime} read',
                        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.excerpt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.favorite_outline, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${article.likes}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${article.comments}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      Text(
                        article.source,
                        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}