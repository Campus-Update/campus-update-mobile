import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/news_repository.dart';
import '../widgets/bookmark_button.dart';

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key});

  static const _categories = [
    'All',
    'General',
    'Campus',
    'Weather',
    'Health',
    'Technology',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedNewsCategoryProvider);
    final newsAsync = ref.watch(filteredNewsListProvider);
    final hasMore = ref.watch(newsListProvider.notifier).hasMore;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header: News + [Search] [Notifications]
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
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
                  Row(
                    children: [
                      // Search Button NAVIGATES to NewsSearchScreen
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          size: 26,
                          color: AppColors.graphite,
                        ),
                        splashRadius: 22,
                        tooltip: 'Search',
                        onPressed: () => context.push(Routes.newsSearch),
                      ),
                      const NotificationButton(),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Categories Scroll
            CategoryChips(
              categories: _categories,
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
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmptyState(
                            icon: Icons.article_outlined,
                            message: selectedCategory == 'All'
                                ? 'No news updates available.'
                                : 'No news found in "$selectedCategory".',
                          ),
                          if (selectedCategory != 'All')
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(selectedNewsCategoryProvider.notifier)
                                    .select('All');
                              },
                              child: const Text('Show all news'),
                            ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.indigo,
                    onRefresh: () =>
                        ref.read(newsListProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: articles.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        // The row after the last card: reaching it asks for
                        // the next page.
                        if (index == articles.length) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) =>
                                ref.read(newsListProvider.notifier).loadMore(),
                          );
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Loader(),
                          );
                        }
                        final article = articles[index];
                        return ContentCard(
                          label: article.category,
                          title: article.title,
                          imageUrl: article.imageUrl,
                          footer: ContentCardMeta(article.timeAgo),
                          trailing: BookmarkButton(
                            isBookmarked: article.isBookmarked,
                            onTap: () {
                              ref
                                  .read(newsListProvider.notifier)
                                  .toggleBookmark(article.id);
                            },
                          ),
                          onTap: () =>
                              context.push('${Routes.news}/${article.id}'),
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
