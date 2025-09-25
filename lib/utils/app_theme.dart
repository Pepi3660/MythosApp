import 'package:flutter/material.dart';

/// Paleta verde + dorado
class AppTheme {
  // Dorados
  static const _gold = Color(0xFFD4AC2C); // Satin Sheen Gold
  static const _goldDeep = Color(0xFFBC8C07); // Dark Goldenrod
  // Verdes
  static const _green = Color(0xFF457A43); // Fern Green
  static const _greenDark = Color(0xFF326430); // Dark Olive Green

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _green,
      primary: _green,
      secondary: _gold,
      tertiary: _goldDeep,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAF7),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: false,
        elevation: 2,
      ),
      // >>> CardThemeData (no CardTheme)
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: .6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surface,
        showDragHandle: true,
        elevation: 2,
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _greenDark,
      primary: _greenDark,
      secondary: _gold,
      tertiary: _goldDeep,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF141A14),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: false,
        elevation: 2,
      ),
      // >>> CardThemeData (no CardTheme)
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: .5),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surface,
        showDragHandle: true,
        elevation: 2,
      ),
    );
  }
}
