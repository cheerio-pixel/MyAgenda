import 'package:flutter/material.dart';

/// Yellow theme configuration for Android-focused app
class AppTheme {
  // Yellow color palette
  static const Color primaryYellow = Color(0xFFFFC107); // Amber 500
  static const Color primaryLight = Color(0xFFFFF9C4); // Yellow 100
  static const Color primaryDark = Color(0xFFFFB300); // Amber 700
  static const Color secondaryAmber = Color(0xFFFFB300); // Amber 600
  static const Color surfaceLight = Color(0xFFFEF7E0); // Very light yellow
  static const Color backgroundLight = Color(0xFFFFFDE7); // Yellow 50
  static const Color backgroundDark = Color(0xFF1C1917); // Dark background

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        onPrimary: Colors.black,
        primaryContainer: primaryLight,
        onPrimaryContainer: Color(0xFF5D4037),
        secondary: secondaryAmber,
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFFFFECB3),
        onSecondaryContainer: Color(0xFF5D4037),
        surface: Colors.white,
        onSurface: Color(0xFF1C1917),
        surfaceContainerHighest: surfaceLight,
        error: Color(0xFFB3261E),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF5D4037)),
      ),
      listTileTheme: const ListTileThemeData(iconColor: Color(0xFF5D4037)),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        onPrimary: Colors.black,
        primaryContainer: Color(0xFF5D4037),
        onPrimaryContainer: primaryLight,
        secondary: secondaryAmber,
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFF6D4C41),
        onSecondaryContainer: Color(0xFFFFECB3),
        surface: Color(0xFF2D2A26),
        onSurface: Color(0xFFF5F5F5),
        surfaceContainerHighest: Color(0xFF3D3A36),
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Color(0xFF2D2A26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF2D2A26),
        elevation: 16,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3D3A36),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),
    );
  }
}
