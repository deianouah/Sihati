import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1B8039); // Green
  static const Color backgroundColor = Color(0xFFF5F7F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2E3E5C);
  static const Color textSecondary = Color(0xFF9FA5C0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: primaryColor.withValues(alpha: 0.8),
        surface: backgroundColor,
      ),
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        displayLarge: GoogleFonts.tajawal(
            fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: GoogleFonts.tajawal(
            fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: GoogleFonts.tajawal(
            fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge: GoogleFonts.tajawal(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.tajawal(
            fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        bodyMedium: GoogleFonts.tajawal(
            fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.tajawal(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
    );
  }
}
