import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Storybook Color Palette ---
  // Primary Backgrounds
  static const Color backgroundColor = Color(0xFFFAF7F0); // Warm ivory / paper cream
  static const Color creamLight = Color(0xFFFFFDF9); // Softest paper highlight
  static const Color creamDark = Color(0xFFF2ECE0); // Gentle paper border / inset
  static const Color cardBackground = Color(0xFFFFFDF9); // Soft paper card

  // Accents
  static const Color primaryPink = Color(0xFFEE6379); // Vibrant storybook rose from reference image
  static const Color primaryPinkLight = Color(0xFFFDE8EC); // Soft blush tint
  static const Color primaryPinkDark = Color(0xFFD64E64); // Pressed pink state

  // Secondary Naturals
  static const Color sageGreen = Color(0xFF8EAA90); // Soft botanical green
  static const Color sageGreenLight = Color(0xFFE4EDE5); // Sprout tint
  static const Color softPeach = Color(0xFFF7D5C4); // Warm peach accent
  static const Color softPeachLight = Color(0xFFFDF0E9);
  static const Color mutedLavender = Color(0xFFDCD6EA); // Gentle lavender twilight
  static const Color softYellow = Color(0xFFFDF3D0); // Gentle sunlight butter
  static const Color softYellowDark = Color(0xFFF5E298);

  // Inks / Typography
  static const Color textPrimary = Color(0xFF362419); // Warm deep chocolate brown ink from reference
  static const Color textSecondary = Color(0xFF6E584B); // Soft brown secondary ink
  static const Color textTertiary = Color(0xFFB5ABA2); // Light muted pencil ink
  static const Color borderSubtle = Color(0xFFEFE8DA); // Delicate paper border

  // --- Storybook Shadows ---
  static const List<BoxShadow> paperShadow = [
    BoxShadow(
      color: Color(0x0A4A403A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x064A403A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> cardElevatedShadow = [
    BoxShadow(
      color: Color(0x0F4A403A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x084A403A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x28F197A2), // Soft tinted pink lift
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
  ];

  // --- Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryPink,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.mali(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.mali(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.nunito(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.nunito(
          color: textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // --- Typography Helpers ---
  static TextStyle get logoStyle {
    return GoogleFonts.mali(
      color: textPrimary,
      fontSize: 44,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    );
  }

  static TextStyle get storybookTitle {
    return GoogleFonts.mali(
      color: textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle get storybookSubtitle {
    return GoogleFonts.nunito(
      color: textSecondary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
  }

  static TextStyle get emotionalLabel {
    return GoogleFonts.mali(
      color: primaryPinkDark,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }
}
