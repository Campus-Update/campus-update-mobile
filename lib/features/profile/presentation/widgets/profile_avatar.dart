import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Circular avatar for profile screens that displays a selected image or initials/placeholder.
///
/// The avatar image is only rendered when [imagePath] is provided (i.e. selected by the user).
/// If no image has been selected, it displays the user's initials or a default profile silhouette.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.radius = 43.0,
    this.imagePath,
    this.name,
    this.initials,
    this.showEditBadge = false,
    this.onEditPhoto,
  });

  final double radius;
  final String? imagePath;
  final String? name;
  final String? initials;
  final bool showEditBadge;
  final VoidCallback? onEditPhoto;

  String get _resolvedInitials {
    final explicit = initials?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;
    final n = name?.trim() ?? '';
    if (n.isNotEmpty) {
      final parts = n.split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return '';
  }

  ImageProvider? _resolveImageProvider(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (!kIsWeb) {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;
    final imageProvider = hasImage ? _resolveImageProvider(imagePath!) : null;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: hasImage
          ? const Color(0xFFE5E7EB)
          : const Color(0xFFEDE9FE),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? (_resolvedInitials.isNotEmpty
              ? Text(
                  _resolvedInitials,
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: radius * 0.52,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: radius * 1.1,
                  color: const Color(0xFF9CA3AF),
                ))
          : null,
    );

    if (!showEditBadge) {
      return avatar;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onEditPhoto,
          child: avatar,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onEditPhoto,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.crop_original_outlined,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
