import 'content_source.dart';

/// One item from `GET /api/v1/feed` or `/content` — news, an announcement, an
/// event or an advert.
///
/// The API's `ContentResponse` also carries a category, a cover image and an
/// event's dates, place, registration link and sponsor. It never returns a
/// summary, though `POST /content` accepts one; that is read here when present
/// so it appears the day the backend starts sending it.
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
    this.eventEndsAt,
    this.eventLocation,
    this.registrationUrl,
    this.sponsorName,
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

  final String? category;

  /// Not returned by the API yet, though `POST /content` accepts one.
  final String? summary;

  /// A signed link when the image is stored by the API; it stops working
  /// 15 minutes after the response.
  final String? imageUrl;

  final DateTime? eventStartsAt;
  final DateTime? eventEndsAt;
  final String? eventLocation;

  /// Where to sign up for an event, when it takes sign-ups.
  final String? registrationUrl;

  /// Who is paying for an event or an advert.
  final String? sponsorName;

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
      eventEndsAt: _date(json['eventEndsAt']),
      eventLocation: _text(json['eventLocation']),
      registrationUrl: _text(json['registrationUrl']),
      sponsorName: _text(json['sponsorName']),
    );
  }

  /// Blank strings count as absent, so a card never shows an empty label.
  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
