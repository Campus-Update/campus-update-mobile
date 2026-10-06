import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/event_item.dart';

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
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AppColors.indigoSurface,
                  ),
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? (event.imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                event.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(),
                              )
                            : Image.network(
                                event.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(),
                              ))
                      : _buildPlaceholder(),
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
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Featured',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.family,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 5),
              Text(
                event.dateFormatted,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.family,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
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
              fontFamily: AppFonts.family,
              fontSize: 17,
              fontWeight: FontWeight.w700,
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
              fontFamily: AppFonts.family,
              fontSize: 13,
              color: const Color(0xFF6B7280),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 6),

          // Location Row
          Row(
            children: [
              const Icon(
                Icons.remove_circle_outline_rounded,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.family,
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.indigoSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.event_outlined,
        size: 48,
        color: AppColors.indigo.withValues(alpha: 0.3),
      ),
    );
  }
}
