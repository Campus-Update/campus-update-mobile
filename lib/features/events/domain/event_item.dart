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
    this.isRegistered = false,
    this.isAddedToCalendar = false,
    this.category = 'Summit',
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String dateFormatted;
  final String time;
  final String? imageUrl;
  final bool isFeatured;
  final bool isRegistered;
  final bool isAddedToCalendar;
  final String category;

  EventItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? dateFormatted,
    String? time,
    String? imageUrl,
    bool? isFeatured,
    bool? isRegistered,
    bool? isAddedToCalendar,
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
      isRegistered: isRegistered ?? this.isRegistered,
      isAddedToCalendar: isAddedToCalendar ?? this.isAddedToCalendar,
      category: category ?? this.category,
    );
  }
}
