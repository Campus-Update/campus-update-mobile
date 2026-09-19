import 'package:flutter/material.dart';

/// The Campus Update palette.
///
/// Four foundational colours from the design system: Indigo carries the brand,
/// Graphite handles text and structure, Alert Red is reserved for actions and
/// alerts, Emerald confirms success.
abstract final class AppColors {
  // Core palette.
  static const indigo = Color(0xFF4F46E5); // primary, brand
  static const graphite = Color(0xFF111214); // text, structure
  static const alertRed = Color(0xFFDC2626); // actions, alerts
  static const emerald = Color(0xFF047857); // success, confirmed

  /// Drives the generated [ColorScheme].
  static const seed = indigo;

  // Announcement priority. The PRD requires these to be distinguishable
  // without relying on colour, so UrgencyBadge pairs each with an icon and a
  // word — see urgency_badge.dart.
  //
  // The palette has no amber, so Important currently borrows Indigo. Worth
  // confirming with design: a warning colour would read better, and Urgent
  // sharing Alert Red with system errors is a deliberate overlap.
  static const urgencyUrgent = alertRed;
  static const urgencyImportant = indigo;
  static const urgencyNormal = Color(0xFF6B7280); // graphite ramp, mid

  // Trust indicators on every content item.
  //
  // Also constrained by a four-colour palette: Sponsored and Promoted Event
  // both fall back to graphite tones, which makes paid content quieter than
  // official content. That reads correctly, but design should confirm it.
  static const sourceOfficial = emerald;
  static const sourceCampusUpdate = indigo;
  static const sourceSponsored = Color(0xFF6B7280);
  static const sourcePromotedEvent = Color(0xFF374151);
}

/// Archivo is the sole typeface: Regular 400 for body and labels, Medium 500
/// for headings, buttons and active navigation. No bold, no italic.
///
/// Until the .ttf files are added to assets/fonts/ and the fonts block in
/// pubspec.yaml is uncommented, Flutter falls back to the platform default.
abstract final class AppFonts {
  static const family = 'Archivo';
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
}
