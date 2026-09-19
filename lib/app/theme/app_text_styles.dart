import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The type scale.
///
/// Archivo in two weights only — Regular 400 for body and labels, Medium 500
/// for headings, buttons and active navigation. No bold, no italic; the design
/// system is deliberate about that, so nothing here goes above w500.
///
/// The sizes are provisional: design has specified the typeface and weights but
/// not yet the scale. Screens should read from `Theme.of(context).textTheme`,
/// so replacing these numbers later touches only this file.
abstract final class AppTextStyles {
  static const _f = AppFonts.family;

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontFamily: _f,
      fontSize: 32,
      height: 1.2,
      fontWeight: AppFonts.medium,
    ),
    headlineMedium: TextStyle(
      fontFamily: _f,
      fontSize: 24,
      height: 1.25,
      fontWeight: AppFonts.medium,
    ),
    headlineSmall: TextStyle(
      fontFamily: _f,
      fontSize: 20,
      height: 1.3,
      fontWeight: AppFonts.medium,
    ),
    titleLarge: TextStyle(
      fontFamily: _f,
      fontSize: 18,
      height: 1.35,
      fontWeight: AppFonts.medium,
    ),
    titleMedium: TextStyle(
      fontFamily: _f,
      fontSize: 16,
      height: 1.4,
      fontWeight: AppFonts.medium,
    ),
    bodyLarge: TextStyle(
      fontFamily: _f,
      fontSize: 16,
      height: 1.5,
      fontWeight: AppFonts.regular,
    ),
    bodyMedium: TextStyle(
      fontFamily: _f,
      fontSize: 14,
      height: 1.5,
      fontWeight: AppFonts.regular,
    ),
    bodySmall: TextStyle(
      fontFamily: _f,
      fontSize: 12,
      height: 1.45,
      fontWeight: AppFonts.regular,
    ),
    labelLarge: TextStyle(
      fontFamily: _f,
      fontSize: 14,
      height: 1.2,
      fontWeight: AppFonts.medium,
    ),
    labelMedium: TextStyle(
      fontFamily: _f,
      fontSize: 12,
      height: 1.2,
      fontWeight: AppFonts.regular,
    ),
    labelSmall: TextStyle(
      fontFamily: _f,
      fontSize: 11,
      height: 1.2,
      fontWeight: AppFonts.medium,
    ),
  );
}
