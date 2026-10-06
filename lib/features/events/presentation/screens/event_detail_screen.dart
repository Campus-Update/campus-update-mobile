import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/events_repository.dart';
import '../widgets/event_image.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventByIdProvider(id));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Event Details'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.graphite),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Event Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.medium,
            color: AppColors.graphite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.graphite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event link copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: EventImage(
                imageUrl: event.imageUrl,
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                iconSize: 56,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Row: Category Badge + Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.indigo,
                                fontWeight: AppFonts.medium,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.sourceSponsored,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.dateFormatted,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.sourceSponsored,
                                  fontSize: 12,
                                  fontWeight: AppFonts.medium,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Event Headline
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Location & Time Information Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: AppFonts.medium,
                                      color: AppColors.graphite,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.time,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: AppFonts.medium,
                                      color: AppColors.graphite,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // About Event Section Title
                  Text(
                    'About this Event',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Event Description Body
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.5,
                      height: 1.6,
                      color: AppColors.sourcePromotedEvent,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Registration & Calendar Actions
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: event.isRegistered
                              ? 'Registered'
                              : 'Register Now',
                          onPressed: () {
                            ref
                                .read(eventsListProvider.notifier)
                                .toggleRegistration(event.id);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () {
                          ref
                              .read(eventsListProvider.notifier)
                              .toggleCalendar(event.id);
                        },
                        icon: Icon(
                          event.isAddedToCalendar
                              ? Icons.calendar_month
                              : Icons.calendar_month_outlined,
                          color: AppColors.indigo,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.indigoSurface,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
