import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/events_repository.dart';

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
            fontFamily: AppFonts.family,
            fontWeight: FontWeight.w700,
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
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.indigoSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? (event.imageUrl!.startsWith('assets/')
                          ? Image.asset(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(),
                            )
                          : Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(),
                            ))
                    : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.dateFormatted,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
                      fontFamily: AppFonts.family,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.graphite,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location & Time Information Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
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
                                      fontWeight: FontWeight.w500,
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
                                      fontWeight: FontWeight.w500,
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
                      fontFamily: AppFonts.family,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.graphite,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Event Description Body
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.5,
                      height: 1.6,
                      color: const Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 32),

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
                          backgroundColor: const Color(0xFFEDE9FE),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.indigoSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.event_outlined,
        size: 56,
        color: AppColors.indigo.withValues(alpha: 0.25),
      ),
    );
  }
}
