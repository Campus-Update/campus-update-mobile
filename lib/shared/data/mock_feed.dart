import '../domain/content_item.dart';
import '../domain/content_source.dart';

/// Stand-in content for while the dev API's feed is empty.
///
/// Written as the JSON the API returns, so it goes through the same
/// [ContentItem.fromJson] as real responses. It also fills in what the API
/// does not send yet — category, summary, imageUrl, eventStartsAt and
/// eventLocation — so the screens can be checked against the design. Those
/// field names are a guess at what the backend will add; rename them here if
/// it picks others.
///
/// [FeedRepository] still calls the API every time and only falls back to
/// this when the answer is empty. See `Env.mockEmptyFeed`.
abstract final class MockFeed {
  /// The slice of mock content a `/feed` call with these filters would get.
  static List<ContentItem> feed({
    ContentType? type,
    Urgency? urgency,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    final q = search?.trim().toLowerCase() ?? '';
    final matches = _items.where((item) {
      if (type != null && item.type != type) return false;
      if (urgency != null && item.urgency != urgency) return false;
      if (q.isNotEmpty &&
          !item.title.toLowerCase().contains(q) &&
          !item.body.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
    return matches.skip((page - 1) * pageSize).take(pageSize).toList();
  }

  static ContentItem? item(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Ids carry this prefix so a mock item is never mistaken for a real one.
  static bool isMock(String id) => id.startsWith('mock-');

  static final List<ContentItem> _items = _json
      .map(ContentItem.fromJson)
      .toList();

  static String _image(String seed) =>
      'https://picsum.photos/seed/$seed/600/400';

  static String _ago(Duration d) =>
      DateTime.now().toUtc().subtract(d).toIso8601String();

  static String _ahead(Duration d) =>
      DateTime.now().toUtc().add(d).toIso8601String();

  static final List<Map<String, dynamic>> _json = [
    // Urgent — these fill the breaking-news hero.
    {
      'id': 'mock-news-1',
      'title': 'Major Infrastructure Overhaul Announced for North Campus',
      'summary':
          'The university administration has unveiled a comprehensive plan to '
          'rebuild roads, drainage and lecture halls on North Campus.',
      'body':
          'The university administration has unveiled a comprehensive plan to '
          'rebuild roads, drainage and lecture halls on North Campus. Work '
          'begins after the first-semester examinations and is expected to run '
          'for eighteen months. Lectures in affected buildings will move to the '
          'Faculty of Science complex.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Urgent',
      'sourceType': 'Official',
      'sourceName': 'Office of the Registrar',
      'publishedAt': _ago(const Duration(minutes: 40)),
      'category': 'Campus',
      'imageUrl': _image('north-campus'),
    },
    {
      'id': 'mock-news-2',
      'title': 'Senate Approves Revised Academic Calendar for 2025/2026',
      'summary':
          'Lectures resume a fortnight earlier than previously planned, and '
          'first-semester examinations move forward by a week.',
      'body':
          'Lectures resume a fortnight earlier than previously planned, and '
          'first-semester examinations move forward by a week. Students are '
          'advised to complete course registration before resumption.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Urgent',
      'sourceType': 'Official',
      'sourceName': 'University Senate',
      'publishedAt': _ago(const Duration(hours: 3)),
      'category': 'General',
      'imageUrl': _image('senate-calendar'),
    },
    {
      'id': 'mock-news-3',
      'title': 'Severe Thunderstorm Warning for Tonight',
      'summary':
          'Heavy rain and strong winds are expected from 6pm. Evening outdoor '
          'events are postponed.',
      'body':
          'Heavy rain and strong winds are expected from 6pm. All evening '
          'outdoor events are postponed, and students are asked to stay '
          'indoors where possible.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Urgent',
      'sourceType': 'Official',
      'sourceName': 'Works and Services',
      'publishedAt': _ago(const Duration(hours: 5)),
      'category': 'Weather',
      'imageUrl': _image('thunderstorm'),
    },

    // Everyday news.
    {
      'id': 'mock-news-4',
      'title':
          'FOCIT introduces machine learning elective for 400 level students',
      'summary':
          'The Faculty of Computing will offer a new machine learning elective '
          'from the second semester.',
      'body':
          'The Faculty of Computing will offer a new machine learning elective '
          'from the second semester. The course is open to 400 level students '
          'in Computer Science and Software Engineering.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Faculty of Computing',
      'publishedAt': _ago(const Duration(hours: 8)),
      'category': 'Campus',
      'imageUrl': _image('ml-elective'),
    },
    {
      'id': 'mock-news-5',
      'title': 'New Library Wing Opens with 24/7 Study Lounges',
      'summary':
          'The new wing adds 400 reading spaces and study lounges that stay '
          'open around the clock.',
      'body':
          'The new wing adds 400 reading spaces, group study rooms and study '
          'lounges that stay open around the clock. A valid student ID is '
          'needed to enter after 10pm.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'University Library',
      'publishedAt': _ago(const Duration(days: 1)),
      'category': 'General',
      'imageUrl': _image('library-wing'),
    },
    {
      'id': 'mock-news-6',
      'title': 'Campus Wi-Fi Moves to Single Sign-On This Weekend',
      'summary':
          'From Saturday, students sign in to campus Wi-Fi with their portal '
          'details instead of a separate password.',
      'body':
          'From Saturday, students sign in to campus Wi-Fi with their portal '
          'details instead of a separate password. Expect short outages '
          'between midnight and 4am while the change goes in.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Important',
      'sourceType': 'Official',
      'sourceName': 'ICT Unit',
      'publishedAt': _ago(const Duration(days: 2)),
      'category': 'Technology',
      'imageUrl': _image('campus-wifi'),
    },
    {
      'id': 'mock-news-7',
      'title': 'Inter-Faculty Sports Festival Registration Now Open',
      'summary':
          'Faculties have until the end of the month to register teams for '
          'football, athletics and table tennis.',
      'body':
          'Faculties have until the end of the month to register teams for '
          'football, athletics and table tennis. Registration forms are '
          'available from the Students Union office.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'External',
      'sourceName': 'Students Union',
      'publishedAt': _ago(const Duration(days: 3)),
      'category': 'Campus',
      'imageUrl': _image('sports-festival'),
    },
    {
      'id': 'mock-news-8',
      'title': 'Heatwave Advisory: Hydration Stations Set Up Across Campus',
      'summary':
          'Temperatures are expected to pass 36°C this week. Free water is '
          'available at six stations.',
      'body':
          'Temperatures are expected to pass 36°C this week. Free water is '
          'available at six hydration stations, including the main gate, the '
          'library and the Faculty of Science.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Health Centre',
      'publishedAt': _ago(const Duration(days: 4)),
      'category': 'Weather',
      'imageUrl': _image('heatwave'),
    },

    {
      'id': 'mock-news-9',
      'title': 'Free Medical Screening at the Health Centre This Week',
      'summary':
          'Blood pressure, blood sugar and eye checks are free for students '
          'and staff until Friday.',
      'body':
          'Blood pressure, blood sugar and eye checks are free for students '
          'and staff until Friday, from 9am to 3pm. Bring your ID card.',
      'type': 'News',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Health Centre',
      'publishedAt': _ago(const Duration(days: 5)),
      'category': 'Health',
      'imageUrl': _image('medical-screening'),
    },

    // Events — the API accepts eventStartsAt and eventLocation on create.
    {
      'id': 'mock-event-1',
      'title': 'Matriculation ceremony for the 2025/2026 session',
      'summary': 'All newly admitted students are expected to attend.',
      'body':
          'All newly admitted students are expected to attend in full academic '
          'dress. Gates open at 8am.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Office of the Registrar',
      'publishedAt': _ago(const Duration(days: 2)),
      'category': 'Campus',
      'imageUrl': _image('matriculation'),
      'eventStartsAt': _ahead(const Duration(days: 5)),
      'eventLocation': 'University Sports Complex',
    },
    {
      'id': 'mock-event-2',
      'title': 'Tech Career Fair with Industry Partners',
      'summary': 'Meet recruiters from twelve technology companies.',
      'body':
          'Meet recruiters from twelve technology companies. Bring printed '
          'copies of your CV.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Sponsored',
      'sourceName': 'Career Services',
      'publishedAt': _ago(const Duration(days: 3)),
      'category': 'Technology',
      'imageUrl': _image('career-fair'),
      'eventStartsAt': _ahead(const Duration(days: 9)),
      'eventLocation': 'Main Auditorium',
    },
    {
      'id': 'mock-event-3',
      'title': 'Departmental Week: Computer Science Hackathon',
      'summary': 'A 24-hour hackathon open to all levels.',
      'body':
          'A 24-hour hackathon open to all levels. Teams of up to four. Meals '
          'are provided.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'External',
      'sourceName': 'Computer Science Students Association',
      'publishedAt': _ago(const Duration(days: 4)),
      'category': 'Campus',
      'imageUrl': _image('hackathon'),
      'eventStartsAt': _ahead(const Duration(days: 14)),
      'eventLocation': 'Faculty of Computing Lab 2',
    },
    {
      'id': 'mock-event-4',
      'title': 'Students Union Town Hall on Hostel Fees',
      'summary': 'Bring your questions on the new hostel fee schedule.',
      'body':
          'The Students Union executive will take questions on the new hostel '
          'fee schedule and the plan for the new blocks.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'External',
      'sourceName': 'Students Union',
      'publishedAt': _ago(const Duration(days: 1)),
      'category': 'Campus',
      'imageUrl': _image('town-hall'),
      'eventStartsAt': _ahead(const Duration(days: 18)),
      'eventLocation': 'Student Union Auditorium',
    },
    {
      'id': 'mock-event-5',
      'title': 'Inaugural Lecture: Data, Health and the Nigerian Hospital',
      'summary': 'The Faculty of Computing presents its first inaugural.',
      'body':
          'The Faculty of Computing presents its first inaugural lecture, on '
          'how hospital data can shorten waiting times. Open to all.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Faculty of Computing',
      'publishedAt': _ago(const Duration(days: 6)),
      'category': 'Health',
      'imageUrl': _image('inaugural-lecture'),
      'eventStartsAt': _ahead(const Duration(days: 21)),
      'eventLocation': 'University Main Auditorium',
    },
    {
      'id': 'mock-event-6',
      'title': 'Inter-Faculty Football Final',
      'summary': 'Computing take on Law for the trophy.',
      'body':
          'Computing take on Law for the inter-faculty trophy. Kick-off at '
          '4pm; come early for seats.',
      'type': 'Event',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'External',
      'sourceName': 'Sports Council',
      'publishedAt': _ago(const Duration(days: 2)),
      'category': 'Campus',
      'imageUrl': _image('football-final'),
      'eventStartsAt': _ahead(const Duration(days: 25)),
      'eventLocation': 'University Sports Complex',
    },

    // Announcements — the Active Alerts screen.
    {
      'id': 'mock-alert-1',
      'title': 'CSC 304 exam venue moved to Auditorium B',
      'summary':
          'The CSC 304 examination has been relocated from the Faculty of '
          'Computing exam hall to Auditorium B. Please arrive 30 minutes early.',
      'body':
          'The CSC 304 examination has been relocated from the Faculty of '
          'Computing exam hall to Auditorium B due to ongoing renovations. '
          'Students are advised to arrive at least 30 minutes early to settle '
          'in. Bring your ID card and exam docket.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Urgent',
      'sourceType': 'Official',
      'sourceName': 'Faculty of Computing',
      'publishedAt': _ago(const Duration(minutes: 32)),
      'category': 'Academic',
    },
    {
      'id': 'mock-alert-2',
      'title': 'Second semester course registration closes 26 September',
      'summary':
          'All students must complete course registration before the deadline.',
      'body':
          'All students must complete their course registration on the portal '
          'before 11:59pm on 26 September. Late registrations will not be '
          'accepted without the Dean\'s approval.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Important',
      'sourceType': 'Official',
      'sourceName': 'Office of the Registrar',
      'publishedAt': _ago(const Duration(days: 1)),
      'category': 'Academic',
    },
    {
      'id': 'mock-alert-3',
      'title': 'Library extends weekend opening hours',
      'summary': 'The main library will now open from 7am to 11pm on weekends.',
      'body':
          'Starting this weekend, the main library extends its Saturday and '
          'Sunday hours to 7am–11pm. The 24-hour study lounge remains '
          'available at all times.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'University Library',
      'publishedAt': _ago(const Duration(days: 2)),
      'category': 'General',
    },
    {
      'id': 'mock-alert-4',
      'title': 'Water supply interruption on South Campus Thursday',
      'summary':
          'Maintenance work will interrupt water supply from 8am to 4pm.',
      'body':
          'Planned maintenance on the South Campus water mains will cause '
          'an interruption from 8am to 4pm on Thursday. Please store water '
          'in advance. The North Campus hostels are not affected.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Important',
      'sourceType': 'Official',
      'sourceName': 'Works and Services',
      'publishedAt': _ago(const Duration(days: 1, hours: 6)),
      'category': 'Campus',
    },
    {
      'id': 'mock-alert-5',
      'title': 'CSC 304 lab submission deadline extended to Friday',
      'summary':
          'The lab submission deadline for CSC 304 has been pushed to Friday.',
      'body':
          'Due to the exam venue change, the lab submission deadline for '
          'CSC 304 has been extended from Wednesday to Friday at 5pm.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Faculty of Computing',
      'publishedAt': _ago(const Duration(hours: 2)),
      'category': 'Academic',
    },
    {
      'id': 'mock-alert-6',
      'title': 'CSC 304 revision tutorial session scheduled for Saturday',
      'summary':
          'A tutorial revision session for CSC 304 will be held in Hall C.',
      'body':
          'Ahead of the exams, course assistants will hold an interactive '
          'revision session for CSC 304 covering core algorithms and queries.',
      'type': 'Announcement',
      'status': 'Published',
      'urgency': 'Normal',
      'sourceType': 'Official',
      'sourceName': 'Faculty of Computing',
      'publishedAt': _ago(const Duration(days: 3)),
      'category': 'Academic',
    },
  ];
}
