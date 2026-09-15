import 'dart:async';

import '../../models/article.dart';

abstract class ArticleRepository {
  Stream<List<ArticleModel>> observeAll();

  Stream<ArticleModel?> observeById(String id);
}

class FeedRemoteChange {
  final ArticleModel article;
  final bool isRemoved;
  const FeedRemoteChange({required this.article, required this.isRemoved});
}

abstract class FeedRemoteDataSource {
  Stream<FeedRemoteChange> observeFeedChanges();
}