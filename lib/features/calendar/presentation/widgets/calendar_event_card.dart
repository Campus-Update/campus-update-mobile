import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/calendar_event.dart';

class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({super.key, required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Date Badge on the left
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.indigoSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${event.day}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: AppFonts.medium,
                    color: AppColors.indigo,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title and Category in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: AppFonts.medium,
                        color: AppColors.graphite,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: AppFonts.regular,
                        color: AppColors.sourceSponsored,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right chevron button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.graphite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
