import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraTheme {
  // Brand colors from HTML
  static const Color primaryGreen = Color(0xFF065F46);
  static const Color accentGreen = Color(0xFF059669);
  static const Color backgroundColor = Color(0xFFF7FAF6);
  static const Color onSurfaceVariant = Color(0xFF545F73);

  static const Color primary = Color(0xFF065F46);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7FAF6);
  static const Color onSurface = Color(0xFF002117);
  static const Color surfaceContainer = Color(0xFFEBF2EB);
  static const Color surfaceContainerLow = Color(0xFFF1F6F1);
  static const Color surfaceContainerHigh = Color(0xFFE5EDE5);
  static const Color surfaceContainerHighest = Color(0xFFDEE7DE);
  static const Color outline = Color(0xFF707973);
  static const Color outlineVariant = Color(0xFFBEC9C2);
  static const Color secondary = Color(0xFF4D6357);
  static const Color secondaryContainer = Color(0xFFCFE9D9);
  static const Color onSecondaryContainer = Color(0xFF0B1F16);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color deepGreen = Color(0xFF004532);
  static const Color emeraldAccent = Color(0xFF34D399);
  static const LinearGradient botanicalGradient = LinearGradient(
    colors: [primaryGreen, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        error: error,
        onError: onPrimary,
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.lexendTextTheme().copyWith(
        bodyMedium: GoogleFonts.lexend(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.lexend(
          color: secondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
