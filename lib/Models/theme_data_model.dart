import 'package:flutter/material.dart';

/// Central place for the app's light and dark [ThemeData].
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system, // or driven by your `theme` setting
///   ...
/// )
/// ```
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------
  // Dark palette (matches the existing settings screen colors)
  // ---------------------------------------------------------------------
  static const _darkBackground = Color(0xFF18181B);
  static const _darkSurface = Color(0xFF202023);
  static const _darkSurfaceVariant = Color(0xFF29292D);
  static const _darkBorder = Colors.white; // used with .withOpacity(0.06) etc.

  // ---------------------------------------------------------------------
  // Light palette
  // ---------------------------------------------------------------------
  static const _lightBackground = Color(0xFFF5F5F7);
  static const _lightSurface = Colors.white;
  static const _lightSurfaceVariant = Color(0xFFEDEDF0);
  static const _lightBorder = Colors.black;

  // Shared brand/accent color across both themes — adjust to match your
  // actual brand color if this doesn't already exist elsewhere.
  static const _accent = Color(0xFF00A7E3);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: colorScheme.copyWith(
        surface: _lightSurface,
        primary: _accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      cardColor: _lightSurface,
      dividerColor: _lightBorder.withValues(alpha: 0.08),
      textTheme: _buildTextTheme(
        base: ThemeData.light().textTheme,
        onColor: Colors.black87,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _accent
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _accent.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.black87, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_lightSurfaceVariant),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black54),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: colorScheme.copyWith(
        surface: _darkSurface,
        primary: _accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: _darkSurface,
      dividerColor: _darkBorder.withValues(alpha: 0.06),
      textTheme: _buildTextTheme(
        base: ThemeData.dark().textTheme,
        onColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _accent
              : Colors.grey.shade600,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _accent.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_darkSurfaceVariant),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required TextTheme base,
    required Color onColor,
  }) {
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 14, color: onColor),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 12,
        color: onColor.withValues(alpha: 0.7),
      ),
    );
  }
}
