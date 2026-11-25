import 'package:flutter/material.dart';

import 'aura_colors.dart';

abstract final class AuraTheme {
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AuraColors.solarGold,
      onPrimary: AuraColors.obsidianVoid,
      secondary: AuraColors.manaCyan,
      onSecondary: AuraColors.obsidianVoid,
      surface: AuraColors.smokedCharcoal,
      onSurface: Colors.white,
      error: AuraColors.psychicMagenta,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AuraColors.obsidianVoid,
      appBarTheme: const AppBarTheme(
        backgroundColor: AuraColors.obsidianVoid,
        foregroundColor: AuraColors.solarGold,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AuraColors.smokedCharcoal,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AuraColors.solarGold.withValues(alpha: 0.22)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
