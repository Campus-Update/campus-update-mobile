import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/news_repository.dart';
import '../../domain/news_item.dart';

/// One article.
///
/// Measured off the news detail design: a round back button and the section
/// name, the photo, a category pill beside the source and date, the title and
/// the body. Save and Share sit in a bar pinned above the tab bar, so they
/// stay in reach however long the article runs.
///
/// The title and body follow the Figma inspector exactly.
class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.id});

  final String id;

  static const _gutter = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(newsItemByIdProvider(id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: article == null
                  ? const EmptyState(
                      icon: Icons.article_outlined,
                      message: 'Article not found.',
                    )
                  : _Article(article: article),
            ),
            if (article != null)
              _Actions(
                isBookmarked: article.isBookmarked,
                onSave: () => ref
                    .read(newsListProvider.notifier)
                    .toggleBookmark(article.id),
                onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sharing link copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The round back button, then the section name beside it.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        NewsDetailScreen._gutter,
        AppSpacing.md,
        NewsDetailScreen._gutter,
        10,
      ),
      child: Row(
        children: [
          BackButtonCircle(),
          // Measured ~24pt from the button to the title.
          SizedBox(width: 24),
          Text(
            'News',
            style: TextStyle(
              fontSize: 22,
              fontWeight: AppFonts.medium,
              color: AppColors.graphite,
            ),
          ),
        ],
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.article});

  final NewsItem article;

  @override
  Widget build(BuildContext context) {
    final publishedAt = article.publishedAt;
    final meta = [
      article.author,
      publishedAt != null
          ? AppDateFormat.dayMonth(publishedAt)
          : article.timeAgo,
    ].join(' · ');
    final imageUrl = article.imageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NewsDetailScreen._gutter,
        0,
        NewsDetailScreen._gutter,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The same 350:184 as the home hero.
          AspectRatio(
            aspectRatio: 350 / 184,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.indigoSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl == null || imageUrl.isEmpty
                  ? null
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CategoryPill(article.category),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: AppFonts.regular,
                    color: AppColors.graphite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            article.title,
            // Figma: Archivo Medium 18 on a 22 line, #000.
            style: const TextStyle(
              fontSize: 18,
              height: 22 / 18,
              fontWeight: AppFonts.medium,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            article.body ?? article.summary,
            // Figma: Archivo Regular 12 on a 15 line, black at 70%.
            style: const TextStyle(
              fontSize: 12,
              height: 15 / 12,
              fontWeight: AppFonts.regular,
              color: AppColors.articleBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// Save and Share, side by side under a hairline.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.isBookmarked,
    required this.onSave,
    required this.onShare,
  });

  final bool isBookmarked;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        NewsDetailScreen._gutter,
        20,
        NewsDetailScreen._gutter,
        20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.fieldBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: isBookmarked ? 'Saved' : 'Save article',
              trailingIcon: isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border_rounded,
              onPressed: onSave,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: 'Share',
              variant: AppButtonVariant.secondary,
              trailingIcon: Icons.send_outlined,
              onPressed: onShare,
            ),
          ),
        ],
      ),
    );
  }
}
