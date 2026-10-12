import 'content_source.dart';

/// One item from `GET /api/v1/feed` or `/content` — news, an announcement, an
/// event or an advert.
///
/// The API's `ContentResponse` carries only id, title, body, type, status,
/// urgency, sourceType, sourceName and publishedAt. The screens also want a
/// category, a summary, an image and an event's date and place; those are read
/// here when present so they appear the day the backend starts sending them,
/// and are null until then.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.urgency,
    required this.source,
    this.sourceName,
    this.publishedAt,
    this.category,
    this.summary,
    this.imageUrl,
    this.eventStartsAt,
    this.eventLocation,
  });

  final String id;
  final String title;
  final String body;
  final ContentType type;
  final Urgency urgency;
  final ContentSource source;

  /// Who published it — 'Registry', 'Students Union'.
  final String? sourceName;

  final DateTime? publishedAt;

  /// Not in the API yet.
  final String? category;

  /// Not returned by the API yet, though `POST /content` accepts one.
  final String? summary;

  /// Not in the API yet.
  final String? imageUrl;

  /// Not returned by the API yet, though `POST /content` accepts it.
  final DateTime? eventStartsAt;

  /// Not returned by the API yet, though `POST /content` accepts it.
  final String? eventLocation;

  /// What sits above the title on a card: the category once the API has one,
  /// and until then the trust label — 'Official', 'Official Event'.
  String get label => category ?? source.labelFor(type);

  /// A line of preview text: the summary, or the start of the body.
  String get excerpt => summary ?? body;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: ContentType.fromApi(json['type'] as String? ?? ''),
      urgency: Urgency.fromApi(json['urgency'] as String? ?? ''),
      source: ContentSource.fromApi(json['sourceType'] as String? ?? ''),
      sourceName: _text(json['sourceName']),
      publishedAt: _date(json['publishedAt']),
      category: _text(json['category']),
      summary: _text(json['summary']),
      imageUrl: _text(json['imageUrl']),
      eventStartsAt: _date(json['eventStartsAt']),
      eventLocation: _text(json['eventLocation']),
    );
  }

  /// Blank strings count as absent, so a card never shows an empty label.
  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
