import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/event_item.dart';
import 'event_image.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onCalendarTap,
  });

  final EventItem event;
  final VoidCallback onTap;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image Thumbnail
              EventImage(
                imageUrl: event.imageUrl,
                width: 130,
                height: 130,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                iconSize: 32,
              ),

              const SizedBox(width: 14),

              // Right Information Column
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Event Title
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 14.5,
                          fontWeight: AppFonts.medium,
                          color: AppColors.graphite,
                          height: 1.25,
                        ),
                      ),

                      // Location & Date Rows
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.sourceSponsored,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 11.5,
                                        color: AppColors.sourceSponsored,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
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
                                      fontSize: 11.5,
                                      fontWeight: AppFonts.medium,
                                      color: AppColors.sourceSponsored,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // "Add to calendar" Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          label: event.isAddedToCalendar
                              ? 'In calendar'
                              : 'Add to calendar',
                          trailingIcon: event.isAddedToCalendar
                              ? Icons.check_circle_outline_rounded
                              : Icons.calendar_month_outlined,
                          expand: false,
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          fontSize: 12.5,
                          onPressed: onCalendarTap,
                        ),
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
}
