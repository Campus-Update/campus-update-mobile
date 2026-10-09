class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.dateFormatted,
    this.time,
    this.venue,
    this.entry,
    this.organiser,
    this.audience,
    this.description,
    this.imageUrl = 'assets/images/calendar_event_banner.png',
    this.sourceLabel = 'Official event',
    this.isSaved = false,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String? dateFormatted;
  final String? time;
  final String? venue;
  final String? entry;
  final String? organiser;
  final String? audience;
  final String? description;
  final String? imageUrl;
  final String sourceLabel;
  final bool isSaved;

  int get day => date.day;
  int get month => date.month;
  int get year => date.year;

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? date,
    String? dateFormatted,
    String? time,
    String? venue,
    String? entry,
    String? organiser,
    String? audience,
    String? description,
    String? imageUrl,
    String? sourceLabel,
    bool? isSaved,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      dateFormatted: dateFormatted ?? this.dateFormatted,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      entry: entry ?? this.entry,
      organiser: organiser ?? this.organiser,
      audience: audience ?? this.audience,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
