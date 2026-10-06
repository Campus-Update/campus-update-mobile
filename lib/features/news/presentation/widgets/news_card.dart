import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/news_item.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBookmarkTap,
  });

  final NewsItem item;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image Thumbnail / Placeholder
              Container(
                width: 135,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.indigoSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 14),

              // Right Information Column
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Category tag and Bookmark button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.category,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontFamily: AppFonts.family,
                                  fontSize: 12,
                                  fontWeight: AppFonts.medium,
                                  color: AppColors.alertRed,
                                ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onBookmarkTap,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 2,
                              ),
                              child: Icon(
                                item.isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_rounded,
                                size: 20,
                                color: item.isBookmarked
                                    ? AppColors.indigo
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Title (2 lines max, ellipsis)
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontFamily: AppFonts.family,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.graphite,
                              height: 1.25,
                            ),
                      ),

                      // Bottom Row: Clock icon and Recency label
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.timeAgo,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: AppFonts.family,
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: AppFonts.regular,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.indigoSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper_outlined,
        size: 28,
        color: AppColors.indigo.withValues(alpha: 0.18),
      ),
    );
  }
}
