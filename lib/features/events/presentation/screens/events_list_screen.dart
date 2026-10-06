import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/events_repository.dart';
import '../widgets/event_card.dart';
import '../widgets/featured_event_card.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredEvent = ref.watch(featuredEventProvider);
    final monthlyEvents = ref.watch(monthlyEventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.indigo,
          onRefresh: () async {
            ref.read(eventsListProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: AppFonts.family,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.graphite,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 4),

                // Screen Subtitle
                Text(
                  'Discover summits, panels, and town halls.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.family,
                    fontSize: 14.5,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtle Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),

                const SizedBox(height: 16),

                // Hero Featured Event Card
                if (featuredEvent != null) ...[
                  FeaturedEventCard(
                    event: featuredEvent,
                    onTap: () =>
                        context.push('${Routes.events}/${featuredEvent.id}'),
                    onRegisterTap: () {
                      ref
                          .read(eventsListProvider.notifier)
                          .toggleRegistration(featuredEvent.id);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            featuredEvent.isRegistered
                                ? 'Registration cancelled for ${featuredEvent.title}'
                                : 'Successfully registered for ${featuredEvent.title}!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                ],

                // "This month" Section Header
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.family,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
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
                      onCalendarTap: () {
                        ref
                            .read(eventsListProvider.notifier)
                            .toggleCalendar(event.id);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              event.isAddedToCalendar
                                  ? 'Removed from your calendar'
                                  : 'Event added to your calendar!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
