import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/events_repository.dart';
import '../event_action_handlers.dart';
import '../widgets/event_card.dart';
import '../widgets/featured_event_card.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsListProvider);
    final featuredEvent = ref.watch(featuredEventProvider);
    final monthlyEvents = ref.watch(monthlyEventsProvider);
    // The API sends no events at all while they are switched off.
    final eventsOff =
        ref.watch(userProfileProvider.select((p) => p?.eventsEnabled)) == false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.indigo,
          onRefresh: () => ref.read(eventsListProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: AppFonts.medium,
                    color: AppColors.graphite,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Screen Subtitle
                Text(
                  'Discover summits, panels, and town halls.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5,
                    color: AppColors.sourceSponsored,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Subtle Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.fieldBorder,
                ),

                const SizedBox(height: AppSpacing.md),

                if (events.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Loader(),
                  )
                else if (events.hasError)
                  ErrorState(
                    message: "Couldn't load events.",
                    onRetry: () =>
                        ref.read(eventsListProvider.notifier).refresh(),
                  )
                else if (featuredEvent == null)
                  EmptyState(
                    icon: Icons.event_outlined,
                    message: eventsOff
                        ? 'Events are switched off for your account.'
                        : 'No upcoming events.',
                  ),

                // Hero Featured Event Card
                if (featuredEvent != null) ...[
                  FeaturedEventCard(
                    event: featuredEvent,
                    onTap: () =>
                        context.push('${Routes.events}/${featuredEvent.id}'),
                    onRegisterTap: () =>
                        registerForEvent(context, ref, featuredEvent),
                  ),
                  const SizedBox(height: 28),
                ],

                // The design's 'This month', renamed: the list holds every
                // other event the API sends, not only this month's.
                if (monthlyEvents.isNotEmpty)
                  Text(
                    'More events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 19,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                    ),
                  ),

                const SizedBox(height: 10),

                // Monthly Events List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final event = monthlyEvents[index];
                    return EventCard(
                      event: event,
                      onTap: () => context.push('${Routes.events}/${event.id}'),
                      onCalendarTap: event.startsAt == null
                          ? null
                          : () => addEventToCalendar(context, ref, event),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
