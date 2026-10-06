import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/event_item.dart';
import 'event_image.dart';

class FeaturedEventCard extends StatelessWidget {
  const FeaturedEventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onRegisterTap,
  });

  final EventItem event;
  final VoidCallback onTap;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with "Featured" pill badge
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Stack(
              children: [
                EventImage(
                  imageUrl: event.imageUrl,
                  width: double.infinity,
                  height: 180,
                  iconSize: 48,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg),
                        bottomRight: Radius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                    child: Text(
                      'Featured',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: AppFonts.medium,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Date Row with Clock Icon
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.sourceSponsored,
              ),
              const SizedBox(width: 5),
              Text(
                event.dateFormatted,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: AppFonts.medium,
                  color: AppColors.sourceSponsored,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Event Title
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: AppFonts.medium,
              color: AppColors.graphite,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 4),

          // Event Description
          Text(
            event.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: AppColors.sourceSponsored,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 6),

          // Location Row
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.sourceSponsored,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.sourceSponsored,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // "Register Now" / "Registered" Button using shared AppButton
          AppButton(
            label: event.isRegistered ? 'Registered' : 'Register Now',
            trailingIcon: event.isRegistered
                ? Icons.check_circle_outline_rounded
                : Icons.calendar_month_outlined,
            height: 48,
            fontSize: 15,
            onPressed: onRegisterTap,
          ),
        ],
      ),
    );
  }
}
