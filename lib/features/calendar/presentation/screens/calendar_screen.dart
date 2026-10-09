import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/calendar_repository.dart';
import '../widgets/calendar_event_card.dart';
import '../widgets/calendar_grid.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMonth = ref.watch(activeMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthEvents = ref.watch(monthEventsProvider);
    final eventDays = ref.watch(eventDaysInActiveMonthProvider);

    final monthTitle = DateFormat('MMMM yyyy').format(activeMonth);

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
              // Screen Header: Title + Search & Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Calendar',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.push(Routes.search),
                        icon: const Icon(
                          Icons.search_rounded,
                          size: 24,
                          color: AppColors.graphite,
                        ),
                        splashRadius: 20,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.push(Routes.notifications),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 24,
                              color: AppColors.graphite,
                            ),
                            Positioned(
                              top: 0,
                              right: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.alertRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        splashRadius: 20,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Subtle Divider
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.fieldBorder,
              ),

              const SizedBox(height: AppSpacing.md),

              // Month Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: AppFonts.medium,
                      color: AppColors.graphite,
                    ),
                  ),
                  Row(
                    children: [
                      _MonthNavButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: () {
                          ref
                              .read(activeMonthProvider.notifier)
                              .previousMonth();
                        },
                      ),
                      const SizedBox(width: 8),
                      _MonthNavButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: () {
                          ref.read(activeMonthProvider.notifier).nextMonth();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Interactive Calendar Grid
              CalendarGrid(
                activeMonth: activeMonth,
                selectedDate: selectedDate,
                eventDays: eventDays,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).selectDate(date);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Reusable Section Header
              SectionHeader(title: '$monthTitle Dates'),

              const SizedBox(height: AppSpacing.sm),

              // List of Dates
              if (monthEvents.isEmpty) ...[
                const EmptyState(
                  message: 'No scheduled dates for this month.',
                  icon: Icons.event_busy_outlined,
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final event = monthEvents[index];
                    return CalendarEventCard(
                      event: event,
                      onTap: () {
                        ref
                            .read(selectedDateProvider.notifier)
                            .selectDate(event.date);
                        context.push('${Routes.calendar}/${event.id}');
                      },
                    );
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.graphite),
      ),
    );
  }
}
