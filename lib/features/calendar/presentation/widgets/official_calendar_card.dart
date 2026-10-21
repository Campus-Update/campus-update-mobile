import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/official_calendar.dart';

/// A row on the Calendar screen that opens the school's official academic
/// calendar, or says it has not been published yet.
class OfficialCalendarCard extends ConsumerWidget {
  const OfficialCalendarCard({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    try {
      // A fresh link: the one loaded with the screen may have expired.
      final calendar = await ref.refresh(officialCalendarProvider.future);
      if (calendar == null) return;
      navigator.push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => _CalendarImageScreen(calendar: calendar),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(officialCalendarProvider);
    final calendar = state.value;
    final published = calendar != null;

    final subtitle = state.isLoading
        ? 'Loading…'
        : state.hasError
        ? "Couldn't load it. Tap to try again."
        : published
        ? [
            calendar.academicSession,
            'Tap to view',
          ].where((s) => s.isNotEmpty).join(' · ')
        : 'Your school has not published it yet.';

    return Material(
      color: AppColors.indigoSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: published || state.hasError ? () => _open(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 22,
                color: AppColors.indigo,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calendar?.title ?? 'Official academic calendar',
                      style: const TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 14,
                        fontWeight: AppFonts.medium,
                        color: AppColors.graphite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (published)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.graphite,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The calendar picture, pinch to zoom.
class _CalendarImageScreen extends StatelessWidget {
  const _CalendarImageScreen({required this.calendar});

  final OfficialCalendar calendar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          [
            calendar.title,
            calendar.academicSession,
          ].where((s) => s.isNotEmpty).join(' · '),
          style: const TextStyle(fontFamily: AppFonts.family, fontSize: 16),
        ),
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Image.network(
            calendar.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const CircularProgressIndicator(color: Colors.white),
            errorBuilder: (_, __, ___) => const Text(
              "Couldn't load the calendar.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
