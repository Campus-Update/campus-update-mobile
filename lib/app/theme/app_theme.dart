import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    // The generated scheme fills in the surface and container tones; the four
    // brand colours are then pinned to their exact values so Indigo, Alert Red
    // and Emerald render as designed rather than as tonal approximations.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.indigo,
          onPrimary: Colors.white,
          error: AppColors.alertRed,
          onError: Colors.white,
        );

    final isLight = brightness == Brightness.light;

    return ThemeData(
      colorScheme: scheme,
      fontFamily: AppFonts.family,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: isLight ? AppColors.graphite : scheme.onSurface,
        displayColor: isLight ? AppColors.graphite : scheme.onSurface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: isLight ? AppColors.graphite : scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      // Fields are white with a hairline border, sitting on AppFormPanel.
      // Measured off the design: 48 high, 10 radius, 1px #E2E2E2.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
          color: AppColors.fieldHint,
          height: 1,
        ),
        // 17 + a 14pt line at height 1 + 17 gives the design's 48.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 17,
        ),
        border: _fieldBorder(AppColors.fieldBorder),
        enabledBorder: _fieldBorder(AppColors.fieldBorder),
        disabledBorder: _fieldBorder(AppColors.fieldBorder),
        // The design does not show a focused or error field, so these follow
        // the palette and should be confirmed.
        focusedBorder: _fieldBorder(AppColors.indigo),
        errorBorder: _fieldBorder(AppColors.alertRed),
        focusedErrorBorder: _fieldBorder(AppColors.alertRed),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: AppTextStyles.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: AppColors.indigo.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              // Medium 500 for active navigation, Regular 400 otherwise.
              ? AppTextStyles.textTheme.labelSmall
              : AppTextStyles.textTheme.labelMedium,
        ),
      ),
    );
  }
}
