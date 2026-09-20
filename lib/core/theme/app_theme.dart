import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color cream = Color(0xFFFDFBF7);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color pastelPink = Color(0xFFFFE4E1);
  static const Color sage = Color(0xFF8A9A86);
  static const Color lavender = Color(0xFFE6E6FA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.light(
        primary: charcoal,
        secondary: sage,
        tertiary: pastelPink,
        surface: cream,
        onSurface: charcoal,
      ),
      textTheme: TextTheme(
        // Chapter titles, major headings
        displayLarge: GoogleFonts.playfairDisplay(
          color: charcoal,
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: charcoal,
          fontSize: 36,
          fontWeight: FontWeight.w600,
        ),
        // Standard headings
        headlineLarge: GoogleFonts.inter(
          color: charcoal,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        // UI text
        bodyLarge: GoogleFonts.inter(
          color: charcoal,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: charcoal,
          fontSize: 14,
        ),
        // Handwritten annotations
        labelLarge: GoogleFonts.caveat(
          color: charcoal,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
