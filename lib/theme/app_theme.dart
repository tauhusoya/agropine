import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌿 Pineapple Theme Colors
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkGreen = Color(0xFF2D5016);
  static const Color lightGreen = Color(0xFF7CB342);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  // 🌞 Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: textDark),
          bodyMedium: TextStyle(color: textLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        foregroundColor: textDark,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: accentOrange,
      ),
    );
  }

  // 🌙 Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      fontFamily: 'Poppins',
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
      ).copyWith(secondary: accentOrange),
    );
  }
}
