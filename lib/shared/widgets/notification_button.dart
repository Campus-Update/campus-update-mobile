import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';

/// App bar / header notification bell with an alert indicator dot.
class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    this.hasUnread = true,
    this.onPressed,
    this.color = AppColors.graphite,
  });

  final bool hasUnread;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_none_rounded, size: 26, color: color),
          if (hasUnread)
            Positioned(
              top: 1,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEA580C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      splashRadius: 22,
      tooltip: 'Notifications',
      onPressed: onPressed ?? () => context.push(Routes.notifications),
    );
  }
}
