import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/event_item.dart';

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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Image Thumbnail / Placeholder
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? (event.imageUrl!.startsWith('assets/')
                          ? Image.asset(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ))
                    : _buildPlaceholder(),
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
                          fontFamily: AppFonts.family,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
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
                                Icons.remove_circle_outline_rounded,
                                size: 13,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontFamily: AppFonts.family,
                                        fontSize: 11.5,
                                        color: const Color(0xFF6B7280),
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
                                size: 13,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.dateFormatted,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontFamily: AppFonts.family,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
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

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFEDE9FE),
      alignment: Alignment.center,
      child: Icon(
        Icons.event_note_outlined,
        size: 32,
        color: AppColors.indigo.withValues(alpha: 0.25),
      ),
    );
  }
}
