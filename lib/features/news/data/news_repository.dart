import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/content_source.dart';
import '../domain/news_item.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> getNews({String? category, String? query});
  Future<NewsItem?> getNewsById(String id);
  Future<void> toggleBookmark(String id);
}

class MockNewsRepository implements NewsRepository {
  MockNewsRepository() {
    _items = [
      const NewsItem(
        id: 'news-1',
        title:
            'New Library Wing Opens with 24/7 Study Lounges and Modern Research Facilities',
        category: 'Campus',
        timeAgo: 'Recent update',
        summary:
            'The long-awaited North Wing of the University Central Library officially opened today, featuring state-of-the-art digital media pods, collaborative study rooms, and quiet research chambers.',
        body:
            'The university administration celebrated the ribbon-cutting ceremony for the newly constructed North Wing of the Main Campus Library. The expansion adds over 500 new study spaces, high-speed fiber connectivity, collaborative media production pods, and specialized research terminals with access to international academic databases.\n\nStudents will now have 24/7 access to the ground floor reading halls using their digital campus ID cards. University Librarian Dr. Eleanor Vance commended the student union for their input on the design, ensuring accessible workstations and natural lighting throughout the architectural blueprint.',
        author: 'Campus News Desk',
        source: ContentSource.officialSchool,
        readTime: '3 min read',
      ),
      const NewsItem(
        id: 'news-2',
        title:
            'City Council Approves New Campus Bus Line and Subsidized Student Transit Passes',
        category: 'General',
        timeAgo: 'Updated recently',
        summary:
            'A revised public transit ordinance provides dedicated express shuttle services connecting major student residential districts directly to campus gates.',
        body:
            'In a unanimous vote yesterday evening, the Metropolitan Transit Authority approved a cooperative transit pact with the university. Starting next Monday, the new Line 14 Express bus will operate every 10 minutes during peak morning and evening lecture hours.\n\nAdditionally, full-time undergraduate and graduate students will be eligible for a 60% fare discount upon presenting their active student barcode via the Campus Update app or standard student credential.',
        author: 'Civic Affairs Bureau',
        source: ContentSource.campusUpdate,
        readTime: '4 min read',
      ),
      const NewsItem(
        id: 'news-3',
        title:
            'Engineering Department Unveils Cutting-Edge AI and Robotics Laboratory',
        category: 'Technology',
        timeAgo: 'Updated recently',
        summary:
            'Faculty of Engineering partners with industry innovators to launch an autonomous robotics workshop equipped with GPU compute clusters.',
        body:
            'The Department of Computer & Electrical Engineering has commissioned a multi-million-dollar AI and Robotics lab. Funded through a strategic partnership with leading technology firms, the facility hosts advanced industrial robotic arms, drone prototyping testbeds, and dedicated local neural-network training nodes.\n\nDean of Engineering remarked that students enrolled in robotics, computer science, and mechatronics courses will begin practical laboratory sessions in the newly unveiled space starting this academic term.',
        author: 'Faculty of Engineering',
        source: ContentSource.officialSchool,
        readTime: '5 min read',
      ),
      const NewsItem(
        id: 'news-4',
        title:
            'Major Security Update Required for Campus WiFi and Single Sign-On Access',
        category: 'Tech',
        timeAgo: 'Updated recently',
        summary:
            'Information Technology Services mandates a certificate renewal for all personal and institutional devices connected to the campus wireless network.',
        body:
            'To maintain compliance with modern cybersecurity protocols, IT Services will deploy an updated root certificate across all university networks at midnight this Friday. Students and faculty members are advised to update their device security profiles through the IT self-service portal to avoid connection interruptions.\n\nSupport desks will be stationed at the student union building and the library to assist anyone experiencing authentication difficulties during the migration window.',
        author: 'IT Services Directorate',
        source: ContentSource.officialSchool,
        readTime: '2 min read',
      ),
      const NewsItem(
        id: 'news-5',
        title:
            'Severe Thunderstorm Warning: Evening Outdoor Campus Events Rescheduled',
        category: 'Weather',
        timeAgo: 'Updated recently',
        summary:
            'National Meteorological Service issues a severe weather alert with anticipated high wind gusts and heavy rainfall starting at 5:00 PM.',
        body:
            'Due to an incoming severe weather front carrying localized thunderstorm activity, campus safety personnel have advised all outdoor extracurricular events scheduled after 5:00 PM today to be moved indoors or postponed.\n\nIntramural sports fixtures scheduled on the central athletic fields will be rescheduled for Saturday afternoon. Shuttle services will remain operational with cautious speed limits in effect across campus roads.',
        author: 'Campus Safety & Emergency Operations',
        source: ContentSource.officialSchool,
        readTime: '2 min read',
      ),
      const NewsItem(
        id: 'news-6',
        title:
            'Major Security Update Released for Departmental Workstations and Lab Devices',
        category: 'Tech',
        timeAgo: 'Updated recently',
        summary:
            'Critical patches deployed to protect laboratory workstations and academic departmental systems against newly identified vulnerabilities.',
        body:
            'Following recommendations from the national cyber defense agency, system administrators have completed rolling out urgent patch updates across all computer clusters and laboratory computers. Network performance should remain stable, and all student lab systems are now verified secure for coursework.',
        author: 'Network Security Operations',
        source: ContentSource.campusUpdate,
        readTime: '3 min read',
      ),
      const NewsItem(
        id: 'news-7',
        title:
            'Annual Inter-Faculty Sports Festival Registration Officially Commences',
        category: 'General',
        timeAgo: 'Updated recently',
        summary:
            'Students from all faculties are invited to register teams for football, track & field, volleyball, and chess tournaments.',
        body:
            'Registration is now open for the 2026 Inter-Faculty Games! Departmental captains must submit final team rosters before Friday at 4:00 PM. Over 1,200 student athletes are expected to compete across twenty sporting disciplines throughout the two-week festival.',
        author: 'Sports Advisory Council',
        source: ContentSource.campusUpdate,
        readTime: '3 min read',
      ),
      const NewsItem(
        id: 'news-8',
        title: 'Campus Solar Energy Grid Expansion Completed Ahead of Schedule',
        category: 'Campus',
        timeAgo: 'Updated recently',
        summary:
            'Rooftop photovoltaic arrays installed across lecture halls will generate over 35% of peak daytime electricity consumption.',
        body:
            'The Green Campus Initiative reached a major milestone today with the commissioning of solar arrays atop the Science Complex and Engineering buildings. This initiative is estimated to offset hundreds of metric tons of carbon emissions annually while providing real-time telemetry data for renewable energy students.',
        author: 'Sustainability Directorate',
        source: ContentSource.officialSchool,
        readTime: '4 min read',
      ),
      const NewsItem(
        id: 'news-9',
        title:
            'Severe Heatwave Advisory: Hydration Stations Deployed Across Campus Grounds',
        category: 'Weather',
        timeAgo: 'Updated recently',
        summary:
            'Temperatures expected to exceed 34°C; additional shaded rest areas and free chilled water dispensers installed along major walking paths.',
        body:
            'With forecasted temperatures peaking over 34°C this week, the University Health Centre reminds students to drink plenty of fluids and limit strenuous physical exertion during peak afternoon hours. Free chilled water stations have been positioned near all main lecture building entrances.',
        author: 'University Health Services',
        source: ContentSource.campusUpdate,
        readTime: '2 min read',
      ),
    ];
  }

  late List<NewsItem> _items;

  @override
  Future<List<NewsItem>> getNews({String? category, String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    var result = List<NewsItem>.from(_items);

    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      result = result.where((item) {
        final cat = item.category.toLowerCase();
        final filter = category.toLowerCase();
        if (filter == 'tech' || filter == 'technology') {
          return cat == 'tech' || cat == 'technology';
        }
        return cat == filter;
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result
          .where(
            (item) =>
                item.title.toLowerCase().contains(q) ||
                item.summary.toLowerCase().contains(q) ||
                item.category.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  @override
  Future<NewsItem?> getNewsById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> toggleBookmark(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(isBookmarked: !current.isBookmarked);
    }
  }
}

/// Provider for the [NewsRepository].
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return MockNewsRepository();
});

/// State notifier managing selected news category filter.
class SelectedNewsCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String category) => state = category;
}

final selectedNewsCategoryProvider =
    NotifierProvider<SelectedNewsCategoryNotifier, String>(
      SelectedNewsCategoryNotifier.new,
    );

/// State notifier managing news search query filter.
class NewsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final newsSearchQueryProvider =
    NotifierProvider<NewsSearchQueryNotifier, String>(
      NewsSearchQueryNotifier.new,
    );

/// State notifier managing the news list state.
class NewsListNotifier extends Notifier<AsyncValue<List<NewsItem>>> {
  @override
  AsyncValue<List<NewsItem>> build() {
    // Initial fetch
    _loadNews();
    return const AsyncValue.loading();
  }

  Future<void> _loadNews() async {
    try {
      final repo = ref.read(newsRepositoryProvider);
      final items = await repo.getNews();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadNews();
  }

  void toggleBookmark(String id) {
    state.whenData((items) {
      final updated = items.map((item) {
        if (item.id == id) {
          final newState = !item.isBookmarked;
          // Also notify repo
          ref.read(newsRepositoryProvider).toggleBookmark(id);
          return item.copyWith(isBookmarked: newState);
        }
        return item;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}

final newsListProvider =
    NotifierProvider<NewsListNotifier, AsyncValue<List<NewsItem>>>(
      NewsListNotifier.new,
    );

/// Provider for filtered news based on selected category and search query.
final filteredNewsListProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final category = ref.watch(selectedNewsCategoryProvider);
  final query = ref.watch(newsSearchQueryProvider).trim().toLowerCase();
  final newsState = ref.watch(newsListProvider);

  return newsState.whenData((items) {
    var result = items;
    if (category.toLowerCase() != 'all') {
      final filter = category.toLowerCase();
      result = result.where((item) {
        final cat = item.category.toLowerCase();
        if (filter == 'tech' || filter == 'technology') {
          return cat == 'tech' || cat == 'technology';
        }
        return cat == filter;
      }).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.summary.toLowerCase().contains(query) ||
            (item.body?.toLowerCase().contains(query) ?? false) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  });
});

/// Family provider to fetch a single news item by id.
final newsItemByIdProvider = Provider.family<NewsItem?, String>((ref, id) {
  final newsState = ref.watch(newsListProvider);
  return newsState.value?.cast<NewsItem?>().firstWhere(
    (item) => item?.id == id,
    orElse: () => null,
  );
});
