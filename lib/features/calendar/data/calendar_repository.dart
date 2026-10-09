import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calendar_event.dart';

/// Tracks the active month displayed on the calendar grid.
final activeMonthProvider = NotifierProvider<ActiveMonthNotifier, DateTime>(
  ActiveMonthNotifier.new,
);

class ActiveMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime(2026, 7);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }
}

/// Tracks the selected day (defaults to July 15, 2026).
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    return DateTime(2026, 7, 15);
  }

  void selectDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void clearSelection() {
    state = null;
  }
}

/// Repository provider containing campus academic and calendar events.
final calendarEventsProvider =
    NotifierProvider<CalendarEventsNotifier, List<CalendarEvent>>(
      CalendarEventsNotifier.new,
    );

class CalendarEventsNotifier extends Notifier<List<CalendarEvent>> {
  static final List<CalendarEvent> _initialEvents = [
    CalendarEvent(
      id: 'cal-1',
      title: 'Second semester lectures',
      category: 'Academics',
      date: DateTime(2026, 7, 15),
      dateFormatted: 'Wed 15 July',
      time: '8:00am — 5:00pm',
      venue: 'Faculty Lecture Halls',
      entry: 'Open to all registered students.',
      organiser: 'Academic Affairs Directorate',
      audience: 'Students & Faculty',
      description:
          'Official commencement of lecture sessions for the second academic semester. All faculty departments will begin instruction according to published timetable schedules.',
    ),
    CalendarEvent(
      id: 'cal-2',
      title: 'Course registration opens',
      category: 'Registration',
      date: DateTime(2026, 7, 16),
      dateFormatted: 'Thu 16 July',
      time: '9:00am — 11:59pm',
      venue: 'Student Online Portal',
      entry: 'Active student portal login required.',
      organiser: 'Office of Academic Registration',
      audience: 'Undergraduate & Postgraduate Students',
      description:
          'Online course registration portal opens for all enrolled students. Ensure fees clearance is verified prior to selecting departmental electives and core courses.',
    ),
    CalendarEvent(
      id: 'cal-3',
      title: 'Matriculation ceremony for the 2025/2026 session',
      category: 'Academics',
      date: DateTime(2026, 7, 17),
      dateFormatted: 'Fri 25 September',
      time: '9:00am — 12:00pm',
      venue: 'University Sports Complex',
      entry:
          'Attendance required for all fresh students. Academic gown compulsory.',
      organiser: 'Office of Student Affairs',
      audience: 'Students',
      description:
          'The matriculation ceremony for newly admitted students holds at the sports complex.\n\nFresh students must attend in full academic gown. Gowns are collected from the Students\' Affairs office from 22 September. Guests are limited to two per student.',
      sourceLabel: 'Official event',
    ),
    CalendarEvent(
      id: 'cal-4',
      title: 'Add/Drop course revision period',
      category: 'Registration',
      date: DateTime(2026, 7, 18),
      dateFormatted: 'Sat 18 July',
      time: '8:00am — 11:59pm',
      venue: 'Student Online Portal',
      entry: 'Subject to department approval.',
      organiser: 'Academic Board',
      audience: 'Students',
      description:
          'Final window for adding and dropping registered elective courses for the semester.',
    ),
    CalendarEvent(
      id: 'cal-5',
      title: 'Departmental Orientation & Advising',
      category: 'Academics',
      date: DateTime(2026, 7, 19),
      dateFormatted: 'Sun 19 July',
      time: '2:00pm — 5:00pm',
      venue: 'Department Auditoriums',
      entry: 'Fresh & transfer students.',
      organiser: 'Academic Advising Center',
      audience: 'Students',
      description:
          'Departmental faculty overview and curriculum guidance sessions with assigned academic advisors.',
    ),
    CalendarEvent(
      id: 'cal-6',
      title: 'Faculty Research Symposium',
      category: 'Research',
      date: DateTime(2026, 7, 20),
      dateFormatted: 'Mon 20 July',
      time: '9:00am — 4:00pm',
      venue: 'Innovation Center',
      entry: 'Open to university community.',
      organiser: 'Directorate of Research & Innovation',
      audience: 'Faculty & Researchers',
      description:
          'Annual symposium showcasing peer-reviewed interdisciplinary research findings and grant presentations.',
    ),
    CalendarEvent(
      id: 'cal-7',
      title: 'Mid-Year Academic Senate Meeting',
      category: 'Governance',
      date: DateTime(2026, 7, 21),
      dateFormatted: 'Tue 21 July',
      time: '1:00pm — 4:30pm',
      venue: 'Council Chambers',
      entry: 'Senate members only.',
      organiser: 'University Secretariat',
      audience: 'Faculty & Senate',
      description:
          'Quarterly statutory assembly addressing academic standards, degree approvals, and institutional policy.',
    ),
    CalendarEvent(
      id: 'cal-8',
      title: 'Graduate Thesis Defense Week',
      category: 'Academics',
      date: DateTime(2026, 7, 22),
      dateFormatted: 'Wed 22 July',
      time: '10:00am — 4:00pm',
      venue: 'Graduate School Boardroom',
      entry: 'Public defense sessions.',
      organiser: 'School of Graduate Studies',
      audience: 'Postgraduate Students',
      description:
          'Oral defenses for graduating Master and PhD candidates across various faculties.',
    ),
    CalendarEvent(
      id: 'cal-9',
      title: 'Campus Career & Internship Workshop',
      category: 'Career',
      date: DateTime(2026, 7, 23),
      dateFormatted: 'Thu 23 July',
      time: '3:00pm — 6:00pm',
      venue: 'Career Services Center',
      entry: 'Pre-registration recommended.',
      organiser: 'Career Development Unit',
      audience: 'Students & Alumni',
      description:
          'Resume crafting, technical interview prep, and corporate recruitment networking workshops.',
    ),
    CalendarEvent(
      id: 'cal-10',
      title: 'University Health & Wellness Fair',
      category: 'Campus Life',
      date: DateTime(2026, 7, 24),
      dateFormatted: 'Fri 24 July',
      time: '10:00am — 3:00pm',
      venue: 'University Quad',
      entry: 'Free health screenings.',
      organiser: 'University Health Services',
      audience: 'Entire Campus',
      description:
          'Comprehensive health checks, nutritional consultations, mental health awareness, and blood donation drives.',
    ),
    CalendarEvent(
      id: 'cal-11',
      title: 'Student Union Leadership Summit',
      category: 'Leadership',
      date: DateTime(2026, 7, 25),
      dateFormatted: 'Sat 25 July',
      time: '9:00am — 2:00pm',
      venue: 'Student Center Auditorium',
      entry: 'Elected student executives & representatives.',
      organiser: 'Student Representative Council',
      audience: 'Student Leaders',
      description:
          'Capacity building, ethical governance, and student advocacy workshop for elected hall and faculty executives.',
    ),
    CalendarEvent(
      id: 'cal-12',
      title: 'Inter-Collegiate Debate Championship',
      category: 'Competition',
      date: DateTime(2026, 7, 26),
      dateFormatted: 'Sun 26 July',
      time: '4:00pm — 7:30pm',
      venue: 'Main Auditorium',
      entry: 'Free entry for spectators.',
      organiser: 'University Debate Society',
      audience: 'Students & General Public',
      description:
          'Annual championship debate series covering national governance, economic policy, and technology ethics.',
    ),
    CalendarEvent(
      id: 'cal-13',
      title: 'Mid-Semester Course Evaluation Opens',
      category: 'Academics',
      date: DateTime(2026, 7, 27),
      dateFormatted: 'Mon 27 July',
      time: '8:00am — 11:59pm',
      venue: 'Student Online Portal',
      entry: 'Anonymous student feedback.',
      organiser: 'Quality Assurance Directorate',
      audience: 'Students',
      description:
          'Confidential feedback portal for students to evaluate instructional delivery and course resources.',
    ),
    CalendarEvent(
      id: 'cal-14',
      title: 'Alumni Mentorship Networking Night',
      category: 'Networking',
      date: DateTime(2026, 7, 28),
      dateFormatted: 'Tue 28 July',
      time: '6:00pm — 9:00pm',
      venue: 'Alumni Pavilion',
      entry: 'RSVP required.',
      organiser: 'Alumni Relations Office',
      audience: 'Final Year Students & Alumni',
      description:
          'Evening of structured networking and one-on-one mentorship pairings with distinguished industry alumni.',
    ),
    CalendarEvent(
      id: 'cal-15',
      title: 'Technology & Innovation Demo Day',
      category: 'Exhibition',
      date: DateTime(2026, 7, 29),
      dateFormatted: 'Wed 29 July',
      time: '10:00am — 5:00pm',
      venue: 'Science & Engineering Complex',
      entry: 'Open exhibition.',
      organiser: 'Tech Hub & Engineering Faculty',
      audience: 'Students, Investors & Industry',
      description:
          'Showcase of student capstone software, hardware, and sustainable energy prototypes to industry venture partners.',
    ),
    CalendarEvent(
      id: 'cal-16',
      title: 'Campus Sustainability Town Hall',
      category: 'Town Hall',
      date: DateTime(2026, 7, 30),
      dateFormatted: 'Thu 30 July',
      time: '5:00pm — 7:00pm',
      venue: 'Green Hall Amphitheatre',
      entry: 'Open forum.',
      organiser: 'Environmental Sustainability Committee',
      audience: 'Campus Community',
      description:
          'Public forum discussing campus solar transition, waste management initiatives, and eco-friendly transit policies.',
    ),
    CalendarEvent(
      id: 'cal-17',
      title: 'Monthly Academic Review & Planning',
      category: 'Academics',
      date: DateTime(2026, 7, 31),
      dateFormatted: 'Fri 31 July',
      time: '2:00pm — 5:00pm',
      venue: 'Senate Hall',
      entry: 'Deans & Heads of Department.',
      organiser: 'Office of the Vice-Chancellor',
      audience: 'Academic Leadership',
      description:
          'Monthly review of institutional progress, accreditation benchmarks, and upcoming examination schedules.',
    ),
  ];

  @override
  List<CalendarEvent> build() {
    return _initialEvents;
  }

  void toggleSaved(String id) {
    state = [
      for (final event in state)
        if (event.id == id) event.copyWith(isSaved: !event.isSaved) else event,
    ];
  }
}

/// Returns events for the currently active month.
final monthEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final activeMonth = ref.watch(activeMonthProvider);
  final allEvents = ref.watch(calendarEventsProvider);

  return allEvents
      .where(
        (e) =>
            e.date.year == activeMonth.year &&
            e.date.month == activeMonth.month,
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

/// Returns a single calendar event by id.
final calendarEventByIdProvider = Provider.family<CalendarEvent?, String>((
  ref,
  id,
) {
  final events = ref.watch(calendarEventsProvider);
  return events.where((e) => e.id == id).firstOrNull;
});

/// Returns a set of days (integers) that have events in the active month.
final eventDaysInActiveMonthProvider = Provider<Set<int>>((ref) {
  final events = ref.watch(monthEventsProvider);
  return events.map((e) => e.date.day).toSet();
});
