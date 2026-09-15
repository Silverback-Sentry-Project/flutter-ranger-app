import 'package:flutter/material.dart';

import '../../../../core/domain/repositories/article_repository.dart';
import '../../../../core/models/article.dart';
import '../../../../core/models/domain_enums.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<ArticleModel?>(
        stream: sl<ArticleRepository>().observeById(articleId),
        builder: (context, snapshot) {
          final article = snapshot.data;
          if (article == null) {
            return const Center(child: Text('Article not found'));
          }
          final theme = _themeColor(article.theme);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                Image.network(
                  article.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 220,
                    color: theme,
                    child: const Icon(Icons.park, color: Colors.white, size: 56),
                  ),
                )
              else
                Container(
                  height: 160,
                  color: theme,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${article.source} · ${article.readTime} read',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _themeColor(ArticleTheme theme) {
    switch (theme) {
      case ArticleTheme.sunset:
        return AppThemeColors.sunsetAmber;
      case ArticleTheme.sky:
        return AppThemeColors.instaBlue;
      case ArticleTheme.wildlife:
        return AppThemeColors.forestGreenGlow;
      case ArticleTheme.security:
        return AppThemeColors.destructive;
      default:
        return AppThemeColors.forestGreen;
    }
  }
}