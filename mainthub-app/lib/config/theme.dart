import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modernized Brand colors
  static const Color primary    = Color(0xFF2563EB); // modern vibrant blue
  static const Color secondary  = Color(0xFF3B82F6); // lighter blue
  static const Color success    = Color(0xFF10B981); // emerald green
  static const Color warning    = Color(0xFFF59E0B); // amber
  static const Color danger     = Color(0xFFEF4444); // red
  static const Color background = Color(0xFFF3F4F6); // soft gray background
  static const Color surface    = Color(0xFFFFFFFF); // pure white cards
  static const Color textDark   = Color(0xFF111827); // near black
  static const Color textLight  = Color(0xFF6B7280); // gray

  static ThemeData get theme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent, // Prevents Material 3 tinting
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 2,
          shadowColor: primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: textLight),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
        color: surface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: textDark),
      ),
    );
  }
}
