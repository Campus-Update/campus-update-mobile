import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/news_repository.dart';
import '../widgets/news_card.dart';

class NewsSearchScreen extends ConsumerStatefulWidget {
  const NewsSearchScreen({super.key});

  static const _categories = [
    'All',
    'General',
    'Campus',
    'Weather',
    'Tech',
    'Technology',
  ];

  @override
  ConsumerState<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends ConsumerState<NewsSearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(newsSearchQueryProvider);
    _searchController = TextEditingController(text: initialQuery);
    _searchFocusNode = FocusNode();

    // Auto-focus search input when navigating to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onClearOrBack() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      ref.read(newsSearchQueryProvider.notifier).clear();
      setState(() {});
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        _searchFocusNode.unfocus();
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // Soft lavender circular container with purple search magnifying glass icon
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE), // Lavender
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.search_rounded,
                  size: 42,
                  color: Color(0xFF4F46E5), // Indigo / purple
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Heading
            const Text(
              'No news articles found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'Try adjusting your search query or selected category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedNewsCategoryProvider);
    final newsAsync = ref.watch(filteredNewsListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header: News title + Notifications
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'News',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: AppFonts.family,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.graphite,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const NotificationButton(),
                ],
              ),
            ),

            // Search Input Box matching design
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(
                          fontFamily: AppFonts.family,
                          fontSize: 17,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: const Color(0xFF111827),
                        cursorWidth: 1.5,
                        cursorHeight: 20,
                        decoration: const InputDecoration(
                          hintText: 'Search news...',
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          ref
                              .read(newsSearchQueryProvider.notifier)
                              .setQuery(val);
                          setState(() {});
                        },
                        onSubmitted: (_) => _searchFocusNode.unfocus(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onClearOrBack,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories Scroll
            CategoryChips(
              categories: NewsSearchScreen._categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (cat) {
                ref.read(selectedNewsCategoryProvider.notifier).select(cat);
              },
            ),

            const SizedBox(height: 12),

            // Subtle Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

            // News List Content
            Expanded(
              child: newsAsync.when(
                loading: () => const Center(child: Loader()),
                error: (error, _) => Center(
                  child: ErrorState(
                    message: 'Failed to load news updates.',
                    onRetry: () =>
                        ref.read(newsListProvider.notifier).refresh(),
                  ),
                ),
                data: (articles) {
                  if (articles.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.indigo,
                    onRefresh: () =>
                        ref.read(newsListProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: articles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return NewsCard(
                          item: article,
                          onTap: () =>
                              context.push('${Routes.news}/${article.id}'),
                          onBookmarkTap: () {
                            ref
                                .read(newsListProvider.notifier)
                                .toggleBookmark(article.id);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
