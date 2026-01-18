import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - "Luxe Noir"
  static const Color pureGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFC5A028);
  static const Color luxeBlack = Color(0xFF111111);
  static const Color luxeWhite = Color(0xFFFAFAFA);
  
  // Aliases for compatibility
  static const Color midnight = luxeBlack;
  static const Color spaceDark = luxeBlack;
  static const Color electricBlue = pureGold;
  static const Color arcticIce = luxeWhite;

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: pureGold,
      scaffoldBackgroundColor: luxeWhite,
      colorScheme: const ColorScheme.light(
        primary: pureGold,
        secondary: darkGold,
        onPrimary: Colors.white,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: luxeBlack,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: luxeBlack),
      ),
      inputDecorationTheme: _inputDecoration(isDark: false),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(isDark: false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: pureGold,
      scaffoldBackgroundColor: luxeBlack,
      colorScheme: const ColorScheme.dark(
        primary: pureGold,
        secondary: darkGold,
        onPrimary: luxeBlack,
        surface: Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: luxeBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: pureGold,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: pureGold),
      ),
      inputDecorationTheme: _inputDecoration(isDark: true),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(isDark: true),
      tabBarTheme: const TabBarThemeData(
        labelColor: pureGold,
        unselectedLabelColor: Colors.white30,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: pureGold.withOpacity(0.1), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: pureGold.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: pureGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38, 
        fontSize: 12, 
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      floatingLabelStyle: const TextStyle(
        color: pureGold,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pureGold,
        foregroundColor: luxeBlack,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
      ),
    );
  }

  static CardThemeData _cardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
    );
  }
}
