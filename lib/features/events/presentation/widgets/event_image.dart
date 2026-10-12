import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable image widget for events with asset/network support and fallback placeholder.
class EventImage extends StatelessWidget {
  const EventImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.iconSize = 32,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    Widget content;
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        content = Image.asset(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } else {
        content = Image.network(
          url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    } else {
      content = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: content),
      );
    }

    return SizedBox(width: width, height: height, child: content);
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.indigoSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.event_outlined,
        size: iconSize,
        color: AppColors.indigo.withValues(alpha: 0.25),
      ),
    );
  }
}
