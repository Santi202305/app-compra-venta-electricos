import 'package:flutter/material.dart';

/// Paleta industrial técnica profesional basada en la regla 60 / 30 / 10.
/// - 60% Neutros: Fondo gris muy claro cálido (#F8FAFC) y superficies blancas (#FFFFFF).
/// - 30% Primario: Azul profundo petróleo (#0F2942) para barras, botones y encabezados.
/// - 10% Acento: Ámbar técnico (#D97706 / #B45309) reservado para ofertas, stock bajo y CTA.
/// - Semánticos independientes: Verde RETIE (#15803D) y Rojo alerta (#DC2626).
class AppColors {
  AppColors._();

  // 30% Primario (Azul Petróleo Industrial)
  static const Color primary = Color(0xFF0F2942);
  static const Color primaryDark = Color(0xFF091A2B);
  static const Color accent = Color(0xFF0F2942); // Alias retrocompatible con código existente
  static const Color accentLight = Color(0xFF1E3A5F);

  // 10% Acento (Ámbar Técnico de Advertencia y Acción)
  static const Color warm = Color(0xFFD97706); // Ámbar principal
  static const Color amberDark = Color(0xFFB45309);
  static const Color volt = Color(0xFF0284C7); // Azul técnico de soporte

  // Semánticos Normalizados
  static const Color success = Color(0xFF15803D); // Verde técnico norma RETIE
  static const Color danger = Color(0xFFDC2626); // Rojo técnico de advertencia

  // 60% Neutros (Luz y Contraste WCAG AA >= 4.5:1)
  static const Color ink = Color(0xFF0F172A); // Slate 900 texto de alto contraste
  static const Color mist = Color(0xFF475569); // Slate 600 secundario legible
  static const Color mistLight = Color(0xFFF8FAFC); // Slate 50 fondo claro limpio
  static const Color panel = Color(0xFFFFFFFF); // Superficie limpia
  static const Color border = Color(0xFFCBD5E1); // Borde fino técnico de 1 px
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color darkBanner = Color(0xFF0F2942);
}

class AppTheme {
  AppTheme._();

  /// Radio geométrico unificado para toda la aplicación (catálogo industrial sobrio).
  static const double borderRadiusValue = 8.0;
  static final BorderRadius borderRadius = BorderRadius.circular(borderRadiusValue);

  /// Tema Claro Oficial
  static ThemeData get theme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE2E8F0),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.warm,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF92400E),
      tertiary: AppColors.volt,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.panel,
      onSurface: AppColors.ink,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.mistLight,
      cardColor: Colors.white,
      dividerColor: AppColors.borderSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.mist,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
        indicatorColor: const Color(0xFFE2E8F0),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.mist,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.mist,
            size: 20,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: Color(0xFFE2E8F0),
        selectedIconTheme: IconThemeData(color: AppColors.primary, size: 22),
        unselectedIconTheme: IconThemeData(color: AppColors.mist, size: 20),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: AppColors.mist,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Tema Oscuro Oficial (Misma disciplina sobria industrial sobre carbón oscuro)
  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0B131E);
    const darkSurface = Color(0xFF131D2A);
    const darkBorder = Color(0xFF1E2D42);
    const darkInk = Color(0xFFF1F5F9);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF38BDF8),
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF0F2942),
      onPrimaryContainer: Color(0xFFBAE6FD),
      secondary: Color(0xFFF59E0B),
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF78350F),
      onSecondaryContainer: Color(0xFFFEF3C7),
      tertiary: Color(0xFF38BDF8),
      onTertiary: Colors.black,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      surface: darkSurface,
      onSurface: darkInk,
      outline: darkBorder,
      outlineVariant: Color(0xFF1E293B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );
  }
}
