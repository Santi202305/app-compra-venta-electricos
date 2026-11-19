import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_compra_venta_electricos/theme/app_theme.dart';

/// Cálculo de luminancia relativa y ratio de contraste según las pautas WCAG 2.1 (AA).
double contrastRatio(Color c1, Color c2) {
  final l1 = c1.computeLuminance();
  final l2 = c2.computeLuminance();
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Fase 4 - Diseño Visual Sobrio Industrial y Paleta 60/30/10', () {
    final theme = AppTheme.theme;
    final darkTheme = AppTheme.darkTheme;

    test('ThemeData utiliza Material 3 con ColorScheme explícito', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.brightness, equals(Brightness.light));
      expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
    });

    test('Paleta 60/30/10 respeta colores corporativos técnicos', () {
      // 30% Primario: Azul Petróleo Industrial
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(AppColors.primary, equals(const Color(0xFF0F2942)));

      // 10% Acento: Ámbar Técnico
      expect(theme.colorScheme.secondary, equals(AppColors.warm));
      expect(AppColors.warm, equals(const Color(0xFFD97706)));

      // 60% Neutros: Fondo cálido claro y superficies limpias
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFF8FAFC)));
      expect(theme.colorScheme.surface, equals(const Color(0xFFFFFFFF)));
    });

    test('Contraste WCAG AA cumple mínimo de 4.5:1 para texto normal', () {
      final textOnScaffold = contrastRatio(AppColors.ink, theme.scaffoldBackgroundColor);
      expect(
        textOnScaffold,
        greaterThanOrEqualTo(4.5),
        reason: 'El texto principal contra el fondo debe cumplir WCAG AA (4.5:1). Ratio real: $textOnScaffold',
      );

      final textOnSurface = contrastRatio(AppColors.ink, theme.colorScheme.surface);
      expect(
        textOnSurface,
        greaterThanOrEqualTo(4.5),
        reason: 'El texto principal sobre tarjetas blancas debe cumplir WCAG AA. Ratio real: $textOnSurface',
      );

      final whiteOnPrimary = contrastRatio(Colors.white, theme.colorScheme.primary);
      expect(
        whiteOnPrimary,
        greaterThanOrEqualTo(4.5),
        reason: 'El texto blanco sobre botones primarios debe cumplir WCAG AA. Ratio real: $whiteOnPrimary',
      );
    });

    test('Radios geométricos son estrictos y consistentes (8 px)', () {
      expect(AppTheme.borderRadiusValue, equals(8.0));

      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape?.borderRadius, equals(BorderRadius.circular(8.0)));

      final inputBorder = theme.inputDecorationTheme.border as OutlineInputBorder?;
      expect(inputBorder?.borderRadius, equals(BorderRadius.circular(8.0)));
    });

    test('Escala tipográfica en TextTheme tiene como máximo 5 tamaños estructurados', () {
      final tt = theme.textTheme;
      expect(tt.headlineMedium?.fontSize, equals(20));
      expect(tt.titleLarge?.fontSize, equals(16));
      expect(tt.titleMedium?.fontSize, equals(14));
      expect(tt.bodyMedium?.fontSize, equals(13));
      expect(tt.bodySmall?.fontSize, equals(11.5));
    });
  });
}
