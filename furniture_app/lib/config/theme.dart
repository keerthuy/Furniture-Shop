import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color background = Color(0xFFFFF8F0);
  static const Color primary = Color(0xFFC08552);
  static const Color secondary = Color(0xFF8C5A3C);
  static const Color dark = Color(0xFF4B2E2B);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF7A6560);
  static const Color border = Color(0xFFE8D8C8);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: white,
      error: error,
      onPrimary: white,
      onSecondary: white,
      onSurface: dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: dark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: dark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondary,
        side: const BorderSide(color: secondary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: TextStyle(color: grey.withOpacity(0.6)),
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 2,
      shadowColor: dark.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primary,
      unselectedItemColor: grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
