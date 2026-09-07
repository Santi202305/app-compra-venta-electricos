import 'package:flutter/material.dart';

/// Paleta y tema visual de la app.
///
/// Los colores se tomaron del prototipo interactivo (prototipo-app.html)
/// para mantener continuidad visual entre el prototipo y la app real.
class AppColors {
  AppColors._();

  static const Color accent = Color(0xFF6C5CE7); // morado principal
  static const Color accentLight = Color(0xFFA29BFE);
  static const Color volt = Color(0xFF00D2FF); // cian de acento
  static const Color warm = Color(0xFFFECA57); // amarillo de aviso/stock
  static const Color success = Color(0xFF00B894);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color ink = Color(0xFF232B33); // texto principal
  static const Color mist = Color(0xFF8B95A1); // texto secundario
  static const Color mistLight = Color(0xFFF0F2F5); // fondos suaves
  static const Color panel = Color(0xFFFFFFFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.mistLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        secondary: AppColors.volt,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(color: AppColors.ink),
        bodySmall: TextStyle(color: AppColors.mist),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mistLight,
        selectedColor: AppColors.accent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
