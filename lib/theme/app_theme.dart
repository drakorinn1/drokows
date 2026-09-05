import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renkler, orijinal v0 (Next.js) projesindeki globals.css içindeki
/// oklch tasarım tokenlarının yaklaşık hex karşılıklarıdır. Ayrıca
/// kullanıcının onayladığı lacivert (#1B2A4A) + turuncu (#F2712B)
/// vurgu rengi ile uyumludur.
class AppColors {
  AppColors._();

  static const background = Color(0xFFFAFAF8);
  static const foreground = Color(0xFF232A3B); // lacivert-gri metin
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFFF2712B); // turuncu vurgu
  static const primaryForeground = Color(0xFF33200F); // turuncu üstü koyu metin
  static const secondary = Color(0xFFF2F1EC);
  static const secondaryForeground = Color(0xFF2C3140);
  static const muted = Color(0xFFF2F1EC);
  static const mutedForeground = Color(0xFF83868D);
  static const accent = Color(0xFFF7E3CF);
  static const accentForeground = Color(0xFF3D2410);
  static const destructive = Color(0xFFD8442F);
  static const border = Color(0xFFE6E4DD);
  static const chart2 = Color(0xFF4C7EA6); // "usta atandı" mavi
  static const chart3 = Color(0xFF3F9E70); // "tamamlandı" yeşil
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.card,
        onSurface: AppColors.foreground,
        error: AppColors.destructive,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.manrope().fontFamily,
      textTheme: GoogleFonts.manropeTextTheme().apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}
