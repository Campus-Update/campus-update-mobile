import 'package:flutter/material.dart';

/// Semantic colour tokens.
///
/// Designs have not been delivered yet, so the palette below is a placeholder.
/// When the brand palette arrives, only the values in this file change — no
/// screen references a raw colour, so nothing else has to be touched.
abstract final class AppColors {
  /// Drives the generated [ColorScheme] for both brightnesses.
  static const seed = Color(0xFF1B5E9B);

  // Urgency, per the PRD's Normal / Important / Urgent ladder.
  static const urgencyNormal = Color(0xFF4B5563);
  static const urgencyImportant = Color(0xFFB45309);
  static const urgencyUrgent = Color(0xFFB91C1C);

  // Trust indicators. Every content item is labelled with one of these.
  static const sourceOfficial = Color(0xFF15803D);
  static const sourceCampusUpdate = Color(0xFF1B5E9B);
  static const sourceSponsored = Color(0xFF7C3AED);
  static const sourceExternal = Color(0xFF9A3412);
}
