import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// The empty-state illustration for Active Alerts:
/// A soft lavender circle with a sleeping bell icon (with 'zZz') and
/// "No notifications yet" message and subtitle.
class AlertsEmptyState extends StatelessWidget {
  const AlertsEmptyState({super.key, this.isSearch = false});

  /// When true, shows a search-specific empty state.
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bell or search icon in a lavender circle.
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isSearch
                    ? const Icon(
                        Icons.search_off_rounded,
                        size: 44,
                        color: AppColors.indigo,
                      )
                    : const _SleepingBellWidget(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isSearch ? 'No results found' : 'No notifications yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.family,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.graphite,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isSearch
                  ? 'Try a different search term or filter.'
                  : "When there's activity on your requests,\nyou'll see updates here.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: AppFonts.family,
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bell icon with sleeping "zZz" drifting up on the top right, exactly
/// matching the Figma design.
class _SleepingBellWidget extends StatelessWidget {
  const _SleepingBellWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.notifications_rounded,
            size: 42,
            color: AppColors.indigo,
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'z',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    height: 1.0,
                  ),
                ),
                Text(
                  'Z',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    height: 1.0,
                  ),
                ),
                Text(
                  'z',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
