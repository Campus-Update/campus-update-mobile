class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateFormatted,
    this.time = '10:00 AM',
    this.imageUrl,
    this.isFeatured = false,
    this.category = 'Summit',
    this.startsAt,
    this.endsAt,
    this.registrationUrl,
    this.sponsorName,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String dateFormatted;
  final String time;
  final String? imageUrl;
  final bool isFeatured;
  final String category;

  /// When it begins; null while the date is still to be announced.
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// Where to sign up; null when the event takes no sign-ups.
  final String? registrationUrl;
  final String? sponsorName;

  EventItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? dateFormatted,
    String? time,
    String? imageUrl,
    bool? isFeatured,
    String? category,
  }) {
    return EventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateFormatted: dateFormatted ?? this.dateFormatted,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
      startsAt: startsAt,
      endsAt: endsAt,
      registrationUrl: registrationUrl,
      sponsorName: sponsorName,
    );
  }
}
