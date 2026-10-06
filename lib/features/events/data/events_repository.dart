import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/event_item.dart';

final eventsListProvider = NotifierProvider<EventsNotifier, List<EventItem>>(
  EventsNotifier.new,
);

final featuredEventProvider = Provider<EventItem?>((ref) {
  final events = ref.watch(eventsListProvider);
  try {
    return events.firstWhere((e) => e.isFeatured);
  } catch (_) {
    return events.isNotEmpty ? events.first : null;
  }
});

final monthlyEventsProvider = Provider<List<EventItem>>((ref) {
  final events = ref.watch(eventsListProvider);
  return events.where((e) => !e.isFeatured).toList();
});

final eventByIdProvider = Provider.family<EventItem?, String>((ref, id) {
  final events = ref.watch(eventsListProvider);
  try {
    return events.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});

class EventsNotifier extends Notifier<List<EventItem>> {
  static const List<EventItem> _initialEvents = [
    EventItem(
      id: 'featured-1',
      title: 'Global Economic Summit 2024',
      description:
          'Join industry leaders for an exclusive day of panels discussing the future of global markets and economic trends across major sectors.',
      location: 'Metropolis Convention Center',
      dateFormatted: 'OCT 12, 2024',
      time: '09:00 AM - 05:00 PM',
      imageUrl: 'assets/images/events_featured.png',
      isFeatured: true,
      category: 'Summit',
    ),
    EventItem(
      id: 'event-1',
      title: 'New Library Wing Opens Ahead of Schedule',
      description:
          'Tour the newly expanded digital research archives and collaborative study spaces at the North Campus Library.',
      location: 'Metropolis Convention Center',
      dateFormatted: 'OCT 12, 2024',
      time: '10:00 AM - 02:00 PM',
      section: 'This month',
      category: 'Campus',
    ),
    EventItem(
      id: 'event-2',
      title: 'New Library Wing Opens Ahead of Schedule',
      description:
          'Tour the newly expanded digital research archives and collaborative study spaces at the North Campus Library.',
      location: 'Metropolis Convention Center',
      dateFormatted: 'OCT 12, 2024',
      time: '10:00 AM - 02:00 PM',
      section: 'This month',
      category: 'Campus',
    ),
    EventItem(
      id: 'event-3',
      title: 'New Library Wing Opens Ahead of Schedule',
      description:
          'Tour the newly expanded digital research archives and collaborative study spaces at the North Campus Library.',
      location: 'Metropolis Convention Center',
      dateFormatted: 'OCT 12, 2024',
      time: '10:00 AM - 02:00 PM',
      section: 'This month',
      category: 'Campus',
    ),
    EventItem(
      id: 'event-4',
      title: 'New Library Wing Opens Ahead of Schedule',
      description:
          'Tour the newly expanded digital research archives and collaborative study spaces at the North Campus Library.',
      location: 'Metropolis Convention Center',
      dateFormatted: 'OCT 12, 2024',
      time: '10:00 AM - 02:00 PM',
      section: 'This month',
      category: 'Campus',
    ),
  ];

  @override
  List<EventItem> build() {
    return _initialEvents;
  }

  void toggleRegistration(String id) {
    state = [
      for (final event in state)
        if (event.id == id)
          event.copyWith(isRegistered: !event.isRegistered)
        else
          event,
    ];
  }

  void toggleCalendar(String id) {
    state = [
      for (final event in state)
        if (event.id == id)
          event.copyWith(isAddedToCalendar: !event.isAddedToCalendar)
        else
          event,
    ];
  }

  void refresh() {
    state = List.of(_initialEvents);
  }
}
