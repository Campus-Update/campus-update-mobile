import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/calendar_repository.dart';

class CalendarDetailScreen extends ConsumerWidget {
  const CalendarDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(calendarEventsProvider);
    final event = events.where((e) => e.id == id).firstOrNull;

    if (event == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.graphite),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Calendar',
            style: TextStyle(
              color: AppColors.graphite,
              fontWeight: AppFonts.medium,
            ),
          ),
        ),
        body: const Center(
          child: EmptyState(
            icon: Icons.event_busy_outlined,
            message: 'Event not found.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with circular back button and Calendar title
              Row(
                children: [
                  BackButtonCircle(onPressed: () => context.pop()),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Calendar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Banner Image
              EventImage(
                imageUrl: event.imageUrl,
                width: double.infinity,
                height: 190,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                iconSize: 48,
              ),

              const SizedBox(height: AppSpacing.md),

              // Badges Row: Category Pill + Source Label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.indigo,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: AppFonts.medium,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.sourceLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: AppFonts.regular,
                      color: AppColors.graphite,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Event Headline
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: AppFonts.medium,
                  color: AppColors.graphite,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Info Table / Group Rows
              Column(
                children: [
                  _InfoTile(
                    label: 'Date:',
                    value:
                        event.dateFormatted ??
                        '${event.day}/${event.month}/${event.year}',
                  ),
                  if (event.time != null && event.time!.isNotEmpty)
                    _InfoTile(label: 'Time:', value: event.time!),
                  if (event.venue != null && event.venue!.isNotEmpty)
                    _InfoTile(label: 'Venue:', value: event.venue!),
                  if (event.entry != null && event.entry!.isNotEmpty)
                    _InfoTile(label: 'Entry:', value: event.entry!),
                  if (event.organiser != null && event.organiser!.isNotEmpty)
                    _InfoTile(label: 'Organiser:', value: event.organiser!),
                  if (event.audience != null && event.audience!.isNotEmpty)
                    _InfoTile(label: 'Audience:', value: event.audience!),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Description Text
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                Text(
                  event.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    height: 1.55,
                    color: AppColors.sourcePromotedEvent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Save this events action button
              AppButton(
                label: event.isSaved ? 'Saved to calendar' : 'Save this events',
                trailingIcon: event.isSaved
                    ? Icons.check_circle_outline_rounded
                    : Icons.calendar_month_outlined,
                fontSize: 15,
                onPressed: () {
                  ref
                      .read(calendarEventsProvider.notifier)
                      .toggleSaved(event.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        event.isSaved
                            ? 'Removed from your saved events'
                            : 'Event saved to your calendar!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.sourceSponsored,
                fontWeight: AppFonts.regular,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.graphite,
                fontWeight: AppFonts.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
