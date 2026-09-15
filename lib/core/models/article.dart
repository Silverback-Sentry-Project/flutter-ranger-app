import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'domain_enums.dart';
part 'article.g.dart';
@HiveType(typeId: 21)
class ArticleModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final String themeName;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String excerpt;
  @HiveField(5)
  final String body;
  @HiveField(6)
  final String? imageUrl;
  @HiveField(7)
  final String readTime;
  @HiveField(8)
  final String source;
  @HiveField(9)
  final int likes;
  @HiveField(10)
  final int comments;
  @HiveField(11)
  final int publishedAt;
const ArticleModel({
    required this.id,
    required this.category,
    required this.themeName,
    required this.title,
    required this.excerpt,
    required this.body,
    this.imageUrl,
    required this.readTime,
    required this.source,
    required this.likes,
    required this.comments,
    required this.publishedAt,
  });

  ArticleTheme get theme => ArticleTheme.fromName(themeName);
  factory ArticleModel.fromFirestoreMap(String documentId, Map<String, dynamic> data) {
    final publishedAtRaw = data['publishedAt'];
    return ArticleModel(
      id: documentId,
      category: data['category'] as String? ?? 'News',
      themeName: ArticleTheme.fromWire(data['theme'] as String?).name,
      title: data['title'] as String? ?? '',
      excerpt: data['excerpt'] as String? ?? '',
      body: data['body'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      readTime: data['readTime'] as String? ?? '3 min',
      source: data['source'] as String? ?? 'Uganda Wildlife Authority',
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      publishedAt: _parsePublishedAt(publishedAtRaw),
    );
  }
  static int _parsePublishedAt(Object? raw) {
    if (raw is num) return raw.toInt();
    if (raw is DateTime) return raw.toLocal().millisecondsSinceEpoch;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed.toLocal().millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }
  ArticleModel copyWith({
    int? likes,
    int? comments,
  }) =>
      ArticleModel(
        id: id,
        category: category,
        themeName: theme.name,
        title: title,
        excerpt: excerpt,
        body: body,
        imageUrl: imageUrl,
        readTime: readTime,
        source: source,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        publishedAt: publishedAt,
      );
  @override
  List<Object?> get props => [
        id,
        category,
        theme,
        title,
        excerpt,
        body,
        imageUrl,
        readTime,
        source,
        likes,
        comments,
        publishedAt,
      ];
}
