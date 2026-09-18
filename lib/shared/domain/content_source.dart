/// `News | Announcement | Event | Advertisement`, matching the API's
/// `ContentType`.
enum ContentType {
  news,
  announcement,
  event,
  advertisement;

  static ContentType fromApi(String value) => switch (value) {
    'Announcement' => ContentType.announcement,
    'Event' => ContentType.event,
    'Advertisement' => ContentType.advertisement,
    _ => ContentType.news,
  };
}

/// The trust label shown on every content item.
///
/// The PRD wording differs by content type: official news is labelled
/// "Official", while an official event is "Official Event" and a paid external
/// one is "Promoted Event". [labelFor] resolves that.
enum ContentSource {
  officialSchool,
  campusUpdate,
  sponsored,
  externalEvent;

  /// Maps the API's `SourceType` string.
  ///
  /// Note the spec currently types this as an integer while the API serialises
  /// it as a string — see `api/README.md`.
  static ContentSource fromApi(String value) => switch (value) {
    'Official' => ContentSource.officialSchool,
    'Sponsored' => ContentSource.sponsored,
    'External' => ContentSource.externalEvent,
    _ => ContentSource.campusUpdate,
  };

  String labelFor(ContentType type) => switch (this) {
    ContentSource.officialSchool =>
      type == ContentType.event ? 'Official Event' : 'Official',
    ContentSource.campusUpdate => 'Campus Update',
    ContentSource.sponsored => 'Sponsored',
    ContentSource.externalEvent => 'Promoted Event',
  };
}

/// `Normal | Important | Urgent`, matching the API's `UrgencyLevel`.
enum Urgency {
  normal,
  important,
  urgent;

  static Urgency fromApi(String value) => switch (value) {
    'Urgent' => Urgency.urgent,
    'Important' => Urgency.important,
    _ => Urgency.normal,
  };
}
