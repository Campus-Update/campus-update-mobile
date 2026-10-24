import '../../../shared/domain/content_source.dart';

/// Represents a news item on the Campus Update platform.
class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    this.body,
    this.imageUrl,
    this.timeAgo = 'Recent update',
    this.publishedAt,
    this.isBookmarked = false,
    this.author = 'Campus Update Staff',
    this.source = ContentSource.campusUpdate,
    this.readTime = '3 min read',
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String? body;
  final String? imageUrl;
  final String timeAgo;
  final DateTime? publishedAt;
  final bool isBookmarked;
  final String author;
  final ContentSource source;
  final String readTime;

  NewsItem copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? body,
    String? imageUrl,
    String? timeAgo,
    DateTime? publishedAt,
    bool? isBookmarked,
    String? author,
    ContentSource? source,
    String? readTime,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      publishedAt: publishedAt ?? this.publishedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      author: author ?? this.author,
      source: source ?? this.source,
      readTime: readTime ?? this.readTime,
    );
  }
}
