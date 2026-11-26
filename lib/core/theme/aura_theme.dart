import 'package:flutter/material.dart';

import 'aura_colors.dart';

abstract final class AuraTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AuraColors.champagneGold,
      onPrimary: AuraColors.obsidianVoid,
      secondary: AuraColors.manaCyan,
      onSecondary: AuraColors.obsidianVoid,
      tertiary: AuraColors.solarGold,
      surface: AuraColors.smokedCharcoal,
      onSurface: AuraColors.creamText,
      error: AuraColors.psychicMagenta,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AuraColors.obsidianVoid,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AuraColors.champagneGold,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AuraColors.smokedCharcoal,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraColors.smokedCharcoal.withValues(alpha: 0.86),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.28),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.24),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AuraColors.champagneGold,
            width: 1.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AuraColors.champagneGold,
          foregroundColor: AuraColors.obsidianVoid,
          disabledBackgroundColor: AuraColors.surfaceRaised,
          disabledForegroundColor: AuraColors.mutedText.withValues(alpha: 0.55),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AuraColors.champagneGold,
          minimumSize: const Size(64, 48),
          side: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.38),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}
