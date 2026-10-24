import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A row in a content list: thumbnail on the left, then a label, a title and a
/// footer line.
///
/// The design reuses this shape on Latest News, Upcoming Events, the News tab
/// and Announcements, so it lives here rather than in one screen. The values
/// are the ones the home screen already shipped with — this is an extraction,
/// not a redesign.
///
/// Only the footer differs between the two uses on home, so it is a slot:
/// pass [ContentCardAction] for a call to action, [ContentCardMeta] for a
/// quiet line of detail. [trailing] sits at the end of the label line, for a
/// per-item action such as a bookmark.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.label,
    required this.title,
    required this.footer,
    this.imageUrl,
    this.trailing,
    this.footerGap = _footerGap,
    this.onTap,
  });

  /// The category or tag above the title — 'Campus', 'Official event'.
  final String label;

  final String title;

  /// The line under the title.
  final Widget footer;

  /// The thumbnail. Without one, or if it fails to load, the thumbnail is a
  /// plain surface.
  final String? imageUrl;

  /// An action at the end of the label line — a bookmark.
  final Widget? trailing;

  /// Space between the title and [footer].
  ///
  /// Latest News shipped with 6 and Upcoming Events with 4. They are meant to
  /// be the same number and the difference is invisible, but both are kept so
  /// the extraction changes nothing on screen; design should settle which.
  final double footerGap;

  final VoidCallback? onTap;

  static const _thumbWidth = 120.0;
  static const _thumbHeight = 80.0;
  static const _thumbRadius = 12.0;
  static const _thumbGap = 14.0;
  static const _labelGap = 3.0;
  static const _footerGap = 6.0;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _thumbWidth,
          height: _thumbHeight,
          decoration: BoxDecoration(
            color: AppColors.indigoSurface,
            borderRadius: BorderRadius.circular(_thumbRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl == null || imageUrl!.isEmpty
              ? null
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
        ),
        const SizedBox(width: _thumbGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.sourceSponsored,
                        fontWeight: AppFonts.regular,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: _labelGap),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: AppFonts.medium,
                  color: AppColors.feedTitle,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: footerGap),
              footer,
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

/// The call to action under a [ContentCard] title — 'READ MORE'.
class ContentCardAction extends StatelessWidget {
  const ContentCardAction(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: AppFonts.medium,
        color: AppColors.feedTitle,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// The quiet detail line under a [ContentCard] title — a date and a venue.
class ContentCardMeta extends StatelessWidget {
  const ContentCardMeta(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        color: AppColors.sourceSponsored,
        fontWeight: AppFonts.regular,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
