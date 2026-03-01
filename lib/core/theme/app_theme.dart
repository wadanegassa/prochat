import 'package:flutter/material.dart';

class AppTheme {
  // Earthy Minimalist Palette
  static const Color rose = Color(0xFFC75F71);
  static const Color peach = Color(0xFFF0B8B8);
  static const Color sage = Color(0xFFA2AE9D);
  static const Color brown = Color(0xFF54463A);
  static const Color deepBrown = Color(0xFF3D342F);
  static const Color cream = Color(0xFFFDF8F5);
  static const Color softGrey = Color(0xFFE5E5E5);
  static const Color vibrantBlue = Color(0xFF0A78FF);
  static const Color darkBg = Color(0xFF0B0F1A); // Cooler deep navy/slate

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: rose,
      scaffoldBackgroundColor: cream,
      colorScheme: const ColorScheme.light(
        primary: rose,
        secondary: sage,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: brown,
        surfaceContainerHigh: softGrey,
        tertiary: vibrantBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: brown,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: brown, size: 22),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: vibrantBlue,
        unselectedItemColor: brown.withValues(alpha: 0.3),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      inputDecorationTheme: _inputDecoration(isDark: false),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(isDark: false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: rose,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: rose,
        secondary: sage,
        onPrimary: Colors.white,
        surface: Color(0xFF161B2E), // Cool navy surface
        onSurface: Color(0xFFE0E0E0), // Premium Light Grey for primary text
        surfaceContainerHigh: Color(0xFF1E253D), // Cooler container
        onSurfaceVariant: Color(0xFF9E9E9E), // Dim Grey for secondary text
        tertiary: vibrantBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFE0E0E0), // Light Grey
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFE0E0E0), size: 22),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        selectedItemColor: vibrantBlue,
        unselectedItemColor: Color(0xFF9E9E9E).withValues(alpha: 0.5), // Dim Grey
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      inputDecorationTheme: _inputDecoration(isDark: true),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(isDark: true),
    );
  }

  static InputDecorationTheme _inputDecoration({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F4F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: vibrantBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(
        color: isDark ? Colors.white.withValues(alpha: 0.3) : brown.withValues(alpha: 0.3), 
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rose,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
      ),
    );
  }

  static CardThemeData _cardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? brown.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }
}
