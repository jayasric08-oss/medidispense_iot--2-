import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global Dark-Mode Cyber-Medical Theme Design System for MediDispense IoT
class CyberMedicalTheme {
  // Brand Color Palette
  static const Color background = Color(0xFF0F172A); // Deep Slate
  static const Color cardSurface = Color(0xFF1E293B); // Slate Surface
  static const Color cardSurfaceTranslucent = Color(0xD91E293B); // Translucent Slate
  static const Color primaryAccent = Color(0xFF06B6D4); // Neon Cyan
  static const Color secondaryAccent = Color(0xFF3B82F6); // Bright Blue
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warningAlert = Color(0xFFEF4444); // Crimson Red
  
  // Neutral Tones
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderGlow = Color(0x3D06B6D4); // Soft Cyan Border
  static const Color dividerColor = Color(0xFF334155);

  /// Dark Cyber-Medical ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryAccent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.dark,
        surface: cardSurface,
        onSurface: textPrimary,
        error: warningAlert,
      ).copyWith(
        primary: primaryAccent,
        secondary: secondaryAccent,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,

      // AppBar Styling
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 6,
        shadowColor: primaryAccent.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: primaryAccent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input Decoration Theme (Form Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151D2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textMuted, fontSize: 15),
        labelStyle: const TextStyle(color: primaryAccent, fontSize: 14, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryAccent.withValues(alpha: 0.2), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryAccent.withValues(alpha: 0.25), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: warningAlert, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: warningAlert, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: const Color(0xFF090D16),
          elevation: 4,
          shadowColor: primaryAccent.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryAccent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: primaryAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryAccent.withValues(alpha: 0.3), width: 1),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardSurface,
        contentTextStyle: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: primaryAccent.withValues(alpha: 0.3), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Custom Box Shadow for Cyber Glow
  static List<BoxShadow> cyberGlow({Color color = primaryAccent, double opacity = 0.25, double blur = 12}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Linear Gradient for Translucent Glass Cards
  static LinearGradient cyberGlassGradient() {
    return LinearGradient(
      colors: [
        const Color(0xFF1E293B).withValues(alpha: 0.85),
        const Color(0xFF0F172A).withValues(alpha: 0.90),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
