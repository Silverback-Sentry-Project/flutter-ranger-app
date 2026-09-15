import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_constants.dart';
import '../../data/hive_database.dart';
import '../../domain/repositories/article_repository.dart';
import '../../models/article.dart';

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<FeedRemoteChange> observeFeedChanges() {
    return _db
        .collection(AppConstants.feedCollection)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async* {
      for (final change in snapshot.docChanges) {
        final doc = change.doc;
        final article = ArticleModel.fromFirestoreMap(doc.id, doc.data() ?? {});
        yield FeedRemoteChange(
          article: article,
          isRemoved: change.type == DocumentChangeType.removed,
        );
      }
    }).asyncExpand((stream) => stream);
  }
}

class ArticleRepositoryImpl implements ArticleRepository {
  final FeedRemoteDataSource _remoteDataSource = FeedRemoteDataSourceImpl();
  StreamSubscription? _sub;

  StreamController<List<ArticleModel>> _boxStream() {
    final controller = StreamController<List<ArticleModel>>.broadcast();
    final box = HiveDatabase.articlesBox;
    controller.add(box.values.toList());
    final sub = box.watch().listen((_) {
      controller.add(box.values.toList());
    });
    sub.onDone(() => controller.close());
    return controller;
  }

  @override
  Stream<List<ArticleModel>> observeAll() {
    final controller = _boxStream();
    _ensureObservingRemote(controller);
    return controller.stream;
  }

  @override
  Stream<ArticleModel?> observeById(String id) {
    return observeAll().map((articles) {
      for (final article in articles) {
        if (article.id == id) return article;
      }
      return null;
    }).distinct();
  }

  void _ensureObservingRemote(StreamController<List<ArticleModel>> controller) {
    if (_sub != null) return;
    _sub = _remoteDataSource.observeFeedChanges().listen((change) {
      final changed = change.article;
      if (change.isRemoved) {
        _removeById(changed.id);
      } else {
        _upsert(changed);
      }
    });
  }

  void _removeById(String id) {
    final box = HiveDatabase.articlesBox;
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) box.delete(key);
  }

  void _upsert(ArticleModel article) {
    final box = HiveDatabase.articlesBox;
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == article.id,
      orElse: () => null,
    );
    if (key != null) {
      box.put(key, article);
    } else {
      box.add(article);
    }
  }
}