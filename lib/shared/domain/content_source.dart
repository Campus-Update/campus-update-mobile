/// The trust label shown on every content item.
///
/// The PRD requires four labels; the API's `SourceType` enum carries three
/// (`Official`, `External`, `Sponsored`). [campusUpdate] is the platform's own
/// content and is distinguished client-side until the backend models it.
enum ContentSource {
  officialSchool('Official School'),
  campusUpdate('Campus Update'),
  sponsored('Sponsored'),
  externalEvent('External Event');

  const ContentSource(this.label);

  final String label;

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
