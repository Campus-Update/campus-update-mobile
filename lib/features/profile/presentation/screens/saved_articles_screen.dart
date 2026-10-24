import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../news/data/news_repository.dart';
import '../../../news/presentation/widgets/bookmark_button.dart';
import '../widgets/profile_screen_header.dart';

/// The articles saved on this phone, opened from Profile.
class SavedArticlesScreen extends ConsumerWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedArticlesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Saved articles'),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.indigo,
                onRefresh: () async {
                  final reload = ref.refresh(savedArticlesProvider.future);
                  try {
                    await reload;
                  } catch (_) {
                    // The error state below says so.
                  }
                },
                child: saved.when(
                  loading: () => const Loader(),
                  error: (_, _) => _Centred(
                    child: ErrorState(
                      message: "Couldn't load your saved articles.",
                      onRetry: () => ref.invalidate(savedArticlesProvider),
                    ),
                  ),
                  data: (articles) => articles.isEmpty
                      ? const _Centred(child: _NothingSaved())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return ContentCard(
                              label: article.category,
                              title: article.title,
                              imageUrl: article.imageUrl,
                              footer: ContentCardMeta(article.timeAgo),
                              trailing: BookmarkButton(
                                isBookmarked: true,
                                onTap: () => ref
                                    .read(newsListProvider.notifier)
                                    .toggleBookmark(article.id),
                              ),
                              onTap: () =>
                                  context.push(Routes.savedArticle(article.id)),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centres [child] in the space below the header while staying scrollable,
/// so pull-to-refresh still works.
class _Centred extends StatelessWidget {
  const _Centred({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NothingSaved extends StatelessWidget {
  const _NothingSaved();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.indigoSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bookmark_border_rounded,
            size: 32,
            color: AppColors.indigo,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No saved articles yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.family,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the bookmark on any news article to keep it here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.family,
            fontSize: 14,
            height: 1.5,
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }
}
